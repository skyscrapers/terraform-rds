import boto3
import botocore
import re
import os
import json

source_region = os.environ['SOURCE_REGION']
target_region = os.environ['TARGET_REGION']
kms_key_id = os.environ['KMS_KEY_ID'] 
instances = os.environ['DB_INSTANCES']  

print('Loading function')

def lambda_handler(event, context): 
    message = event['Records'][0]['Sns']['Message']
    if "Manual snapshot created" in message:
        source = boto3.client('rds', region_name=source_region)
        source_snap = json.loads(message)['Source ID']
        snapshot_details = source.describe_db_snapshots(DBSnapshotIdentifier=source_snap)['DBSnapshots'][0]
        if snapshot_details['DBInstanceIdentifier'] in instances.split(','):
            source_snap_arn = snapshot_details['DBSnapshotArn']
            target_snap_id = (re.sub('rds:', '', source_snap))
            target = boto3.client('rds', region_name=target_region)
            print(('Will Copy %s to %s' % (source_snap_arn, target_snap_id)))
            try:
                response = target.copy_db_snapshot(
                SourceDBSnapshotIdentifier=source_snap_arn,
                TargetDBSnapshotIdentifier=target_snap_id,
                SourceRegion=source_region,
                KmsKeyId=kms_key_id,
                CopyTags = True)
                print(response)
            except botocore.exceptions.ClientError as e:
                raise Exception("Could not issue copy command: %s" % e)
                
