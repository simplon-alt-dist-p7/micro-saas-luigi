# Dictionnaire de données — Cockpit

| Information | Valeur |
| --- | --- |
| Version | 0.1 |
| Date | 4 septembre 2026 |
| SGBD cible | PostgreSQL |
| Périmètre | Fonctionnalités prévues pour la V1 |

Ce dictionnaire décrit les données persistées par Cockpit. Les noms techniques restent en anglais dans la base ; les libellés affichés dans l’interface sont traduits en français.

## Légende

- `PK` : clé primaire ;
- `FK` : clé étrangère ;
- `UQ` : valeur ou groupe de valeurs unique ;
- `non` dans la colonne « Null » : valeur obligatoire ;
- `oui` dans la colonne « Null » : valeur facultative.

Les identifiants sont des `bigint generated always as identity`. Les horodatages utilisent `timestamptz` afin de conserver un instant non ambigu.

## organizations

Représente une ESN ou une agence utilisant une installation de Cockpit.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| organization_id | bigint | non | PK | Identifiant technique de l’organisation. | 42 |
| name | text | non | — | Nom de l’organisation, de 1 à 160 caractères après suppression des espaces périphériques. | Atelier Horizon |
| created_at | timestamptz | non | — | Date et heure de création. Valeur initiale : instant courant. | 2026-09-04T08:30:00Z |
| updated_at | timestamptz | non | — | Date et heure de dernière modification. | 2026-09-04T09:15:00Z |

## users

Représente l’identité globale d’une personne pouvant accéder à Cockpit.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| user_id | bigint | non | PK | Identifiant technique de l’utilisateur. | 108 |
| email | text | non | UQ insensible à la casse | Adresse de connexion, de 3 à 320 caractères. | lea@example.fr |
| password_hash | text | non | — | Empreinte du mot de passe ; le mot de passe en clair n’est jamais stocké. | argon2id… |
| display_name | text | non | — | Nom affiché, de 1 à 120 caractères après suppression des espaces périphériques. | Léa Martin |
| is_active | boolean | non | — | Indique si le compte peut être utilisé. Valeur initiale : `true`. | true |
| created_at | timestamptz | non | — | Date et heure de création du compte. | 2026-09-04T08:30:00Z |
| updated_at | timestamptz | non | — | Date et heure de dernière modification du compte. | 2026-09-04T09:15:00Z |

## clients

Représente une entreprise cliente suivie par une organisation.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| client_id | bigint | non | PK | Identifiant technique du client. | 73 |
| organization_id | bigint | non | FK → organizations | Organisation propriétaire du client. Le couple avec `client_id` est unique. | 42 |
| name | text | non | — | Nom du client, de 1 à 160 caractères après suppression des espaces périphériques. | Maison Rivage |
| created_at | timestamptz | non | — | Date et heure de création. | 2026-09-04T08:45:00Z |
| updated_at | timestamptz | non | — | Date et heure de dernière modification. | 2026-09-04T09:10:00Z |

## organization_memberships

Associe un utilisateur à son organisation et détermine son rôle. Dans la V1, un utilisateur possède une seule adhésion.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| membership_id | bigint | non | PK | Identifiant technique de l’adhésion. | 205 |
| organization_id | bigint | non | FK → organizations | Organisation à laquelle appartient l’utilisateur. Le couple avec `membership_id` est unique. | 42 |
| user_id | bigint | non | FK → users, UQ | Utilisateur associé à l’adhésion. | 108 |
| client_id | bigint | oui | FK → clients | Client représenté. Obligatoire uniquement pour le rôle `client_guest`. | 73 |
| role | text | non | CHECK | Rôle parmi `admin`, `project_manager`, `collaborator`, `client_guest`. | project_manager |
| joined_at | timestamptz | non | — | Date et heure d’entrée dans l’organisation. | 2026-09-04T08:50:00Z |

## sessions

