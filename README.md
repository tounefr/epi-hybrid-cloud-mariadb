# Prérequis
* Ansible
* ansible-galaxy install bertvv.mariadb
* Terraform
* CLI Azure

# Déploiement des applicatifs
Créer les instances publics vers 3 zones distinctes et génèrer un fichier d'inventaire ansible
> terraform apply

> cat inventory

# Déploiement MariaDB 
> ANSIBLE_REMOTE_USER=epitech ansible-playbook --inventory-file=./inventory install-mariadb.yml

# Configuration de la réplication
## Récuprer varibles File and Position
> ansible db-master -i inventory -a "sudo mysql -u root -p -e'show master status'"

## Instances privées
> ANSIBLE_REMOTE_USER=epitech ansible-playbook --inventory-file=./inventory install-mariadb-slave-private.yml

## Instances publics
> ANSIBLE_REMOTE_USER=epitech ansible-playbook --inventory-file=./inventory install-mariadb-slave-cloud.yml

# Script de postinstall de vérification de l'état des clients MariaDB

> ANSIBLE_REMOTE_USER=epitech ansible-playbook --inventory-file=./inventory check-slaves.yml

# Procédure de PRA pour déployer l'ensemble du cloud privé chez AWS
Voir pra_aws.docx
