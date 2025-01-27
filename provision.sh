#!/bin/bash
. ./Django/feedback_logger/.env

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
EFS_ID=$(cd terraform && terraform output efs_id | tr -d \")
EKS_CLUSTER_NAME=$(cd terraform && terraform output cluster_name | tr -d \")

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

cd "${SCRIPT_DIR}" || exit
aws eks update-kubeconfig --region eu-central-1 --name "${EKS_CLUSTER_NAME}"

#change the volumeHandle: fs-*** with efs id in the yaml file
sed -i.bak "s/volumeHandle: fs-.*/volumeHandle: ${EFS_ID}/g" "${SCRIPT_DIR}"/deployment.yaml
kubectl apply -f "${SCRIPT_DIR}"/deployment.yaml
kubectl config set-context --current --namespace feedback-logger
sleep 30
kubectl get svc -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' && echo