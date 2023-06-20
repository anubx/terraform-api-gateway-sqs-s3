import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    sqs_msg = json.loads(event['Records'][0]['body'])
    print("SQS Message : ", sqs_msg)
    bucket_name = os.environ['s3_bucket']
    current_datetime = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    str_current_datetime = str(current_datetime)
    s3_filename = "message_"+str_current_datetime+".json"

    try:
        s3Client = boto3.client("s3", region_name= os.environ['region'])
        response = s3Client.put_object(Bucket= bucket_name, Key= s3_filename, Body= json.dumps(sqs_msg))
        print("S3 upload success!")
        return {
            "status" : 200,
            "body" : "S3 upload success"
        }
    except Exception as e:
        print("Client connection to S3 failed because ", e)
        return{
            "status" : 500,
            "body" : "S3 upload failed"
        }