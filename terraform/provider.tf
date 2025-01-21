terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
      Service     = "feedback_logger"
      DevelopedBy = "Krasimir Karov"
    }
  }

}
