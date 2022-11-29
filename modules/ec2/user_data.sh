#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
sudo touch /var/www/html/index.html
sudo chmod 666 /var/www/html/index.html
echo "Application ${subnet} ${info}" > /var/www/html/index.html
