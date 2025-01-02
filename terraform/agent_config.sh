#!/bin/bash
sudo su
curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/mssql-release.repo
sudo yum -y remove mssql-tools unixODBC-utf16 unixODBC-utf16-devel
sudo yum install -y mssql-tools18 unixODBC-devel
sudo yum -y check-update
sudo yum -y update mssql-tools18
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc