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
# EC2 インスタンスの設定
# ================================================

resource "aws_instance" "web_a" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # 上で作ったプロフィールを紐付け
  iam_instance_profile   = "GitHubActionsRole"

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
  
  iam_instance_profile   = "GitHubActionsRole"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              usermod -a -G docker ec2-user
              EOF
  tags = { Name = "web-2b" }
}