# Recherche Jobs To Be Done

## Contexte de la recherche

Cette recherche vise à vérifier si les petites ESN et agences numériques rencontrent un problème de fragmentation lorsqu’elles pilotent plusieurs missions clients avec différents services SaaS.

### Cible étudiée

- Petites ESN et agences numériques françaises de 5 à 30 personnes.
- Acheteur pressenti : dirigeant ou responsable des opérations.
- Utilisateur principal : chef de projet.
- Utilisateurs secondaires : collaborateurs et clients invités.

### Hypothèse de problème

Le suivi des missions est dispersé entre des outils de gestion de projet, de documentation, de communication et de reporting. Cette dispersion oblige les équipes à recopier les informations, crée plusieurs versions de l’avancement et augmente la dépendance envers des fournisseurs SaaS tiers.

## Sources documentées

### Source 1 — Besoin d’un outil adapté aux petites agences

- **Type :** témoignage publié sur le forum `r/agency`.
- **Lien :** [All in one tool for managing agency work, workloads & budgets](https://www.reddit.com/r/agency/comments/1i7bn5t/all_in_one_tool_for_managing_agency_work/)
- **Contexte :** une agence numérique d’environ dix personnes compare des outils spécialisés et généralistes.
- **Extrait pertinent :** « They have all the capabilities for a services business but seem like they are too bloated / complex for a small agency. »
- **Ce que cela indique :** les solutions métier complètes sont perçues comme trop complexes, tandis que les outils généralistes demandent beaucoup de personnalisation.

### Source 2 — Centralisation et transparence de l’avancement

- **Type :** demande d’expérience publiée sur le forum `r/agency`.
- **Lien :** [What tools do you use to manage your clients' work?](https://www.reddit.com/r/agency/comments/11vt4ay/what_tools_do_you_use_to_manage_your_clients_work/)
- **Contexte :** une agence recherche une solution simple pour gérer le travail réalisé pour plusieurs clients.
- **Extrait pertinent :** « Manage all our clients' work in the same place, keep track of tasks, and be transparent about progress. »
- **Ce que cela indique :** la centralisation du suivi et la transparence envers les clients correspondent à un besoin explicitement formulé.

### Source 3 — Désorganisation lors de la croissance d’une agence

- **Type :** retour d’expérience publié sur le forum `r/agency`.
- **Lien :** [The productivity systems that saved my agency from chaos](https://www.reddit.com/r/agency/comments/1o09h1n/the_productivity_systems_that_saved_my_agency_from_chaos/)
- **Contexte :** un dirigeant décrit le passage d’une activité individuelle à une petite équipe travaillant pour plusieurs clients.
- **Extrait pertinent :** « Missed deadlines, scattered communication, and me drowning in tasks. »
- **Ce que cela indique :** la multiplication des clients et des collaborateurs rend le suivi plus difficile et disperse la communication.

### Source 4 — Maîtrise technologique et souveraineté

- **Type :** étude sectorielle menée auprès de 507 entreprises.
- **Lien :** [Open Source Monitor France 2023](https://cnll.fr/media/Open-Source-Monitor-France-Rapport-2023.pdf)
- **Contexte :** le rapport analyse l’usage de l’open source et son apport à la souveraineté numérique.
- **Extrait pertinent :** « 9 entreprises sur 10 considèrent l’open source comme un atout majeur pour la souveraineté numérique de la France et de l’Europe. »
- **Ce que cela indique :** la maîtrise du code et des données constitue un argument crédible pour une solution déployable sur l’infrastructure du client.

## Synthèse des enseignements

La recherche fait apparaître quatre attentes convergentes :

1. disposer d’un état de référence unique pour les missions clients ;
2. éviter la complexité des plateformes généralistes très configurables ;
3. partager un avancement compréhensible sans exposer le fonctionnement interne de l’équipe ;
4. garder la possibilité de maîtriser l’hébergement et les données.

Le problème n’est donc pas uniquement le nombre d’abonnements. Il concerne surtout la duplication des informations, le manque de visibilité commune et la dépendance opérationnelle envers plusieurs outils.

## Jobs To Be Done retenu

> Quand je pilote plusieurs missions clients avec une petite équipe, je veux partager une vision unique et actualisée de leur avancement, pour éviter de recopier les informations entre plusieurs SaaS et conserver la maîtrise de nos données.

## Décision produit

La V1 se concentre sur un cockpit de mission client auto-hébergeable :

- l’équipe organise ses tâches et livrables dans un Kanban interne ;
- le client consulte une vue simplifiée et authentifiée ;
- le client valide un livrable ou demande une révision motivée ;
- l’avancement client est calculé à partir des livrables validés.

## Limites de la recherche

- Les témoignages proviennent principalement de communautés anglophones et ne représentent pas statistiquement toutes les ESN françaises.
- Les auteurs se déclarent membres ou dirigeants d’agences, sans vérification indépendante de leur profil.
- Le rapport Open Source Monitor soutient l’enjeu de souveraineté, mais ne porte pas spécifiquement sur la gestion de missions en ESN.
- Aucun entretien direct avec une ESN française n’a encore été réalisé.

La prochaine validation recommandée consiste à interroger un ou deux dirigeants ou chefs de projet d’ESN sur leurs outils actuels, le temps consacré au reporting client et leur intérêt réel pour un déploiement on-premise.
