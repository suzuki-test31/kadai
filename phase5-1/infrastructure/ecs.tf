#================================================
# ECS Cluster
#================================================
resource "aws_ecs_cluster" "handson" {
  name = "handson-cluster"
}

#================================================
# ECS Task Definition
#================================================
resource "aws_ecs_task_definition" "handson" {
  family                   = "handson-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/handson"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

#================================================
# ECS Service
#================================================
resource "aws_ecs_service" "handson" {
  name            = "handson-service"
  cluster         = aws_ecs_cluster.handson.id
  task_definition = aws_ecs_task_definition.handson.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.handson.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.handson]
}
