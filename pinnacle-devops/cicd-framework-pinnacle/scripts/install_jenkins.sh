#!/bin/bash

# Quick script to install Jenkins on Amazon Linux
# 1) In the future will add the ability to test OS type and install on other Linux Servers
# 2) Offload this to Chef or Saltstack

# Install Jenkins Dependencies
printf '%s\n' 'Updating Yum'
yum -y update || {
    printf '%s\n' 'Failed to update yum'
    exit 1
}

printf '%s\n' 'Installing Jenkins dependencies'
yum -y install jq java-1.8.0 java-1.8.0-openjdk-devel git wget docker || {
    printf '%s\n' 'Failed to install jenkins dependencies'
    exit 1
}

# update repositories on first install
printf '%s\n' 'Updating Yum Repositories and installing Jenkins LTS'
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo || {
    printf '%s\n' 'Repository update failed'
    exit 1
}

rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key || {
    printf '%s\n' 'Repository Key update failed'
    exit 1
}

yum -y install jenkins-2.150.3 || {
    printf '%s\n' 'Jenkins Install Failed'
    exit 1
}

# Get some defaults set for a bug when installing plugins and also skipping the install wizzzard
sed -i -e 's#^JENKINS_ARGS=""#JENKINS_ARGS="-Dhudson.diyChunking=false"#' /etc/sysconfig/jenkins
sed -i -e 's#^JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"#JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"#' /etc/sysconfig/jenkins
#@TODO Get SSL working

# Download Jenkins Jar so that we can run command line configuration
printf '%s\n' 'Waiting for Jenkins to start'
service jenkins start  || {
    printf '%s\n' 'Failed to Start Jenkins'
    exit 1
}

# set Jenkins to autostart on reboot
printf  '%s\n' 'Adding Jenkins to chkconfig'
chkconfig jenkins on || {
    printf '%s\n' 'Failed to add Jenkins to chkconfig'
    exit 1
}

until wget -O /home/ec2-user/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar; do
    echo "Trying to download jenkins-cli.jar attempt."
    sleep 10
done

chown ec2-user:ec2-user /home/ec2-user/jenkins-cli.jar

# Test Jar installation
printf '%s\n' 'Testing Jenkins Installation'
java -jar /home/ec2-user/jenkins-cli.jar -s http://localhost:8080/ help || {
    printf '%s\n' 'Running jar for jenkins failed'
    exit 1
}

# Need to update plugins
printf '%s\n' 'Updating Jenkins Plugins'
UPDATE_LIST=$( java -jar /home/ec2-user/jenkins-cli.jar -s http://localhost:8080/ list-plugins | grep -e ')$' | awk '{ print $1 }' );
if [ ! -z "${UPDATE_LIST}" ]; then
    echo Updating Jenkins Plugins: ${UPDATE_LIST};
    java -jar /home/ec2-user/jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin ${UPDATE_LIST} ;
fi

# Install default plugins for Jenkins Server to support CorpInfo base Development Platform
printf '%s\n' 'Installing Default Plugins'
for each in "
    sectioned-view
    role-strategy
    docker-workflow
    workflow-aggregator
    join
    ws-cleanup
    uno-choice
    git-parameter
    categorized-view
    chef-tracking
    junit
    subversion
    git
    dashboard-view
    parameterized-trigger
    run-condition
    script-security
    http_request
    cvs
    ec2
    dynamicparameter
    matrix-project
    delivery-pipeline-plugin
    github
    mailer
    bitbucket
    aws-lambda
    build-pipeline-plugin
    snsnotify
    ssh-credentials
    team-views
    javadoc
    cloudbees-credentials
    cloudbees-folder
    antisamy-markup-formatter
    aws-beanstalk-publisher-plugin
    files-found-trigger
    conditional-buildstep
    ec2-deployment-dashboard
    codedeploy
    node-iterator-api
    github-api
    ssh-slaves
    jquery
    matrix-auth
    credentials-binding
    ant
    scriptler
    git-server
    pam-auth
    awseb-deployment-plugin
    maven-plugin
    ldap
    python
    credentials
    translation
    jenkins-multijob-plugin
    publish-over-ssh
    vagrant
    simple-theme-plugin
    workflow-step-api
    windows-slaves
    ssh-agent
    scm-api
    envinject
    github-sqs-plugin
    jslint
    token-macro
    ec2-cloud-axis
    deployment-notification
    mapdb-api
    git-client
    external-monitor-job
    packer
    validating-string-parameter
    plain-credentials
    hipchat
    gravatar
    saltstack
    authentication-tokens
    docker-commons
    docker-build-step
    docker-build-publish
    docker-traceability
    docker-custom-build-environment";
    do
        java -jar /home/ec2-user/jenkins-cli.jar -s http://localhost:8080/ install-plugin $each ;
    done

# Restarting Jenkins Server to install plugins and jobs
java -jar /home/ec2-user/jenkins-cli.jar -s http://localhost:8080/ restart

until wget -O /home/ec2-user/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar; do
    echo "Trying to download jenkins-cli.jar attempt to check jenkins is backup and running."
    sleep 10
done

# Add jenkins user to docker group so that sudo isn't required
gpasswd -a jenkins docker

# Install ElasticBeanstalk CLI Tools
pip install awsebcli

# Starting Docker
service docker restart

# Installing nodejs
yum install -y gcc-c++ make openssl-devel nodejs npm --enablerepo=epel
npm install -g grunt-cli
npm install forever -g

# Installing Terraform
mkdir -p /opt/terraform
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip -O /opt/terraform/terraform_0.11.11_linux_amd64.zip
cd /opt/terraform ; unzip terraform_0.11.11_linux_amd64.zip
ln -s /opt/terraform/terraform /usr/bin/terraform

# Setting up Terraform Paths
echo "PATH=/opt/terraform:$PATH" > /etc/profile.d/terraform.sh

# Restarting Jenkins Server to install updates
java -jar /home/ec2-user/jenkins-cli.jar -s http://localhost:8080/ safe-restart

# Download Jenkins Jar so that we can run command line configuration
printf '%s\n' 'Waiting for Jenkins to restart'

# Clearing Up
rm -rf /home/ec2-user/jenkins
rm -rf /home/ec2-user/*.tar
rm -rf $0

# We need the jenkins user to have the docker group as its primary group
usermod -g docker jenkins

# Add user information to git global config. This allows Jenkins to update engagednation/app-manifest
git config --global user.email "no-reply@pinn.us"
git config --global user.name "Jenkins"

exit 0
