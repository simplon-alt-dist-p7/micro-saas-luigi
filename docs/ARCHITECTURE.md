# Architecture — Cockpit de suivi de mission client

| Information | Valeur |
| --- | --- |
| Version | 0.1 |
| Date | 2 septembre 2026 |
| Statut | Architecture logique de Phase 1 |
| Périmètre | V1 définie dans le PRD |

## 1. Objectifs et contraintes

L’architecture doit permettre de construire une V1 maintenable par une petite équipe, déployable dans le cloud ou sur l’infrastructure d’un client, et indépendante de tout service cloud propriétaire obligatoire.

Les contraintes structurantes sont :

- un frontend et un backend API explicitement découplés ;
- un cloisonnement strict des organisations et des données client ;
- des mises à jour instantanées sans polling fréquent ;
- un déploiement On-Premise reproductible ;
- une seule fonctionnalité forte en V1 : suivre une mission et valider ses livrables ;
- aucun code applicatif ni détail physique de conteneurisation pendant la Phase 1.

Le diagramme logique associé est disponible dans [diagrams/deployment.png](diagrams/deployment.png).

## 2. Décision d’architecture

### Monolithe modulaire découplé

Le système suit un **monolithe modulaire** organisé en couches et inspiré de l’architecture hexagonale. Next.js et Fastify sont deux applications distinctes dans le même dépôt. Le backend reste un seul déploiement métier, mais ses modules communiquent par des interfaces explicites.

Ce choix évite la complexité opérationnelle des microservices tout en permettant d’extraire ultérieurement un composant, par exemple le temps réel collaboratif, sans déplacer les règles métier.

La structure cible de Phase 2 sera :

```text
apps/
├── web/                 application Next.js
└── api/                 API Fastify
packages/
├── contracts/           schémas d’échange et types partagés
└── config/              configuration TypeScript partagée
db/
└── migrations/          migrations SQL versionnées
tests/                   tests transverses et end-to-end
compose.yml              packaging On-Premise
```

Cette structure est une cible et ne doit pas être créée avant la Phase 2.

## 3. Stack retenue

| Élément | Choix | Justification |
| --- | --- | --- |
| Langage | TypeScript | Un langage commun au frontend, au backend et aux contrats réduit les erreurs d’intégration. |
| Frontend | Next.js avec App Router | Fournit routage, layouts, rendu serveur et composants React interactifs pour le Kanban et le portail. |
| Backend | Fastify | API légère, validation par schémas, bonnes performances et prise en charge adaptée des connexions WebSocket. |
| Contrat API | REST sur HTTP/JSON | Simple à documenter, tester et consommer indépendamment du frontend. |
| Temps réel | WebSocket sécurisé | Diffuse uniquement les changements utiles sans polling fréquent. |
| ORM | Drizzle ORM | Reste proche de SQL, conserve le typage TypeScript et génère des migrations SQL lisibles. |
| SGBD | PostgreSQL | Transactions, contraintes, indexation, Row-Level Security et portabilité cloud/On-Premise. |
| Reverse proxy | Caddy | Point d’entrée unique, routage vers le frontend ou l’API et gestion de TLS. |
| Packaging | Docker Compose | Décrit une installation reproductible sur un serveur unique sans orchestrateur complexe. |

Supabase, Vercel, AWS, Redis et un moteur de recherche externe ne font pas partie du socle obligatoire. L’application utilise un PostgreSQL standard et ne dépend d’aucune API spécifique à un fournisseur.

## 4. Composants et responsabilités

### Frontend Next.js

- rend l’espace interne et le portail client ;
- gère navigation, formulaires, états de chargement et accessibilité ;
- consomme exclusivement les contrats exposés par Fastify ;
- ouvre une connexion WebSocket vers Fastify pour les événements autorisés ;
- n’applique les permissions dans l’interface que pour l’expérience utilisateur, jamais comme contrôle de sécurité unique.

### Backend Fastify

- authentifie les requêtes et résout l’organisation courante ;
- valide les entrées et produit des réponses limitées au rôle courant ;
- exécute les règles métier et les transactions ;
- accède à PostgreSQL par les repositories Drizzle ;
- publie les événements temps réel après validation des transactions ;
- constitue l’unique autorité pour les permissions métier.

### PostgreSQL

- constitue la source de vérité ;
- garantit clés, unicité, relations et contraintes de statut ;
- conserve sessions, données métier et historique d’audit ;
- applique une défense en profondeur contre les accès inter-organisations.

### Caddy

- termine HTTPS ;
- transmet `/api/*` et `/ws` à Fastify ;
- transmet les autres requêtes à Next.js ;
- applique les limites réseau générales et les en-têtes de sécurité adaptés.

### Service SMTP facultatif

