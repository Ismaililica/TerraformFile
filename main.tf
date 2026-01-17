resource "aws_vpc" "terraformvpc" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraformVPC"
  }

}

resource "aws_internet_gateway" "terraformigw" {

  vpc_id = aws_vpc.terraformvpc.id

  tags = {
    Name = "terraformigw"
  }

}

resource "aws_subnet" "publicsubnettf" {

  vpc_id                  = aws_vpc.terraformvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "privatesubnettf" {
  vpc_id            = aws_vpc.terraformvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "private-subnet-1b"
  }

}

resource "aws_route_table" "publicsubneticinrt" {

  vpc_id = aws_vpc.terraformvpc.id


  tags = {
    Name = "PublicSubnetRT"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraformigw.id
  }

}

resource "aws_route_table_association" "routetableassociation" {

  subnet_id      = aws_subnet.publicsubnettf.id
  route_table_id = aws_route_table.publicsubneticinrt.id

}

resource "aws_route_table" "privateicinrt" {

  vpc_id = aws_vpc.terraformvpc.id

  tags = {
    Name = "PrivateicinRT"

  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

}

resource "aws_route_table_association" "privateRTasc" {

  subnet_id      = aws_subnet.privatesubnettf.id
  route_table_id = aws_route_table.privateicinrt.id

}


resource "aws_default_security_group" "defaultsg" {

  vpc_id = aws_vpc.terraformvpc.id

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

  ingress {

    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraformileolusanSG"

  }
}

resource "aws_instance" "EC2deneme" {

  instance_type          = "t3.micro"
  ami                    = "ami-0683ee28af6610487"
  subnet_id              = aws_subnet.publicsubnettf.id
  vpc_security_group_ids = [aws_default_security_group.defaultsg.id]

  tags = {

    Name = "TerraformPublicEC2"
  }

} 

resource "aws_instance" "privatesubnetEC2" {

  ami = "ami-0683ee28af6610487"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.privatesubnettf.id
  vpc_security_group_ids = [aws_default_security_group.defaultsg.id]

   tags = {

    Name = "TerraformPrivateEC2"
  }
}