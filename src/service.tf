module "services" {
  source = "../modules/service"
  for_each = var.service_names
  network_mode = "awsvpc"
  family = "${each.key}-Service-task"
  //image  = "${var.registryUrl}/ca-${serviceBasename}:latest"
  # image = "${var.registryUrl}/basehealthimage:latest"
  image = "paulbouwer/hello-kubernetes:1.8"
  vpc_id = aws_vpc.main.id
  lb_dns_name = aws_lb.loadbalancer.dns_name
  root_domain = var.root_domain
  tg_http_port = 80
  container_port = 8080
  cluster = aws_ecs_cluster.ecs.id
  desired_count = 1
  security_groups = [aws_security_group.lb_sg.id]
  subnets = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]
  listener_arn_http = aws_lb_listener.alb_listener.arn

  listener_rule_priority = each.value
  environment = [
    {
      "Name" = "MESSAGE"
      "Value" = each.key
    },
  ]
  memory = var.memory
  cpu = var.cpu
  requires_compatibilities = [
    "FARGATE",
  ]
  name   = each.key
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

