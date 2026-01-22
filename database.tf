# DB subnet group defines which subnets RDS can use
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS MySQL instance with Multi-AZ for high availability
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-mysql"

  # Database configuration
  engine            = "mysql"
  engine_version    = "8.0.40"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Multi-AZ creates standby replica in different AZ
  multi_az = true

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  # Authentication
  username = var.db_username
  password = var.db_password

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Disable final snapshot for easier cleanup (change for production)
  skip_final_snapshot = true

  # Enable deletion protection in production
  deletion_protection = false

  tags = {
    Name        = "${var.environment}-mysql"
    Environment = var.environment
  }
}