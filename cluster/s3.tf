resource "aws_s3_bucket" "config" {
  bucket_prefix = local.cluster_name
  acl           = "private"

  force_destroy = true
}

resource "aws_s3_bucket_object" "daemon-json" {
  bucket = aws_s3_bucket.config.bucket
  key    = "daemon.json"
  source = "${path.module}/files/docker-daemon.json"
}

resource "aws_s3_bucket_object" "kubeadm_init-yaml" {
  bucket = aws_s3_bucket.config.bucket
  key    = "kubeadm_init.yaml"
  content = templatefile("${path.module}/templates/kubeadm_init.yaml", {
    region : var.aws_region,
    accountId : data.aws_caller_identity.account.account_id,
    version : var.kubernetes_version,
    name : local.cluster_name,
  })
}

resource "aws_s3_bucket_object" "kubeadm" {
  bucket = aws_s3_bucket.config.bucket
  key    = "kubeadm"
  source = "${var.kubernetes_directory}/_output/dockerized/bin/linux/amd64/kubeadm"
}

resource "aws_s3_bucket_object" "kubelet" {
  bucket = aws_s3_bucket.config.bucket
  key    = "kubelet"
  source = "${var.kubernetes_directory}/_output/dockerized/bin/linux/amd64/kubelet"
}

resource "aws_s3_bucket_object" "kubectl" {
  bucket = aws_s3_bucket.config.bucket
  key    = "kubectl"
  source = "${var.kubernetes_directory}/_output/dockerized/bin/linux/amd64/kubectl"
}

resource "aws_s3_bucket_object" "kubelet-service" {
  bucket = aws_s3_bucket.config.bucket
  key    = "kubelet.service"
  source = "${var.kubernetes_directory}/build/debs/kubelet.service"
}

resource "aws_s3_bucket_object" "ten-kubeadm-conf" {
  bucket = aws_s3_bucket.config.bucket
  key    = "10-kubeadm.conf"
  source = "${var.kubernetes_directory}/build/debs/10-kubeadm.conf"
}

resource "aws_s3_bucket_object" "fifty-kubeadm-conf" {
  bucket = aws_s3_bucket.config.bucket
  key    = "50-kubeadm.conf"
  source = "${var.kubernetes_directory}/build/debs/50-kubeadm.conf"
}

resource "null_resource" "s3_objects" {
  depends_on = [
    aws_s3_bucket_object.daemon-json,
    aws_s3_bucket_object.fifty-kubeadm-conf,
    aws_s3_bucket_object.kubeadm,
    aws_s3_bucket_object.kubeadm_init-yaml,
    aws_s3_bucket_object.kubectl,
    aws_s3_bucket_object.kubelet,
    aws_s3_bucket_object.kubelet-service,
    aws_s3_bucket_object.ten-kubeadm-conf,
  ]
}
