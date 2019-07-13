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
mkdir -p /data/jenkins
mkdir -p /data/docker
ln -s /data/jenkins jenkins
ln -s /data/docker docker

# INSTALL aws-cli and wget
yum install -y aws-cli wget

if [ $? -ne 0 ]; then
  echo Could not install aws-cli or wget
  exit 1
fi

# INSTALL JENKINS
aws s3 cp s3://${s3DevOpsBucket}/install_jenkins.sh /home/ec2-user/install_jenkins.sh

if [ $? -ne 0 ]; then
  echo Could not download install_jenkins
  exit 1
fi

chmod 755 /home/ec2-user/install_jenkins.sh
/home/ec2-user/install_jenkins.sh

if [ $? -ne 0 ]; then
  echo Failed to execute install_jenkins.sh
  exit 1
fi

# Copy Backup / Resotore scripts
aws s3 cp s3://${s3DevOpsBucket}/backup_jenkins.sh /opt/

# Setting up SSH IAM Access
aws s3 cp s3://${s3DevOpsBucket}/import_users.sh /opt/
aws s3 cp s3://${s3DevOpsBucket}/authorized_keys.sh /opt/
chmod -R 755 /opt/*

echo "" >> /etc/ssh/sshd_config
echo "AuthorizedKeysCommand /opt/authorized_keys.sh" >> /etc/ssh/sshd_config
echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config
echo "*/5 * * * * root /opt/import_users.sh >> /var/log/ssh-lockdown.log 2>&1" > /etc/cron.d/import_users

# Add jenkins sudoers rules
cat << EOF > /etc/sudoers.d/jenkins
jenkins ALL = NOPASSWD: ALL
# User rules for jenkins
jenkins ALL=(root) NOPASSWD:/usr/bin/salt-key
Defaults:jenkins !requiretty
EOF
