import boto3  
import botocore
import datetime 
import os


source_region = os.environ['SOURCE_REGION']
instances = os.environ['DB_INSTANCES']
print('Loading function')

def lambda_handler(event, context):  
    source = boto3.client('rds', region_name=source_region)

    for instance in instances.split(','):
        now = datetime.datetime.now()
        db_snapshot_name = now.strftime('%Y-%m-%d-%H-%M')
        try:
            response = create_snapshot = source.create_db_snapshot(DBSnapshotIdentifier='snapshot'+db_snapshot_name,DBInstanceIdentifier=instance)
        except botocore.exceptions.ClientError as e:
            raise Exception("Could not issue create command: %s" % e)

