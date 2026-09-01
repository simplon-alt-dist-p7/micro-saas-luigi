# PRD lean — Cockpit de suivi de mission client

| Information | Valeur |
| --- | --- |
| Version | 0.1 |
| Date | 1er septembre 2026 |
| Statut | Hypothèse produit à valider |
| Phase | Conception — Phase 1 |

## 1. Résumé

La vision de Micro SaaS Luigi est de devenir un espace de travail souverain pour les petites ESN et agences numériques françaises de 5 à 30 personnes. Le produit vise à centraliser progressivement le pilotage des missions clients afin de réduire la fragmentation et la dépendance à plusieurs solutions SaaS.

La V1 reste volontairement limitée à un cockpit de suivi et de validation des livrables. L’équipe pilote les tâches et les livrables dans un Kanban interne. Le client accède à un portail authentifié présentant uniquement l’avancement utile, les échéances, les blocages et les livrables soumis. Il peut valider un livrable ou demander une révision avec un motif obligatoire.

Cette première fonctionnalité fournit une source de vérité commune entre l’équipe et son client sans exposer les détails internes du projet. La solution doit être utilisable dans le cloud et déployable sur l’infrastructure de l’ESN, sans dépendance obligatoire envers un service cloud propriétaire.

## 2. Problème

Les petites ESN utilisent fréquemment plusieurs services pour organiser les tâches, documenter les décisions et communiquer l’avancement aux clients. L’état d’une mission se retrouve alors réparti entre tableaux de tâches, documents, messages et comptes rendus.

Cette fragmentation produit plusieurs difficultés :

- le chef de projet recopie et reformule manuellement l’avancement ;
- les informations transmises au client peuvent être incomplètes ou obsolètes ;
- l’équipe et le client ne travaillent pas à partir de la même représentation de la mission ;
- les données opérationnelles sont distribuées entre plusieurs fournisseurs ;
- les plateformes généralistes sont souvent trop complexes pour une petite structure.

La recherche qualitative soutenant cette hypothèse est documentée dans [recherche-jtbd.md](recherche-jtbd.md).

## 3. Cible et persona principal

### Segment

Petites ESN et agences numériques françaises de 5 à 30 personnes réalisant simultanément plusieurs missions pour des clients externes.

### Persona principal — hypothèse

**Antoine, 38 ans, dirigeant et chef de projet d’une agence de 12 personnes.**

Il supervise plusieurs missions en parallèle, répartit le travail et communique régulièrement leur avancement. Son équipe utilise un outil de tâches, une messagerie et des documents partagés. Il veut réduire les doubles saisies et présenter une information claire aux clients sans les inviter dans l’espace de travail interne.

Ses objectifs sont :

- connaître rapidement l’état réel de chaque mission ;
- identifier les livrables bloqués ou en attente de validation ;
- éviter de produire manuellement des comptes rendus redondants ;
- limiter la dispersion des données de ses clients.

### Autres acteurs

- **Administrateur :** gère l’organisation, les utilisateurs et les paramètres de déploiement.
- **Chef de projet :** crée les missions, organise les tâches et soumet les livrables.
- **Collaborateur :** met à jour les tâches qui lui sont assignées.
- **Client invité :** consulte ses missions et répond aux demandes de validation.

## 4. Jobs To Be Done

> Quand je pilote plusieurs missions clients avec une petite équipe, je veux partager une vision unique et actualisée de leur avancement, pour éviter de recopier les informations entre plusieurs SaaS et conserver la maîtrise de nos données.

## 5. Proposition de valeur unique

> Un cockpit de mission auto-hébergeable qui transforme l’avancement interne d’une petite ESN en une vue client claire et directement validable.

Le produit se différencie d’un gestionnaire de tâches généraliste par trois choix :

- un parcours centré sur les missions et livrables client ;
- une séparation stricte entre travail interne et information visible du client ;
- un déploiement possible sur l’infrastructure choisie par l’ESN.

## 6. Fonctionnalité principale de la V1

La fonctionnalité principale est le **suivi et la validation des livrables d’une mission client**.

### Parcours principal

1. Le chef de projet crée une mission et y définit des livrables.
2. L’équipe organise et met à jour ses tâches dans le Kanban interne.
3. Le chef de projet passe un livrable au statut `À valider`.
4. Le client consulte le livrable dans son portail authentifié.
5. Le client choisit `Valider` ou `Demander une révision`.
6. Une demande de révision exige un motif visible par l’équipe.
7. L’état du livrable et l’avancement global de la mission sont actualisés.
8. La décision est conservée dans l’historique de la mission.

### Périmètre fonctionnel inclus

