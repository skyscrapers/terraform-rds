import boto3  
import botocore  
import datetime  
import re
import datetime

SOURCE_REGION = os.environ['SOURCE_REGION']  
iam = boto3.client('iam')  
instances = os.environ['DB_INSTANCES']

print('Loading function')

def lambda_handler(event, context):  
    account_ids = []
    try:
        iam.get_user()
    except Exception as e:
        account_ids.append(re.search(r'(arn:aws:sts::)([0-9]+)', str(e)).groups()[1])
        account = account_ids[0]

    source = boto3.client('rds', region_name=SOURCE_REGION)

    for instance in instances:
        now = datetime.datetime.now()
        db_snapshot_name = now.strftime('%Y-%m-%d-%H-%M')
        create_snapshot = source.create_db_snapshot(DBSnapshotIdentifier='snapshot'+db_snapshot_name,DBInstanceIdentifier=instance)