resource "aws_security_group" "ecs_sg" {
  name   = "${var.project_name}-ecs-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-app-repo"
  image_tag_mutability = "MUTABLE" # risky - for production use immutable

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" #fill in the correct ARN for your region
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "my-container"
    image     = "${aws_ecr_repository.app_repo.repository_url}:latest" #replace with image tag
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      { name = "REGION", value = var.aws_region },
      { name = "CLOUD_PROVIDER", value = "aws" },
      { name = "PORT", value = tostring(var.container_port) }
    ]
  }])
}

resource "aws_ecs_service" "app_service" {
  name                              = "${var.project_name}-service"
  cluster                           = aws_ecs_cluster.main_cluster.id
  task_definition                   = aws_ecs_task_definition.app_task.arn
  desired_count                     = 2
  count                             = var.create_ecs_service ? 1 : 0
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "my-container"
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.project_name}-log-group"
  retention_in_days = 7
}
