import boto3
import datetime
import os
import botocore

# target_region = os.environ['TARGET_REGION']
instances = os.environ['RDS_INSTANCE_IDS']
retention_period = os.environ['RETENTION_PERIOD']
setup_name = os.environ['SETUP_NAME']


def match_tags(snapshot):
    """Checks if the snapshot was created by the current setup"""

    for tags in snapshot.TagList:
        if tags['Key'] == 'created_by' and tags['Value'] == setup_name:
            return True
    return False


def process_snapshot(rds, snapshot):
    """Processes a single snapshot to determine if it needs to be deleted"""

    create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
    if create_ts < datetime.datetime.now() - datetime.timedelta(days=int(retention_period)) and match_tags(snapshot):
        print(("Deleting snapshot id:", snapshot['DBSnapshotIdentifier']))
        try:
            rds.delete_db_snapshot(
                DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'])
        except botocore.exceptions.ClientError as e:
            raise Exception("Could not issue delete command: %s" % e)


def process_snapshots(rds):
    """Processes the snapshots of the configured RDS instances"""

    for instance in instances.split(','):
        paginator = rds.get_paginator('describe_db_snapshots')
        page_iterator = paginator.paginate(
            DBInstanceIdentifier=instance, SnapshotType='manual')

        for page in page_iterator:
            for snapshot in page['DBSnapshots']:
                process_snapshot(rds, snapshot)


def lambda_handler(event, context):
    """Lambda entry point"""

    print('Lambda function start: going to clean up snapshots older than ' +
          retention_period + ' days for the RDS instances ' + instances)

    rds = boto3.client('rds')

    # Cleanup snapshots from the source account
    process_snapshots(rds)

    # Cleanup snapshots from the target account
    # TODO deleteSnapshots(region=target_region)
