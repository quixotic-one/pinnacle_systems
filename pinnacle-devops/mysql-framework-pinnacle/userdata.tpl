#!/bin/bash

# Waiting for EBS mounts to become available
while [ ! -e /dev/xvdf ]; do echo waiting for /dev/xvdf to attach; sleep 10; done
mkdir -p /data

# Remove java 7

# Create filesystems and mount point info
if [[ $(file -s /dev/xvdf | awk '{ print $2 }') == data ]]
then
  mke2fs -t ext4 -F /dev/xvdf > /tmp/mke2fs1.log 2>&1
fi

echo '/dev/xvdf /data ext4 defaults 0 0' | tee -a /etc/fstab
mount /data > /tmp/mount1.log 2>&1
cd /var/lib
mkdir -p /data/mysql
mkdir -p /data/docker
ln -s /data/mysql mysql
ln -s /data/docker docker

# INSTALL aws-cli and wget
yum install -y aws-cli wget

if [ $? -ne 0 ]; then
  echo Could not install aws-cli or wget
  exit 1
fi



# Setting up SSH IAM Access
aws s3 cp s3://${s3DevOpsBucket}/import_users.sh /opt/
aws s3 cp s3://${s3DevOpsBucket}/authorized_keys.sh /opt/
chmod -R 755 /opt/*

echo "" >> /etc/ssh/sshd_config
echo "AuthorizedKeysCommand /opt/authorized_keys.sh" >> /etc/ssh/sshd_config
echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config
echo "*/5 * * * * root /opt/import_users.sh >> /var/log/ssh-lockdown.log 2>&1" > /etc/cron.d/import_users

# Add mysql sudoers rules
cat << EOF > /etc/sudoers.d/mysql
mysql ALL = NOPASSWD: ALL
# User rules for mysql
mysql ALL=(root) NOPASSWD:/usr/bin/salt-key
Defaults:mysql !requiretty
EOF

# Add mariaDB repo
cat << EOF > /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

if [ $? -ne 0 ]; then
  echo Could not add MariaDB.repo
  exit 1
fi

# Update yum repo
yum update -y

if [ $? -ne 0 ]; then
  echo Could not add MariaDB.repo
  exit 1
fi

# INSTALL MariaDB
yum install mariadb-server.x86_64 -y
yum install mariadb-libs.x86_64 -y

if [ $? -ne 0 ]; then
  echo Could not download install_mysql
  exit 1
fi

# Add MariaDB Service and Start
systemctl start mariadb
systemctl enable mariadb

if [ $? -ne 0 ]; then
  echo Could not start mariadb
  exit 1
fi
