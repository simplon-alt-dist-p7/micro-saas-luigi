# Modèle logique de données — Cockpit

## Notation

- `PK` désigne une clé primaire ;
- `FK` désigne une clé étrangère et la flèche suivant ses colonnes indique sa relation cible ;
- `UQ` désigne une contrainte d’unicité ;
- `NULL` désigne un attribut facultatif ;
- les pattes d’oie matérialisent les relations structurantes sans répéter tous les liens de cloisonnement par `organization_id`.

## Relations

- **organizations** (**organization_id**, name, created_at, updated_at)
- **users** (**user_id**, email [UQ], password_hash, display_name, is_active, created_at, updated_at)
- **clients** (**client_id**, organization_id [FK], name, created_at, updated_at), avec [UQ] (organization_id, client_id)
- **organization_memberships** (**membership_id**, organization_id [FK], user_id [FK, UQ], client_id [FK, NULL], role, joined_at), avec [UQ] (organization_id, membership_id)
- **sessions** (**session_id**, organization_id [FK], membership_id [FK], token_hash [UQ], expires_at, last_seen_at, created_at)
- **missions** (**mission_id**, organization_id [FK], client_id [FK], name, description, status, start_date, due_date, created_at, updated_at), avec [UQ] (organization_id, mission_id)
- **mission_accesses** (**organization_id** [FK], **mission_id** [FK], **membership_id** [FK], granted_at)
- **tasks** (**task_id**, organization_id [FK], mission_id [FK], assignee_membership_id [FK, NULL], title, description, status, position, due_date, created_at, updated_at), avec [UQ] (organization_id, task_id)
- **task_status_changes** (**task_status_change_id**, organization_id [FK], task_id [FK], actor_membership_id [FK], previous_status, new_status, changed_at)
- **deliverables** (**deliverable_id**, organization_id [FK], mission_id [FK], title, description, reference_url, status, version, due_date, submitted_at, validated_at, created_at, updated_at), avec [UQ] (organization_id, deliverable_id)
- **deliverable_status_changes** (**deliverable_status_change_id**, organization_id [FK], deliverable_id [FK], actor_membership_id [FK], previous_status, new_status, reason [NULL], changed_at)
- **audit_events** (**audit_event_id**, organization_id [FK], actor_membership_id [FK, NULL], event_type, resource_type, resource_id, occurred_at)

## Références

| Relation | Clé étrangère | Relation cible |
| --- | --- | --- |
| clients | organization_id | organizations |
| organization_memberships | organization_id | organizations |
| organization_memberships | user_id | users |
| organization_memberships | client_id | clients |
| sessions | (organization_id, membership_id) | organization_memberships |
| missions | (organization_id, client_id) | clients |
| mission_accesses | (organization_id, mission_id) | missions |
| mission_accesses | (organization_id, membership_id) | organization_memberships |
| tasks | (organization_id, mission_id) | missions |
| tasks | (organization_id, assignee_membership_id) | organization_memberships |
| task_status_changes | (organization_id, task_id) | tasks |
| task_status_changes | (organization_id, actor_membership_id) | organization_memberships |
| deliverables | (organization_id, mission_id) | missions |
| deliverable_status_changes | (organization_id, deliverable_id) | deliverables |
| deliverable_status_changes | (organization_id, actor_membership_id) | organization_memberships |
| audit_events | (organization_id, actor_membership_id) | organization_memberships |

## Contraintes structurantes

- Un utilisateur possède une seule adhésion d’organisation dans la V1.
- Un membre de rôle client_guest référence un client ; les autres rôles n’en référencent aucun.
- Toutes les références entre données métier utilisent le couple organization_id et identifiant afin d’interdire les rattachements inter-organisations.
- Une mission appartient à un seul client de son organisation.
- Une tâche et un livrable appartiennent à une seule mission.
- Les historiques de statut sont ajoutés sans modification ni suppression par l’application.
- La progression d’une mission est calculée depuis ses livrables validés et n’est pas stockée.
