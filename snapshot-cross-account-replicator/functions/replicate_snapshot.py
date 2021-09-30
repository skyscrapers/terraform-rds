import boto3
import botocore
import os

target_account_id = os.environ['TARGET_ACCOUNT_ID']
target_account_iam_role_arn = os.environ['TARGET_ACCOUNT_IAM_ROLE']
target_region = os.environ['TARGET_REGION']
target_account_kms_key_arn = os.environ['TARGET_ACCOUNT_KMS_KEY_ARN']
instances = os.environ['RDS_INSTANCE_IDS']
setup_name = os.environ['SETUP_NAME']
replication_type = os.environ['TYPE']
source_region = os.environ['SOURCE_REGION']


def share_snapshot(rds, snapshot):
    """Enables the sharing of a snapshot to the target replication AWS account"""

    try:
        rds.modify_db_snapshot_attribute(
            DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'],
            AttributeName='restore',
            ValuesToAdd=[target_account_id]
        )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not share snapshot with target account: %s" % e)


def get_target_account_rds_client():
    """Assumes an IAM role in the target account"""

    sts_client = boto3.client('sts')

    try:
        assumed_role_object = sts_client.assume_role(
            RoleArn=target_account_iam_role_arn,
            RoleSessionName="RDSSnapshotReplicator"
        )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not assume role in target account: %s" % e)

    credentials = assumed_role_object['Credentials']

    return boto3.client(
        'rds',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
        region_name=target_region
    )


def replicate_snapshot(snapshot, rds):
    """Triggers a local copy of a snapshot using the provided RDS client"""

    try:
        rds.copy_db_snapshot(
            SourceDBSnapshotIdentifier=snapshot['DBSnapshotArn'],
            TargetDBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'],
            KmsKeyId=target_account_kms_key_arn,
            SourceRegion=source_region,
            Tags=[
                {
                    'Key': 'created_by',
                    'Value': setup_name
                }
            ]
        )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not issue copy command: %s" % e)


def match_tags(snapshot):
    """Checks if the snapshot was created by the current setup"""

    for tags in snapshot['TagList']:
        if tags['Key'] == 'created_by' and tags['Value'] == setup_name:
            return True
    return False


def lambda_handler(event, context):
    """Lambda entry point"""

    rds = boto3.client('rds', region_name=source_region)
    snapshot_id = event['detail']['SourceIdentifier']
    snapshot = rds.describe_db_snapshots(
        DBSnapshotIdentifier=snapshot_id)['DBSnapshots'][0]
    if snapshot['DBInstanceIdentifier'] in instances.split(',') and match_tags(snapshot) and snapshot['Status'] == 'available':
        if replication_type == 'cross-region':
            print('Replicating snapshot ' +
                  snapshot['DBSnapshotIdentifier'] + ' to region ' + target_region)
            target_region_rds = boto3.client('rds', region_name=target_region)
            replicate_snapshot(snapshot, target_region_rds)
        elif replication_type == 'cross-account':
            print('Replicating snapshot ' +
                  snapshot['DBSnapshotIdentifier'] + ' to AWS account ' + target_account_id)
            share_snapshot(rds, snapshot)
            target_account_rds = get_target_account_rds_client()
            replicate_snapshot(snapshot, target_account_rds)
