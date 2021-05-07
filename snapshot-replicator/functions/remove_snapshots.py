import boto3  
import datetime  
import os
import botocore


source_region = os.environ['SOURCE_REGION']
target_region = os.environ['TARGET_REGION']
instances = os.environ['DB_INSTANCES']
duration = os.environ['RETENTION']


print('Loading function')

def lambda_handler(event, context):
    def deleteSnapshots(region):
        for instance in instances.split(','):
            rds = boto3.client('rds', region_name=region)
            paginator = rds.get_paginator('describe_db_snapshots')
            page_iterator = paginator.paginate(DBInstanceIdentifier=instance, SnapshotType='manual')
            snapshots = []
            for page in page_iterator:
                 snapshots.extend(page['DBSnapshots'])
            for snapshot in snapshots:
                create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
                if create_ts < datetime.datetime.now() - datetime.timedelta(days=int(duration)):
                    print(("Deleting snapshot id:", snapshot['DBSnapshotIdentifier']))
                    try:
                        response = rds.delete_db_snapshot(DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'])
                        print(response)
                    except botocore.exceptions.ClientError as e:
                        raise Exception("Could not issue delete command: %s" % e)

    deleteSnapshots(region=source_region)
    deleteSnapshots(region=target_region)

