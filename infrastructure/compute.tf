#================================================
# AMI
#================================================
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#================================================
# EC2
#================================================
resource "aws_instance" "web_a" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  # 【重要】この行を追加して、作成したIAMロールをEC2に付与します
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 --name nginx nginx:latest
              EOF
  tags = {
    Name = "web-2a"
  }
}

resource "aws_instance" "web_b" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_b.id
  vpc_security_group_ids = [aws_security_group.web.id]
  # 【重要】こちらにも同様に追加
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 --name nginx nginx:latest
              EOF
  tags = {
    Name = "web-2b"
  }
}
# 1. IAM ロールの作成
resource "aws_iam_role" "ssm_role" {
  name = "handson-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. AWS管理ポリシー（SSMManagedInstanceCore）をアタッチ
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. EC2が使用できる形（インスタンスプロフィール）にする
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "handson-ssm-profile"
  role = aws_iam_role.ssm_role.name
}