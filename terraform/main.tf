# Définition du fournisseur AWS
provider "aws" {
  region = var.region
}

# 1. Recherche de la dernière AMI Ubuntu 24.04 (Noble Numbat)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 2. Création de la paire de clés dans AWS à partir de ta clé locale
resource "aws_key_pair" "exam_key" {
  key_name   = "morganm-exam-key"
  public_key = file("~/.ssh/exam_key.pub")
}

# 3. Groupe de sécurité (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "morganm-webapp-sg"
  description = "Autoriser SSH, HTTP et HTTPS pour le projet From Code to Cluster"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ouverture du port 443 pour le bonus Ingress/TLS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Déploiement de l'instance EC2 avec ta convention de nommage
resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.exam_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "morganm-webapp"
  }
}
