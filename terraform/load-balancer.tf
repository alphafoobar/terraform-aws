resource "aws_lb" "public-lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
    aws_security_group.allow-public-http.id
  ]
  lifecycle {
    create_before_destroy = true
  }
  subnets            = module.vpc.public_subnets[*].id
  tags               = local.tags
}

resource "aws_lb_listener" "public-lb-listener" {
  load_balancer_arn = aws_lb.public-lb.arn
  port              = "80"
  protocol          = "HTTP"
  lifecycle {
    create_before_destroy = true
  }
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
      message_body = "hello world! ${terraform.workspace}"
    }
  }
}

resource "aws_security_group" "allow-lb-traffic" {
  name        = "bnc-allow-lb"
  description = "Allow inbound ALB traffic to ports 80"
  vpc_id      = module.vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [
      aws_security_group.allow-public-http.id
    ]
  }
  tags = local.tags
}

resource "aws_security_group" "allow-public-http" {
  name        = "allow_public"
  description = "Allow inbound http traffic"
  vpc_id      = module.vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [
      "0.0.0.0/0"
    ]
    ipv6_cidr_blocks = [
      "::/0"
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [
      "0.0.0.0/0"
    ]
    ipv6_cidr_blocks = [
      "::/0"
    ]
  }
  tags = local.tags
}
