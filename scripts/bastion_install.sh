#!/bin/bash
# Create a new folder for the log files
mkdir /var/log/bastion

# Allow ec2-user only to access this folder and its content
chown ec2-centos:centos /var/log/bastion
chmod -R 770 /var/log/bastion
setfacl -Rdm other:0 /var/log/bastion

# Make OpenSSH execute a custom script on logins
echo -e "\nForceCommand /usr/bin/bastion/shell" >> /etc/ssh/sshd_config

# Block some SSH features that bastion host users could use to circumvent
# the solution
awk '!/AllowTcpForwarding/' /etc/ssh/sshd_config > temp && mv temp /etc/ssh/sshd_config
awk '!/X11Forwarding/' /etc/ssh/sshd_config > temp && mv temp /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config

mkdir /usr/bin/bastion

cat > /usr/bin/bastion/shell << 'EOF'

# Check that the SSH client did not supply a command
if [[ -z $SSH_ORIGINAL_COMMAND ]]; then

  # The format of log files is /var/log/bastion/YYYY-MM-DD_HH-MM-SS_user
  LOG_FILE="`date --date="today" "+%Y-%m-%d_%H-%M-%S"`_`whoami`"
  LOG_DIR="/var/log/bastion/"

  # Print a welcome message
  echo ""
  echo "NOTE: This SSH session will be recorded"
  echo "AUDIT KEY: $LOG_FILE"
  echo ""

  # I suffix the log file name with a random string. I explain why
  # later on.
  SUFFIX=`mktemp -u _XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

  # Wrap an interactive shell into "script" to record the SSH session
  script -qf --timing=$LOG_DIR$LOG_FILE$SUFFIX.time $LOG_DIR$LOG_FILE$SUFFIX.data --command=/bin/bash

else

  # The "script" program could be circumvented with some commands
  # (e.g. bash, nc). Therefore, I intentionally prevent users
  # from supplying commands.

  echo "This bastion supports interactive sessions only. Do not supply a command"
  exit 1

fi

EOF

# Make the custom script executable
chmod a+x /usr/bin/bastion/shell

# Bastion host users could overwrite and tamper with an existing log file
# using "script" if they knew the exact file name. I take several measures
# to obfuscate the file name:
# 1. Add a random suffix to the log file name.
# 2. Prevent bastion host users from listing the folder containing log
# files.
# This is done by changing the group owner of "script" and setting GID.
chown root:centos /usr/bin/script
chmod g+s /usr/bin/script

# 3. Prevent bastion host users from viewing processes owned by other
# users, because the log file name is one of the "script"
# execution parameters.
mount -o remount,rw,hidepid=2 /proc
awk '!/proc/' /etc/fstab > temp && mv temp /etc/fstab
echo "proc /proc proc defaults,hidepid=2 0 0" >> /etc/fstab

# Restart the SSH service to apply /etc/ssh/sshd_config modifications.
service sshd restart
The preceding commands make OpenSSH execute a custom script on login, which records SSH sessions into log files stored in the folder,/var/log/bastion. For durable storage, the log files are copied at a regular interval to an Amazon S3 bucket, using theaws s3 cp command, which follows.

cat > /usr/bin/bastion/sync_s3 << 'EOF'
# Copy log files to S3 with server-side encryption enabled.
# Then, if successful, delete log files that are older than a day.
LOG_DIR="/var/log/bastion/"
aws s3 cp $LOG_DIR s3://bucket-name/logs/ --sse --region region --recursive && find $LOG_DIR* -mtime +1 -exec rm {} \;

EOF

chmod 700 /usr/bin/bastion/sync_s3
At this point, OpenSSH is configured to record SSH sessions and the log files are copied to Amazon S3. In order to determine the origin of any action performed on the Linux instances using SSH, bastion host users are provided with personal user accounts on the bastion host and they use their personal SSH key pair to log in. Each user account receives the minimum required privileges so that bastion host users are unable to disable or tamper with the solution.

To ease the management of user accounts, the SSH public key of each bastion host user is uploaded to an S3 bucket. At a regular interval, the bastion host retrieves the public keys available in this bucket. For each public key, a user account is created if it does not already exist, and the SSH public key is copied to the bastion host to allow the user to log in with this key pair. For example, if the bastion host finds a file, john.pub, in the bucket, which is John’s SSH public key, it creates a user account, john, and the public key is copied to /home/john/.ssh/authorized_keys. If an SSH public key were to be removed from the S3 bucket, the bastion host would delete the related user account. Personal user account creations and deletions are logged in /var/log/bastion/users_changelog.txt.

The following commands create a shell script for managing personal user accounts and scheduling a cron job to run the shell script every 5 minutes.

# Bastion host users should log in to the bastion host with
# their personal SSH key pair. The public keys are stored on
# S3 with the following naming convention: "username.pub". This
# script retrieves the public keys, creates or deletes local user
# accounts as needed, and copies the public key to
# /home/username/.ssh/authorized_keys

cat > /usr/bin/bastion/sync_users << 'EOF'

# The file will log user changes
LOG_FILE="/var/log/bastion/users_changelog.txt"

# The function returns the user name from the public key file name.
# Example: public-keys/sshuser.pub => sshuser
get_user_name () {
  echo "$1" | sed -e 's/.*\///g' | sed -e 's/\.pub//g'
}

# For each public key available in the S3 bucket
aws s3api list-objects --bucket bucket-name --prefix public-keys/ --region region --output text --query 'Contents[?Size>`0`].Key' | sed -e 'y/\t/\n/' > ~/keys_retrieved_from_s3
while read line; do
  USER_NAME="`get_user_name "$line"`"

  # Make sure the user name is alphanumeric
  if [[ "$USER_NAME" =~ ^[a-z][-a-z0-9]*$ ]]; then

    # Create a user account if it does not already exist
    cut -d: -f1 /etc/passwd | grep -qx $USER_NAME
    if [ $? -eq 1 ]; then
      /usr/sbin/adduser $USER_NAME && \
      mkdir -m 700 /home/$USER_NAME/.ssh && \
      chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh && \
      echo "$line" >> ~/keys_installed && \
      echo "`date --date="today" "+%Y-%m-%d %H-%M-%S"`: Creating user account for $USER_NAME ($line)" >> $LOG_FILE
    fi

    # Copy the public key from S3, if a user account was created
    # from this key
    if [ -f ~/keys_installed ]; then
      grep -qx "$line" ~/keys_installed
      if [ $? -eq 0 ]; then
        aws s3 cp s3://bucket-name/$line /home/$USER_NAME/.ssh/authorized_keys --region region
        chmod 600 /home/$USER_NAME/.ssh/authorized_keys
        chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
      fi
    fi

  fi
done < ~/keys_retrieved_from_s3

# Remove user accounts whose public key was deleted from S3
if [ -f ~/keys_installed ]; then
  sort -uo ~/keys_installed ~/keys_installed
  sort -uo ~/keys_retrieved_from_s3 ~/keys_retrieved_from_s3
  comm -13 ~/keys_retrieved_from_s3 ~/keys_installed | sed "s/\t//g" > ~/keys_to_remove
  while read line; do
    USER_NAME="`get_user_name "$line"`"
    echo "`date --date="today" "+%Y-%m-%d %H-%M-%S"`: Removing user account for $USER_NAME ($line)" >> $LOG_FILE
    /usr/sbin/userdel -r -f $USER_NAME
  done < ~/keys_to_remove
  comm -3 ~/keys_installed ~/keys_to_remove | sed "s/\t//g" > ~/tmp && mv ~/tmp ~/keys_installed
fi

EOF

chmod 700 /usr/bin/bastion/sync_users

cat > ~/mycron << EOF
*/5 * * * * /usr/bin/bastion/sync_s3
*/5 * * * * /usr/bin/bastion/sync_users
0 0 * * * yum -y update --security
EOF
crontab ~/mycron
rm ~/mycron
