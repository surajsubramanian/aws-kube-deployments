provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "sample" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "sample"
  }
}

resource "aws_subnet" "sample" {
  vpc_id                  = aws_vpc.sample.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "sample"
  }
}

resource "aws_security_group" "sample" {
  name   = "public_sg_hyro"
  vpc_id = aws_vpc.sample.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "sample" {
  tags = {
    Name = "sample"
  }
}

resource "aws_internet_gateway_attachment" "sample" {
  vpc_id              = aws_vpc.sample.id
  internet_gateway_id = aws_internet_gateway.sample.id
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.sample.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample.id
  }
  tags = {
    Name = "public_route_table_sample"
  }
}

resource "aws_route_table_association" "RouteTableAssociation" {
  subnet_id      = aws_subnet.sample.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "sample"       # Create "sample" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "sample.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./sample.pem"
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "ec2.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "aws_batch_service_role" {
  name = "aws_batch_service_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "batch.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_batch_compute_environment" "sample" {
  compute_environment_name = "sample"

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    instance_type = [
      "c4.large",
    ]

    max_vcpus     = 16
    min_vcpus     = 1
    desired_vcpus = 2

    security_group_ids = [
      "${aws_security_group.sample.id}",
    ]

    ec2_key_pair = "sample"

    subnets = [
      "${resource.aws_subnet.sample.id}",
    ]

    type = "EC2"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
}

resource "aws_batch_job_queue" "this" {
  name     = "job-queue"
  state    = "ENABLED"
  priority = "1"
  compute_environments = [
    "${aws_batch_compute_environment.sample.arn}",
  ]
}

resource "aws_batch_job_definition" "example" {
  name                 = "this-job-definition"
  type                 = "container"
  container_properties = <<CONTAINER_PROPERTIES
{
    "command": ["echo", "Hello World"],
    "image": "busybox",
    "memory": 120,
    "vcpus": 1,
    "environment": [
        {"name": "EXAMPLE_KEY", "value": "EXAMPLE_VALUE"}
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "example"
        }
    }
}
CONTAINER_PROPERTIES
}

resource "aws_batch_job_definition" "test" {
  name = "this-job-definition2"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
{
    "command": ["ls", "-la"],
    "image": "busybox",
    "memory": 120,
    "vcpus": 1,
    "volumes": [
      {
        "host": {
          "sourcePath": "/tmp"
        },
        "name": "tmp"
      }
    ],
    "environment": [
        {"name": "VARNAME", "value": "VARVAL"}
    ],
    "mountPoints": [
        {
          "sourceVolume": "tmp",
          "containerPath": "/tmp",
          "readOnly": false
        }
    ],
    "ulimits": [
      {
        "hardLimit": 1024,
        "name": "nofile",
        "softLimit": 1024
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "example"
        }
    }
}
CONTAINER_PROPERTIES
}

resource "aws_cloudwatch_log_group" "example" {
  name = "example"
}
