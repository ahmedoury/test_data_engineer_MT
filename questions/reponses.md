## Partie 1
#### Décrivez comment vous structureriez une plateforme de données permettant l’ingestion, la transformation et l’exposition des données à des consommateurs analytiques.

Pour structurer cette plateforme de données, j’aurais besoin d’un connecteur ou d’un mécanisme d’ingestion permettant de faire le lien entre l’application et la plateforme data afin de capter les différents événements générés par l’application.
Cela peut se faire via une connexion API ou via un outil de transport de messages chargé d’assurer la transmission des événements entre l’application et la plateforme de données.
Pour la couche d’ingestion, plusieurs options sont possibles selon le besoin:
* Airbyte si l’on souhaite répliquer ou ingérer des données depuis des APIs, bases de données ou outils tiers,
* ou bien Pub/Sub / Kafka dans le cas d’une ingestion temps réel orientée événements.

Les données brutes seront ensuite stockées dans un data lake, dans une couche Bronze (sous forme de tables ou de fichiers bruts), afin de conserver les données originales dans leur état initial. Cette couche permet de garantir la traçabilité, de faciliter les audits et de rendre possible le rejeu des traitements si nécessaire.
Une première phase de transformation sera ensuite appliquée sur ces données brutes:
* nettoyage,
* déduplication,
* standardisation,
* conversion dans les bons types de données.

Après ces traitements initiaux, les données pourront être transférées vers une couche Silver, qui correspond à une couche de données nettoyées, structurées et prêtes à être enrichies.
Cette couche permet d’effectuer des transformations complémentaires, de consolider les informations, ou encore de préparer les données avant leur exposition à des usages analytiques.
Une fois les transformations métier finalisées, les données pourront être chargées dans une couche Gold ou dans un datamart, selon que l’on souhaite exposer une vue métier globale ou des jeux de données spécifiques à un besoin analytique.
À ce stade, les données sont prêtes à être consommées pour des usages de reporting, de business intelligence, d’analyse ou de data science.
Concernant les transformations, il est possible d’utiliser Python et SQL et dbt pour construire les pipelines de traitement et modéliser les données de manière adaptée aux besoins métiers.
Enfin, un orchestrateur comme Airflow permettra de piloter l’ensemble des pipelines, de gérer les dépendances entre les traitements, de superviser leur exécution, de suivre les erreurs et d’intégrer des contrôles de qualité de données tout au long du processus.

## Partie 2 
### Décrivez un pipeline d’ingestion des événements vers une couche brute, puis expliquez comment vous construiriez des tables exploitables à partir de ces données.

Les événements arrivent généralement sous forme de JSON.
La première étape consiste donc à les stocker dans une couche brute (Bronze) au sein d’un data lake, en conservant les données dans leur format d’origine. Cette couche permet de garder une copie fidèle des données sources, ce qui est utile pour la traçabilité, les audits et le rejeu des traitements si nécessaire.Une deuxième étape consiste à mettre en place des jobs de transformation qui vont lire ces données brutes, parser les événements JSON et les transformer en tables structurées.
Dans cette étape, on applique les premières règles de qualité et de préparation :

* déduplication des événements (par exemple sur event_id)
* contrôle du schéma
* conversion des types (ex. event_time en timestamp)
* nettoyage des données
* conservation uniquement des événements conformes, avec éventuellement une gestion des lignes 
invalides dans une table de rejet.

Enfin, une troisième étape consiste à construire des tables exploitables pour l’analytics, par exemple :

* une table de faits des événements
* une table consolidée des clients
* ou des datamarts / tables agrégées orientées métier.

Ces tables finales contiennent uniquement les données utiles pour les usages analytiques, comme le reporting, la BI ou la data science.

## Partie 3 
#### Expliquez comment vous garantiriez la qualité des données et comment vous surveilleriez le bon fonctionnement des traitements.

Pour garantir la qualité des données, je mettrais en place des jobs ou des contrôles automatiques dédiés à la data quality. Ces contrôles permettraient par exemple de vérifier la fraîcheur des données, de mesurer le taux de valeurs nulles sur les colonnes critiques, de détecter des doublons ou encore de valider le respect du schéma attendu. Ces règles de qualité devraient être définies en collaboration avec les équipes métier afin de s’assurer qu’elles correspondent bien aux besoins fonctionnels. En parallèle, pour surveiller le bon fonctionnement des traitements, je mettrais en place un suivi des jobs avec des logs, des alertes en cas d’échec, de retard ou d’anomalie sur les volumes traités, ainsi qu’un monitoring des temps d’exécution et des erreurs.

