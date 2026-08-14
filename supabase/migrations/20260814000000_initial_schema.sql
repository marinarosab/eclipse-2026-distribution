-- Eclipse 2026 Distribution
-- Initial Supabase/PostgreSQL schema
--
-- This migration is the deployable version of database/schema.sql.
-- Business rules are represented at database level where possible.

create extension if not exists pgcrypto;

-- ============================================================
-- ENUMS
-- ============================================================

do $$ begin
  create type public.participant_status as enum ('pending', 'confirmed', 'claimed', 'cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.token_status as enum ('active', 'used', 'revoked', 'expired');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.claim_status as enum ('confirmed', 'reversed');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.user_role as enum ('organizer', 'manager', 'operator');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.point_status as enum ('active', 'inactive');
exception when duplicate_object then null; end $$;

-- ============================================================
-- ORGANIZATION
-- ============================================================

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- DISTRIBUTION POINTS
-- ============================================================

create table if not exists public.distribution_points (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete restrict,
  name text not null,
  address text,
  city text not null,
  status public.point_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_distribution_points_organization
  on public.distribution_points(organization_id);

-- ============================================================
-- AUTHENTICATED STAFF PROFILES
-- ============================================================

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique,
  organization_id uuid not null references public.organizations(id) on delete restrict,
  full_name text not null,
  email text not null,
  role public.user_role not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_organization
  on public.profiles(organization_id);

-- ============================================================
-- STAFF ACCESS TO DISTRIBUTION POINTS
-- ============================================================

create table if not exists public.point_access (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  distribution_point_id uuid not null references public.distribution_points(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(profile_id, distribution_point_id)
);

create index if not exists idx_point_access_profile
  on public.point_access(profile_id);

create index if not exists idx_point_access_point
  on public.point_access(distribution_point_id);

-- ============================================================
-- PARTICIPANTS
--
-- NIF is represented by a cryptographic hash for campaign-level
-- deduplication. The plaintext NIF is deliberately not stored.
-- ============================================================

create table if not exists public.participants (
  id uuid primary key default gen_random_uuid(),
  participant_code text not null unique,
  nif_hash text not null unique,
  full_name text not null,
  email text not null,
  distribution_point_id uuid not null references public.distribution_points(id) on delete restrict,
  status public.participant_status not null default 'pending',
  registered_at timestamptz not null default now(),
  confirmed_at timestamptz,
  claimed_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_participants_email
  on public.participants(email);

create index if not exists idx_participants_point_status
  on public.participants(distribution_point_id, status);

-- ============================================================
-- CONSENTS
-- ============================================================

create table if not exists public.consents (
  id uuid primary key default gen_random_uuid(),
  participant_id uuid not null references public.participants(id) on delete cascade,
  consent_type text not null,
  policy_version text not null,
  accepted_at timestamptz not null default now(),
  source text not null default 'registration',
  unique(participant_id, consent_type, policy_version)
);

create index if not exists idx_consents_participant
  on public.consents(participant_id);

-- ============================================================
-- QR TOKENS
--
-- Only the token hash is persisted. The raw token is delivered to the
-- participant and is never required to be stored in plaintext.
-- ============================================================

create table if not exists public.qr_tokens (
  id uuid primary key default gen_random_uuid(),
  participant_id uuid not null unique references public.participants(id) on delete cascade,
  token_hash text not null unique,
  status public.token_status not null default 'active',
  issued_at timestamptz not null default now(),
  expires_at timestamptz,
  used_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_qr_tokens_status
  on public.qr_tokens(status);

-- ============================================================
-- CLAIMS / DISTRIBUTION EVENTS
-- ============================================================

create table if not exists public.claims (
  id uuid primary key default gen_random_uuid(),
  participant_id uuid not null references public.participants(id) on delete restrict,
  qr_token_id uuid not null references public.qr_tokens(id) on delete restrict,
  distribution_point_id uuid not null references public.distribution_points(id) on delete restrict,
  processed_by uuid not null references public.profiles(id) on delete restrict,
  status public.claim_status not null default 'confirmed',
  claimed_at timestamptz not null default now(),
  reversal_reason text,
  created_at timestamptz not null default now()
);

-- A reversal is an administrative correction, not a second claim.
-- Only one claim may be confirmed at any given time for a participant.
create unique index if not exists uq_one_confirmed_claim_per_participant
  on public.claims(participant_id)
  where status = 'confirmed';

create index if not exists idx_claims_participant_date
  on public.claims(participant_id, claimed_at desc);

create index if not exists idx_claims_point_date
  on public.claims(distribution_point_id, claimed_at desc);

-- ============================================================
-- INVENTORY
-- ============================================================

create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  distribution_point_id uuid not null unique references public.distribution_points(id) on delete restrict,
  initial_quantity integer not null default 0 check (initial_quantity >= 0),
  received_quantity integer not null default 0 check (received_quantity >= 0),
  adjustment_quantity integer not null default 0,
  claimed_quantity integer not null default 0 check (claimed_quantity >= 0),
  updated_at timestamptz not null default now(),
  constraint inventory_quantity_consistent check (
    initial_quantity + received_quantity + adjustment_quantity >= claimed_quantity
  )
);

-- ============================================================
-- AUDIT LOG
-- ============================================================

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete restrict,
  actor_profile_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_audit_logs_organization_date
  on public.audit_logs(organization_id, created_at desc);

-- ============================================================
-- EMAIL EVENTS
-- ============================================================

create table if not exists public.email_events (
  id uuid primary key default gen_random_uuid(),
  participant_id uuid references public.participants(id) on delete set null,
  email text not null,
  event_type text not null,
  provider_message_id text,
  status text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_email_events_participant
  on public.email_events(participant_id, created_at desc);

-- ============================================================
-- UPDATED_AT HELPER
-- ============================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists organizations_set_updated_at on public.organizations;
create trigger organizations_set_updated_at
before update on public.organizations
for each row execute function public.set_updated_at();

drop trigger if exists distribution_points_set_updated_at on public.distribution_points;
create trigger distribution_points_set_updated_at
before update on public.distribution_points
for each row execute function public.set_updated_at();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists participants_set_updated_at on public.participants;
create trigger participants_set_updated_at
before update on public.participants
for each row execute function public.set_updated_at();

drop trigger if exists inventory_set_updated_at on public.inventory;
create trigger inventory_set_updated_at
before update on public.inventory
for each row execute function public.set_updated_at();

-- ============================================================
-- RLS
-- ============================================================
-- Row Level Security policies will be introduced in a dedicated migration
-- after Supabase Auth and the application roles are configured.
