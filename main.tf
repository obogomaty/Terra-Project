provider "aws" {
  region     = "eu-west-1"
  access_key = "********"
  secret_key = "********"
}


resource "aws_vpc" "awslab-vpc" {
  cidr_block = "192.16.0.0/23"
    enable_dns_hostnames = "true"
   tags = {
    Name = "terra-vpc"
  }
}



resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.awslab-vpc.id
  cidr_block = "192.16.0.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "awslab-subnet-public"
  }
}



resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.awslab-vpc.id
  cidr_block = "192.16.1.0/24"
    availability_zone = "eu-west-1b"

  tags = {
    Name = "awslab-subnet-private"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.awslab-vpc.id

  tags = {
    Name = "terra-gw"
  }
}



resource "aws_route_table" "r" {
  vpc_id = aws_vpc.awslab-vpc.id

route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
}
   
 tags = {
    Name = "awslab-vpc"
  }
}



resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.r.id
}







resource "aws_eip" "lb" {
   vpc      = true
}





resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.subnet1.id

  tags = {
    Name = "gw-NAT"
  }
}




resource "aws_route_table" "privte" {
  vpc_id = aws_vpc.awslab-vpc.id

route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat-gw.id
}
   
 tags = {
    Name = "awslab-vpc"
  }
}



resource "aws_route_table_association" "ab" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.privte.id
}


resource "aws_security_group" "allowssh" {
  name        = "allowssh"
  description = "Allow TLS inbound traffic"
  vpc_id      =  aws_vpc.awslab-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public"
  }
}



resource "aws_security_group" "allowsql" {
  name        = "allowsql"
  description = "Allow TLS inbound traffic"
  vpc_id      =  aws_vpc.awslab-vpc.id


 ingress {
    description = "mysql-rule"
    from_port   = 3110
    to_port     = 3110                                         
    protocol    = "tcp"
    cidr_blocks = ["192.178.0.0/24"]
  }

  ingress {
    description = "SSH"
    from_port   = 22                                                     
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.178.0.0/24"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private"
  }
}





resource "aws_key_pair" "trial" {
    key_name   = "trial"
    public_key = file("trial.pub")
  
  }
  




resource "aws_instance" "wp" {
  ami           = "ami-0ea0f26a6d50850c5"
  instance_type = "t2.micro"
  subnet_id  =  aws_subnet.subnet1.id
  vpc_security_group_ids  =  ["${aws_security_group.allowssh.id}"]
  key_name  = "trial"
  

  tags = {
    Name = "Terra-Webserver"
  }
}



resource "aws_instance" "sql" {
  ami           = "ami-0ea0f26a6d50850c5"
  instance_type = "t2.micro"
  subnet_id  =  aws_subnet.subnet2.id
  vpc_security_group_ids  =  ["${aws_security_group.allowsql.id}"]
  key_name  = "trial"
  

  tags = {
    Name = "Terra-Sqlserver"
  }
}


