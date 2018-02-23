# Launch concourse server on AWS using Terraform and Ansible 
  - First deploy the AWS infrastructure using Terraform    
  - Next install the needed packages using Ansible

# Install Terraform from HashiCop on host machine
  - https://www.terraform.io/downloads.html

# Install Python, Python-pip and AWS-CLI
  http://docs.aws.amazon.com/cli/latest/userguide/installing.html

  - Make sure to export your terraform instalation to your PATH
  - Use "aws configure" to set enviroment defaults

# terraform.tvars file
  Set deplyoment defaults:
  - Region
  - Key
  - Key path
  - Instance class
  - AMI's
  - DB users

# Deployment
  - You will be prompted for AWS user and localip_cidr at deployment.

# SSH into instances:
  - Use command ssh -i ~/.ssh/keyname ec2-user@instance_ip

# Useful commands:
  - terraform plan   (will generate a list of resoruces to be created in AWS)
  - terraform apply  (will deploy resources, or apply modifications)
  - terraform destroy (will destroy all resoruces and create final snapshot of DB) 
 
# Dependencies for Ansible install, python-pip
  - Run command: sudo easy_install pip

# Install Ansible on host machine
  - http://docs.ansible.com/ansible/latest/intro_installation.html#latest-releases-via-pip
  - Run command: sudo pip install ansible

# Configure Ansible
  - Verify defaults in /etc/ansible/ansible.cfg
  - Move /etc/ansible/hosts to /etc/ansible/hosts_default
  - Create new /etc/ansible/hosts file as in the sample_hosts file (insert server public ip, and path to private key genrated by Terraform for AWS)

# Prep files for playbook
  - Edit ./ansible/scripts/concourse/concourse_start_web.sh script (Add DB endpoint, UN, PW, domain)
  - Edit ./ansible/scripts/nginx/your_ci_server_domain.conf script (enter server domain, verify path to certificate, verify upstream)
  - Rename ./ansible/scripts/nginx/your_ci_server_domain.conf
  - Enter email and domain for cert in ./ansible/tasks/certbot.yml
  - Enter your project specifics in ./ansible/tasks/nginx_conf.yml

# Run playbook
  - While in directory containing main.yml file, run command: ansible-playbook main.yml
  - This will install all concourse dependencies, and the concourse web & fly binairies

# Conclusion
  - You should now have https access to the concourse server
  - Enter <your_ci_server_domain> into your browser and verify that http is upgraded to https

