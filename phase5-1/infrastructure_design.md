                    ┌─────────────────────────────────────────────────────────────┐
                    │                          VPC                                 │
                    │                     10.0.0.0/16                              │
                    │                                                              │
┌──────────┐        │  ┌─────────────────────────────────────────────────────┐    │
│          │        │  │              パブリックサブネット                      │    │
│ Internet │◄──────►│  │  ┌─────────────────┐    ┌─────────────────┐         │    │
│          │        │  │  │ public-1a       │    │ public-1c       │         │    │
└──────────┘        │  │  │ 10.0.1.0/24     │    │ 10.0.2.0/24     │         │    │
     │              │  │  │                 │    │                 │         │    │
     │              │  │  │ ┌─────────────┐ │    │ ┌─────────────┐ │         │    │
     ▼              │  │  │ │ NAT Gateway │ │    │ │ NAT Gateway │ │         │    │
┌──────────┐        │  │  │ └─────────────┘ │    │ └─────────────┘ │         │    │
│   ALB    │        │  │  └─────────────────┘    └─────────────────┘         │    │
│ Port:80  │        │  └─────────────────────────────────────────────────────┘    │
└──────────┘        │                                                              │
     │              │  ┌─────────────────────────────────────────────────────┐    │
     │              │  │              プライベートサブネット                    │    │
     ▼              │  │  ┌─────────────────┐    ┌─────────────────┐         │    │
┌──────────┐        │  │  │ private-1a      │    │ private-1c      │         │    │
│ Target   │        │  │  │ 10.0.11.0/24    │    │ 10.0.12.0/24    │         │    │
│ Group    │───────►│  │  │                 │    │                 │         │    │
│ Port:80  │        │  │  │ ┌─────────────┐ │    │ ┌─────────────┐ │         │    │
└──────────┘        │  │  │ │ECS Fargate  │ │    │ │ECS Fargate  │ │         │    │
     │              │  │  │ │  Task       │ │    │ │  Task       │ │         │    │
     │              │  │  │ │ (Nginx)     │ │    │ │ (Nginx)     │ │         │    │
     │              │  │  │ └─────────────┘ │    │ └─────────────┘ │         │    │
     │              │  │  └─────────────────┘    └─────────────────┘         │    │
     │              │  │                                                      │    │
     │              │  │  ┌─────────────────────────────────────────────┐    │    │
     │              │  │  │           RDSサブネットグループ               │    │    │
     │              │  │  │  ┌─────────────────┐ ┌─────────────────┐   │    │    │
     │              │  │  │  │ db-1a           │ │ db-1c           │   │    │    │
     │              │  │  │  │ 10.0.21.0/24    │ │ 10.0.22.0/24    │   │    │    │
     │              │  │  │  └─────────────────┘ └─────────────────┘   │    │    │
     │              │  │  │         ┌─────────────────┐                │    │    │
     │              │  │  │         │      RDS        │                │    │    │
     │              │  │  │         │  MySQL 8.0      │                │    │    │
     │              │  │  │         │  Port:3306      │                │    │    │
     │              │  │  │         └─────────────────┘                │    │    │
     │              │  │  └─────────────────────────────────────────────┘    │    │
     │              │  └─────────────────────────────────────────────────────┘    │
     │              └─────────────────────────────────────────────────────────────┘
     │
     │              ┌─────────────────────────────────────────────────────────────┐
     │              │                    ECS Cluster                               │
     │              │  ┌──────────────────────────────────────────────────────┐   │
     │              │  │                   ECS Service                         │   │
     └─────────────►│  │  desired_count: 2                                     │   │
                    │  │  launch_type: FARGATE                                 │   │
                    │  │  ┌─────────────────────────────────────────────────┐  │   │
                    │  │  │              Task Definition                     │  │   │
                    │  │  │  CPU: 256 (.25 vCPU)                            │  │   │
                    │  │  │  Memory: 512 MB                                 │  │   │
                    │  │  │  Container: nginx:latest                        │  │   │
                    │  │  │  Port: 80                                       │  │   │
                    │  │  └─────────────────────────────────────────────────┘  │   │
                    │  └──────────────────────────────────────────────────────┘   │
                    └─────────────────────────────────────────────────────────────┘
