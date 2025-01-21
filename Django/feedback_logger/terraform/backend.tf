terraform {
  backend "s3" {
    bucket = "kkarov-feedback-logger-terraform-state"
    key    = "feedback_logger/terraform.tfstate"
    region = "eu-central-1"
  }
}
