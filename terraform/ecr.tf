# create ecr & ecr endpoints for the eks cluster

resource "aws_ecr_repository" "feedback_logger" {
  name = "feedback-logger"
}

resource "aws_ecr_repository" "feedback_db" {
  name = "feedback-db"
}

