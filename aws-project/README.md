# SFTP to S3 Data Lake Solution

## Overview

This repository contains Terraform scripts to set up an AWS infrastructure that allows multiple marketing agencies to upload data to an S3 bucket via SFTP. The solution uses AWS Transfer Family for SFTP, S3 for storage, Lambda for processing, KMS for encryption, and CloudWatch for monitoring and alerting.

## Requirements

- AWS Free Tier account
- Terraform 1.0.0 or later
- AWS CLI configured with appropriate credentials

## Assumptions

1. File types are CSV, Excel, and JSON.
2. File sizes range from 20KB to 50MB.
3. Each agency uploads 1-24 files per batch.
4. Agencies are located in different geographical regions, and network latency is considered.
5. Each agency shares a single SFTP user for uploads.

## Features

- Automated and reproducible infrastructure deployment using Terraform.
- Secure file upload via SFTP to S3 bucket.
- Encryption of data using AWS KMS.
- Lambda function to process uploaded files.
- Monitoring and alerting using CloudWatch and SNS.
- Principle of least privilege applied to IAM roles and policies.
- Rollback and de-provisioning of resources.

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/Aditi698/sftp-to-s3-datalake.git
cd sftp-to-s3-datalake
```

2. Update Variables
   Update the variables.tf file with your specific details such as email addresses for alerts, bucket names, etc.

3. Initialize Terraform

   terraform init

4. Plan the Deployment

   terraform plan

5. Apply the Deployment

   terraform apply

6. Destroy the Deployment
   To destroy the infrastructure and clean up resources:

   terraform destroy

Components

S3 Bucket
An S3 bucket is created to store the uploaded data. The bucket is encrypted using a KMS key.

AWS Transfer Family
An SFTP server is created using AWS Transfer Family. IAM roles and policies are set up to provide least privilege access to the S3 bucket.

Lambda Function
A Lambda function is deployed to process the uploaded files. The function is triggered by S3 bucket notifications.

CloudWatch Alarms
CloudWatch alarms are set up to monitor Lambda function errors and alert via SNS.

IAM Policies
The solution adheres to the principle of least privilege. IAM roles and policies are explicitly documented and configured to grant only necessary permissions.

Rollback and De-provisioning
In case of any issues, the Terraform scripts ensure that all resources can be rolled back and de-provisioned without leaving any orphaned or cost-incurring resources.

Monitoring and Alerts
CloudWatch is used to monitor the Lambda function, and SNS is used to send alerts in case of errors or missing data uploads.

License
This project is licensed under the MIT License. See the LICENSE file for details.

Scope

This project aims to design, deploy, and manage an automated and secure data ingestion pipeline that allows multiple marketing agencies across various geographical locations to upload data to an S3 bucket in the eu-west-1 AWS region using SFTP. The solution is designed to be scalable, maintainable, and compliant with best security practices, ensuring data integrity and privacy.

Key Objectives

SFTP Setup and Management

Provision and manage SFTP servers for each agency.
Ensure secure and reliable file uploads to the S3 bucket.
Automate user creation and management for each agency with unique SFTP credentials.
Data Ingestion and Storage

Configure an S3 bucket (data-lake-498) to store incoming files.
Implement KMS encryption (aws_kms_key) for all objects stored in the S3 bucket to protect sensitive data.
Ensure files of types CSV, Excel, and JSON are correctly ingested and stored.
Lambda Function Deployment

Deploy a Lambda function (data-lake) to process uploaded files.
Automate the packaging and deployment of the Lambda function using Terraform (archive_file).
Grant necessary permissions for the Lambda function to access S3 and KMS resources.
IAM Role and Policy Management

Define and assign IAM roles and policies with the principle of least privilege.
Ensure the Lambda function has the necessary permissions to access CloudWatch, SES, S3, and KMS resources.
Monitoring and Alerting

Set up CloudWatch alarms to monitor Lambda function execution and errors.
Configure SNS topics to alert the SRE team in case of missing data or other incidents.
Implement automated notifications via email or Slack for priority incidents.
Automation and Scalability

Use Terraform to manage and deploy all AWS resources, ensuring reproducibility and scalability.
Automate the onboarding and offboarding process for new and existing agencies within a 6-hour SLA.
Ensure the deployment process is smooth and updates are easily applied by updating the repository.
Security and Compliance

Implement and document security measures to protect PII and ensure compliance with data protection regulations.
Ensure S3 bucket policies are configured to restrict access and protect sensitive data.
Regularly review and update IAM policies to maintain the principle of least privilege.
Rollback and Cleanup

Ensure that the solution supports easy rollback and de-provisioning of resources to avoid unnecessary costs.
Provide Terraform scripts to clean up all resources if needed, leaving no orphaned or cost-incurring resources behind.
This scope outlines the primary objectives and boundaries of the project, ensuring a robust, secure, and scalable solution for managing data uploads from multiple agencies to the data lake using AWS services and Terraform for infrastructure as code.
