<?php
header("Content-Type: application/json");

$servername = "mysql";
$username = "eleve";
$password = "eleve";
$dbname = "appdb";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["error" => "Échec de la connexion : " . $conn->connect_error]));
}

// Requête 1 : Films réalisés par un artiste
$sql_films = "SELECT Film.titre, Film.annee, Artiste.nom, Artiste.prenom 
              FROM Film 
              JOIN Realiser ON Film.id = Realiser.id_film
              JOIN Artiste ON Realiser.id_artiste = Artiste.id";
$result_films = $conn->query($sql_films);
$films = $result_films->fetch_all(MYSQLI_ASSOC);

// Requête 2 : Artistes, films et rôles joués
$sql_roles = "SELECT Artiste.nom, Artiste.prenom, Film.titre, Jouer.role
              FROM Jouer
              JOIN Film ON Jouer.id_film = Film.id
              JOIN Artiste ON Jouer.id_artiste = Artiste.id";
$result_roles = $conn->query($sql_roles);
$roles = $result_roles->fetch_all(MYSQLI_ASSOC);

// Requête 3 : Notes des internautes pour un film
$sql_notes = "SELECT Film.titre, Internaute.nom, Internaute.prenom, Noter.note
              FROM Noter
              JOIN Film ON Noter.id_film = Film.id
              JOIN Internaute ON Noter.id_internaute = Internaute.id";
$result_notes = $conn->query($sql_notes);
$notes = $result_notes->fetch_all(MYSQLI_ASSOC);

echo json_encode([
    "films" => $films,
    "roles" => $roles,
    "notes" => $notes
]);

$conn->close();
?>
