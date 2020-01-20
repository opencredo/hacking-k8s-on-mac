resource "aws_launch_template" "nodes" {
  name_prefix   = local.cluster_name
  image_id      = data.aws_ami.ubuntu_1804.id
  instance_type = var.instance_type

  key_name = aws_key_pair.ssh.id
  iam_instance_profile {
    name = aws_iam_instance_profile.iam.name
  }

  user_data = data.template_cloudinit_config.nodes.rendered

  block_device_mappings {
    device_name = data.aws_ami.ubuntu_1804.root_device_name
    ebs {
      delete_on_termination = true
      volume_size           = 40
      volume_type           = "gp2"
    }
  }

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg.id]
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }
  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }
  tags = local.tags
}

resource "aws_autoscaling_group" "nodes" {
  name_prefix = local.cluster_name

  max_size         = 3
  min_size         = 3
  desired_capacity = 3

  vpc_zone_identifier = aws_subnet.subnets.*.id

  launch_template {
    id      = aws_launch_template.nodes.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      propagate_at_launch = false
      value               = tag.value
    }
  }

  depends_on = [
    aws_instance.master,
    aws_internet_gateway.ig,
    null_resource.s3_objects,
  ]
}

data "template_cloudinit_config" "nodes" {
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/install.sh", { bucket : aws_s3_bucket.config.bucket })
  }
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/node.sh", { bucket : aws_s3_bucket.config.bucket })
  }
}
