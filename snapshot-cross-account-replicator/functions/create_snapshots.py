import boto3
import botocore
import datetime
import os

instances = os.environ['RDS_INSTANCE_IDS']
setup_name = os.environ['SETUP_NAME']


def lambda_handler(event, context):
    print('Lambda function start: going to create snapshots for the RDS instances ' + instances)

    source = boto3.client('rds')

    for instance in instances.split(','):
        now = datetime.datetime.now()
        db_snapshot_name = instance + '_' + now.strftime('%Y-%m-%d-%H-%M')
        try:
            source.create_db_snapshot(
                DBSnapshotIdentifier=db_snapshot_name,
                DBInstanceIdentifier=instance,
                Tags=[
                    {
                        'Key': 'created_by',
                        'Value': setup_name
                    }
                ])
        except botocore.exceptions.ClientError as e:
            raise Exception("Could not issue create command: %s" % e)
