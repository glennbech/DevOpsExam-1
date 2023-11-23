import json
import boto3
import os

s3_client = boto3.client('s3', region_name='eu-west-1')
rekognition_client = boto3.client('rekognition', region_name='eu-west-1')

try:
    BUCKET_NAME = os.environ['BUCKET_NAME']
except KeyError:
    raise ValueError("Provide the environment variable <BUCKET_NAME>.")

def lambda_handler(event, context):

    # List all objects in the S3 bucket
    paginator = s3_client.get_paginator('list_objects_v2')
    rekognition_results = []  # Store the results

    for page in paginator.paginate(Bucket=BUCKET_NAME):
        for obj in page.get('Contents', []):
            # Perform PPE detection using Rekognition
            rekognition_response = rekognition_client.detect_protective_equipment(
                Image={
                    'S3Object': {
                        'Bucket': BUCKET_NAME,
                        'Name': obj['Key']
                    }
                },
                SummarizationAttributes={
                    'MinConfidence': 80,  # Confidence level threshold
                    'RequiredEquipmentTypes': ['FACE_COVER']
                }
            )
            rekognition_results.append(rekognition_response)

    return {
        "statusCode": 200,
        "body":  json.dumps(rekognition_results),
    }

print(lambda_handler(None, None))