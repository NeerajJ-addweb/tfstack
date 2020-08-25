#Service Deployment
module "ecs-task-definition" {
  source = "github.com/mongodb/terraform-aws-ecs-task-definition"
  network_mode = "awsvpc"
  family = "${var.serviceBaseName}Service-task"
  //image  = "${var.registryUrl}/ca-${serviceBasename}:latest"
  # image = "${var.registryUrl}/basehealthimage:latest"
  image = "paulbouwer/hello-kubernetes:1.8"
  environment = [
    {
      "Name" = "MESSAGE"
      "Value" = var.serviceBaseName
    },
  ]
  memory = var.memory
  cpu = var.cpu
  requires_compatibilities = [
    "FARGATE",
  ]
  name   = var.serviceBaseName
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  portMappings = [
    {
      containerPort = 8080
    },
  ]
  tags = {
    Environment = "${var.EnvironmentName}"
  }
}
resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = module.ecs-task-definition.arn
  desired_count   = 1
  launch_type = "FARGATE"
  health_check_grace_period_seconds = 60
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.serviceBaseName
    container_port   = 8080
  }

  network_configuration {
    subnets = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]
    security_groups = [aws_security_group.lb_sg.id]
    assign_public_ip = true
  }
  depends_on = [aws_lb_listener_rule.base]
}
resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.serviceBaseName}-${var.EnvironmentName}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  lifecycle {
        create_before_destroy = true
    }
  deregistration_delay = 30
  health_check {
    interval = 300
    # path = "/healthcheck.php" 
    path = "/"
    protocol = "HTTP"
    timeout = 120
    matcher = "200,202"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = {
    Environment = "${var.EnvironmentName}"
  }
}


# Service Networking
data "aws_route53_zone" "selected" {
  name         = "${var.root_domain}."
  private_zone = false
}
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
  
}
resource "aws_lb_listener_rule" "base" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    host_header {
      values = ["${var.serviceBaseName}.${var.root_domain}"]
    }
  }
}
resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.serviceBaseName}.${var.root_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.loadbalancer.dns_name]
}