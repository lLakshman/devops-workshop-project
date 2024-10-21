provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "demo-server" {
    ami = "ami-0866a3c8686eaeeba"
    instance_type = "t2.micro"
    key_name = "terraform verginia"
    //security_groups = ["demo-sg"]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.my_public_subnet.id
    for_each = toset(["jenkins-master", "jenkins-slave", "ansible"])
    tags = {
      Name = "${each.key}"
    }
}
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.my_vpc.id
  

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
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
    Name = "ssh-port"
  }
}

resource "aws_vpc" "my_vpc" {
 cidr_block =  "10.1.0.0/16"
 
 tags = {
   Name = "my_vpc"
 }
}

resource "aws_subnet" "my_public_subnet" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block =  "10.1.1.0/24"
 map_public_ip_on_launch = true
 availability_zone = "us-east-1a"

 tags = {
   Name = "mypublicsubnet"
 }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "myinternetgateway"
  }
}

resource "aws_route_table" "my_route_table" {
 vpc_id = aws_vpc.my_vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
 } 

 tags = {
   Name = "myroutetable"
 }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}