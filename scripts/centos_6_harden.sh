#!/bin/bash
# Base packages
# yum install -y http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# yum install -y cloud-init cloud-utils cloud-utils-growpart dos2unix vim iotop wget python-jinja2 python-deltarpm python-futures python-zmq python-psutil python-rsa python-tornado libselinux-ruby tcp_wrappers parted ntp ntpdate heat-cfntools glibc.i686 glibc.x86_64 yum-plugin-priorities acpid nc pystache yum-utils unzip python-msgpack

# remove CTRL-ALT-DEL action
rm -f  /etc/init/control-alt-delete.conf

# set sysconfig
echo "umask 022" >> /etc/sysconfig/init
sed -i "/^SINGLE/s/=.*/=\/sbin\/sulogin/1" /etc/sysconfig/init
sed -i "/^PROMPT/s/=.*/=no/1" /etc/sysconfig/init
sed -i "/^SYNC_HWCLOCK/s/SYNC_HWCLOCK.*/SYNC_HWCLOCK\=yes/1" /etc/sysconfig/ntpdate

# delete cron & at deny definition
rm -f /etc/cron.deny

for i in /usr/etc /usr/local/etc /var/log /sbin /usr/sbin /usr/local/bin
do
chmod 711 $i
chown root:root $i
done
chmod 700 /root/

for i in shutdown halt games gopher ftp
do userdel $i
done
for i in postfix cgconfig cgred netconsole rdisc restorecond saslauthd iptables ip6tables
do chkconfig $i off
done


for i in vm.swappiness net.ipv4.conf.eth0.arp_notify kernel.exec-shield kernel.randomize_va_space sunrpc.tcp_slot_table_entries net.ipv4.ip_local_port_range net.ipv4.tcp_max_syn_backlog net.ipv4.tcp_sack net.ipv4.tcp_window_scaling net.core.somaxconn net.core.rmem_max net.core.wmem_max net.ipv4.tcp_rmem net.ipv4.tcp_wmem net.ipv4.tcp_tw_reuse net.ipv4.tcp_timestamps fs.file-max net.ipv4.conf.all.accept_source_route net.ipv4.conf.default.accept_source_route net.ipv4.conf.all.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.conf.all.secure_redirects net.ipv4.conf.default.secure_redirects net.ipv4.conf.all.log_martians net.ipv4.conf.default.log_martians net.ipv4.icmp_echo_ignore_broadcasts net.ipv4.icmp_ignore_bogus_error_responses  net.ipv4.conf.all.rp_filter net.ipv4.conf.default.rp_filter net.ipv4.tcp_syncookies
do sed -i "/^${i}/d" /etc/sysctl.conf
done

echo "vm.swappiness = 0
kernel.exec-shield = 1
kernel.randomize_va_space = 2

sunrpc.tcp_slot_table_entries = 16

net.core.somaxconn = 4096
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432

fs.file-max = 300000
fs.suid_dumpable = 0

net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.send_redirects = 0

net.ipv4.conf.eth0.arp_notify = 1

net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

net.ipv4.ip_local_port_range = 16384 61000

net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_challenge_ack_limit = 999999999

net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf

for i in /etc/passwd /etc/group /etc/csh.login /etc/environment;do chmod 444 $i; chown root:root $i;done

sed -i "/^decode/s/decode/\#decode/1" /etc/aliases

# tmp FS with nodev,nosuid,noexec
sed -i "/tmpfs/s/defaults.*/defaults,nodev,nosuid,noexec        0 0/1" /etc/fstab

chmod 600 /etc/ssh/sshd_config
sed -i "/^X11Forwarding/s/.*X11Forwarding.*/X11Forwarding\ no/1" /etc/ssh/sshd_config
sed -i "/MaxAuthTries/s/.*MaxAuthTries.*/MaxAuthTries\ 4/1" /etc/ssh/sshd_config
sed -i "/^IgnoreRhosts/s/.*IgnoreRhosts.*/IgnoreRhosts\ yes/1" /etc/ssh/sshd_config
sed -i "/LogLevel/s/.*LogLevel.*/LogLevel\ INFO/1" /etc/ssh/sshd_config
sed -i "/^HostbasedAuthentication/s/.*HostbasedAuthentication.*/HostbasedAuthentication\ no/1" /etc/ssh/sshd_config
sed -i "/^PermitRootLogin/s/.*PermitRootLogin.*/PermitRootLogin\ no/1" /etc/ssh/sshd_config
sed -i "/^PermitEmptyPasswords/s/.*PermitEmptyPasswords.*/PermitEmptyPasswords\ no/1" /etc/ssh/sshd_config
sed -i "/PermitUserEnvironment/s/.*PermitUserEnvironment.*/PermitUserEnvironment\ no/1" /etc/ssh/sshd_config
sed -i "/Ciphers/s/.*Ciphers.*/Ciphers\ aes128-ctr,aes192-ctr,aes256-ctr/1" /etc/ssh/sshd_config
sed -i "/ClientAliveInterval/s/.*ClientAliveInterval.*/ClientAliveInterval\ 300/1" /etc/ssh/sshd_config
sed -i "/ClientAliveCountMax/s/.*ClientAliveCountMax.*/ClientAliveCountMax\ 0/1" /etc/ssh/sshd_config
sed -i "/LoginGraceTime/s/.*LoginGraceTime.*/LoginGraceTime\ 1m/1" /etc/ssh/sshd_config
sed -i "/UseDNS/s/.*UseDNS.*/UseDNS\ no/1" /etc/ssh/sshd_config
sed -i "/Banner/s/.*Banner.*/Banner\ \/etc\/issue\.net/1" /etc/ssh/sshd_config
## This line causes problems
sed -i "/PasswordAuthentication/s/.*PasswordAuthentication.*/PasswordAuthentication no/1" /etc/ssh/sshd_config
##
echo -e "\nCiphers aes128-ctr,aes192-ctr,aes256-ctr\nMACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config

