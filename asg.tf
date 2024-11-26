data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Generate random strings for WordPress authentication keys and salts
resource "random_string" "auth_key" {
  length  = 64
  special = true
}

resource "random_string" "secure_auth_key" {
  length  = 64
  special = true
}

resource "random_string" "logged_in_key" {
  length  = 64
  special = true
}

resource "random_string" "nonce_key" {
  length  = 64
  special = true
}

resource "random_string" "auth_salt" {
  length  = 64
  special = true
}

resource "random_string" "secure_auth_salt" {
  length  = 64
  special = true
}

resource "random_string" "logged_in_salt" {
  length  = 64
  special = true
}

resource "random_string" "nonce_salt" {
  length  = 64
  special = true
}

# Template for wp-config.php
data "template_file" "wp_config" {
  template = file("${path.module}/template/wp-config.tpl")

  vars = {
    db_name         = var.db_name
    db_user         = var.db_username
    db_password     = var.db_password
    db_host         = aws_db_instance.main.endpoint
    db_charset      = "utf8mb4"
    db_collate      = ""
    auth_key        = random_string.auth_key.result
    secure_auth_key = random_string.secure_auth_key.result
    logged_in_key   = random_string.logged_in_key.result
    nonce_key       = random_string.nonce_key.result
    auth_salt        = random_string.auth_salt.result
    secure_auth_salt = random_string.secure_auth_salt.result
    logged_in_salt   = random_string.logged_in_salt.result
    nonce_salt       = random_string.nonce_salt.result
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.environment}-wordpress-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx php-fpm php-mysql

              # Install SSM Agent (if not pre-installed)
              apt-get install -y amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent

              # Install WordPress
              wget https://wordpress.org/latest.tar.gz
              tar -xzf latest.tar.gz
              mv wordpress/* /var/www/html/

              # Configure Nginx
              cat > /etc/nginx/sites-available/default <<EOL
              server {
                  listen 80 default_server;
                  root /var/www/html;
                  index index.php index.html;

                  location / {
                      try_files \$uri \$uri/ /index.php?\$args;
                  }

                  location ~ \.php$ {
                      include snippets/fastcgi-php.conf;
                      fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
                  }
              }
              EOL

              systemctl restart nginx
              systemctl restart php8.1-fpm

              # Write wp-config.php
              echo "${data.template_file.wp_config.rendered}" > /var/www/html/wp-config.php
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-wordpress"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name                      = "${var.environment}-wordpress-asg"
  target_group_arns         = [aws_lb_target_group.main.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = aws_subnet.private[*].id

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }
  depends_on = [aws_launch_template.main]

  tag {
    key                 = "Name"
    value               = "${var.environment}-wordpress"
    propagate_at_launch = true
  }
}