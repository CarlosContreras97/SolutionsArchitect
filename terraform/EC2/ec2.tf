resource "aws_instance" "WSLabInstance"{
    ami = var.ami
    instance_type = var.instance_type
    key_name = aws_key_pair.access_key.key_name
    root_block_device {
      volume_type ="gp3"
      volume_size = "8"
    }
    user_data = <<-EOT
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>hello world from $(hostname -f)</h1>" > /var/www/html/index.html
EOT
    vpc_security_group_ids = [aws_security_group.SGAllowSSH_HTTP.id]
    #subnet_id = aws_subnet.main-sub.id
}

resource "aws_default_vpc" "main"{}

resource "aws_key_pair" "access_key"{
    key_name = "AWSSAATerraformKey.pem"
    public_key = file("~/.ssh/AWSSAATerraformKey.pem")
}

resource "aws_security_group" "SGAllowSSH_HTTP"{
    name= "allow_ssh_http"
    description = "allow inbound http traffic and ssh access to instance"
    #using default vpc
    vpc_id = aws_default_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "allow_external_data"{
    security_group_id = aws_security_group.SGAllowSSH_HTTP.id
    cidr_ipv4="0.0.0.0/0"
    from_port=0
    to_port =0
    ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh"{
    security_group_id = aws_security_group.SGAllowSSH_HTTP.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http"{
    security_group_id = aws_security_group.SGAllowSSH_HTTP.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
}

/*resource "aws_subnet" "main-sub"{
    vpc_id=aws_default_vpc.main.id
    cidr_block = "172.31.0.0/24"
}*/