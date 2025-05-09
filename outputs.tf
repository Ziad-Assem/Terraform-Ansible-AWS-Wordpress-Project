output "account_id" { value = data.aws_caller_identity.current.account_id}
output "user_id" { value = data.aws_caller_identity.current.user_id}
output "arn" { value = data.aws_caller_identity.current.arn}

########################################################################################

output "ansible_controlServer_public_ip_virginia" { value = aws_instance.ansible_controlServer_virginia.public_ip }
output "wordpress_public_ip_virginia_A" { value = aws_instance.wordpress_virginia.public_ip }
output "wordpress_public_ip_virginia_B" { value = aws_instance.wordpress_virginia_b.public_ip }
output "wordpress_private_ip_virginia_A" { value = aws_instance.wordpress_virginia.private_ip}
output "wordpress_private_ip_virginia_B" { value = aws_instance.wordpress_virginia_b.private_ip}
output "mariadb_private_ip_virginia" { value = aws_instance.mariadb_virginia.private_ip }

#############################################################################################################

output "wordpress_public_ip_ohio_A" { value = aws_instance.wordpress_ohio.public_ip }
output "wordpress_private_ip_ohio" { value = aws_instance.wordpress_ohio.private_ip }
output "mariadb_private_ip_ohio" { value = aws_instance.mariadb_ohio.private_ip }
output "wordpress_public_ip_ohio_B" { value = aws_instance.wordpress_ohio_b.public_ip }
output "alb_sg_virginia_id" { value = aws_security_group.alb_sg_virginia.id }
output "alb_sg_ohio_id" { value = aws_security_group.alb_sg_ohio.id }


resource "local_file" "wp_db_php_file_virginia" {
  content = <<-DOC
    <?php
    define('DB_NAME', 'wordpress');
    define('DB_USER', 'zozz');
    define('DB_PASSWORD', '12341234');
    define('DB_HOST', '${aws_instance.mariadb_virginia.private_ip}');  // MariaDB EC2 IP
    define('DB_CHARSET', 'utf8');
    define('DB_COLLATE', '');

    $table_prefix = 'wp_';
    define('WP_DEBUG', false);

    if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

    require_once(ABSPATH . 'wp-settings.php');
    DOC
  filename = "ansible-config/roles/php_wordpress/templates/virginia-wp-config.php.j2"
}

resource "local_file" "wp_db_php_file_ohio" {
  content = <<-DOC
    <?php
    define('DB_NAME', 'wordpress');
    define('DB_USER', 'zozz');
    define('DB_PASSWORD', '12341234');
    define('DB_HOST', '${aws_instance.mariadb_ohio.private_ip}');  // MariaDB EC2 IP
    define('DB_CHARSET', 'utf8');
    define('DB_COLLATE', '');

    $table_prefix = 'wp_';
    define('WP_DEBUG', false);

    if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

    require_once(ABSPATH . 'wp-settings.php');
    DOC
  filename = "ansible-config/roles/php_wordpress/templates/ohio-wp-config.php.j2"
}

resource "local_file" "hosts_file_creation_for_ansible" {
  content = <<-DOC
    [virginia]
    wordpress_server_virginia ansible_host=${aws_instance.wordpress_virginia.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2-ansible.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    wordpress_server_virginia_b ansible_host=${aws_instance.wordpress_virginia_b.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2-ansible.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    db_server_virginia ansible_host=${aws_instance.mariadb_virginia.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2-ansible.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    
    [ohio]
    wordpress_server_ohio ansible_host=${aws_instance.wordpress_ohio.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2-ansible.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    wordpress_server_ohio_b ansible_host=${aws_instance.wordpress_ohio_b.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2-ansible.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'    
    db_server_ohio ansible_host=${aws_instance.mariadb_ohio.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2-ansible.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'

  DOC

  filename = "ansible-config/hosts.ini"
}


resource "local_file" "playbook_yaml_virginia" {
  content = <<-DOC
  - hosts: virginia
    become: yes
    vars:
      db_name: wordpress
      db_user: zozz
      db_password: 12341234
      db_host: ${aws_instance.mariadb_virginia.private_ip}
    roles:
      - apache
      - php_wordpress
      - mariadb
    DOC

  filename = "ansible-config/playbook_virginia.yaml"
}

resource "local_file" "playbook_yaml_ohio" {
  content = <<-DOC
  - hosts: ohio
    become: yes
    vars:
      db_name: wordpress
      db_user: zozz
      db_password: 12341234
      db_host: ${aws_instance.mariadb_ohio.private_ip}
    roles:
      - apache
      - php_wordpress
      - mariadb
    DOC

  filename = "ansible-config/playbook_ohio.yaml"
}