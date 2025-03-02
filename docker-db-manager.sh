#!/bin/bash

# Nom du conteneur MySQL
DB_CONTAINER="mysql-container"
DB_NAME="appdb"
BACKUP_FILE="./code/backup_full.sql"

# Fonction pour récupérer la base de données après `docker-compose up -d`
restore_db() {
    echo "⏳ Récupération de la base de données..."
    if [ -f "$BACKUP_FILE" ]; then
        docker exec -i $DB_CONTAINER mysql -u root -proot $DB_NAME < $BACKUP_FILE
        echo "✅ Base de données restaurée avec succès."
    else
        echo "❌ Fichier de sauvegarde non trouvé : $BACKUP_FILE"
    fi
}

# Fonction pour sauvegarder la base de données avant `docker-compose down`
backup_db() {
    echo "⏳ Sauvegarde de la base de données..."
    if [ "$(docker inspect -f '{{.State.Running}}' $DB_CONTAINER)" = "true" ]; then
        docker exec -i $DB_CONTAINER mysqldump -u root -proot $DB_NAME > $BACKUP_FILE
        echo "✅ Sauvegarde terminée : $BACKUP_FILE"
    else
        echo "❌ Le conteneur $DB_CONTAINER n'est pas en cours d'exécution. Impossible de sauvegarder la base de données."
    fi
}

# Fonction pour commit et push
commit_and_push() {
    echo "⏳ Commit et push de toutes les modifications..."
    git add .
    git commit -m "Sauvegarde automatique et mise à jour du projet"
    git push
    echo "✅ Commit et push effectués."
}
# Vérifier l'argument fourni
case "$1" in
    up)
        docker-compose up -d
        sleep 5  # Laisse le temps au conteneur de démarrer
        restore_db
        ;;
    down)
        backup_db
        commit_and_push
        docker-compose down
        ;;
    *)
        echo "Utilisation : $0 {up|down}"
        exit 1
        ;;
esac
