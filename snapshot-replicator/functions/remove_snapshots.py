import boto3  
import datetime  
import argparse

TARGET_REGION = 'eu-central-1'  
DURATION= 30
iam = boto3.client('iam')  
instances = ['frisket-production-api-rds01']

print('Loading function')

def lambda_handler(event, context):
    target = boto3.client('rds', region_name=TARGET_REGION)
    for instance in instances:
        for snapshot in target.describe_db_snapshots(DBInstanceIdentifier=instance, MaxRecords=50)['DBSnapshots']:
            create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
            if create_ts < datetime.datetime.now() - datetime.timedelta(days=DURATION):
                print "Deleting snapshot id:", snapshot['DBSnapshotIdentifier']
                target.delete_db_snapshot(
                    DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier']
                )