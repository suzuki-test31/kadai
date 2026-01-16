resource "aws_db_subnet_group" "handson" {
  name       = "handson-db-subnet"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]
}

resource "aws_db_instance" "handson" {
  identifier_prefix      = "handson-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.handson.name
  vpc_security_group_ids = [aws_security_group.db.id]
  username               = "admin"

  # secrets.tf で定義したリソースを直接参照
  password               = aws_secretsmanager_secret_version.db_password.secret_string

  skip_final_snapshot    = true
}