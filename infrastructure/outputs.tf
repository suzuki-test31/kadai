#================================================
# Outputs
#================================================
output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.handson.dns_name
}