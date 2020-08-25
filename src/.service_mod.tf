module "ecs-task-definition" {
  source = "../modules/service"
  network_mode = "awsvpc"
  family = "${var.serviceBaseName}Service-task"
  //image  = "${var.registryUrl}/ca-${serviceBasename}:latest"
  # image = "${var.registryUrl}/basehealthimage:latest"
  image = "paulbouwer/hello-kubernetes:1.8"
  vpc_id = aws_vpc.main.id
  root_domain = var.root_domain
  tg_http_port = 80
  container_port = 8080
  desired_count = 1
  security_groups = [aws_security_group.lb_sg.id]
  subnets = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]

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