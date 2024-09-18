# terraform {
#     required_providers {
#         aws = {
#             source  = "hashicorp/aws"
#             version = "~> 4.16"
#         }
#     }

#     required_version = ">= 1.2.0"
# }

# provider "aws" {
#   region = "us-east-1"
# }

# resource "aws_instance" "ec2-iac-aula2" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t2.micro"

#   tags = {
#     name = "ec2-iac-aula2"
#   }

#   ebs_block_device {
#     device_name = "/dev/sda1"
#     volume_size = 30
#     volume_type = "gp3"
#   }

#   security_groups = [aws_security_group.sg_aula_iac.name, "default"]

#   key_name = "aula_iac"

#   // Assim é caso queira indicar uma subnet da AWS
#   //subnet_id = "subnet-0872bc5ec7f20dae8" 

#   // Assim é caso queira indicar uma subnet criada pelo Terraform
#   # subnet_id = aws_subnet.minha_subnet.id
# }

# variable "porta_http" {
#   description = "porta http"
#   default = 80
#   type = number
# }

# variable "porta_https" {
#   description = "porta https"
#   default = 443
#   type = number
# }

# resource "aws_security_group" "sg_aula_iac" {
#   name = "sg_aula_iac"

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port = var.porta_http
#     to_port = var.porta_http
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = var.porta_https
#     to_port = var.porta_https
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_subnet" "minha_subnet" {
#   vpc_id = "id da vpc"
#   cidr_block = "10.10.10.0/24"
# }
