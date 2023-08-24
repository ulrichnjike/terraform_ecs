resource "aws_ecs_cluster" "web-cluster" {
  name = "web-cluster"

}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "web-container"
      image     = "nginx" #choose your web app image
      content_type     = "text/plain"
      message_body     = "Hello, DevOps!"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}


resource "aws_lb" "alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = ["sg-06c866f3b338c7d94"] # choose your security goup
  subnets            = ["subnet-12345678", "subnet-87654321"]  # Replace with your subnet IDs

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-12345678"  # Replace with your VPC ID
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    type             = "forward"
  }
}

resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = ["subnet-12345678", "subnet-87654321"]  # Replace with your subnet IDs
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    container_name   = "web-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.alb_listener]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "web-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = "60"
  statistic          = "Average"
  threshold          = "75"
  alarm_description = "Scale up if CPU utilization is greater than 75%"
  alarm_actions     = [aws_appautoscaling_policy.scale_up_policy.arn]
  dimensions = {
    ServiceName = aws_ecs_service.web_service.name
    ClusterName = aws_ecs_cluster.web-cluster.name
  }
}

resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "web-cpu-scale-up-policy"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.web-cluster.id}/${aws_ecs_service.web_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = aws_ecs_service.web_service.cluster

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

