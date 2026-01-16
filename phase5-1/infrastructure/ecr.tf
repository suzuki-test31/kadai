resource "aws_ecr_repository" "app" {
  name                 = "kadai-app-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Name = "kadai-app-repo"
  }
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}
