import boto3  
import datetime  
import os

TARGET_REGION = os.environ['TARGET_REGION']
DURATION= os.environ['RETENTION']
iam = boto3.client('iam')  
instances = os.environ['DB_INSTANCES']

print('Loading function')

def lambda_handler(event, context):
    target = boto3.client('rds', region_name=TARGET_REGION)
    for instance in instances.split(','):
        for snapshot in target.describe_db_snapshots(DBInstanceIdentifier=instance, MaxRecords=50)['DBSnapshots']:
            create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
            if create_ts < datetime.datetime.now() - datetime.timedelta(days=int(DURATION)):
                print "Deleting snapshot id:", snapshot['DBSnapshotIdentifier']
                target.delete_db_snapshot(
                    DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier']
                )
