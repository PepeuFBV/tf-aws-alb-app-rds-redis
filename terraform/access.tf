resource "aws_key_pair" "admin" {
  key_name   = "${var.project_name}-admin"
  public_key = var.ssh_public_key

  tags = {
    Name = "${var.project_name}-admin"
  }
}
