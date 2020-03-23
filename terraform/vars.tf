variable "aws_region" {
  description = "aws region (default is us-east-1)"
  default     = "us-east-1"
}
variable "prefix" {
  description = "unique prefix for tags"
}
variable "ssh_key" {
  description = "name of existing ssh key"
}

