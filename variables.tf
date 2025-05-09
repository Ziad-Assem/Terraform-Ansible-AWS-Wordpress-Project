variable "ami_ubuntu_east_1" {
    sensitive = true
}
variable "ami_ubuntu_east_2" {
  sensitive = true
}
variable "instance_type" {
    sensitive = true
}
variable "key-ec2" {
    description = "AWS key-pair for ec2"
}