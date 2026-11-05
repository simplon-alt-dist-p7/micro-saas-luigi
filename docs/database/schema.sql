-- Cockpit — Modèle physique PostgreSQL de la V1
-- Les migrations Drizzle de Phase 2 devront produire un schéma équivalent.

begin;

create schema if not exists app_private;

create function app_private.current_organization_id()
returns bigint
language sql
stable
parallel safe
set search_path = ''
as $$
  select nullif(current_setting('app.current_organization_id', true), '')::bigint
$$;

create table organizations (
  organization_id bigint generated always as identity primary key,
  name text not null check (char_length(btrim(name)) between 1 and 160),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table users (
  user_id bigint generated always as identity primary key,
  email text not null check (char_length(email) between 3 and 320),
  password_hash text not null,
  display_name text not null check (char_length(btrim(display_name)) between 1 and 120),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index users_email_lower_uidx on users (lower(email));

create table clients (
  client_id bigint generated always as identity primary key,
  organization_id bigint not null,
  name text not null check (char_length(btrim(name)) between 1 and 160),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint clients_organization_fk
    foreign key (organization_id)
    references organizations (organization_id)
    on delete cascade,
  constraint clients_organization_client_uq
    unique (organization_id, client_id)
);

create table organization_memberships (
  membership_id bigint generated always as identity primary key,
  organization_id bigint not null,
  user_id bigint not null,
  client_id bigint,
  role text not null,
  joined_at timestamptz not null default now(),
  constraint organization_memberships_role_ck
    check (role in ('admin', 'project_manager', 'collaborator', 'client_guest')),
  constraint organization_memberships_client_role_ck
    check (
      (role = 'client_guest' and client_id is not null)
      or (role <> 'client_guest' and client_id is null)
    ),
  constraint organization_memberships_organization_fk
    foreign key (organization_id)
    references organizations (organization_id)
    on delete cascade,
  constraint organization_memberships_user_fk
    foreign key (user_id)
    references users (user_id)
    on delete restrict,
  constraint organization_memberships_client_fk
    foreign key (organization_id, client_id)
    references clients (organization_id, client_id)
    on delete restrict,
  constraint organization_memberships_user_uq unique (user_id),
  constraint organization_memberships_organization_membership_uq
    unique (organization_id, membership_id)
);

create index organization_memberships_organization_role_idx
  on organization_memberships (organization_id, role, membership_id);

create index organization_memberships_client_idx
  on organization_memberships (organization_id, client_id)
  where client_id is not null;

create table sessions (
  session_id bigint generated always as identity primary key,
  organization_id bigint not null,
  membership_id bigint not null,
  token_hash text not null check (char_length(token_hash) = 64),
  expires_at timestamptz not null,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint sessions_membership_fk
    foreign key (organization_id, membership_id)
    references organization_memberships (organization_id, membership_id)
    on delete cascade,
  constraint sessions_token_hash_uq unique (token_hash),
  constraint sessions_expiration_ck check (expires_at > created_at)
);

create index sessions_membership_idx
  on sessions (organization_id, membership_id);

create index sessions_expiration_idx on sessions (expires_at);

create table missions (
  mission_id bigint generated always as identity primary key,
  organization_id bigint not null,
  client_id bigint not null,
  name text not null check (char_length(btrim(name)) between 1 and 160),
  description text,
  status text not null default 'draft',
  start_date date,
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint missions_status_ck
    check (status in ('draft', 'active', 'completed', 'archived')),
  constraint missions_dates_ck
    check (start_date is null or due_date is null or due_date >= start_date),
  constraint missions_client_fk
    foreign key (organization_id, client_id)
    references clients (organization_id, client_id)
    on delete restrict,
  constraint missions_organization_mission_uq
    unique (organization_id, mission_id)
);

create index missions_organization_status_idx
  on missions (organization_id, status, updated_at desc, mission_id);

create index missions_client_idx
  on missions (organization_id, client_id, status, mission_id);

create table mission_accesses (
  organization_id bigint not null,
  mission_id bigint not null,
  membership_id bigint not null,
  granted_at timestamptz not null default now(),
  constraint mission_accesses_pk
    primary key (organization_id, mission_id, membership_id),
  constraint mission_accesses_mission_fk
    foreign key (organization_id, mission_id)
    references missions (organization_id, mission_id)
    on delete cascade,
  constraint mission_accesses_membership_fk
    foreign key (organization_id, membership_id)
    references organization_memberships (organization_id, membership_id)
    on delete cascade
);

create index mission_accesses_member_idx
  on mission_accesses (organization_id, membership_id, mission_id);

create table tasks (
  task_id bigint generated always as identity primary key,
  organization_id bigint not null,
  mission_id bigint not null,
  assignee_membership_id bigint,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  description text,
  status text not null default 'backlog',
  position bigint not null default 0 check (position >= 0),
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tasks_status_ck
    check (status in ('backlog', 'todo', 'in_progress', 'done')),
  constraint tasks_mission_fk
    foreign key (organization_id, mission_id)
    references missions (organization_id, mission_id)
    on delete cascade,
  constraint tasks_assignee_fk
    foreign key (organization_id, assignee_membership_id)
    references organization_memberships (organization_id, membership_id)
    on delete restrict,
  constraint tasks_organization_task_uq
    unique (organization_id, task_id)
);

create index tasks_kanban_idx
  on tasks (organization_id, mission_id, status, position, task_id);

create index tasks_assignee_idx
  on tasks (organization_id, assignee_membership_id, status, task_id)
  where assignee_membership_id is not null;

create table task_status_changes (
  task_status_change_id bigint generated always as identity primary key,
  organization_id bigint not null,
  task_id bigint not null,
  actor_membership_id bigint not null,
  previous_status text not null,
  new_status text not null,
  changed_at timestamptz not null default now(),
  constraint task_status_changes_previous_status_ck
    check (previous_status in ('backlog', 'todo', 'in_progress', 'done')),
  constraint task_status_changes_new_status_ck
    check (new_status in ('backlog', 'todo', 'in_progress', 'done')),
  constraint task_status_changes_transition_ck
    check (previous_status <> new_status),
  constraint task_status_changes_task_fk
    foreign key (organization_id, task_id)
    references tasks (organization_id, task_id)
    on delete cascade,
  constraint task_status_changes_actor_fk
    foreign key (organization_id, actor_membership_id)
    references organization_memberships (organization_id, membership_id)
    on delete restrict
);

create index task_status_changes_history_idx
  on task_status_changes (
    organization_id,
    task_id,
    changed_at desc,
    task_status_change_id desc
  );

create index task_status_changes_actor_idx
  on task_status_changes (organization_id, actor_membership_id);

create table deliverables (
  deliverable_id bigint generated always as identity primary key,
  organization_id bigint not null,
  mission_id bigint not null,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  description text,
  reference_url text,
  status text not null default 'draft',
  version integer not null default 1 check (version >= 1),
  due_date date,
  submitted_at timestamptz,
  validated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint deliverables_status_ck
    check (status in ('draft', 'in_progress', 'to_validate', 'validated', 'to_revise')),
  constraint deliverables_submission_ck
    check (status <> 'to_validate' or submitted_at is not null),
  constraint deliverables_validation_ck
    check (status <> 'validated' or validated_at is not null),
  constraint deliverables_mission_fk
    foreign key (organization_id, mission_id)
    references missions (organization_id, mission_id)
    on delete cascade,
  constraint deliverables_organization_deliverable_uq
    unique (organization_id, deliverable_id)
);

create index deliverables_mission_status_idx
  on deliverables (
    organization_id,
    mission_id,
    status,
    due_date,
    deliverable_id
  );

create index deliverables_awaiting_validation_idx
  on deliverables (organization_id, mission_id, submitted_at, deliverable_id)
  where status = 'to_validate';

create table deliverable_status_changes (
  deliverable_status_change_id bigint generated always as identity primary key,
  organization_id bigint not null,
  deliverable_id bigint not null,
  actor_membership_id bigint not null,
  previous_status text not null,
  new_status text not null,
  reason text,
  changed_at timestamptz not null default now(),
  constraint deliverable_status_changes_previous_status_ck
    check (previous_status in ('draft', 'in_progress', 'to_validate', 'validated', 'to_revise')),
  constraint deliverable_status_changes_new_status_ck
    check (new_status in ('draft', 'in_progress', 'to_validate', 'validated', 'to_revise')),
  constraint deliverable_status_changes_transition_ck
    check (previous_status <> new_status),
  constraint deliverable_status_changes_revision_reason_ck
    check (
      new_status <> 'to_revise'
      or nullif(btrim(reason), '') is not null
    ),
  constraint deliverable_status_changes_deliverable_fk
    foreign key (organization_id, deliverable_id)
    references deliverables (organization_id, deliverable_id)
    on delete cascade,
  constraint deliverable_status_changes_actor_fk
    foreign key (organization_id, actor_membership_id)
    references organization_memberships (organization_id, membership_id)
    on delete restrict
);

create index deliverable_status_changes_history_idx
  on deliverable_status_changes (
    organization_id,
    deliverable_id,
    changed_at desc,
    deliverable_status_change_id desc
  );

create index deliverable_status_changes_actor_idx
  on deliverable_status_changes (organization_id, actor_membership_id);

create table audit_events (
  audit_event_id bigint generated always as identity primary key,
  organization_id bigint not null,
  actor_membership_id bigint,
  event_type text not null check (char_length(event_type) between 1 and 80),
  resource_type text not null check (char_length(resource_type) between 1 and 80),
  resource_id bigint,
  occurred_at timestamptz not null default now(),
  constraint audit_events_organization_fk
    foreign key (organization_id)
    references organizations (organization_id)
    on delete cascade,
  constraint audit_events_actor_fk
    foreign key (organization_id, actor_membership_id)
    references organization_memberships (organization_id, membership_id)
    on delete restrict
);

create index audit_events_timeline_idx
  on audit_events (
    organization_id,
    occurred_at desc,
    audit_event_id desc
  );

create index audit_events_actor_idx
  on audit_events (organization_id, actor_membership_id)
  where actor_membership_id is not null;

-- Défense en profondeur : l’API définit app.current_organization_id
-- avec SET LOCAL au début de chaque transaction authentifiée.
alter table organizations enable row level security;
alter table organizations force row level security;
create policy organizations_tenant_policy on organizations
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table clients enable row level security;
alter table clients force row level security;
create policy clients_tenant_policy on clients
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table organization_memberships enable row level security;
alter table organization_memberships force row level security;
create policy organization_memberships_tenant_policy on organization_memberships
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table missions enable row level security;
alter table missions force row level security;
create policy missions_tenant_policy on missions
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table mission_accesses enable row level security;
alter table mission_accesses force row level security;
create policy mission_accesses_tenant_policy on mission_accesses
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table tasks enable row level security;
alter table tasks force row level security;
create policy tasks_tenant_policy on tasks
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table task_status_changes enable row level security;
alter table task_status_changes force row level security;
create policy task_status_changes_read_policy on task_status_changes
  for select
  using (organization_id = app_private.current_organization_id());
create policy task_status_changes_insert_policy on task_status_changes
  for insert
  with check (organization_id = app_private.current_organization_id());

alter table deliverables enable row level security;
alter table deliverables force row level security;
create policy deliverables_tenant_policy on deliverables
  for all
  using (organization_id = app_private.current_organization_id())
  with check (organization_id = app_private.current_organization_id());

alter table deliverable_status_changes enable row level security;
alter table deliverable_status_changes force row level security;
create policy deliverable_status_changes_read_policy on deliverable_status_changes
  for select
  using (organization_id = app_private.current_organization_id());
create policy deliverable_status_changes_insert_policy on deliverable_status_changes
  for insert
  with check (organization_id = app_private.current_organization_id());

alter table audit_events enable row level security;
alter table audit_events force row level security;
create policy audit_events_read_policy on audit_events
  for select
  using (organization_id = app_private.current_organization_id());
create policy audit_events_insert_policy on audit_events
  for insert
  with check (organization_id = app_private.current_organization_id());

commit;
