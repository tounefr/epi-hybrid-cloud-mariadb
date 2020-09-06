
# Importer une VM dans EC2

## CLI AWS

### Créer un utilisateur et un groupe depuis IAM
https://console.aws.amazon.com/iam/home?#/users

### Ajouter les droits administrateur au groupe

![](https://i.imgur.com/7SfHVTK.png)


### Récupérer clés API
AWS Access Key ID
AWS Secret Access Key 

![](https://i.imgur.com/OAKVvbw.png)


### Configurer les clés d’accès API sur l’outil CLI

Choisir une région:
eu-west-1

> aws configure
```
epitech@Testarossa:~/client1$ aws configure
AWS Access Key ID [****************UN5O]:
AWS Secret Access Key [****************ofgn]:
Default region name [eu-west-1]:
Default output format [None]:
```

## Créer une VM au format disque raw

Doc AWS : https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html

### Créer une VM proxmox CentOS 7 avec un disque au format raw de 5G pour rester sur l’offre gratuite S3

![](https://i.imgur.com/opK1mte.png)


## Créer un role IAM “vmimport”

Doc AWS: https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html#vmimport-role

> aws iam create-role --role-name vmimport --assume-role-policy-document "file://trust-policy.json"
```
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
```


> aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://role-policy.json"
```
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket" 
         ],
         "Resource": [
            "arn:aws:s3:::epivmimg",
            "arn:aws:s3:::epivmimg/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl"
         ],
         "Resource": [
            "arn:aws:s3:::epivmimg",
            "arn:aws:s3:::epivmimg/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
```



## Créer un bucket S3
Notre bucket: epivmimg
![](https://i.imgur.com/j70lBLG.png)

## Upload l’image disque sur S3

> aws s3 cp /mnt/pve/vm-storage/images/103/vm-103-disk-0.raw s3://epivmimg/

## Importer l’image S3 vers AMI

> aws ec2 import-image --description "My server VM" --disk-containers "file://containers.json"
```
[
  {
    "Description": "First disk",
    "Format": "raw",
    "UserBucket": {
        "S3Bucket": "epivmimg",
        "S3Key": "vm-103-disk-0.raw"
    }
  }
]
```

### Monitorer l’import :
> aws ec2 describe-import-image-tasks --import-task-ids import-ami-1234567890abcdef0

# Script de déploiement de 3 instances

## Installer la CLI azure, configurer les clés API

https://portal.azure.com/

# Déploiement des applicatifs et MariaDB et configuration de la réplication

Déploiement avec le role ansible et mysql_replication
https://github.com/bertvv/ansible-role-mariadb
https://docs.ansible.com/ansible/latest/modules/mysql_replication_module.html

> ansible-galaxy install bertvv.mariadb


> ansible-playbook --inventory-file=./inventory playbook.yml

# Script de postinstall de vérification de l'état des clients MariaDB

# Procédure de PRA pour déployer l'ensemble du cloud privz chez AWS
