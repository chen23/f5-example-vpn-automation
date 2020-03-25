#!/bin/bash
S3_BUCKET=$1
#echo "Waiting for /info endpoint to be available"
until aws s3 ls ${S3_BUCKET}/credentials/master &> /dev/null; do
    sleep 10;
done
aws s3 cp s3://${S3_BUCKET}/credentials/master ../vpn/cft.auto.tfvars.json
