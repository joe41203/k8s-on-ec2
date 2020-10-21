resource "aws_security_group" "http" {
  name   = "k8s-http"
  vpc_id = module.network.vpc_id
}

resource "aws_security_group" "nginx" {
  name   = "k8s-nginx"
  vpc_id = module.network.vpc_id
}

resource "aws_security_group" "https" {
  name   = "k8s-https"
  vpc_id = module.network.vpc_id
}

resource "aws_security_group" "common" {
  name   = "k8s-common"
  vpc_id = module.network.vpc_id
}

resource "aws_security_group" "ssh" {
  name   = "k8s-ssh"
  vpc_id = module.network.vpc_id
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.http.id
}

resource "aws_security_group_rule" "nginx_ingress" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 30000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nginx.id
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.https.id
}

resource "aws_security_group_rule" "common_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "common_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh.id
}
