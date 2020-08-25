module "content" {
  source = "../modules/service"
  network_mode = "awsvpc"
  family = "content-Service-task"
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
  listener_rule_priority = 100
  listener_arn_http = aws_lb_listener.alb_listener.arn
  environment = [
    {
      "Name" = "MESSAGE"
      "Value" = "content"
    },
  ]
  memory = var.memory
  cpu = var.cpu
  requires_compatibilities = [
    "FARGATE",
  ]
  name   = "content"
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
output "content-endpoint" {
  value = module.content.service-endpoint
}