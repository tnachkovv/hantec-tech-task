#!/bin/bash
sudo su
# Install httpd
yum install httpd -y

# Start and enable the httpd service
systemctl start httpd
systemctl enable httpd

# Open HTTP port in the firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Get the server's hostname
HOSTNAME=$(hostname)

# Create a custom HTML file displaying the hostname
echo "<!DOCTYPE html>
<html>
<head>
    <title>Web Server</title>
</head>
<body>
    <h1>Welcome to the web server!</h1>
    <p>Server hostname: $HOSTNAME</p>
</body>
</html>" > /var/www/html/index.html

# Restart the httpd service to apply changes
systemctl restart httpd

echo "Web server is running. Visit http://$HOSTNAME/"