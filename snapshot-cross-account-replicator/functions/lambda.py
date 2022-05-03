import boto3
import botocore
import datetime
import os

target_account_id = os.environ['TARGET_ACCOUNT_ID']
target_account_iam_role_arn = os.environ['TARGET_ACCOUNT_IAM_ROLE']
source_account_iam_role_arn = os.environ['SOURCE_ACCOUNT_IAM_ROLE']
target_region = os.environ['TARGET_REGION']
target_account_kms_key_arn = os.environ['TARGET_ACCOUNT_KMS_KEY_ARN']
instances = os.environ['RDS_INSTANCE_IDS']
setup_name = os.environ['SETUP_NAME']
replication_type = os.environ['TYPE']
source_region = os.environ['SOURCE_REGION']
retention_period = os.environ['RETENTION_PERIOD']
is_cluster = os.environ['IS_CLUSTER'] == 'true'


def share_snapshot(rds, snapshot):
    """Enables the sharing of a snapshot to the target replication AWS account"""

    try:
        if is_cluster:
            rds.modify_db_cluster_snapshot_attribute(
                DBClusterSnapshotIdentifier=snapshot['DBClusterSnapshotIdentifier'],
                AttributeName='restore',
                ValuesToAdd=[target_account_id]
            )
        else:
            rds.modify_db_snapshot_attribute(
                DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'],
                AttributeName='restore',
                ValuesToAdd=[target_account_id]
            )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not share snapshot with target account: %s" % e)


def get_assumed_role_rds_client(iam_role_arn, region):
    """Assumes an IAM role in the target account and returns an RDS client for it"""

    sts_client = boto3.client('sts')

    try:
        assumed_role_object = sts_client.assume_role(
            RoleArn=iam_role_arn,
            RoleSessionName="RDSSnapshotReplicator"
        )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not assume role: %s" % e)

    credentials = assumed_role_object['Credentials']

    return boto3.client(
        'rds',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
        region_name=region
    )


def copy_snapshot(snapshot, rds, source_region):
    """Triggers a local copy of a snapshot using the provided RDS client"""

    tags = [
        {
            'Key': 'created_by',
            'Value': setup_name
        },
        {
            'Key': 'replicating',
            'Value': 'false'
        }
    ]

    try:
        if is_cluster:
            rds.copy_db_cluster_snapshot(
                SourceDBClusterSnapshotIdentifier=snapshot['DBClusterSnapshotArn'],
                TargetDBClusterSnapshotIdentifier=snapshot['DBClusterSnapshotIdentifier'],
                KmsKeyId=target_account_kms_key_arn,
                SourceRegion=source_region,
                Tags=tags
            )
        else:
            rds.copy_db_snapshot(
                SourceDBSnapshotIdentifier=snapshot['DBSnapshotArn'],
                TargetDBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'],
                KmsKeyId=target_account_kms_key_arn,
                SourceRegion=source_region,
                Tags=tags
            )
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not issue copy command: %s" % e)


def match_tags(snapshot, replication_status='false'):
    """Checks if the snapshot is meant for this lambda"""

    tags = snapshot['TagList']

    try:
        for tag1 in tags:
            if tag1['Key'] == 'created_by' and tag1['Value'] == setup_name:
                for tag2 in tags:
                    if tag2['Key'].lower() == 'replicating' and tag2['Value'].lower() == replication_status:
                        return True
    except Exception:
        return False

    return False


def snapshot_set_replicating_tag(rds, snapshot_arn, value):
    """Sets replicating=true Tag on snapshot"""

    rds.add_tags_to_resource(
        ResourceName=snapshot_arn,
        Tags=[
            {
                'Key': 'replicating',
                'Value': value
            }
        ]
    )


def delete_old_snapshot(rds, snapshot):
    """Removes snapshots alder than retention_period"""

    create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
    if create_ts < (datetime.datetime.now() - datetime.timedelta(days=int(retention_period))) and match_tags(snapshot, 'finished'):
        if is_cluster:
            delete_snapshot(rds, snapshot['DBClusterSnapshotIdentifier'])
        else:
            delete_snapshot(rds, snapshot['DBSnapshotIdentifier'])


def delete_snapshot(rds, snapshot_id):
    """Deletes a snapshot"""

    print(("Deleting snapshot id:", snapshot_id))
    try:
        if is_cluster:
            rds.delete_db_cluster_snapshot(
                DBClusterSnapshotIdentifier=snapshot_id)
        else:
            rds.delete_db_snapshot(
                DBSnapshotIdentifier=snapshot_id)
    except botocore.exceptions.ClientError as e:
        raise Exception("Could not issue delete command: %s" % e)


def match_snapshot_event(rds, event):
    """Checks if the provided event is meant for this lambda"""

    snapshot_id = event['detail']['SourceIdentifier']
    if is_cluster:
        snapshot = rds.describe_db_cluster_snapshots(
            DBClusterSnapshotIdentifier=snapshot_id)['DBClusterSnapshots'][0]
        if snapshot['DBClusterIdentifier'] in instances.split(',') and match_tags(snapshot) and snapshot['Status'].lower() == 'available':
            return snapshot
        else:
            return False
    else:
        snapshot = rds.describe_db_snapshots(
            DBSnapshotIdentifier=snapshot_id)['DBSnapshots'][0]
        if snapshot['DBInstanceIdentifier'] in instances.split(',') and match_tags(snapshot) and snapshot['Status'].lower() == 'available':
            return snapshot
        else:
            return False