Représente une session d’authentification active.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| session_id | bigint | non | PK | Identifiant technique de la session. | 910 |
| organization_id | bigint | non | FK composite → organization_memberships | Organisation placée dans le contexte de sécurité de la session. | 42 |
| membership_id | bigint | non | FK composite → organization_memberships | Adhésion authentifiée dans l’organisation. | 205 |
| token_hash | text | non | UQ, CHECK | Empreinte hexadécimale du jeton de session, exactement 64 caractères. | 4f9c…a82e |
| expires_at | timestamptz | non | CHECK | Date d’expiration, obligatoirement postérieure à `created_at`. | 2026-09-11T08:50:00Z |
| last_seen_at | timestamptz | non | — | Dernière activité connue de la session. | 2026-09-04T09:12:00Z |
| created_at | timestamptz | non | — | Date et heure de création de la session. | 2026-09-04T08:50:00Z |

## missions

Représente une mission réalisée par l’organisation pour un client.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| mission_id | bigint | non | PK | Identifiant technique de la mission. | 301 |
| organization_id | bigint | non | FK composite → clients | Organisation propriétaire de la mission. Le couple avec `mission_id` est unique. | 42 |
| client_id | bigint | non | FK composite → clients | Client concerné par la mission. | 73 |
| name | text | non | CHECK | Nom de la mission, de 1 à 160 caractères après suppression des espaces périphériques. | Refonte du portail client |
| description | text | oui | — | Description détaillée de la mission. | Concevoir et livrer le nouveau portail. |
| status | text | non | CHECK | État parmi `draft`, `active`, `completed`, `archived`. Valeur initiale : `draft`. | active |
| start_date | date | oui | CHECK avec due_date | Date civile de début prévue ou réelle. | 2026-09-07 |
| due_date | date | oui | CHECK avec start_date | Échéance, égale ou postérieure à la date de début lorsqu’elles sont renseignées. | 2026-10-30 |
| created_at | timestamptz | non | — | Date et heure de création. | 2026-09-04T09:00:00Z |
| updated_at | timestamptz | non | — | Date et heure de dernière modification. | 2026-09-04T09:20:00Z |

## mission_accesses

Autorise une adhésion à consulter ou piloter une mission.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| organization_id | bigint | non | PK, FK composite | Organisation commune à la mission et à l’adhésion. | 42 |
| mission_id | bigint | non | PK, FK composite → missions | Mission rendue accessible. | 301 |
| membership_id | bigint | non | PK, FK composite → organization_memberships | Adhésion autorisée. | 205 |
| granted_at | timestamptz | non | — | Date et heure d’attribution de l’accès. | 2026-09-04T09:05:00Z |

## tasks

Représente une tâche affichée dans le Kanban interne d’une mission.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| task_id | bigint | non | PK | Identifiant technique de la tâche. | 1204 |
| organization_id | bigint | non | FK composite | Organisation propriétaire. Le couple avec `task_id` est unique. | 42 |
| mission_id | bigint | non | FK composite → missions | Mission à laquelle appartient la tâche. | 301 |
| assignee_membership_id | bigint | oui | FK composite → organization_memberships | Adhésion responsable de la tâche, si elle est affectée. | 205 |
| title | text | non | CHECK | Intitulé de 1 à 200 caractères après suppression des espaces périphériques. | Valider les contenus |
| description | text | oui | — | Détails nécessaires à la réalisation. | Contrôler les textes avec le client. |
| status | text | non | CHECK | Colonne parmi `backlog`, `todo`, `in_progress`, `done`. Valeur initiale : `backlog`. | in_progress |
| position | bigint | non | CHECK | Ordre de la carte dans sa colonne, supérieur ou égal à zéro. | 2048 |
| due_date | date | oui | — | Échéance civile de la tâche. | 2026-09-18 |
| created_at | timestamptz | non | — | Date et heure de création. | 2026-09-04T09:10:00Z |
| updated_at | timestamptz | non | — | Date et heure de dernière modification. | 2026-09-04T09:25:00Z |

## task_status_changes

Conserve l’historique non modifiable des changements de statut d’une tâche.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| task_status_change_id | bigint | non | PK | Identifiant technique du changement. | 4501 |
| organization_id | bigint | non | FK composite | Organisation propriétaire de l’historique. | 42 |
| task_id | bigint | non | FK composite → tasks | Tâche modifiée. | 1204 |
| actor_membership_id | bigint | non | FK composite → organization_memberships | Adhésion ayant effectué le changement. | 205 |
| previous_status | text | non | CHECK | Statut avant le changement, dans la liste des statuts de tâche. | todo |
| new_status | text | non | CHECK | Nouveau statut, différent du précédent. | in_progress |
| changed_at | timestamptz | non | — | Date et heure du changement. | 2026-09-04T09:25:00Z |

