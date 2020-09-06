# 1. Prérequis
## Ansible
1. Role ansible d'installation de mariadb
> ansible-galaxy install bertvv.mariadb
## Terraform
## CLI Azure
1. Installer la CLI Azure
2. Configurer les clés API

# 2. Déploiement des applicatifs
Créer les instances publics vers 3 zones distinctes et génèrer un fichier d'inventaire ansible
> terraform apply

> cat inventory

# Déploiement MariaDB 
> ansible-playbook --inventory-file=./inventory install-mariadb.yml

# Configuration de la réplication
## Récupérer les variables File et Position du master mariadb
> ansible db-master -i inventory -a "sudo mysql -u root -p -e'show master status'"

## Configuration des instances privées
> ansible-playbook --inventory-file=./inventory install-mariadb-slave-private.yml

## Configuration des instances publics
> ansible-playbook --inventory-file=./inventory install-mariadb-slave-public.yml

# 3. Script de postinstall de vérification de l'état des clients MariaDB

> ansible-playbook --inventory-file=./inventory check-slaves.yml

# 4. Procédure de PRA pour déployer l'ensemble du cloud privé chez AWS
Voir pra_aws.docx

# 5. TODO
1. SSL MySQL slaves <--> master
