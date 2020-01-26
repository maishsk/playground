import boto3 

def lambda_handler(event, context):
    
    # Get list of Regions
    ec2_client = boto3.client('ec2')
    regions = [region['RegionName']
                for region in ec2_client.describe_regions()['Regions']
              ]
    print('Event: ', event)
    print('Context: ', context)
    
    # Iterate over each region
    for region in regions:
        ec2 = boto3.resource('ec2', region_name=region)
        
        print("Region:", region)
        
        # Get only running instances with Tags
        instances = ec2.instances.filter(
            Filters=[
                {
                'Name': 'instance-state-name',
                'Values': ['running']
                },
                {
                'Name': 'tag:AutoOff',
                'Values': ['True']
                }
            ]
        )
        
        # Stop instances
        for instance in instances:
            instance.stop()
            print('Stopped instance: ', instance.id)

