

# resource "aws_vpc" "vpc_atividade" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true

#   tags = {
#     Name = "vpc_atividade"
#   }
# }

# //Faça uma subnte pública
# resource "aws_subnet" "subnet_publica" {
#   vpc_id = aws_vpc.vpc_atividade.id
#   cidr_block = "10.0.1.0/24"

#   enable_resource_name_dns_a_record_on_launch = true

#   map_public_ip_on_launch = true

#   tags = {
#     Name = "subnet_publica"
#   }
# }

# //Faça uma subnet privada
# resource "aws_subnet" "subnet_privada" {
#   vpc_id = aws_vpc.vpc_atividade.id
#   cidr_block = "10.0.2.0/24"

#   tags = {
#     Name = "subnet_privada"
#   }
# }

# resource "aws_instance" "ec2_publica" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ec2_publica"
#   }

#   ebs_block_device {
#     device_name = "/dev/sda1"
#     volume_size = 30
#     volume_type = "gp3"
#   }

#   subnet_id = aws_subnet.subnet_publica.id
# }

# resource "aws_instance" "ec2_privada" {
#   ami = "ami-0e86e20dae9224db8"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ec2_privada"
#   }

#   ebs_block_device {
#     device_name = "/dev/sda1"
#     volume_size = 30
#     volume_type = "gp3"
#   }

#   subnet_id = aws_subnet.subnet_privada.id
# }