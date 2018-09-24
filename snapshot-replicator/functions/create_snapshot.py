import boto3  
import botocore  
import datetime  
import re
import os
import datetime

#SOURCE_REGION = os.environ['SOURCE_REGION']
SOURCE_REGION = "eu-west-1"  
iam = boto3.client('iam')  
instances = ["frisket-production-api-rds01"]
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