# Hacking Kubernetes on AWS (EKS) from a Mac

## Introduction

This is repository the code required to automate the deployment of a test Kubernetes cluster built from the Kubernetes
Git repository. [There is a blog post associated with this repository](https://www.opencredo.com/blogs/hacking-kubernetes-on-aws-eks-from-a-mac).

## `cluster/`
The `cluster/` directory contains the Terraform required to stand up a simple Kubernetes cluster using binaries and
container images that you've built on your laptop. The cluster will contain a single master and three nodes.

## `repositories/`
The `repositories` directory contains the Terraform required to build the ECR repositories used to house the container images so
that they can be transferred from your laptop to the instances that will become the cluster.
