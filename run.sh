#!/bin/bash

# Script de lancement du PoC
# Récupère l'ID utilisateur courant pour la configuration

echo "[*] Configuration de l'environnement..."
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env

echo "[*] Lancement du conteneur..."
docker-compose up -d

echo "[*] Le conteneur tourne en arrière-plan."
echo "[*] Vérifiez votre bureau pour voir si le fichier 'SECURITY_AUDIT.txt' est apparu."
echo "[*] Pour nettoyer : docker-compose down"
