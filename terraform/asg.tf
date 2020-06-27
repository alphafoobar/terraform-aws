locals {
  development_instance_override = [
    {
      type = "t3.nano"
      weight = 5
    },
    {
      type = "t3.micro"
      weight = 3
    },
    {
      type = "t3.small"
      weight = 1
    }
  ]
}

resource "aws_security_group" "allow-vpc-traffic-for-ec2" {
  name        = "bnc-allow-vpc"
  description = "Allow all internal traffic for ec2 instance"
  vpc_id      = module.vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }
  ingress {
    from_port        = 0
    to_port          = 0
    protocol        = "tcp"
    security_groups = [
      aws_security_group.allow-lb-traffic.id
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

resource "aws_launch_template" "launch-template" {
  name_prefix = "kaizen-ecs-"
  description = "Launch template for cluster"
  image_id = data.aws_ami.latest-amazon-linux-2.image_id
  instance_type = "t3.nano"
  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs-profile.arn
  }
  vpc_security_group_ids = [
    aws_security_group.allow-vpc-traffic-for-ec2.id
  ]
  instance_initiated_shutdown_behavior = "terminate"
  user_data = base64encode(templatefile("${path.module}/templates/cloud_init.yml", {
    cloudwatch_agent_configuration = base64encode(templatefile("${path.module}/templates/agent_configuration.json", {}))
    cluster_name = aws_ecs_cluster.kaizen-ecs.id,
    log_drivers = "[\"awslogs\",\"fluentd\",\"json-file\",\"splunk\"]",
    instance_attributes = "{\"kaizen_group\": \"kaizen\"}"
  }))
  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
  tag_specifications {
    resource_type = "volume"
    tags = local.tags
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

resource "aws_autoscaling_group" "autoscaling-group" {
  // We want a new name when the launch template updates, otherwise the changes won't be applied to the autoscaling group.
  // This is a known issue in Terraform and this work around ensures the autoscaling is updated without any outage.
  name = "${aws_launch_template.launch-template.name}-${aws_launch_template.launch-template.latest_version}"

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity = 1
      on_demand_percentage_above_base_capacity = 50
      spot_allocation_strategy = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch-template.id
        version = aws_launch_template.launch-template.latest_version
      }

      dynamic "override" {
        for_each = local.development_instance_override
        content {
          instance_type = override.value["type"]
          weighted_capacity = override.value["weight"]
        }
      }
    }
  }

  termination_policies = [
    "OldestLaunchTemplate",
    "Default"
  ]
  desired_capacity = 2
  min_size = 1
  max_size = 12
  vpc_zone_identifier = module.vpc.public_subnets[*].id
  tag {
    key = "Name"
    value = "${aws_launch_template.launch-template.name}-${aws_launch_template.launch-template.latest_version}"
    propagate_at_launch = true
  }
}