def match_cluster_snapshots(rds):
    """Returns all matching cluster snapshots to replicate or delete"""

    snapshots = []

    paginator = rds.get_paginator('describe_db_cluster_snapshots')
    page_iterator = paginator.paginate(
        SnapshotType='manual',
        IncludeShared=False,
        IncludePublic=False
    )

    for page in page_iterator:
        for snapshot in page['DBClusterSnapshots']:
            snapshot_taglist = rds.list_tags_for_resource(
                ResourceName=snapshot['DBClusterSnapshotArn'])

            if snapshot['Status'].lower() == 'available' and match_tags(snapshot_taglist):
                snapshots.append(snapshot)

    return snapshots


def cleanup_snapshots(event, context):
    """Lambda entry point for the cleanup snapshots"""

    print('Lambda function start: going to clean up snapshots older than ' +
          retention_period + ' days for the RDS instances ' + instances)

    rds = boto3.client('rds')

    for instance in instances.split(','):
        if is_cluster:
            paginator = rds.get_paginator('describe_db_cluster_snapshots')
            page_iterator = paginator.paginate(
                DBClusterIdentifier=instance, SnapshotType='manual')

            for page in page_iterator:
                for snapshot in page['DBClusterSnapshots']:
                    delete_old_snapshot(rds, snapshot)
        else:
            paginator = rds.get_paginator('describe_db_snapshots')
            page_iterator = paginator.paginate(
                DBInstanceIdentifier=instance, SnapshotType='manual')

            for page in page_iterator:
                for snapshot in page['DBSnapshots']:
                    delete_old_snapshot(rds, snapshot)


def replicate_snapshot_cross_account(rds, snapshot):
    """Replicates (share&copy) a snapshot across accounts"""

    snapshot_arn = snapshot['DBClusterSnapshotArn'] if is_cluster else snapshot['DBSnapshotArn']
    snapshot_id = snapshot['DBClusterSnapshotIdentifier'] if is_cluster else snapshot['DBSnapshotIdentifier']

    # Delete initial snapshot in source account, source region
    source_region_rds = boto3.client('rds', region_name=source_region)
    delete_snapshot(source_region_rds, snapshot_id)

    print('Replicating snapshot ' + snapshot_id +
          ' to AWS account ' + target_account_id)

    snapshot_set_replicating_tag(rds, snapshot_arn, 'true')
    share_snapshot(rds, snapshot)
    target_account_rds = get_assumed_role_rds_client(
        target_account_iam_role_arn, target_region)
    copy_snapshot(snapshot, target_account_rds, target_region)


def replicate_snapshot(event, context):
    """Lambda entry point for the cross-region and cross-account replication (STEP2&3)"""
    # This gets run in step 2 (cross-region) and step 3 (cross-account)

    rds = boto3.client('rds')

    # CRON based, search & replicate all matching snapshots
    # Needed for the cross-account replication in cluster mode (step 3), because AWS
    # doesn't publish a cluster finished snapshot event
    if is_cluster and replication_type == 'cross-account':
        snapshots = match_cluster_snapshots(rds)
        for snapshot in snapshots:
            replicate_snapshot_cross_account(rds, snapshot)
    # EVENT based, used for step 2 (instance and cluster) and step 3 (instance)
    else:
        snapshot = match_snapshot_event(rds, event)
        if snapshot:
            if replication_type == 'cross-region':
                if is_cluster:
                    print('Replicating snapshot ' +
                          snapshot['DBClusterSnapshotIdentifier'] + ' to region ' + target_region)
                else:
                    print('Replicating snapshot ' +
                          snapshot['DBSnapshotIdentifier'] + ' to region ' + target_region)
                target_region_rds = boto3.client(
                    'rds', region_name=target_region)
                copy_snapshot(snapshot, target_region_rds, source_region)
            elif replication_type == 'cross-account':
                replicate_snapshot_cross_account(rds, snapshot)


def create_snapshots(event, context):
    """Lambda entry point for the snapshot creation (STEP1)"""

    print('Lambda function start: going to create snapshots for the RDS instances ' + instances)

    source_rds = boto3.client('rds', region_name=source_region)

    tags = [
        {
            'Key': 'created_by',
            'Value': setup_name
        },
        {
            'Key': 'replicating',
            'Value': 'false'
        }
    ]

    for instance in instances.split(','):
        now = datetime.datetime.now()
        db_snapshot_name = instance + '-' + now.strftime('%Y-%m-%d-%H-%M')
        try:
            if is_cluster:
                source_rds.create_db_cluster_snapshot(
                    DBClusterSnapshotIdentifier=db_snapshot_name,
                    DBClusterIdentifier=instance,
                    Tags=tags
                )
            else:
                source_rds.create_db_snapshot(
                    DBSnapshotIdentifier=db_snapshot_name,
                    DBInstanceIdentifier=instance,
                    Tags=tags
                )
        except botocore.exceptions.ClientError as e:
            raise Exception("Could not issue create command: %s" % e)


def delete_intermediate_snapshot(event, context):
    """Lambda entry point for cleaning up the 2nd intermediate snapshot (STEP4)"""

    rds = boto3.client('rds', region_name=target_region)
    source_rds = get_assumed_role_rds_client(
        source_account_iam_role_arn, target_region)

    # CRON based, used for step 4 (cluster)
    if is_cluster:
        snapshots = match_cluster_snapshots(rds)
        for snapshot in snapshots:
            snapshot_set_replicating_tag(
                rds, snapshot['DBClusterSnapshotArn'], 'finished')
            delete_snapshot(
                source_rds, snapshot['DBClusterSnapshotIdentifier'])
    # EVENT based, used for step 4 (instance)
    else:
        snapshot = match_snapshot_event(rds, event)
        if snapshot:
            snapshot_set_replicating_tag(
                rds, snapshot['DBSnapshotArn'], 'finished')
            delete_snapshot(source_rds, snapshot['DBSnapshotIdentifier'])
