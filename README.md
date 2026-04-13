Reponse au Test technique

Ce test contient  3 grandes partie une 
* Questions : Pour cette partie les éléments serons dans le dossier **questions** à l'intérieur duquel se trouve un fichier **reponses.md** qui contient les reponses de la question 1 à ala question 5
* SQL/dbt : dbt viens avec beaucoup de fichier et dossiers. cependant le modele client est dans le dossier **models** et dans le fichier **dim/clients.sql**.  
Les tests ont été implémenter dans le fichier **schema.yml** 
Le fichier source defini la table source de notre modèle sql. (on aurai pu mettre la data aussi dans mais la declaration dans source me parraissait plus interssante)
Un snapshot aussi a été mis en place dans le dossier **snapshot** et dans le fichier **scd_clients.yml**

Un snapshot a été
* Python : Le code python se retrouve dans le dossier **python** qui lui même contient le fichier **build_client.py** dans lequel se trouve la fonction avec toutes les règles attendues

