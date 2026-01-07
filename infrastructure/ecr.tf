resource "aws_ecr_repository" "app" {
  name                 = "handson-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Name = "handson-app"
  }
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}
