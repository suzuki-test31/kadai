# パスワードの自動生成
resource "random_password" "db" {
  length  = 16
  special = false
}

# シークレットの器
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "db-password-" # 名前重複回避のためprefixを推奨
}

# 値の保存
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}