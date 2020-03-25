#!/bin/bash
S3_BUCKET=$1
aws s3 rm  s3://${S3_BUCKET} --recursive