Un serveur SMTP compatible peut envoyer invitations et réinitialisations de mot de passe. Une indisponibilité SMTP ne doit pas interrompre le suivi d’une mission déjà active.

## 5. Couches du backend

### Présentation

Les routes et contrôleurs Fastify traduisent HTTP/JSON en commandes applicatives. Des schémas JSON valident paramètres, corps et réponses à la frontière du système. Cette couche ne contient aucune règle métier.

### Application

Les cas d’utilisation orchestrent les opérations, les transactions et les autorisations : créer une mission, changer le statut d’une tâche, soumettre un livrable, valider ou demander une révision. Ils dépendent d’interfaces de repository et de publication d’événements.

### Domaine

Le domaine porte les invariants indépendants de Fastify et de Drizzle : transitions de statut autorisées, motif de révision obligatoire, calcul de progression et visibilité interne/client.

### Infrastructure

Les adapters implémentent les repositories Drizzle, les sessions PostgreSQL, le WebSocket, l’horloge et le SMTP. Ils peuvent être remplacés sans modifier le domaine.

### Données

PostgreSQL applique les contraintes finales. Les migrations SQL sont versionnées, relues et exécutées séparément du démarrage normal de l’API.

## 6. Modules métier

| Module | Responsabilité | Données principales |
| --- | --- | --- |
| Identité et organisations | utilisateurs, sessions, rôles et rattachements | organisation, utilisateur, session, rôle |
| Clients et missions | clients, missions et autorisations client | client, mission, accès client |
| Travail interne | Kanban et tâches non visibles du client | tâche, assignation, ordre |
| Livrables et validations | soumission, validation, révision et progression | livrable, décision |
| Audit | historique immuable des transitions métier | événement d’audit |

Chaque module possède ses règles et ses repositories. Une route ne lit pas directement les tables appartenant à un autre module sans passer par son contrat applicatif.

## 7. Flux critiques

### Consultation du portail client

1. Le navigateur envoie la session à Caddy par HTTPS.
2. Caddy transmet la requête API à Fastify.
3. Fastify valide la session, le rôle et le rattachement à la mission.
4. Le repository interroge PostgreSQL dans le contexte de l’organisation.
5. Un DTO exclut tâches, estimations et champs internes.
6. Fastify retourne la vue client en HTTP/JSON.

### Décision sur un livrable

1. Fastify valide la session, l’autorisation, le statut courant et le motif éventuel.
2. Une transaction verrouille le livrable, enregistre la décision et l’événement d’audit, puis recalcule la progression.
3. La transaction est validée entièrement ou annulée entièrement.
4. Après validation, l’API publie un événement WebSocket aux membres autorisés de l’organisation et de la mission.

Un numéro de version sur le livrable permet de refuser une décision fondée sur un état devenu obsolète.

## 8. Cloisonnement multi-tenant

La V1 utilise une base et un schéma partagés. Chaque table métier porte un `organization_id` non nul.

Le cloisonnement combine plusieurs contrôles :

- l’organisation est résolue depuis la session, jamais depuis une valeur libre fournie par le navigateur ;
- chaque cas d’utilisation vérifie rôle et rattachement à la ressource ;
- les relations et unicités incluent `organization_id` lorsque cela empêche une référence inter-organisation ;
- PostgreSQL Row-Level Security utilise le contexte d’organisation de la transaction comme défense en profondeur ;
- les canaux WebSocket sont autorisés côté serveur et segmentés par organisation et mission ;
- les journaux techniques évitent le contenu métier et conservent seulement les identifiants nécessaires au diagnostic.

Des tests d’isolation tenteront systématiquement d’accéder à une ressource en utilisant l’identifiant d’une autre organisation.

## 9. Sécurité

Ces mesures sont inspirées des bonnes pratiques de l’ANSSI ; elles ne constituent pas une certification.

### Validation et sorties

- Fastify valide toutes les entrées avec des schémas stricts et rejette les propriétés inconnues.
- Les identifiants, longueurs, formats et transitions de statut sont contrôlés avant toute écriture.
- Les réponses utilisent des DTO dédiés ; une entité interne n’est jamais sérialisée directement vers le client.
- La taille du corps HTTP est limitée à 1 Mio pour la V1, qui n’héberge pas de fichiers.

### Authentification et sessions

- les mots de passe sont hachés avec Argon2id et un paramétrage maintenu selon les recommandations au moment de l’implémentation ;
- les sessions utilisent un identifiant opaque aléatoire, stocké sous forme protégée dans PostgreSQL ;
- le cookie de session est `Secure`, `HttpOnly`, `SameSite=Lax`, limité au domaine et renouvelé après authentification ;
- les requêtes mutatives vérifient l’origine et utilisent une protection CSRF ;
- les tentatives d’authentification et opérations sensibles sont limitées en fréquence ;
- une déconnexion, une désactivation ou une rotation de privilège invalide les sessions concernées.

