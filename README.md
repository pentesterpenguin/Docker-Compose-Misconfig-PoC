# Docker-Compose-Misconfig-PoC
Démonstration d'une compromission de machine hôte via une configuration Docker Compose malveillante (PoC).

# 🛡️ Docker Supply Chain Attack (PoC)

> ⚠️ **DISCLAIMER / AVERTISSEMENT**
> Ce projet est réalisé dans un but **strictement éducatif** et de sensibilisation à la cybersécurité. Il a pour objectif de démontrer l'importance de l'audit des configurations de déploiement. L'auteur décline toute responsabilité en cas de mauvaise utilisation de ce code.

---

## 🧐 Le Contexte

En tant que développeurs ou étudiants, nous utilisons souvent des projets trouvés sur GitHub. Notre réflexe de sécurité est généralement de vérifier :
1.  Le code source de l'application (ex: `main.py`).
2.  L'image Docker utilisée (ex: `Dockerfile` utilisant une image officielle).

**L'hypothèse :** Si le code est sain et l'image officielle, alors le conteneur est sûr.

**La réalité :** Ce dépôt démontre que cette hypothèse est fausse. Une configuration malveillante (et souvent ignorée) dans le fichier `docker-compose.yml` suffit pour compromettre la machine hôte, même avec une image légitime.

## 🚀 Scénario d'Attaque

Ce projet simule une **"Supply Chain Attack"** (Attaque de la chaîne d'approvisionnement) :
1.  Une application Python "leurre" (un moniteur système factice) est proposée. Son code est inoffensif.
2.  L'image Docker est basée sur `python:3.9-slim` (officielle).
3.  **Le piège** réside uniquement dans la configuration du Runtime (`docker-compose.yml`).

Une fois lancé, le conteneur va silencieusement écrire un fichier témoin sur votre Bureau, prouvant qu'il a réussi à sortir de son isolation.

## 🛠️ Comment reproduire le PoC

1.  **Clonez ce dépôt :**
    ```bash
    git clone [https://github.com/VOTRE-USERNAME/docker-misconfig-poc.git](https://github.com/VOTRE-USERNAME/docker-misconfig-poc.git)
    cd docker-misconfig-poc
    ```

2.  **Lancez le script d'installation :**
    *(Ce script génère simplement un fichier .env avec votre UID actuel pour que la démo fonctionne)*
    ```bash
    chmod +x run.sh
    ./run.sh
    ```

3.  **Observez le résultat :**
    * L'application se lance normalement et affiche des logs (le leurre).
    * Regardez votre **Bureau** (Desktop). Un fichier nommé `SECURITY_DEMO.txt` est apparu.
    * **Conclusion :** Le conteneur a eu un accès en écriture à vos fichiers personnels.

4.  **Nettoyage :**
    ```bash
    docker-compose down
    rm ~/Desktop/SECURITY_DEMO.txt
    ```

## ⚙️ Analyse Technique

Ce PoC utilise une approche **"Fileless"** (sans malware sur le disque) en exploitant trois fonctionnalités légitimes de Docker :

### 1. Usurpation d'Identité (UID Mapping)
Dans le `docker-compose.yml` :
```yaml
user: "${UID}:${GID}"
