terraform {
  backend "s3" {
    bucket = "kkarov-tfstate"
    key    = "feedback_logger/terraform.tfstate"
    region = "eu-central-1"
  }
}

