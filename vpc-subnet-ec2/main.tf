provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon" {
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2"]
    }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "main"
  }
}

resource "aws_subnet" "PublicSubnetA" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "PublicSubnetA"
  }
}

resource "aws_subnet" "PublicSubnetB" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "PublicSubnetB"
  }
}

resource "aws_subnet" "PrivateSubnetA" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.16.0/20"
  tags = {
    "Name" = "PrivateSubnetA"
  }
}

resource "aws_subnet" "PrivateSubnetB" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.32.0/20"
  tags = {
    "Name" = "PrivateSubnetB"
  }
}

resource "aws_instance" "PublicInstanceA" {
    ami = data.aws_ami.amazon.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.PublicSubnetA.id
    vpc_security_group_ids = [aws_security_group.PublicSG.id]
}

resource "aws_security_group" "PublicSG" {
    name = "PublicSG"
    vpc_id = aws_vpc.main.id
    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH from the internet"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_internet_gateway" "main" {
  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway_attachment" "main" {
    vpc_id = aws_vpc.main.id
    internet_gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table" "PublicRouteTable" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "PublicRouteTable"
    }
}

resource "aws_route_table" "PrivateRouteTable" {
    vpc_id = aws_vpc.main.id
    

    tags = {
        Name = "PrivateRouteTable"
    }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.PublicSubnetA.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.PublicSubnetB.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.PrivateSubnetA.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.PrivateSubnetB.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

