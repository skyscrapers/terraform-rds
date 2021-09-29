import boto3
import botocore
import re
import os
import json

target_account_id = os.environ['TARGET_ACCOUNT_ID']
target_account_iam_role_arn = os.environ['TARGET_ACCOUNT_IAM_ROLE']
target_region = os.environ['TARGET_REGION']
target_account_kms_key_id = os.environ['TARGET_ACCOUNT_KMS_KEY_ID']
instances = os.environ['RDS_INSTANCE_IDS']
setup_name = os.environ['SETUP_NAME']


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


def replicate_snapshot(snapshot):
    """Assumes a role in the target AWS account and triggers a local copy of a snapshot"""

    sts_client = boto3.client('sts')

    try:
        assumed_role_object = sts_client.assume_role(
            RoleArn=target_account_iam_role_arn,
            RoleSessionName="RDSSnapshotReplicator"
        )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not assume role in target account: %s" % e)

    credentials = assumed_role_object['Credentials']

    rds = boto3.client(
        'rds',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
        region=target_region
    )

    try:
        rds.copy_db_snapshot(
            SourceDBSnapshotIdentifier=snapshot['DBSnapshotArn'],
            TargetDBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'],
            KmsKeyId=target_account_kms_key_id,
            CopyTags=True)
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not issue copy command: %s" % e)


def match_tags(snapshot):
    """Checks if the snapshot was created by the current setup"""

    for tags in snapshot.TagList:
        if tags['Key'] == 'created_by' and tags['Value'] == setup_name:
            return True
    return False


def lambda_handler(event, context):
    """Lambda entry point"""

    message = event['Records'][0]['Sns']['Message']
    rds = boto3.client('rds')
    snapshot_id = json.loads(message)['Source ID']
    snapshot = rds.describe_db_snapshots(
        DBSnapshotIdentifier=snapshot_id)['DBSnapshots'][0]
    if snapshot['DBInstanceIdentifier'] in instances.split(',') & match_tags(snapshot) & snapshot['Status'] == 'available':
        print('Replicating snapshot ' +
              snapshot['DBSnapshotIdentifier'] + ' to AWS account ' + target_account_id)
        share_snapshot(rds, snapshot)
        replicate_snapshot(snapshot)
