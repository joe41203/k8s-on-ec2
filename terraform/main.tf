resource "aws_key_pair" "k8s_app" {
  key_name   = "k8s-app"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAPtyH+jWd1Xkw8fujWOJ1gs6avAy37zitKg9Be0TTb0nQPnuvBCIYoJWci5VoeMClG0XR3GO/LkEPpguwsMzgjyJF+WXbDjLT+/NuE1v4fLh/yJAiPyhOe1I/EUM5XGqDKyRS6LxkIitjYh+x71Uv3XpOtSAuGjZclSYju+jT/0CTyDgKLwefbTCXLO71IYAy+paGDZYHdtE38OmsQWJXrsTILnO96RLf0awHEa5yu31xWDTDQ+HciKZjAJGL9ciT1gEgdC0ktn9aPnmMuBvsgoAkL60embPM4Q8E0EmvwAm4xdDDHSo2e39hDnEU+2+8cj2IN6lN2zBbjvYau8lYzC9/jd6+ucqyz5FuFPD3g0FRpEX2znJf0NTNKkEV+W34h1wct8VkRtLDR+fgmrvrL70x8F3kyLjaZmmYcWtQfWkeGikirBI9OmAmo8AKvJnGrjrPewDjuIvtPePXqsF/m4O62pdLhxB9qydyWdu39GDEaHODEzE7IGztXtqb0SfIsLferdTW3DGaWFU9qL19G2hDJWwDlOWazEuFAlOVZgfpxvRQnnyUbIdtOlg2WbckjMeAqyKmi23+zkwZI5hNFYzdahtefo9B7dKFjCpj4tiR/Gwv/5GXn+4pkEW5yEvG4JXulLUTP4akVzuDNmxEzRfhmpHQTw7s4BSiWZ/gKw=="
}

data "template_file" "user_data" {
  template = "${file("./user_data.sh")}"
}

resource "aws_launch_template" "template" {
  name                                 = "k8s-template"
  ebs_optimized                        = true
  image_id                             = "ami-0ce107ae7af2e92b5"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.small"
  key_name                             = aws_key_pair.k8s_app.key_name
  user_data                            = base64encode(data.template_file.user_data.rendered)

  vpc_security_group_ids = [
    aws_security_group.common.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.k8s_profile.name
  }

  monitoring {
    enabled = false
  }
}

resource "aws_autoscaling_group" "master" {
  name                = "k8s-master"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = module.network.private_subnets
  target_group_arns   = [aws_lb_target_group.front_end.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "k8s-master"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "worker" {
  name                = "k8s-node"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = module.network.private_subnets

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "k8s-node"
    propagate_at_launch = true
  }
}


resource "aws_iam_instance_profile" "k8s_profile" {
  name = "k8s-profile"
  role = aws_iam_role.server_role.name
}

resource "aws_iam_role" "server_role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_lb" "front_end" {
  name               = "k8s-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.common.id,
    aws_security_group.ssh.id
  ]

  subnets                    = module.network.public_subnets
  enable_deletion_protection = false
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "k8s-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
}
