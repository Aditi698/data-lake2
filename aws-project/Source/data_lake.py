import os
import boto3 
from botocore.client import Config

def lambda_handler(event,context):
   
        #s3 client
        s3_client = boto3.client('s3', config=Config(signature_version='s3v4'))
        #ses client
        ses_client = boto3.client('ses')
        #list to store file names
        key = []

        #emails for ses
        SOURCE_EMAIL = os.environ['SOURCE_EMAIL']
        DEST_EMAIL = os.environ['DEST_EMAIL']

        #message for file modification
        message1 = 'File is uploaded '
    
        try:
            for x in s3_client.list_objects(Bucket='data-lake-498')['Contents']:
                #adding file names into the list
                key.append(x['Key'])
            
        except:
        
            #message for empty bucket
            empty_message = 'Bucket is empty'
        
            #email for empty bucket
            ses_client.send_email(
                        Source = SOURCE_EMAIL,
                        Destination={'ToAddresses': [DEST_EMAIL]},
                        Message={
                            'Subject':{'Data': 'Empty','Charset': 'utf-8'},
                            'Body':{'Text':{'Data': str(empty_message),'Charset':'utf-8'}}
                        })
        if key != None:
            ses_client.send_email(
                Source = SOURCE_EMAIL,
                Destination={'ToAddresses': [DEST_EMAIL]},
                Message={
                    'Subject':{'Data': 'File Notification','Charset': 'utf-8'},
                    'Body':{'Text':{'Data': str(message1),'Charset':'utf-8'}}
                })