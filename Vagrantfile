Vagrant.configure("2") do |config|
    # Master Node
    config.vm.define "master" do |master|
      master.vm.box = "ubuntu/focal64"
      master.vm.network "private_network", type: "dhcp"
      master.vm.network "private_network", ip: "192.168.20.10" # Set the desired IP address
      master.vm.hostname = "master"
  
      # Update and upgrade
      master.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get upgrade -y
      SHELL
  
      # Create altschool user with root privileges
      master.vm.provision "shell", inline: <<-SHELL
        sudo useradd -m -s /bin/bash altschool
        echo "altschool:junior" | sudo chpasswd
        sudo usermod -aG sudo altschool
      SHELL
  
      # Enable SSH key-based authentication for altschool
      master.vm.provision "shell", inline: <<-SHELL
        sudo -u altschool ssh-keygen -t rsa -b 4096 -N "" -f /home/altschool/.ssh/id_rsa
        sudo cp /home/altschool/.ssh/id_rsa.pub /home/altschool/.ssh/authorized_keys
        sudo chown altschool:altschool /home/altschool/.ssh/authorized_keys
        sudo chmod 600 /home/altschool/.ssh/authorized_keys
        sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo systemctl restart ssh
      SHELL
  
      # Copy data from Master to Slave using altschool user
      master.vm.provision "shell", inline: <<-SHELL
        sudo apt-get install -y sshpass
        sshpass -p "junior" scp -o StrictHostKeyChecking=no -r /mnt/altschool altschool@192.168.20.11:/mnt/altschool/slave
      SHELL
  
      # Process Monitoring
      master.vm.provision "shell", inline: <<-SHELL
        top -n 1
      SHELL
  
      # Install and configure Nginx as a load balancer
      master.vm.provision "shell", inline: <<-SHELL
        sudo apt-get install -y nginx
        # Add Nginx configuration for load balancing
        echo "upstream backend {
          server 192.168.20.11; # IP of the slave node
          server 127.0.0.1:80;
        }
  
        server {
          listen 80;
          server_name your_domain.com; # Replace with your domain
          location / {
            proxy_pass http://backend;
          }
        }" | sudo tee /etc/nginx/sites-available/load-balancer
        sudo ln -s /etc/nginx/sites-available/load-balancer /etc/nginx/sites-enabled/
        sudo nginx -t
        sudo systemctl restart nginx
      SHELL
    end
  
    # Slave Node
    config.vm.define "slave" do |slave|
      slave.vm.box = "ubuntu/focal64"
      slave.vm.network "private_network", type: "dhcp"
      slave.vm.network "private_network", ip: "192.168.20.11" # Set the desired IP address
      slave.vm.hostname = "slave"
  
      # Update and upgrade
      slave.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get upgrade -y
      SHELL
  
      # LAMP Stack Deployment
      slave.vm.provision "shell", inline: <<-SHELL
        sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql
        sudo systemctl enable apache2
        sudo systemctl start apache2
        # Secure MySQL installation and set a default user and password
        sudo mysql_secure_installation <<EOF
  Y
  junior
  junior
  Y
  Y
  Y
  Y
  EOF
      SHELL
  
      # Create a test PHP page to validate the LAMP setup
      slave.vm.provision "shell", inline: <<-SHELL
        echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
      SHELL
    end
  end