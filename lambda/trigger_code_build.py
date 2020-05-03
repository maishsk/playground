import os
import boto3

PROJECT_NAME = os.environ['PROJECT_NAME']
codebuildclient = boto3.client('codebuild')

def lambda_handler(event, context):
    response = codebuildclient.start_build(projectName=PROJECT_NAME)
