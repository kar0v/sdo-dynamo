#!/bin/bash
. ./Django/feedback_logger/.env

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

cd "${SCRIPT_DIR}"/Django/feedback_logger || exit
# This script is to build and push the docker images for the app and db to ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}".dkr.ecr.eu-central-1.amazonaws.com

docker build -t feedback-app:latest --platform linux/amd64 .
docker tag feedback-app:latest "${AWS_ACCOUNT_ID}".dkr.ecr.eu-central-1.amazonaws.com/feedback-logger:latest
docker push "${AWS_ACCOUNT_ID}".dkr.ecr.eu-central-1.amazonaws.com/feedback-logger:latest

cd "${SCRIPT_DIR}"/Django/feedback_logger/database || exit
docker build -t feedback-db:latest --platform linux/amd64 .
docker tag feedback-db:latest "${AWS_ACCOUNT_ID}".dkr.ecr.eu-central-1.amazonaws.com/feedback-db:latest
docker push "${AWS_ACCOUNT_ID}".dkr.ecr.eu-central-1.amazonaws.com/feedback-db:latest