# backup jenkins or restore if new
if [[ -e "/data/backup" ]];
        then
		tar -cvf /data/backup_compressed/jenkins.`date +%F`.tar.gz /data/jenkins
		aws s3 cp /data/backup_compressed/jenkins.*.tar.gz  s3://pinnacle-devops-us-west-2/backup/jenkins.`date +%F`.tar.gz
        else
                mkdir -p /data/restore
                aws s3 cp s3://pinnacle-devops-us-west-2/backup/jenkins.*.tar.gz /data/restore
                tar -xvf /data/restore/jenkins.*.tar.gz /data/jenkins
fi
