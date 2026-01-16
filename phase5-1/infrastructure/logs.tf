#================================================
# CloudWatch Log Group for ECS
#================================================
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/handson"
  retention_in_days = 30
}
