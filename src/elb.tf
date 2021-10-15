module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.5.0"

  name = "elb-${var.app_name}"

  subnets         = data.aws_subnet_ids.subnets_private.ids
  security_groups = [aws_security_group.sg_elb.id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    },
    {
      instance_port     = 443
      instance_protocol = "http"
      lb_port           = 443
      lb_protocol       = "https"
    },
  ]

  health_check = {
    target              = "http:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  access_logs = {
    bucket = aws_s3_bucket.elb_logs.id
  }
}

resource "aws_s3_bucket" "elb_logs" {
  bucket        = "elb-${var.app_name}_logs"
  acl           = "private"
  force_destroy = true
}

resource "aws_security_group" "sg_elb" {
  name        = "sg-elb"
  description = "Allow https inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
