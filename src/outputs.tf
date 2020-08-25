output "aws_lb_dns" {
  value = aws_lb.loadbalancer.dns_name
}
