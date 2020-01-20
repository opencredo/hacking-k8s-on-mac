resource "aws_iam_instance_profile" "iam" {
  name_prefix = "k8s"
  role        = aws_iam_role.iam.name
}

resource "aws_iam_role" "iam" {
  name_prefix        = "k8s"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy" "policy" {
  policy = data.aws_iam_policy_document.policy.json
  role   = aws_iam_role.iam.id
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc.id
  description = "Security group used to connect instances within the cluster"
  tags        = local.tags

  ingress {
    description = "Allow traffic between nodes"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    self        = true
  }
  egress {
    description = "Allow traffic between nodes"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    self        = true
  }

  ingress {
    description = "Allow SSH from your laptop"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${trimspace(data.http.ip.body)}/32"]
  }

  egress {
    description = "Allow traffic out"
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = "k8s"
  public_key      = tls_private_key.ssh.public_key_openssh
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  filename          = "${path.module}/ssh_key"
  sensitive_content = tls_private_key.ssh.private_key_pem
  file_permission   = "0600"
}
