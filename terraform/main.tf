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
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.nginx.id,
    aws_security_group.common.id,
    aws_security_group.ssh.id
  ]

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "k8s-node"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = module.network.public_subnets


  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}
