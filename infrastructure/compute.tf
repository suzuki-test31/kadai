# ================================================
# AMIの取得
# ================================================
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ================================================
# IAM 設定（EC2がECRやSSMを使うための権限）
# ================================================

# 1. ロール本体
resource "aws_iam_role" "ssm_role" {
  name = "handson-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 2. 権限アタッチ（SSM操作権限）
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. 権限アタッチ（ECR読み取り権限）
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 4. EC2に適用するための「プロフィール」
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "handson-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# ================================================
# EC2 インスタンスの設定
# ================================================

resource "aws_instance" "web_a" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # 上で作ったプロフィールを紐付け
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              usermod -a -G docker ec2-user
              EOF
  tags = { Name = "web-2a" }
}

resource "aws_instance" "web_b" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_b.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              usermod -a -G docker ec2-user
              EOF
  tags = { Name = "web-2b" }
}