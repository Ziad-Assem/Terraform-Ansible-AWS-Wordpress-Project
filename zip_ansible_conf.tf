resource "null_resource" "copy_key" {
  provisioner "local-exec" {
    command = "sudo cp ./ec2-ansible.pem ./ansible-config/"
  }
}

resource "null_resource" "post_deploy_file_transfer" {
  depends_on = [
    aws_instance.ansible_controlServer_virginia,
    aws_instance.mariadb_ohio,
    aws_instance.mariadb_virginia,
    aws_instance.wordpress_ohio,
    aws_instance.wordpress_virginia,
    null_resource.copy_key
  ]

  provisioner "file" {
    source      = "ansible-config"
    destination = "/home/ubuntu/ansible-config"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("ec2-ansible.pem")
      host        = aws_instance.ansible_controlServer_virginia.public_ip
    }
  }
}

resource "null_resource" "change_umask_for_key" {

  depends_on = [null_resource.copy_key, null_resource.post_deploy_file_transfer]

  provisioner "local-exec" {
    command = "ssh -i ./ec2-ansible.pem -o StrictHostKeyChecking=no ubuntu@${aws_instance.ansible_controlServer_virginia.public_ip} 'cp ansible-config/ec2-ansible.pem ~/.ssh/ec2-ansible.pem && chmod 400 ~/.ssh/ec2-ansible.pem'"
  }
}

resource "null_resource" "run_ansible_script_virginia" {

  depends_on = [
    null_resource.copy_key, 
    null_resource.wait_for_ssh_virginia, 
    null_resource.change_umask_for_key, 
    aws_instance.mariadb_ohio,
    aws_instance.wordpress_ohio,
    aws_instance.mariadb_virginia,
    aws_instance.wordpress_virginia,
    aws_internet_gateway.main_igw_virginia
    ]

  provisioner "local-exec" {
    command = "ssh -i ./ec2-ansible.pem -o StrictHostKeyChecking=no ubuntu@${aws_instance.ansible_controlServer_virginia.public_ip} ansible-playbook -i ansible-config/hosts.ini --limit virginia ansible-config/playbook_virginia.yaml --extra-vars \"wp_config_template=virginia-wp-config.php.j2\""
  }
}

resource "null_resource" "run_ansible_script_ohio" {

  depends_on = [null_resource.run_ansible_script_virginia]

  provisioner "local-exec" {
    command = "ssh -i ./ec2-ansible.pem -o StrictHostKeyChecking=no ubuntu@${aws_instance.ansible_controlServer_virginia.public_ip} ansible-playbook -i ansible-config/hosts.ini --limit ohio ansible-config/playbook_ohio.yaml --extra-vars \"wp_config_template=ohio-wp-config.php.j2\""
  }
}

resource "null_resource" "wait_for_ssh_virginia" {
  depends_on = [
    aws_instance.ansible_controlServer_virginia,
    aws_instance.mariadb_ohio,
    aws_instance.mariadb_virginia,
    aws_instance.wordpress_ohio,
    aws_instance.wordpress_ohio_b,
    aws_instance.wordpress_virginia,
    aws_instance.wordpress_virginia_b,
    null_resource.post_deploy_file_transfer
    ]

  provisioner "local-exec" {
    command = <<-EOT
      IP=${aws_instance.ansible_controlServer_virginia.public_ip}

      echo "Waiting for SSH on $IP..."
      until nc -z $IP 22; do
        echo "SSH not ready, retrying in 5 seconds..."
        sleep 5
      done

      echo "Checking if ansible-playbook is available..."
      until ssh -o StrictHostKeyChecking=no -i ./ec2-ansible.pem ubuntu@$IP "command -v ansible-playbook >/dev/null 2>&1"; do
        echo "ansible-playbook not found, retrying in 5 seconds..."
        sleep 5
      done

      echo "SSH is ready and ansible-playbook is installed."
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

