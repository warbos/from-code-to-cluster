# 🚀 Projet : From Code to Cluster - Portfolio DevOps

**Auteur :** Morgan 
**Domaine de déploiement :** `morgan.x73-e6k.com`

---

## 🎯 But du projet
Ce projet a pour objectif d'automatiser le déploiement complet d'une application web (Portfolio) de "bout en bout" en appliquant les principes fondamentaux du DevOps (IaC, CI/CD, Configuration Management, et Orchestration K8s). 

Le but est de garantir qu'une modification du code source déclenche la création d'une nouvelle version d'image, et qu'une unique commande puisse provisionner l'infrastructure Cloud, configurer le nom de domaine, sécuriser le serveur et déployer l'application avec un certificat HTTPS valide (Let's Encrypt), le tout sans aucune intervention manuelle sur le serveur cible.

---

## 🏗️ Architecture globale
L'architecture repose sur la séparation des responsabilités et l'automatisation dynamique :

1. **Intégration Continue (CI) :** À chaque `git push`, le pipeline GitHub Actions construit une image conteneurisée avec Podman. L'image est taguée dynamiquement avec un "Short SHA" Git pour assurer la traçabilité, puis stockée sur le GitHub Container Registry (GHCR). L'identifiant de version est également injecté dans le code HTML.
2. **Infrastructure (IaC) :** Terraform provisionne une instance AWS EC2 (`t3.small`) et ses règles de pare-feu. Il crée un enregistrement DNS dynamique (Type A) sur Route 53 liant l'IP publique générée au nom de domaine. Enfin, il génère le fichier d'inventaire dynamiquement pour Ansible.
3. **Configuration & Déploiement (CD) :** Ansible se connecte à l'instance pour :
   - Mettre à jour le système et installer K3s (distribution Kubernetes légère).
   - Installer Cert-Manager pour la gestion automatisée des certificats TLS.
   - Injecter la version de l'image (Short SHA) et le nom de domaine dans les manifestes Kubernetes.
4. **Orchestration (K8s) :** Le cluster déploie les Pods, répartit la charge via un service interne (`ClusterIP`), et expose l'application de manière sécurisée via l'Ingress natif (Traefik) couplé à Let's Encrypt.

---

## 📂 Structure du dépôt

```text
from-code-to-cluster/
├── .github/workflows/
│   └── pipeline.yml         # Pipeline CI/CD (GitHub Actions) pour le build et push de l'image
├── app/
│   ├── Containerfile        # Instructions de conteneurisation (standard Podman)
│   ├── index.html           # Structure de l'application web
│   ├── script.js            # Logique dynamique front-end
│   └── style.css            # Feuilles de style du portfolio
├── terraform/
│   ├── main.tf              # Code IaC : Provisionnement EC2, Security Groups, Route 53
│   ├── outputs.tf           # Définition des variables de sortie (ex: IP publique)
│   └── variables.tf         # Fichier de déclaration des variables Terraform
├── ansible/
│   ├── ansible.cfg          # Configuration locale (gestion stricte des empreintes SSH)
│   ├── inventory.ini        # Inventaire généré dynamiquement par Terraform
│   └── playbook.yml         # Playbook principal : K3s, Cert-Manager, et déploiement
├── k8s/
│   ├── cluster-issuer.yaml  # Configuration de Cert-Manager (serveur Let's Encrypt Prod)
│   ├── deployment.yaml      # Déploiement des Pods Portfolio (avec balise de version)
│   ├── ingress.yaml         # Routeur d'entrée (Traefik) avec terminaison HTTPS
│   └── service.yaml         # Service réseau interne (Load Balancing via ClusterIP)
├── .gitignore               # Fichiers exclus du versioning (ex: *.tfstate, secrets)
└── README.md                # Documentation principale du projet
(Note : Les fichiers d'état locaux de Terraform comme terraform.tfstate sont générés à l'exécution mais exclus du dépôt distant via le .gitignore pour des raisons de sécurité).

⚙️ Prérequis
Pour lancer ce projet depuis une "Management Station", les éléments suivants sont requis :

Accès Cloud & Services :

Un compte AWS avec droits d'administration (EC2, Route 53).

Un nom de domaine géré par AWS Route 53.

Un compte GitHub avec un Personal Access Token (droit d'écriture sur les packages GHCR).

Outils locaux :

git

terraform (v1.0+)

ansible (v2.9+)

Une paire de clés SSH (ex: ~/.ssh/exam_key) pour la connexion sécurisée à l'instance EC2.

🚀 Étapes principales de lancement
1. Intégration et Génération de l'image
Toute modification du code ou de l'infrastructure est poussée sur le dépôt :

Bash
git add .
git commit -m "feat: description de la mise à jour"
git push
(Le workflow .github/workflows/pipeline.yml se déclenche et met à jour le GHCR).

2. Provisionnement de l'Infrastructure
Création du serveur EC2, ouverture des ports de sécurité, et mise à jour de l'enregistrement DNS :

Bash
cd terraform/
terraform init    # (Uniquement au premier lancement)
terraform apply -auto-approve
(⚠️ Attendre ~45 secondes pour laisser l'OS Ubuntu finaliser son processus de démarrage).

3. Configuration et Déploiement
Installation du cluster K3s, de l'infrastructure de certificats, et application des manifestes :

Bash
cd ../ansible/
ansible-playbook -i inventory.ini playbook.yml
(Patienter 1 à 2 minutes après l'exécution pour permettre à Let's Encrypt de valider le domaine et de délivrer le certificat).

L'application est désormais accessible, load-balancée et sécurisée à l'adresse : https://morgan.x73-e6k.com

🛠️ Outils utilisés
Cloud Provider : AWS (EC2, Route 53, Security Groups).

Infrastructure as Code : HashiCorp Terraform.

Gestion de Configuration : Ansible.

Conteneurisation : Podman & GitHub Container Registry (GHCR).

CI/CD : Git & GitHub Actions.

Orchestration : Kubernetes (K3s).

Réseau & Sécurité K8s : Traefik (Ingress), Cert-Manager, Let's Encrypt (TLS).