## deliverables

Représente un livrable attendu ou soumis dans une mission.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| deliverable_id | bigint | non | PK | Identifiant technique du livrable. | 807 |
| organization_id | bigint | non | FK composite | Organisation propriétaire. Le couple avec `deliverable_id` est unique. | 42 |
| mission_id | bigint | non | FK composite → missions | Mission à laquelle appartient le livrable. | 301 |
| title | text | non | CHECK | Intitulé de 1 à 200 caractères après suppression des espaces périphériques. | Maquette du tableau de bord |
| description | text | oui | — | Description du résultat attendu. | Écrans desktop et mobile finalisés. |
| reference_url | text | oui | — | Adresse externe du fichier ou de la ressource ; le binaire n’est pas stocké dans la V1. | https://files.example.fr/maquette |
| status | text | non | CHECK | État parmi `draft`, `in_progress`, `to_validate`, `validated`, `to_revise`. Valeur initiale : `draft`. | to_validate |
| version | integer | non | CHECK | Numéro de version supérieur ou égal à 1. | 2 |
| due_date | date | oui | — | Échéance civile du livrable. | 2026-09-25 |
| submitted_at | timestamptz | oui | CHECK | Date de soumission ; obligatoire lorsque le statut est `to_validate`. | 2026-09-20T14:00:00Z |
| validated_at | timestamptz | oui | CHECK | Date de validation ; obligatoire lorsque le statut est `validated`. | 2026-09-21T10:30:00Z |
| created_at | timestamptz | non | — | Date et heure de création. | 2026-09-04T09:15:00Z |
| updated_at | timestamptz | non | — | Date et heure de dernière modification. | 2026-09-20T14:00:00Z |

## deliverable_status_changes

Conserve l’historique non modifiable des décisions prises sur un livrable.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| deliverable_status_change_id | bigint | non | PK | Identifiant technique du changement. | 6201 |
| organization_id | bigint | non | FK composite | Organisation propriétaire de l’historique. | 42 |
| deliverable_id | bigint | non | FK composite → deliverables | Livrable concerné. | 807 |
| actor_membership_id | bigint | non | FK composite → organization_memberships | Adhésion ayant effectué le changement. | 205 |
| previous_status | text | non | CHECK | Statut avant le changement, dans la liste des statuts de livrable. | to_validate |
| new_status | text | non | CHECK | Nouveau statut, différent du précédent. | to_revise |
| reason | text | oui | CHECK | Motif de décision ; obligatoire et non vide pour `to_revise`. | Corriger le contraste du bouton principal. |
| changed_at | timestamptz | non | — | Date et heure du changement. | 2026-09-21T10:30:00Z |

## audit_events

Conserve les événements sensibles ou structurants produits par une personne ou par le système.

| Champ | Type | Null | Clé ou référence | Définition et règle | Exemple |
| --- | --- | --- | --- | --- | --- |
| audit_event_id | bigint | non | PK | Identifiant technique de l’événement. | 9901 |
| organization_id | bigint | non | FK → organizations | Organisation dans laquelle l’événement s’est produit. | 42 |
| actor_membership_id | bigint | oui | FK composite → organization_memberships | Acteur humain ; absent pour un événement automatique du système. | 205 |
| event_type | text | non | CHECK | Nature technique ou métier de l’événement, de 1 à 80 caractères. | mission.access_granted |
| resource_type | text | non | CHECK | Type de ressource concernée, de 1 à 80 caractères. | mission |
| resource_id | bigint | oui | — | Identifiant de la ressource lorsqu’elle en possède un. | 301 |
| occurred_at | timestamptz | non | — | Date et heure de l’événement. | 2026-09-04T09:05:00Z |

## Données calculées et non persistées

| Donnée | Définition | Source |
| --- | --- | --- |
| Progression d’une mission | Pourcentage de livrables au statut `validated` parmi les livrables prévus. | `deliverables.status` regroupé par mission |

## Données hors périmètre

La V1 ne persiste pas de données propres à la comptabilité, au CRM commercial, aux ressources humaines, à l’édition collaborative, aux champs personnalisés avancés ou à l’intelligence artificielle.
