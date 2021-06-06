provider "aws" {
  region = "eu-central-1"
}
resource "aws_vpc" "Primary_VPC" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "Primary_VPC"
  }
}

resource "aws_internet_gateway" "Primary_VPC_GW" {
  vpc_id = aws_vpc.Primary_VPC.id

  tags = {
    Name = "Primary_VPC_GW"
  }
}
resource "aws_default_route_table" "Primary_VPC_RT" {
  default_route_table_id = aws_vpc.Primary_VPC.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Primary_VPC_GW.id
  }
  tags = {
    Name = "Primary_VPC_RT"
  }
}

resource "aws_route_table_association" "Main_RT" {
  subnet_id      = aws_subnet.Primary_Subnet.id
  route_table_id = aws_default_route_table.Primary_VPC_RT.id

}
resource "aws_route_table_association" "Secondary_RT" {
  subnet_id      = aws_subnet.Secondary_Subnet.id
  route_table_id = aws_default_route_table.Primary_VPC_RT.id

}

resource "aws_subnet" "Primary_Subnet" {
  vpc_id                  = aws_vpc.Primary_VPC.id
  cidr_block              = "192.168.10.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Primary_Subnet"
  }
}
resource "aws_subnet" "Secondary_Subnet" {
  vpc_id                  = aws_vpc.Primary_VPC.id
  cidr_block              = "192.168.20.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Secondary_Subnet"
  }
}
resource "aws_security_group" "SG_Primary_VPC" {
  name   = "SG_Primary_VPC"
  vpc_id = aws_vpc.Primary_VPC.id

  dynamic "ingress" {
    for_each = ["22", "443", "80"]
    content {
      description = "TLS from VPC"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Server_1" {
  ami                    = "ami-0c2b1c303a2e4cb49"
  instance_type          = "t2.micro"
  key_name               = "frankfurt"
  subnet_id              = aws_subnet.Primary_Subnet.id
  vpc_security_group_ids = [aws_security_group.SG_Primary_VPC.id]
  user_data              = file("userdata.sh")
  tags = {
    Name = "Server_1"
  }
}
resource "aws_instance" "Server_2" {
  ami                    = "ami-0c2b1c303a2e4cb49"
  instance_type          = "t2.micro"
  key_name               = "frankfurt"
  subnet_id              = aws_subnet.Secondary_Subnet.id
  vpc_security_group_ids = [aws_security_group.SG_Primary_VPC.id]
  user_data              = file("userdata.sh")
  tags = {
    Name = "Server_2"
  }
}

resource "aws_elb" "MainLB" {
  name               = "MainLB"
  subnets            =   [aws_subnet.Primary_Subnet.id,  aws_subnet.Secondary_Subnet.id,]
  #availability_zones = ["eu-central-1a", "eu-central-1b"]
  security_groups     = [aws_security_group.SG_Primary_VPC.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }

  instances                   = [aws_instance.Server_1.id, aws_instance.Server_2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


}