### Autorisations

- le principe du moindre privilège s’applique aux rôles Administrateur, Chef de projet, Collaborateur et Client invité ;
- Fastify contrôle chaque ressource, y compris lorsqu’un identifiant valide est fourni ;
- un client invité ne reçoit jamais les tâches, estimations ou données d’une autre mission ;
- les changements de statut sensibles sont inscrits dans un historique non modifiable par les utilisateurs ordinaires.

### Secrets et dépendances

- aucun secret n’est versionné ;
- `.env.example` ne contiendra que les noms et exemples non sensibles en Phase 2 ;
- l’installation génère des secrets distincts et restreint les permissions du fichier de configuration ;
- les images et dépendances sont épinglées, auditées et mises à jour par un processus contrôlé ;
- les sauvegardes sont chiffrées et une restauration est testée périodiquement.

## 10. Sobriété et performance

- les listes utilisent une pagination par curseur de 50 éléments par défaut et 100 au maximum ;
- les endpoints sélectionnent uniquement les colonnes nécessaires au DTO ;
- les index couvrent `organization_id`, les clés de rattachement, les statuts et les tris fréquents ;
- les ressources statiques versionnées utilisent un cache HTTP long ;
- les données métier privées utilisent des validateurs HTTP ciblés et ne sont jamais mises en cache publiquement ;
- aucun Redis n’est ajouté tant qu’une mesure ne justifie pas un cache partagé ;
- le WebSocket diffuse des événements courts d’invalidation ou de changement, pas des objets métier complets ;
- une reconnexion WebSocket récupère l’état courant par l’API au lieu de rejouer un historique illimité ;
- aucun polling fréquent, CDN externe, script marketing ou télémétrie tierce n’est activé par défaut ;
- les limites, tris et filtres sont appliqués côté base avant sérialisation.

## 11. Déploiement et exploitation

En Phase 1, le diagramme reste logique : navigateur, reverse proxy, frontend, backend, base de données et SMTP facultatif. Les VPS, conteneurs, volumes et règles physiques seront détaillés en Phase 2.

La distribution On-Premise de Phase 2 utilisera Docker Compose avec des images versionnées. Après préparation du serveur et du domaine, l’objectif d’installation est :

```bash
sudo ./install.sh
```

L’installateur devra vérifier les prérequis, générer les secrets, démarrer les services dans l’ordre, exécuter les migrations, créer le premier administrateur et contrôler les points de santé. Il devra être idempotent et ne jamais supprimer les données lors d’une relance.

Les mises à jour, sauvegardes, restaurations et désinstallations disposeront de commandes séparées. PostgreSQL utilisera un volume persistant qui ne sera jamais intégré à une image applicative.

## 12. Évolutions conditionnelles

| Évolution | Condition d’introduction |
| --- | --- |
| Redis | Plusieurs instances exigent un cache, une présence WebSocket ou une file partagée. |
| Worker asynchrone | Une opération dépasse la durée acceptable d’une requête ou nécessite des reprises durables. |
| Stockage S3 compatible | La V1 commence à héberger des fichiers plutôt que leurs seules références. |
| Moteur de recherche | Les index PostgreSQL et la recherche plein texte ne respectent plus les objectifs mesurés. |
| Service Yjs/Hocuspocus | L’édition collaborative riche entre dans le périmètre produit. |
| Backend supplémentaire | Une capacité doit évoluer, être sécurisée ou être déployée indépendamment de l’API principale. |

Ces composants seront ajoutés sur preuve d’un besoin. Fastify reste l’API principale ; Next.js ne contient aucune règle métier backend.

## 13. Risques et réponses

| Risque | Réponse architecturale |
| --- | --- |
| Fuite entre organisations | Contrôles API, contraintes composites, RLS et tests d’isolation. |
| Décisions concurrentes sur un livrable | Transaction, verrouillage et contrôle de version. |
| Perte d’une mise à jour WebSocket | Relecture de l’état courant par REST après reconnexion. |
| Installation On-Premise trop complexe | Peu de services obligatoires, Compose et installateur idempotent. |
| Dépendance à un fournisseur | Protocoles standards, PostgreSQL standard et adapters remplaçables. |
| Dérive vers une plateforme généraliste | Modules limités au parcours défini dans le PRD et conditions d’évolution explicites. |

## 14. Décisions à vérifier en Phase 2

- mesurer la latence des listes et du Kanban avec plusieurs milliers de tâches ;
- tester le cloisonnement entre deux organisations ;
- tester deux décisions concurrentes sur le même livrable ;
- mesurer le nombre de connexions WebSocket supporté par une instance ;
- réaliser une installation sur un serveur Linux vierge ;
- sauvegarder puis restaurer une instance complète ;
- vérifier l’accessibilité du parcours principal selon RGAA 4.1.
