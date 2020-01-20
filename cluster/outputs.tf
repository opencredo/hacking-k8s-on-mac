output "master" {
  value = "ssh -i ${abspath(local_file.ssh_private_key.filename)} ubuntu@${aws_instance.master.public_ip}"
}

output "node" {
  value = "ssh -i ${abspath(local_file.ssh_private_key.filename)} ubuntu@"
}
