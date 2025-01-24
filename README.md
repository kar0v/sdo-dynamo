# sdo-dynamo

## A devops project to deploy a CRUD application to AWS EKS. 

> **_NOTE:_**  Currently building the docker containers on a Mac with M2 processor, so keep this in mind.

## Deployment
From the root dir:

``` shell
cd terraform
terraform init
terraform apply --auto-approve
```

From the root dir run the provision.sh script. 
This will build and populate the ECR repositories with the desired containers. 
``` shell
./provision.sh
```

