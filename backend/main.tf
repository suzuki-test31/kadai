terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# ランダムなサフィックス（バケット名の一意性確保）
resource "random_id" "suffix" {
  byte_length = 4
}

# S3バケット（tfstate保存用）
resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-handson-${random_id.suffix.hex}"

  tags = {
    Name    = "Terraform State"
    Purpose = "tfstate"
  }
}

# バージョニング有効化
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# パブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDBテーブル（ロック用）
resource "aws_dynamodb_table" "tflock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "Terraform Lock"
    Purpose = "tfstate-lock"
  }
}

# 出力
output "s3_bucket_name" {
  description = "S3 bucket name for tfstate"
  value       = aws_s3_bucket.tfstate.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for lock"
  value       = aws_dynamodb_table.tflock.name
}

# CICD Demo Trigger