## PARTIE 4 
### Expliquez comment vous organiseriez le développement, les tests et les déploiements dans un contexte d’équipe data.

Dans un contexte d’équipe data, j’organiserais le développement en séparant clairement les environnements et en m’appuyant sur un workflow Git. Le développement des pipelines se ferait d’abord dans un environnement de développement (dev), afin que chaque membre de l’équipe puisse travailler et tester ses changements de manière isolée. Chaque développeur travaillerait sur une branche dédiée à sa fonctionnalité ou à sa correction.
Une fois le développement terminé, le code serait poussé sur Git puis soumis à une merge request / pull request vers une branche d’intégration du projet. Cette étape permettrait de réaliser une code review afin de vérifier la qualité du code, le respect des bonnes pratiques de l’équipe, la lisibilité, la cohérence avec l’architecture existante et la conformité aux standards du projet.
Avant validation, plusieurs types de tests automatiques devraient être exécutés dans le pipeline CI :

* tests unitaires sur les composants Python ou les fonctions de transformation,
* tests d’intégration pour vérifier le bon enchaînement des pipelines,
* tests de qualité de données (unicité, non-nullité, fraîcheur, schéma, doublons),
* éventuellement des vérifications de style ou de linting.

Une fois ces contrôles validés, le code pourrait être déployé dans un environnement de recette / staging, où il serait testé dans des conditions plus proches de la production, avec un volume de données plus représentatif et une validation fonctionnelle plus indépendante. Si tout est conforme, le code pourrait ensuite être promu en production, idéalement via un pipeline CI/CD automatisé, afin de sécuriser et standardiser les déploiements.

## Partie 5 
####  Expliquez comment vous travaillez au sein d’une équipe data et comment vous contribuez à la structuration et à l’amélioration continue des pratiques.

Au sein d’une équipe data, je travaille généralement avec un backlog partagé, dans lequel les sujets sont priorisés en fonction des objectifs métier, des urgences opérationnelles et de la capacité de l’équipe. Les tâches sont ensuite réparties selon les priorités, les compétences disponibles et les contraintes du moment.
J’organise aussi le travail autour de deux grands volets :

* le Run, qui couvre la maintenance des pipelines existants, la supervision, la résolution d’incidents et la fiabilisation de la plateforme,
* et le Build, qui concerne la conception de nouveaux pipelines, de nouvelles transformations ou de nouvelles fonctionnalités.

La répartition entre ces deux dimensions évolue selon la période et les besoins du métier.
Au quotidien, la collaboration s’appuie sur des rituels d’équipe comme les daily meetings, qui permettent de partager les avancées, de signaler les blocages et d’aligner les priorités. Selon les sujets, j’apprécie aussi les temps d’échange plus ciblés, par exemple en pair programming, en revue de design ou lors de points techniques, afin de résoudre plus rapidement des problématiques complexes.
Pour contribuer à la structuration de l’équipe, je considère qu’un rôle important est de faire émerger des standards communs : conventions de nommage, structure des projets, bonnes pratiques de développement, règles de revue de code, organisation des pipelines et des modèles de données. L’objectif est de rendre les projets plus lisibles, plus homogènes et plus faciles à maintenir collectivement.
Je contribue également à l’amélioration continue en favorisant la documentation des pipelines, des règles métier et des choix d’architecture, afin de faciliter la maintenance, la transmission de connaissance et l’onboarding des nouveaux membres. Je trouve aussi utile de mettre en place des retours d’expérience après un projet ou un incident, afin d’identifier ce qui a bien fonctionné, ce qui doit être amélioré et quelles pratiques peuvent être standardisées à l’échelle de l’équipe.
Enfin, j’accorde beaucoup d’importance à la qualité et à la fiabilité : promouvoir des tests automatiques, des contrôles de qualité de données, du monitoring et des alertes permet non seulement de sécuriser les livraisons, mais aussi d’améliorer durablement les pratiques de l’équipe. Pour moi, contribuer à une équipe data ne consiste pas seulement à livrer des pipelines, mais aussi à faire progresser le cadre de travail collectif pour gagner en robustesse, en efficacité et en autonomie.


