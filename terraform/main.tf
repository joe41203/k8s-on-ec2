resource "aws_key_pair" "k8s_app" {
  key_name   = "k8s-app"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAPtyH+jWd1Xkw8fujWOJ1gs6avAy37zitKg9Be0TTb0nQPnuvBCIYoJWci5VoeMClG0XR3GO/LkEPpguwsMzgjyJF+WXbDjLT+/NuE1v4fLh/yJAiPyhOe1I/EUM5XGqDKyRS6LxkIitjYh+x71Uv3XpOtSAuGjZclSYju+jT/0CTyDgKLwefbTCXLO71IYAy+paGDZYHdtE38OmsQWJXrsTILnO96RLf0awHEa5yu31xWDTDQ+HciKZjAJGL9ciT1gEgdC0ktn9aPnmMuBvsgoAkL60embPM4Q8E0EmvwAm4xdDDHSo2e39hDnEU+2+8cj2IN6lN2zBbjvYau8lYzC9/jd6+ucqyz5FuFPD3g0FRpEX2znJf0NTNKkEV+W34h1wct8VkRtLDR+fgmrvrL70x8F3kyLjaZmmYcWtQfWkeGikirBI9OmAmo8AKvJnGrjrPewDjuIvtPePXqsF/m4O62pdLhxB9qydyWdu39GDEaHODEzE7IGztXtqb0SfIsLferdTW3DGaWFU9qL19G2hDJWwDlOWazEuFAlOVZgfpxvRQnnyUbIdtOlg2WbckjMeAqyKmi23+zkwZI5hNFYzdahtefo9B7dKFjCpj4tiR/Gwv/5GXn+4pkEW5yEvG4JXulLUTP4akVzuDNmxEzRfhmpHQTw7s4BSiWZ/gKw=="
}

data "template_file" "user_data" {
  template = "${file("./user_data.sh")}"
}

resource "aws_instance" "k8s_app" {
  ami                         = "ami-0ce107ae7af2e92b5"
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.k8s_app.key_name
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  tags = {
    Name = "k8s-app"
  }
}
