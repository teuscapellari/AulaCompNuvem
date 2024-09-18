variable "porta_http" {
  default = 80
  type    = number
}

variable "porta_https" {
  default = 443
  type    = number
}

resource "aws_security_group" "sg_publica" {
  name   = "sg_aula_iac_rede_publica"
  vpc_id = aws_vpc.vpc_aula_iac_3.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.porta_http
    to_port     = var.porta_http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.porta_http
    to_port     = var.porta_http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.porta_https
    to_port     = var.porta_https
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.porta_https
    to_port     = var.porta_https
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_privada" {
  name   = "sg_aula_iac_rede_privada"
  vpc_id = aws_vpc.vpc_aula_iac_3.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

// criando uma VPC chamada "vpc_aula_iac_3"

resource "aws_vpc" "vpc_aula_iac_3" {
  cidr_block = "10.10.10.0/25"
  tags = {
    Name = "vpc_aula_iac_3"
  }
}

resource "aws_subnet" "subrede_publica" {
  vpc_id            = aws_vpc.vpc_aula_iac_3.id
  cidr_block        = "10.10.10.0/26"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subrede_publica"
  }

  // determina se as instâncias executadas na VPC recebem nomes de host DNS públicos que correspondem a seus endereços IPpúblicos.
  enable_resource_name_dns_a_record_on_launch = true

  // Determina que uma EC2 criada nessa sub-rede recebe automaticamente um endereço IPv4 público
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subrede_privada" {
  vpc_id            = aws_vpc.vpc_aula_iac_3.id
  cidr_block        = "10.10.10.64/26"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subrede_privada"
  }
}


// Criando um Internet Gateway para a VPC "vpc_aula_iac_3"

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_aula_iac_3.id

  tags = {
    Name = "igw_vpc_aula_iac_3"
  }
}


// Criando uma Route Table "rt_vpc_aula_iac_3" para a internet gateway "igw_vpc_aula_iac_3"

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_aula_iac_3.id

  tags = {
    Name = "rt_vpc_aula_iac_3"
  }
}


// Criando uma rota para a internet gateway "igw_vpc_aula_iac_3" na route table "rt_vpc_aula_iac_3"
// A rota é para qualquer destino (0.0.0.0/0)

resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}


// Associando a route table "rt_vpc_aula_iac_3" com a sub-rede "subrede_publica"

resource "aws_route_table_association" "rt_subrede_publica" {
  subnet_id      = aws_subnet.subrede_publica.id
  route_table_id = aws_route_table.rt.id
}


// Associando a route table "rt_vpc_aula_iac_3" com a sub-rede "subrede_privada"

resource "aws_route_table_association" "rt_subrede_privada" {
  subnet_id      = aws_subnet.subrede_privada.id
  route_table_id = aws_route_table.rt.id
}



// Criando uma instância EC2 na sub-rede "subrede_publica" e no security group "sg_publica"

resource "aws_instance" "ec2-iac-aula3" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  tags = {
    Name = "ec2-iac-aula3-publica"
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "gp3"
  }

  key_name = "aula_iac"

  subnet_id = aws_subnet.subrede_publica.id

  vpc_security_group_ids = [aws_security_group.sg_publica.id]

}


// Criando uma instância EC2 na sub-rede "subrede_privada" e no security group "sg_privada"

resource "aws_instance" "ec2-iac-aula2-2" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  tags = {
    Name = "ec2-iac-aula3-privada"
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "gp3"
  }

  key_name = "aula_iac"

  subnet_id = aws_subnet.subrede_privada.id

  vpc_security_group_ids = [aws_security_group.sg_privada.id]

}

## crianção de bucket s3
resource "aws_s3_bucket" "aula1" {
  tags = {
    Name = "arquivos"
  }

  # impedir que o bucket seja excluído caso tenha objetos
  force_destroy = false  # o padrão é false

  # habilitar o bloqueio de objetos (se alguém estive lendo, fica bloqueado). 
  object_lock_enabled = false # O padrão é false
}

## Configuração de acesso público ao bucket
resource "aws_s3_bucket_public_access_block" "bucket_acessos" {
  bucket = aws_s3_bucket.aula1.id

  # configurações para acesso público via ACL - Access Control Lists (se true pode permitir  que outras contas AWS tenhamn acesso)
  block_public_acls   = false # o padrão é false  

  # configurações para acesso público via bucket policy (se true pode permitir que qualquer pessoa tenha acesso)
  block_public_policy = false # o padrão é false
}