#!/bin/bash
S3_BUCKET=$1
aws s3 rm  s3://erchen-cross-az-stack-s3bucket-g07thodylaa2 --recursive