- organisations et utilisateurs authentifiés ;
- rôles administrateur, chef de projet, collaborateur et client invité ;
- clients et missions ;
- Kanban interne avec des tâches simples ;
- livrables rattachés à une mission ;
- soumission d’un livrable à validation ;
- portail client limité aux missions autorisées ;
- validation ou demande de révision motivée ;
- progression calculée à partir des livrables validés ;
- historique des changements de statut ;
- actualisation en temps réel des statuts utiles ;
- packaging compatible avec un déploiement cloud ou on-premise.

## 7. Règles métier principales

- Un utilisateur appartient à une seule organisation dans la V1.
- Toutes les données sont rattachées à une organisation et cloisonnées entre organisations.
- Un client invité ne voit que les missions auxquelles il est explicitement rattaché.
- Les tâches, estimations et informations internes ne sont jamais exposées au client.
- Seul un chef de projet peut soumettre un livrable à validation.
- Seul un client autorisé sur la mission peut répondre à cette demande.
- Un livrable soumis peut être validé ou renvoyé en révision.
- Une demande de révision comporte obligatoirement un motif.
- La progression visible du client correspond au rapport entre les livrables validés et les livrables prévus.
- Chaque changement de statut conserve son auteur, sa date et son état précédent.

## 8. Métriques de succès

Les valeurs suivantes sont des seuils initiaux à confronter à des utilisateurs réels :

1. **Temps de reporting :** réduire d’au moins 50 % le temps hebdomadaire consacré par un chef de projet aux comptes rendus d’avancement.
2. **Adoption de la validation :** obtenir au moins 80 % des décisions de validation directement dans le portail sur les missions pilotes.
3. **Délai de validation :** atteindre un délai médian inférieur à trois jours ouvrés entre la soumission et la décision du client.

Les mesures nécessiteront une valeur de référence collectée avant le test et un suivi sur plusieurs missions pilotes.

## 9. Hors périmètre explicite

La V1 ne couvre pas :

- la comptabilité, les devis, la facturation et les paiements ;
- la paie, les congés et les fonctions de ressources humaines ;
- le CRM commercial et la prospection ;
- le suivi du temps, les budgets, la capacité et la rentabilité ;
- le chat, la visioconférence et l’hébergement des emails ;
- l’édition collaborative riche de documents ;
- les vues Gantt, calendrier et portefeuille avancé ;
- les champs personnalisés avancés ;
- les intégrations avec ClickUp, Slack, Jira ou Notion ;
- la recherche avancée ;
- l’assistance IA locale ou distante ;
- une application mobile native.

Ces éléments pourront être réévalués après validation de la fonctionnalité principale. Ils ne doivent pas complexifier la conception de la V1.

## 10. Contraintes non fonctionnelles

- Le frontend et le backend API sont explicitement découplés.
- Le produit ne dépend d’aucun service cloud propriétaire obligatoire.
- Le déploiement on-premise doit être documenté et reproductible.
- Les secrets sont fournis par configuration et ne sont jamais stockés dans Git.
- Les autorisations sont contrôlées côté API pour chaque ressource.
- Les listes sont paginées et les charges utiles limitées.
- Aucun mécanisme de polling fréquent n’est utilisé pour les mises à jour en temps réel.
- Les interfaces principales visent la conformité RGAA 4.1.

## 11. Hypothèses et risques

| Hypothèse ou risque | Impact | Réponse prévue |
| --- | --- | --- |
| Les petites ESN consacrent assez de temps au reporting pour vouloir changer d’outil. | Élevé | Mesurer ce temps lors d’entretiens et de tests pilotes. |
| Les clients accepteront de créer un compte supplémentaire. | Élevé | Tester un accès invité simple et mesurer l’activation. |
| Le déploiement on-premise constitue un critère d’achat réel. | Élevé | Interroger séparément décideurs techniques et métiers. |
| Le périmètre dérive vers une plateforme tout-en-un. | Élevé | Maintenir le hors-périmètre et prioriser uniquement le parcours de validation. |
| Les solutions concurrentes couvrent déjà le besoin. | Moyen | Comparer simplicité, séparation interne/client et maîtrise des données. |
| Le temps réel et le cloisonnement augmentent la complexité technique. | Moyen | Concevoir les permissions et le modèle d’événements avant le développement. |
| Une indisponibilité du portail bloque une validation. | Moyen | Prévoir reprise, journalisation et sauvegarde dans l’architecture. |

## 12. Critères d’acceptation produit

La V1 est considérée comme fonctionnellement démontrable lorsqu’un chef de projet peut :

- créer une mission et ses livrables ;
- organiser les tâches internes sans les exposer au client ;
- soumettre un livrable à validation ;
- permettre au bon client de consulter uniquement sa mission ;
- recevoir une validation ou une demande de révision motivée ;
- constater l’actualisation de la progression et de l’historique ;
- exécuter ce parcours sur une installation ne nécessitant aucun service cloud propriétaire.
