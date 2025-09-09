🚀 PROJECT OVERVIEW

project_name: "Hardened WordPress on LEMP Stack"
description: "Automated deployment of secure WordPress on Ubuntu 24.04"
main_playbook: "main-playbook.yaml"
inventory_file: "inventory"
vault_password_file: ".vault_pass.txt"

🧰 TECHNOLOGY and TOOLS:
  - 🔧 Automation: Ansible
  - 🌐 Web Server: Nginx
  - 💾 Database: MySQL 8.0
  - ⚙️ PHP Processing: PHP-FPM 8.3
  - 📝 CMS: WordPress
  - 🛡️ Security: UFW + Fail2Ban + Let's Encrypt
  - 🐧 OS: Ubuntu 24.04 LTS

=========================
 🚦 QUICK START
=========================

setup:
  prerequisites:
    - Control machine: Linux/macOS with Ansible
    - Target server: Ubuntu 24.04
    - SSH access to target server
    - Domain name pointing to server

  steps:
    - 1. 📝 Create inventory file:
      code: |
        [hardened_lemp_server]
        184.72.203.40  # Replace with your server IP
        
        [all:vars]
        ansible_user=ubuntu
        ansible_ssh_private_key_file=~/path/to/key.pem

    - 2. ⚙️ Configure variables:
      file: "group_vars/all.yml"
      example: |
        # System Configuration
        timezone: UTC
        domain_name: mywordpressite.zapto.org
        ssl_email: your@email.com
        
        # Database
        wordpress_db_name: hard_infra_wordpress
        wordpress_db_user: hard_infra_wpuser
        
        # Security
        ssh_port: 22
        fail2ban_enabled: true

    - 3. 🔐 Create encrypted secrets:
      command: "ansible-vault create group_vars/vault.yml"
      content: |
        vault_mysql_root_password: "RootStrongPassword123!"
        vault_wp_db_password: "StrongPassword123!"

    - 4. 🚀 Run playbook:
      command: "ansible-playbook -i inventory main-playbook.yaml --vault-password-file .vault_pass.txt"

 📂 FILE STRUCTURE
 |
  hardened-lemp-project/
  ├── 📄 README.yml                  # This documentation
  ├── 📄 main-playbook.yaml          # Main playbook
  ├── 📄 inventory                   # Server inventory
  ├── 🔐 .vault_pass.txt             # Ansible Vault password
  ├── group_vars/
  │   ├── 📄 all.yml                 # Public variables
  │   └── 🔐 vault.yml               # Encrypted secrets
  ├── roles/
  │   ├️ 📄 base-server-setup.yaml    # OS hardening
  │   ├️ 📄 configure-ufw.yaml        # Firewall setup
  │   ├️ 📄 nginx-installation.yaml   # Web server
  │   ├️ 📄 mysql-setup.yaml          # Database
  │   ├️ 📄 php-fpm.yaml              # PHP processor
  │   ├️ 📄 letsencrypt-ssl.yaml      # SSL certificates
  │   └️ 📄 wordpress-deployment.yaml # WordPress install
  └── templates/
      ├️ 📄 nginx-site.conf.j2        # Nginx config
      └️ 📄 wp-config.php.j2          # WordPress config

 🔒 SECURITY FEATURES

  server:
    - 🛡️ SSH hardening: Disabled root login, key auth only
    - 🔥 UFW firewall: Only ports 22, 80, 443 open
    - 🔄 Automatic security updates
    - 🚨 Fail2Ban intrusion prevention
  
  application:
    - 🔐 TLS 1.3 with modern ciphers
    - 📜 Security headers: CSP, X-XSS-Protection
    - 🧩 PHP-FPM process isolation"
    - 🔑 Database privilege separation
  
  wordpress:
    - 🔓 Secure file permissions (640 for wp-config.php)
    - 🔑 Salt keys for encryption
    - 🚫 Disabled file editing in admin
    - ⏱️ Limited login attempts

 ⚙️ MAINTENANCE COMMANDS

  update_system: "ansible-playbook main-playbook.yaml --tags common"
  renew_ssl: "ansible-playbook main-playbook.yaml --tags ssl"
  update_wordpress: "ansible-playbook main-playbook.yaml --tags wordpress"
  check_services: "ansible all -i inventory -m shell -a 'systemctl status nginx mysql php8.2-fpm' -b"
  debug_db: "ansible all -i inventory -m shell -a 'grep DB_ /var/www/html/wp-config.php' -b"

 🧪 VERIFICATION

  - 1. 🌐 Access WordPress: https://your-domain.com
  - 2. 🔒 SSL Test: https://www.ssllabs.com/ssltest/
  - 3. 🛡️ Security Headers: https://securityheaders.com/
  - 4. 📄 File Permissions Check:
      command: "ansible all -i inventory -m shell -a 'ls -l /var/www/html/wp-config.php' -b"
      expected: "-rw-r----- 1 www-data www-data"

 🐛 TROUBLESHOOTING

  database_errors:
    - 🔍 Check credentials:
        command: "ansible all -i inventory -m shell -a \"grep DB_ /var/www/html/wp-config.php\" -b"
    - 🧪 Test connection:
        command: "ansible all -i inventory -m shell -a \"mysql -u {{user}} -p'{{pass}}' -e 'SELECT 1'\" -b"
  
  ssl_issues:
    - 📜 List certificates:
        command: "ansible all -i inventory -m shell -a 'certbot certificates' -b"
    - 🧪 Test renewal:
        command: "ansible all -i inventory -m shell -a 'certbot renew --dry-run' -b"
  
  nginx_errors:
    - ✅ Check config:
        command: "ansible all -i inventory -m shell -a 'nginx -t' -b"
    - 📋 View logs:
        command: "ansible all -i inventory -m shell -a 'tail -20 /var/log/nginx/error.log' -b"

 💾 BACKUP STRATEGY

  frequency: 
    daily: Database dump with mysqldump
    weekly: Full /var/www/html backup
  tools: 
    - 📦 mysqldump
    - 🔄 rsync
    - 🧰 BorgBackup
  storage: 
    - ☁️ AWS S3
    - 💽 Local NAS
  automation: Ansible cron jobs

 📸 SCREENSHOTS

  - playbook-success.png: ✅ Ansible playbook output
  - wordpress-login.png: 🔑 WordPress admin screen
  - ssl-valid.png: 🔒 Browser padlock icon
  - security-headers.png: 🛡️ A+ rating from securityheaders.com
  - wp-admin.png: 🖥️ WordPress dashboard

 💡 PRO TIPS

  - 🚀 Use 'ansible-lint main-playbook.yaml' to validate playbook
  - 🔐 Rotate database passwords quarterly
  - 📊 Set up monitoring with netdata or prometheus
  - 💾 Test backups regularly

Maintainer: Alan Varghese
email: thealanvarghese@gmail.com
linkedin: https://linkedin.com/in/alanvarghese-dev
github: https:github.com/alanvarghese-dev



