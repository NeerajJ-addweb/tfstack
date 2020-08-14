module "mongo-task-definition" {
  source = "github.com/mongodb/terraform-aws-ecs-task-definition"
  network_mode = "awsvpc"
  family = "${var.serviceBaseName}Service-task"
  //image  = "${var.registryUrl}/ca-${serviceBasename}:latest"
  image = "${var.registryUrl}/basehealthimage:latest"
  memory = var.memory
  cpu = var.cpu
  requires_compatibilities = [
    "FARGATE",
  ]
  name   = var.serviceBaseName
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  portMappings = [
    {
      containerPort = 80
    },
  ]
}
resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.serviceBaseName}-${var.EnvironmentName}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    interval = 35
    path = "/healthcheck.php"
    protocol = "HTTP"
    timeout = 30
    matcher = "200,202"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags
  {
    
  }
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