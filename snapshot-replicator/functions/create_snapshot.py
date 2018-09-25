import boto3  
import datetime 
import os

source_region = os.environ['SOURCE_REGION']
instances = os.environ['DB_INSTANCES']
iam = boto3.client('iam')
print('Loading function')

def lambda_handler(event, context):  
    source = boto3.client('rds', region_name=source_region)

    for instance in instances.split(','):
        now = datetime.datetime.now()
        db_snapshot_name = now.strftime('%Y-%m-%d-%H-%M')
        create_snapshot = source.create_db_snapshot(DBSnapshotIdentifier='snapshot'+db_snapshot_name,DBInstanceIdentifier=instance)
