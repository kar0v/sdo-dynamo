
####################################
### Bastion host in Private Zone ###
####################################

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSM_EC2_Instance_Profile"
  role = aws_iam_role.ssm_role.name
}


locals {
  services = ["com.amazonaws.eu-central-1.ssm", "com.amazonaws.eu-central-1.ssmmessages", "com.amazonaws.eu-central-1.ec2messages"]
}
resource "aws_vpc_endpoint" "ssm" {
  count               = length(local.services)
  vpc_id              = aws_vpc.eks.id
  service_name        = local.services[count.index]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.bastion.id, ]
  subnet_ids          = [aws_subnet.public-a.id, aws_subnet.public-b.id, aws_subnet.public-c.id]
  tags = {
    Name = "${local.services[count.index]}"
  }
}

# AMI

data "aws_ami" "amzn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]

}

# resource "aws_instance" "bastion" {
#   ami                         = data.aws_ami.amzn.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public-a.id
#   vpc_security_group_ids      = [aws_security_group.bastion.id]
#   iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
#   associate_public_ip_address = true
#   tags = {
#     Name = "bastion"
#   }
# }
