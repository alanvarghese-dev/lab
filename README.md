# Software Engineering & DevOps Portfolio

A comprehensive collection of software engineering projects, focusing on **DevOps**, **Infrastructure as Code (IaC)**, **Containerization**, and **Automation**. This repository showcases various implementations of web stacks (LEMP, LAMP, WordPress), CI/CD pipelines, and system administration tools.

## 🚀 Key Project Categories

### ☁️ Infrastructure & Automation (Ansible/Terraform)
*   **[Automated LEMP Setup](./automated-lemp-setup/)**: Ansible playbooks for automating the deployment of Linux, Nginx, MySQL, and PHP stacks.
*   **[Hardened LEMP Ansible Setup](./hardened_lemp_ansible_setup/)**: A security-focused version of the LEMP stack deployment using Ansible best practices.
*   **[LAMP Stack on AWS](./lamp-stack-on-aws/)**: Manual and automated (Ansible) deployment strategies for LAMP stacks on Amazon Web Services.
*   **[WordPress Nginx AWS Setup](./wordpress-nginx-aws-setup/)**: Specialized setup for WordPress with Nginx and SSL configuration on AWS infrastructure.

### 🐳 Docker & Containerization
*   **[Docker Image Optimization Lab](./Docker_image_optimization_lab/)**: Examples of multi-stage builds and best practices for reducing image size for Node.js and Python.
*   **[Docker Security Hardening](./Docker_security_hardening/)**: Implementations of security best practices for containerized environments.
*   **[Dockerized WordPress](./dockerized-wordpress/)**: Portable WordPress deployment using Docker Compose with Nginx and MySQL.
*   **[Ecommerce Platform](./ecommerce-platform/)**: A full-stack containerized application featuring load balancing and monitoring.

### 🛠️ DevOps & Orchestration
*   **[DevOps CI/CD Pipeline](./devops-ci-cd-pipeline/)**: A complete pipeline demonstration using Docker, Kubernetes manifests, and monitoring tools (Prometheus/Grafana).
*   **[Local Kubernetes Cluster Setup](./Local_kubernetes_cluster_setup/)**: Configuration files and steps for setting up a local K8s environment.
*   **[PHP Microservices](./php-microservices/)**: A microservices architecture demonstration using PHP and Docker.

### 📜 Bash Scripting & System Tools
Located in the **[Bash_Scripting](./Bash_Scripting/)** directory:
*   **Automated System Update Manager**: Keeps your Linux systems up-to-date automatically.
*   **Automatic Log Cleanup**: Manages disk space by cleaning up old log files.
*   **Cron Job Health Monitor**: Ensures your scheduled tasks are running as expected.
*   **File Integrity Checker**: Monitors files for unauthorized changes.
*   **Network Connectivity Tool**: Monitors network status and alerts on downtime.

---

## 🛠️ Technologies Used
- **Cloud:** AWS (EC2, VPC, IAM)
- **Containerization:** Docker, Docker Compose, Kubernetes
- **Automation:** Ansible, Terraform, Bash Scripting
- **Stack:** Nginx, Apache, MySQL/MariaDB, PHP, Node.js, Python
- **Monitoring:** Prometheus, Grafana
- **CI/CD:** GitHub Actions

## 📂 Repository Structure
Each directory contains its own `README.md` with specific installation and usage instructions.

```text
.
├── automated-lemp-setup/     # Ansible LEMP automation
├── Bash_Scripting/           # Collection of system automation scripts
├── devops-ci-cd-pipeline/    # Full pipeline implementation
├── Docker_image_optimization/# Optimization techniques
├── Docker_security_hardening/# Security best practices
├── dockerized-wordpress/     # WordPress via Docker Compose
├── ecommerce-platform/       # Full-stack containerized app
└── ...
```

---
*Created with the help of Gemini CLI.*