# Disable IPTABLES  & SELINUX
iptables -F
service iptables save
service iptables stop

sed -i "/^SELINUX/s/SELINUX=.*/SELINUX=disabled/1" /etc/selinux/config

# modprobe definition
FILES="/etc/modprobe.d/blacklist.conf /etc/modprobe.d/ccatg-media.conf /etc/modprobe.d/ccatg-wireless.conf"

cat > /etc/modprobe.d/blacklist.conf << EOFBLACK
#
# Listing a module here prevents the hotplug scripts from loading it.
# Usually that'd be so that some other driver will bind it instead,
# no matter which driver happens to get probed first.  Sometimes user
# mode tools can also control driver binding.
#
# Syntax: see modprobe.conf(5).
#

# watchdog drivers
blacklist i8xx_tco

# framebuffer drivers
blacklist aty128fb
blacklist atyfb
blacklist radeonfb
blacklist i810fb
blacklist cirrusfb
blacklist intelfb
blacklist kyrofb
blacklist i2c-matroxfb
blacklist hgafb
blacklist nvidiafb
blacklist rivafb
blacklist savagefb
blacklist sstfb
blacklist neofb
blacklist tridentfb
blacklist tdfxfb
blacklist virgefb
blacklist vga16fb
blacklist viafb

# ISDN - see bugs 154799, 159068
blacklist hisax
blacklist hisax_fcpcipnp

# sound drivers
blacklist snd-pcsp

# I/O dynamic configuration support for s390x (bz #563228)
blacklist chsc_sch
EOFBLACK

# postfix fix
sed -i "/^inet_interfaces/s/=.*/=\ localhost/1" /etc/postfix/main.cf

dd="/bin/dmesg /bin/mount /bin/rpm /usr/bin/write /usr/bin/ipcrm /usr/bin/ipcs /sbin/arp /sbin/ifconfig /bin/tracepath /bin/tracepath6 /usr/bin/wget /usr/bin/who /usr/bin/w /usr/bin/nc /usr/bin/wall"
for i in $dd;do chmod 0550 $i;done
for i in /etc/bashrc /etc/csh.cshrc /etc/csh.login;do chown root:root $i ; chmod 0444 $i;done
for i in /etc/profile /etc/environment;do chown root:root $i ; chmod 0444 $i;done
sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers

find /var/log -type f -exec chmod g-wx,o-rwx {} +
chkconfig crond on
chown root:root /etc/crontab ; chmod og-rwx /etc/crontab

sed -i "/ttyS0/d" /etc/securetty
sed -i "/tty0/d" /etc/securetty

for i in cron.d cron.daily cron.hourly cron.monthly crontab cron.weekly;do chmod og-rwx /etc/$i;done

sed -i "/^PASS_MAX_DAYS/s/PASS_MAX_DAYS.*/PASS_MAX_DAYS\t90/1"   /etc/login.defs
sed -i "/^PASS_MIN_DAYS/s/PASS_MIN_DAYS.*/PASS_MIN_DAYS\t7/1"   /etc/login.defs
sed -i "/^PASS_MIN_LEN/s/PASS_MIN_LEN.*/PASS_MIN_LEN\t8/1"   /etc/login.defs

echo "RES_OPTIONS='rotate timeout:1 attempts:1'" >> /etc/sysconfig/network

# CHANGE PROMPT
rm -f /etc/issue*
echo "------------------------------
    CentOS Version 6
    NOTICE TO USERS
------------------------------
It is for authorized users only. Users (authorized & unauthorized) have no explicit/implicit expectation of privacy. Any or all uses of this system and all files on this system may be intercepted, monitored, recorded, copied, audited, inspected, and disclosed to your employer, to authorized site, government, and/or law enforcement personnel, as well as authorized officials of government agencies, both domestic and foreign.

By using this system, the user expressly consents to such interception, monitoring, recording, copying, auditing, inspection, and disclosure at the discretion of such officials. Unauthorized or improper use of this system may result in civil and criminal penalties and administrative or disciplinary action, as appropriate. By continuing to use this system you indicate your awareness of and consent to these terms and conditions of use. LOG OFF IMMEDIATELY if you do not agree to the conditions stated in this warning.
"  > /etc/issue
cp -f /etc/issue /etc/issue.net
chmod 644 /etc/issue*
yum update -y

##Finalize
service rsyslog stop
service auditd stop

rm -f /etc/ssh/*key*
package-cleanup --oldkernels --count=1
yum clean all

logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
rm -rf /var/log/anaconda

cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
cat /dev/null > /var/log/grubby

rm -f /etc/udev/rules.d/70*
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f ~root/.bash_history
unset HISTFILE
rm -rf ~root/.ssh/
rm -f ~root/anaconda-ks.cfg
