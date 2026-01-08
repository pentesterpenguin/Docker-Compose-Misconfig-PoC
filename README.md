# 🐳 Docker Runtime Misconfiguration PoC

**Démonstration simple : Comment une mauvaise config `docker-compose` peut compromettre ton PC.**

> ⚠️ **DISCLAIMER** : Projet éducatif uniquement. Ne lancez jamais un Compose inconnu sans l'auditer.

## ⚡ C'est quoi le piège ?
Ce dépôt montre qu'une image officielle (`python:3.9-slim`) peut être utilisée pour **accéder à tes fichiers personnels** sans aucun virus, juste via une mauvaise configuration du fichier `docker-compose.yml`.

## 🚀 Teste-le toi-même

1. **Clone et lance le script :**
   ```bash
   git clone [https://github.com/TON-USER/docker-misconfig-poc](https://github.com/TON-USER/docker-misconfig-poc)
   cd docker-misconfig-poc
   chmod +x run.sh
   ./run.sh
Le résultat : Le conteneur affiche des logs innocents... mais regarde ton Bureau : un fichier SECURITY_DEMO.txt a été créé de force.

⚙️ Comment ça marche ? (L'analyse)
L'attaque est "Fileless" (cachée dans la config) et utilise 3 failles courantes :

Usurpation (user: ${UID}) : Le conteneur tourne avec tes droits utilisateurs, pas en root isolé.

Volumes (volumes: ${HOME}:...) : Le conteneur a accès en écriture à tout ton dossier personnel.

Injection (command: ...) : Une commande cachée (encodée en Base64) remplace le lancement normal pour exécuter l'attaque.

🛡️ Comment se protéger ?
Auditez vos fichiers YAML : Vérifiez toujours les sections volumes et privileged.

Moindre privilège : Ne montez jamais / ou $HOME entier.

Rootless : Utilisez Docker en mode Rootless pour limiter la casse en cas d'évasion.
