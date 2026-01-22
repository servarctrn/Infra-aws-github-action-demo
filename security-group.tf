# Security Group for Application Load Balancer
# Accepts HTTP and HTTPS from the internet, forwards to web servers
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere on the internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere on the internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic so ALB can forward to web servers
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# Security Group for Web Servers
# Only accepts HTTP from the load balancer, not directly from internet
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web server instances"
  vpc_id      = aws_vpc.main.id

  # Only allow HTTP from the load balancer security group
  # This prevents direct access to web servers from the internet
  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow all outbound for package updates and external API calls
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  }
}

# Security Group for RDS Database
# Only accepts MySQL connections from web servers
resource "aws_security_group" "database" {
  name        = "${var.environment}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  # Only allow MySQL from the web server security group
  # Database is completely inaccessible from the internet
  ingress {
    description     = "MySQL from web servers only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}