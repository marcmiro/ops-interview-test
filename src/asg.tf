resource "aws_launch_configuration" "launch_configuration" {
  name          = "launch_configuration-${var.app_name}"
  image_id      = var.instance_ami
  instance_type = "t2.micro"
  user_data     = "#!/bin/bash\ncurl -o /usr/local/bin/testapp-autoupdater -u user:tUkArsHqQX4A7Hk7 https://server.com/testapp-autoupdater "
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "asg-${var.app_name}"
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 6
  health_check_type         = "ELB"
  health_check_grace_period = 60
  launch_configuration = aws_launch_configuration.launch_configuration.id
  load_balancers      = module.elb_http.elb_name
  vpc_zone_identifier = data.aws_subnet_ids.subnets_private.ids

  warm_pool {
    pool_state                  = "Stopped"
    min_size                    = 3
    max_group_prepared_capacity = 6
  }

  tag {
    key                 = "InstanceGroup"
    value               = "instance-${var.app_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "InstanceGroupByRegion"
    value               = "instance-${var.app_name}-${var.region}"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "sg_asg" {
  name        = "sg-asg"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_elb.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_elb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
