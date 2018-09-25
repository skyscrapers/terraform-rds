import boto3
import botocore
import datetime
import re
import os

source_region = os.environ['SOURCE_REGION']
target_region = os.environ['TARGET_REGION']
kms_key_id = os.environ['KMS_KEY_ID'] 
iam = boto3.client('iam')  
instances = os.environ['DB_INSTANCES']  

print('Loading function')

def byTimestamp(snap):  
    if 'SnapshotCreateTime' in snap:
        return datetime.datetime.isoformat(snap['SnapshotCreateTime'])
    else:
        return datetime.datetime.isoformat(datetime.datetime.now())

def lambda_handler(event, context): 
    if("Finished" in event['Records'][0]['Sns']['Message']):
        account_ids = []
        try:
            iam.get_user()
        except Exception as e:
            account_ids.append(re.search(r'(arn:aws:sts::)([0-9]+)', str(e)).groups()[1])
            account = account_ids[0]

        source = boto3.client('rds', region_name=source_region)

        for instance in instances.split(','):
            source_instances = source.describe_db_instances(DBInstanceIdentifier=instance)
            source_snaps = source.describe_db_snapshots(DBInstanceIdentifier=instance)['DBSnapshots']
            source_snap = sorted(source_snaps, key=byTimestamp, reverse=True)[0]['DBSnapshotIdentifier']
            source_snap_arn = 'arn:aws:rds:%s:%s:snapshot:%s' % (source_region, account, source_snap)
            target_snap_id = (re.sub('rds:', '', source_snap))
            print('Will Copy %s to %s' % (source_snap_arn, target_snap_id))
            target = boto3.client('rds', region_name=target_region)

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
            copied_snaps = target.describe_db_snapshots(SnapshotType='manual', DBInstanceIdentifier=instance)['DBSnapshots']