リソース一覧
カテゴリ	リソース	名前	設定値
VPC	aws_vpc	handson-vpc	10.0.0.0/16
サブネット	aws_subnet	public-2a	10.0.1.0/24, AZ: us-west-2a
サブネット	aws_subnet	public-2b	10.0.2.0/24, AZ: us-west-2b
サブネット	aws_subnet	private-2a	10.0.11.0/24, AZ: us-west-2a
サブネット	aws_subnet	private-2b	10.0.12.0/24, AZ: us-west-2b
サブネット	aws_subnet	db-2a	10.0.21.0/24, AZ: us-west-2a
サブネット	aws_subnet	db-2b	10.0.22.0/24, AZ: us-west-2b
ゲートウェイ	aws_internet_gateway	handson-igw	-
ゲートウェイ	aws_nat_gateway	nat-2a	public-2aに配置
ゲートウェイ	aws_nat_gateway	nat-2b	public-2bに配置
ALB	aws_lb	handson-alb	internet-facing, HTTP:80
ターゲットグループ	aws_lb_target_group	handson-tg	HTTP:80, target_type: ip
ECS	aws_ecs_cluster	handson-cluster	-
ECS	aws_ecs_task_definition	handson-task	CPU:256, Memory:512, Nginx
ECS	aws_ecs_service	handson-service	desired_count:2, FARGATE
RDS	aws_db_instance	handson-db	MySQL 8.0, db.t3.micro
RDS	aws_db_subnet_group	handson-db-subnet	db-2a, db-2b
Secrets	aws_secretsmanager_secret	db-password	DBパスワード
ECR	aws_ecr_repository	handson-app	カスタムイメージ用
IAM	aws_iam_role	ecs-task-execution-role	ECRアクセス、ログ出力
IAM	aws_iam_role	ecs-task-role	（必要に応じて）
CloudWatch	aws_cloudwatch_log_group	/ecs/handson	コンテナログ
セキュリティグループ
SG名	アタッチ先	インバウンド	アウトバウンド
alb-sg	ALB	0.0.0.0/0:80	all
ecs-sg	ECS Task	alb-sg:80	all
db-sg	RDS	ecs-sg:3306	all
ディレクトリ構成（推奨）
infrastructure/
├── main.tf           # provider, backend
├── network.tf        # VPC, Subnet, IGW, NAT, RouteTable
├── security.tf       # Security Groups
├── alb.tf            # ALB, Listener, Target Group
├── ecs.tf            # Cluster, Task Definition, Service
├── iam.tf            # ECS用IAMロール
├── database.tf       # RDS, Subnet Group
├── secrets.tf        # Secrets Manager
├── ecr.tf            # ECR
├── logs.tf           # CloudWatch Logs
└── outputs.tf        # 出力

課題1: Terraformでインフラを構築せよ
上記の構成図とリソース一覧を参考に、Terraformコードを作成せよ。

要件:

すべてのリソースをTerraformで作成すること
ECS Fargateでコンテナを2つ起動すること
ターゲットグループのtarget_typeは ip にすること
コンテナログをCloudWatch Logsに出力すること
RDSのパスワードはSecrets Managerで管理すること
ALBのDNS名でアクセスできること

課題2: CI/CDパイプラインを拡張せよ

以下を実現するワークフローを作成せよ。

要件:

PRを出すと terraform plan がコメントされる
mainにマージすると terraform apply が自動実行される
Dockerfile/index.htmlを変更すると：
Dockerイメージがビルド・プッシュされる
ECSサービスが新しいイメージで更新される

課題3: ECSデプロイの自動化
ECSサービスを新しいイメージで更新するワークフローを作成せよ。

ヒント: aws ecs update-service --force-new-deployment または新しいタスク定義を登録