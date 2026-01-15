# ================================================
# 1. IAM Role & Profile (EC2がECRやSSMを使うための権限)
# ================================================
resource "aws_iam_role" "web_role" {
  name = "web-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# SSM（デプロイ操作）と ECR（イメージ取得）の権限を付与
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EC2インスタンスにロールを渡すための「プロフィール」
resource "aws_iam_instance_profile" "web_profile" {
  name = "web-instance-profile"
  role = aws_iam_role.web_role.name
}

# ================================================
# 2. AMIの取得 (Amazon Linux 2)
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
# 3. EC2 インスタンスの設定
# ================================================

# インスタンス A (us-west-2a)
resource "aws_instance" "web_a" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # 上で作ったインスタンスプロフィールを紐付け
  iam_instance_profile   = aws_iam_instance_profile.web_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = { Name = "web-2a" }
}

# インスタンス B (us-west-2b)
resource "aws_instance" "web_b" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_b.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  iam_instance_profile   = aws_iam_instance_profile.web_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = { Name = "web-2b" }
}