# Modèle de données — Cockpit

| Information | Valeur |
| --- | --- |
| Version | 0.1 |
| Date | 3 septembre 2026 |
| SGBD cible | PostgreSQL |
| Périmètre | Ensemble des fonctionnalités prévues pour la V1 |

## 1. Livrables

- [MCD](diagrams/mcd.png), [source Draw.io](diagrams/mcd.drawio) et [source de contrôle Mocodo](diagrams/mcd.mcd) ;
- [MLD](diagrams/mld.png), [source Draw.io](diagrams/mld.drawio), [relations détaillées](diagrams/mld.md) et [source de contrôle Mocodo](diagrams/mld.mcd) ;
- [MPD](diagrams/mpd.png), [source Draw.io](diagrams/mpd.drawio), [source de contrôle Mocodo](diagrams/mpd.mcd) et [DDL PostgreSQL](database/schema.sql) ;
- [dictionnaire de données](data-dictionary.md).

## 2. Couverture fonctionnelle

| Fonction de la V1 | Entités ou relations principales |
| --- | --- |
| Organisations et comptes authentifiés | organization, user_account, organization_membership, session |
| Rôles et rattachement client | organization_membership, client, represents |
| Clients et missions | client, mission |
| Autorisations par mission | mission_access |
| Kanban interne | task, task_status_change |
| Livrables et références externes | deliverable |
| Validation ou demande de révision | deliverable_status_change |
| Progression de la mission | calcul depuis les livrables validés |
| Historique et traçabilité | task_status_change, deliverable_status_change, audit_event |
| Cloisonnement des organisations | organization_id et clés étrangères composites dans le MPD |

Le modèle couvre toute la V1 définie dans le PRD. Il n’ajoute aucune table pour la comptabilité, le CRM, les ressources humaines, l’édition collaborative, les champs personnalisés avancés ou l’IA, qui restent hors périmètre.

## 3. Conventions de nommage

- Le MCD utilise des noms conceptuels singuliers en anglais et en capitales.
- Le MLD et le MPD utilisent des noms de tables pluriels en anglais et en snake_case.
- Les clés primaires suivent la forme nom_singulier_id.
- Les clés étrangères reprennent exactement le nom de la clé référencée, sauf lorsqu’un rôle doit être précisé, comme actor_membership_id ou assignee_membership_id.
- Les dates techniques se terminent par _at ; les dates civiles se terminent par _date.
- Les contraintes et index suivent la forme table_colonnes_type.

Dans le MLD et le MPD, chaque clé étrangère indique explicitement sa table cible. Les pattes d’oie sont réservées aux relations structurantes afin de préserver la lisibilité ; le tableau des références du MLD et le DDL restent les sources exhaustives pour les couples complets.

## 4. Décisions structurantes

### Identifiants

Les clés primaires utilisent bigint generated always as identity. Cockpit fonctionne sur une base PostgreSQL unique par installation ; des identifiants séquentiels offrent donc une indexation compacte sans introduire d’extension supplémentaire. Les autorisations ne reposent jamais sur le caractère devinable ou non d’un identifiant.

### Cloisonnement

Les tables métier portent organization_id dans le MPD. Les clés étrangères composites empêchent une tâche, un livrable ou un accès d’être relié à une ressource d’une autre organisation. Les politiques Row-Level Security utilisent l’organisation placée dans le contexte de la transaction par l’API.

### Accès aux missions

mission_accesses associe une adhésion d’organisation à une mission. Le rôle de l’adhésion détermine ensuite la vue autorisée : données internes pour l’équipe, vue limitée pour le client invité.

### Progression

La progression n’est pas persistée. Elle correspond au nombre de livrables validés divisé par le nombre total de livrables prévus. Ce calcul évite qu’une valeur stockée diverge de l’état réel.

### Historique

Les changements de statut possèdent leur propre relation avec l’ancien état, le nouvel état, l’auteur et la date. Une demande de révision exige un motif non vide. Les politiques RLS des historiques autorisent la lecture et l’ajout, mais pas leur modification ni leur suppression par le rôle applicatif courant.

Un événement d’audit appartient toujours à une organisation. Son acteur est facultatif afin de représenter aussi les événements automatiques produits par le système.

## 5. Valeurs contrôlées

| Attribut | Valeurs |
| --- | --- |
| organization_memberships.role | admin, project_manager, collaborator, client_guest |
| missions.status | draft, active, completed, archived |
| tasks.status | backlog, todo, in_progress, done |
| deliverables.status | draft, in_progress, to_validate, validated, to_revise |

Les libellés techniques restent en anglais dans la base. L’interface fournit leur traduction française.

## 6. Régénération des diagrammes

Les livrables visuels sont produits avec Draw.io Desktop afin de maîtriser leur organisation et le routage des relations.

```bash
drawio --export --theme light --border 20 --width 3000 --format png --output docs/diagrams/mcd.png docs/diagrams/mcd.drawio
drawio --export --theme light --border 20 --width 3000 --format png --output docs/diagrams/mld.png docs/diagrams/mld.drawio
drawio --export --theme light --border 20 --width 3000 --format png --output docs/diagrams/mpd.png docs/diagrams/mpd.drawio
```

Les sources Mocodo 4.3.3 sont conservées comme contrôle textuel et peuvent être validées dans un dossier temporaire sans remplacer les exports Draw.io.

```bash
mkdir -p /tmp/cockpit-mocodo/{mcd,mld,mpd}
mocodo --input docs/diagrams/mcd.mcd --output_dir /tmp/cockpit-mocodo/mcd --detect_overlaps
mocodo --input docs/diagrams/mld.mcd --output_dir /tmp/cockpit-mocodo/mld --detect_overlaps
mocodo --input docs/diagrams/mpd.mcd --output_dir /tmp/cockpit-mocodo/mpd --detect_overlaps
```
