# Store state file in S3
terraform {
  backend "s3" {
    bucket = "vinit-905418074680"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

#resource "aws_ecr_repository" "flask_repo" {
#  name                 = "flask-backend"
#  image_tag_mutability = "MUTABLE"
#}

#resource "aws_ecr_repository" "node_repo" {
#  name                 = "node-frontend"
#  image_tag_mutability = "MUTABLE"
#}


# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "myvpc"
  }
}


# public subnet-1a
resource "aws_subnet" "publicSubnet1a" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.publicSubnet1a_cidr_block
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

# public subnet-1b
resource "aws_subnet" "publicSubnet1b" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.publicSubnet1b_cidr_block
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}


# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}


# Public Route Tables
resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


# Associate the public subnets-1a with the public route table
resource "aws_route_table_association" "public_subnet_association1a" {
  subnet_id      = aws_subnet.publicSubnet1a.id
  route_table_id = aws_route_table.publicRouteTable.id
}

# Associate the public subnets-1b with the public route table
resource "aws_route_table_association" "public_subnet_association1b" {
  subnet_id      = aws_subnet.publicSubnet1b.id
  route_table_id = aws_route_table.publicRouteTable.id
}


# Security Group for Load Balancer for both FE & BE 
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
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
}


# Security Group for ECS Services
resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ALB for frontend
resource "aws_alb" "application_load_balancer" {
  name               = "frontend-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.publicSubnet1a.id, aws_subnet.publicSubnet1b.id]
  security_groups    = [aws_security_group.load_balancer_security_group.id]
}

# ALB for backend
resource "aws_alb" "backend_alb" {
  name               = "backend-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.publicSubnet1a.id, aws_subnet.publicSubnet1b.id]
  security_groups    = [aws_security_group.load_balancer_security_group.id]
}


# Frontend target group
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.myvpc.id
}

# Backend target group
resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.myvpc.id
}


# Frontend listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# Backend listener
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_alb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}


# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "app-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/app"
  retention_in_days = 7
}


# Frontend Task Definitions
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = "arn:aws:iam::905418074680:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "http://${aws_alb.backend_alb.dns_name}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = "arn:aws:iam::905418074680:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])
}


# Frontend ECS Services
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  network_configuration {
    subnets          = [aws_subnet.publicSubnet1a.id, aws_subnet.publicSubnet1b.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }
}

# Backend ECS Services
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1


  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "backend"
    container_port   = 8000
  }

  network_configuration {
    subnets          = [aws_subnet.publicSubnet1a.id, aws_subnet.publicSubnet1b.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }
}


### Dashboard
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "ecs-metrics-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.my_cluster.name, "ServiceName", aws_ecs_service.frontend_service.name ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ],
          ]
          view = "timeSeries"
          stacked = false
          region = "ap-south-1"
          title = "CPU and Memory Utilization"
        }
      }
    ]
  })
}
