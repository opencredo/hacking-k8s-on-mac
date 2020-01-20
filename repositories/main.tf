resource "aws_ecr_repository" "kube-apiserver" {
  name = "kube-apiserver"
}

resource "aws_ecr_repository" "kube-controller-manager" {
  name = "kube-controller-manager"
}

resource "aws_ecr_repository" "kube-proxy" {
  name = "kube-proxy"
}

resource "aws_ecr_repository" "kube-scheduler" {
  name = "kube-scheduler"
}

resource "aws_ecr_repository" "pause" {
  name = "pause"
}
