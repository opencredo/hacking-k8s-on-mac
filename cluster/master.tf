resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu_1804.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.subnets[0].id
  iam_instance_profile   = aws_iam_instance_profile.iam.name

  user_data = data.template_cloudinit_config.master.rendered

  root_block_device {
    volume_size = 40
    volume_type = "gp2"
  }

  volume_tags = local.tags

  tags = local.tags

  depends_on = [
    aws_internet_gateway.ig,
    null_resource.s3_objects,
  ]
}

data "template_cloudinit_config" "master" {
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/install.sh", { bucket : aws_s3_bucket.config.bucket })
  }
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/master.sh", { bucket : aws_s3_bucket.config.bucket })
  }
}
