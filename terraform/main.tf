# Définition du fournisseur AWS
provider "aws" {
  region = var.region
}

# 1. Recherche de la dernière AMI Ubuntu 24.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 2. Création de la paire de clés dans AWS à partir de la clé locale
resource "aws_key_pair" "exam_key" {
  key_name   = "morganm-exam-key"
  public_key = file("~/.ssh/exam_key.pub")
}

# 3. Groupe de sécurité
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

  # Ouverture du port 443
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

# 4. Déploiement de l'instance EC2
resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.exam_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "morganm-webapp"
  }
}

resource "local_file" "ansible_inventory" {
  content  = "[web]\n${aws_instance.vm.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/exam_key"
  filename = "../ansible/inventory.ini"
}
