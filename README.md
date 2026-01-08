# 🐳 Docker Runtime Misconfiguration PoC

**Démonstration technique d'une compromission de l'hôte via une configuration Docker Compose non sécurisée.**

[![Security](https://img.shields.io/badge/Security-PoC-red)](https://github.com/)
[![Docker](https://img.shields.io/badge/Docker-Misconfiguration-blue)](https://www.docker.com/)
[![Educational](https://img.shields.io/badge/Status-Educational_Only-green)]()

> ⚠️ **AVERTISSEMENT ÉTHIQUE**
> Ce dépôt est un "Proof of Concept" (Preuve de Concept) réalisé dans un cadre éducatif (Étudiant B2 Cybersécurité).
> Son but est de sensibiliser les développeurs et administrateurs système aux risques liés aux configurations de déploiement par défaut ou copiées-collées.
> L'auteur décline toute responsabilité concernant l'utilisation de ces techniques à des fins malveillantes.

---

## 🎯 Objectif du Projet

L'objectif est de démontrer qu'une **image Docker officielle et saine** (scanner de vulnérabilités au vert) peut devenir un vecteur d'attaque critique uniquement à cause de sa configuration d'exécution (Runtime).

Ce scénario simule une **"Supply Chain Attack"** où un attaquant fournit un outil légitime (ici, un leurre Python) accompagné d'un fichier `docker-compose.yml` piégé.

## ⚡ Démarrage Rapide

Pour tester la vulnérabilité sur votre propre machine (environnement Linux/WSL) :

1. **Cloner le dépôt :**
   ```bash
   git clone [https://github.com/VOTRE-USERNAME/docker-misconfig-poc.git](https://github.com/VOTRE-USERNAME/docker-misconfig-poc.git)
   cd docker-misconfig-poc
Lancer le PoC (via le script d'aide) : Le script configure les variables d'environnement nécessaires (UID/GID) et lance le conteneur.

Bash

chmod +x run.sh
./run.sh
Constat : Une application factice se lance et affiche des logs normaux (leurre). Cependant, vérifiez votre Bureau : un fichier SECURITY_DEMO.txt a été créé silencieusement par le conteneur.

🔬 Analyse Technique Approfondie
L'attaque repose sur une approche "Fileless" (sans dépôt de binaire malveillant) et exploite la confiance implicite accordée aux fichiers d'orchestration.

Voici les 3 vecteurs combinés pour réussir l'évasion :

1. Usurpation d'Identité (UID/GID Mapping)
Par défaut, un conteneur tourne souvent en root. Cependant, pour des raisons de "commodité" en développement (pour éviter les problèmes de permissions sur les fichiers générés), on utilise souvent cette configuration :

YAML

user: "${UID}:${GID}"
Le Mécanisme : Docker lance le processus du conteneur avec l'identifiant numérique de l'utilisateur hôte (ex: 1000:1000).

La Vulnérabilité : Du point de vue du Kernel Linux, le processus dans le conteneur EST l'utilisateur hôte (vous). Il n'y a plus de distinction de privilèges sur le système de fichiers. Toutes les restrictions de sécurité basées sur les utilisateurs (ACLs) sont contournées car le processus possède légitimement les droits du propriétaire des fichiers.

2. Violation de l'Isolation Disque (Bind Mounts)
L'accès au système de fichiers hôte est accordé via un montage de volume excessif :

YAML

volumes:
  - ${HOME}:/host_home
Le Mécanisme : Le répertoire personnel de l'utilisateur (/home/user) est monté directement dans le conteneur sous /host_home.

La Vulnérabilité : Combiné au point n°1 (UID Mapping), le conteneur a un accès Lecture et Écriture total sur les données sensibles de l'hôte :

Clés SSH (~/.ssh/id_rsa)

Fichiers de configuration Shell (~/.bashrc pour la persistance)

Documents personnels et Code source.

Dans ce PoC, nous nous contentons d'écrire un fichier texte inoffensif pour la démonstration.

3. Injection de Commande et Offuscation (Runtime Override)
L'attaque est cachée directement dans le fichier YAML, rendant l'audit du code Python inutile.

YAML

command: >
  /bin/sh -c "python main.py & 
  echo ZWNobyAiW1BSRVVWRV0gLi4uIiA+IC9ob3N0X2hvbWUvRGVza3RvcC9TRUNVUklUWV9ERU1PLnR4dAo= | base64 -d | sh;
  wait"
Override : La directive command dans Docker Compose écrase l'instruction CMD définie dans le Dockerfile de l'image officielle.

Offuscation : La charge utile (Payload) est encodée en Base64.

Un administrateur pressé lisant le fichier verra une chaîne de caractères ressemblant à une clé d'API ou un certificat, et non une commande bash.

Exécution Parallèle : L'utilisation de & permet de lancer l'application légitime (python main.py) en même temps que le code malveillant, rendant l'attaque invisible dans les logs standards (docker logs).

🛡️ Remédiation et Bonnes Pratiques
Cette démonstration souligne l'importance de sécuriser le Runtime Docker, et pas seulement les images.

1. Audit des Fichiers Compose
Ne jamais exécuter docker-compose up sur un dépôt tiers sans auditer les sections critiques :

volumes : Vérifier les montages de l'hôte (Bind mounts).

privileged: true : À bannir sauf nécessité absolue.

network_mode: host : Expose la stack réseau de l'hôte.

pid: host : Expose les processus de l'hôte.

2. Principe de Moindre Privilège
Limitez strictement les volumes montés aux sous-dossiers nécessaires.

❌ Mauvais : - .:/app (Monte tout le dossier courant, y compris le .git)

❌ Critique : - /:/host ou - /var/run/docker.sock:/var/run/docker.sock

✅ Bon : - ./data:/app/data (Monte uniquement le dossier de données nécessaire)

3. Docker Rootless
L'utilisation de Docker en mode Rootless permet d'exécuter le démon Docker et les conteneurs en tant qu'utilisateur non privilégié. Même en cas d'évasion (Container Escape), l'attaquant n'obtiendra pas les droits root sur la machine hôte.
