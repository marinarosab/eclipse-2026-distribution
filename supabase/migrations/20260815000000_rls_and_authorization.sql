-- Eclipse 2026 Distribution
-- RLS and authorization baseline
--
-- Authentication is handled by Supabase Auth.
-- Authorization is handled by public.profiles.role and public.point_access.
-- Public participant registration will use trusted server-side operations;
-- no anonymous direct database writes are exposed by these policies.

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

create or replace function public.current_profile_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id
  from public.profiles
  where auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_organization_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select organization_id
  from public.profiles
  where auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_user_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.profiles
  where auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.is_organizer()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_user_role() = 'organizer', false);
$$;

create or replace function public.has_point_access(target_point_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_organizer()
    or exists (
      select 1
      from public.point_access pa
      join public.profiles p on p.id = pa.profile_id
      where p.auth_user_id = auth.uid()
        and pa.distribution_point_id = target_point_id
    );
$$;

create or replace function public.is_manager_at_point(target_point_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_organizer()
    or (
      public.current_user_role() = 'manager'
      and public.has_point_access(target_point_id)
    );
$$;

-- ============================================================
-- ENABLE RLS
-- ============================================================

alter table public.organizations enable row level security;
alter table public.distribution_points enable row level security;
alter table public.profiles enable row level security;
alter table public.point_access enable row level security;
alter table public.participants enable row level security;
alter table public.consents enable row level security;
alter table public.qr_tokens enable row level security;
alter table public.claims enable row level security;
alter table public.inventory enable row level security;
alter table public.audit_logs enable row level security;
alter table public.email_events enable row level security;

-- ============================================================
-- ORGANIZATIONS
-- ============================================================

create policy organizations_select
on public.organizations
for select
to authenticated
using (id = public.current_organization_id());

-- ============================================================
-- DISTRIBUTION POINTS
-- ============================================================

create policy distribution_points_select
on public.distribution_points
for select
to authenticated
using (
  organization_id = public.current_organization_id()
  and public.has_point_access(id)
);

-- Organizers can manage the campaign's points.
create policy distribution_points_organizer_insert
on public.distribution_points
for insert
to authenticated
with check (
  public.is_organizer()
  and organization_id = public.current_organization_id()
);

create policy distribution_points_organizer_update
on public.distribution_points
for update
to authenticated
using (
  public.is_organizer()
  and organization_id = public.current_organization_id()
)
with check (
  public.is_organizer()
  and organization_id = public.current_organization_id()
);

-- ============================================================
-- PROFILES
-- ============================================================

create policy profiles_select
on public.profiles
for select
to authenticated
using (
  id = public.current_profile_id()
  or (
    public.is_organizer()
    and organization_id = public.current_organization_id()
  )
);

create policy profiles_organizer_insert
on public.profiles
for insert
to authenticated
with check (
  public.is_organizer()
  and organization_id = public.current_organization_id()
);

create policy profiles_organizer_update
on public.profiles
for update
to authenticated
using (
  public.is_organizer()
  and organization_id = public.current_organization_id()
)
with check (
  public.is_organizer()
  and organization_id = public.current_organization_id()
);

-- ============================================================
-- POINT ACCESS
-- ============================================================

create policy point_access_select
on public.point_access
for select
to authenticated
using (
  profile_id = public.current_profile_id()
  or public.is_organizer()
);

create policy point_access_organizer_insert
on public.point_access
for insert
to authenticated
with check (
  public.is_organizer()
  and exists (
    select 1
    from public.profiles p
    where p.id = profile_id
      and p.organization_id = public.current_organization_id()
  )
  and exists (
    select 1
    from public.distribution_points dp
    where dp.id = distribution_point_id
      and dp.organization_id = public.current_organization_id()
  )
);

create policy point_access_organizer_delete
on public.point_access
for delete
to authenticated
using (public.is_organizer());

-- ============================================================
-- PARTICIPANTS
-- ============================================================

create policy participants_select
on public.participants
for select
to authenticated
using (
  public.has_point_access(distribution_point_id)
);

-- Participant registration and participant self-service changes are
-- intentionally not exposed as direct client-side table writes.
-- They will use controlled server-side operations.

-- ============================================================
-- CONSENTS
-- ============================================================

create policy consents_select
on public.consents
for select
to authenticated
using (
  exists (
    select 1
    from public.participants p
    where p.id = participant_id
      and public.has_point_access(p.distribution_point_id)
  )
);

-- ============================================================
-- QR TOKENS
-- ============================================================

-- QR token hashes are sensitive and are deliberately not exposed through
-- direct table reads. Scan/validation will use a dedicated secure RPC.

-- ============================================================
-- CLAIMS
-- ============================================================

create policy claims_select
on public.claims
for select
to authenticated
using (public.has_point_access(distribution_point_id));

-- Claim creation and reversal will use controlled server-side RPCs.
-- This prevents an operator from directly changing claim status or point.

-- ============================================================
-- INVENTORY
-- ============================================================

create policy inventory_select
on public.inventory
for select
to authenticated
using (public.has_point_access(distribution_point_id));

create policy inventory_manager_update
on public.inventory
for update
to authenticated
using (public.is_manager_at_point(distribution_point_id))
with check (public.is_manager_at_point(distribution_point_id));

create policy inventory_organizer_insert
on public.inventory
for insert
to authenticated
with check (
  public.is_organizer()
  and exists (
    select 1
    from public.distribution_points dp
    where dp.id = distribution_point_id
      and dp.organization_id = public.current_organization_id()
  )
);

-- ============================================================
-- AUDIT LOGS
-- ============================================================

create policy audit_logs_select
on public.audit_logs
for select
to authenticated
using (
  public.is_organizer()
  or actor_profile_id = public.current_profile_id()
);

-- Audit entries will be created by controlled server-side operations.

-- ============================================================
-- EMAIL EVENTS
-- ============================================================

create policy email_events_select
on public.email_events
for select
to authenticated
using (public.is_organizer());

-- Email events will be created by the email service/backend.

-- ============================================================
-- SECURITY NOTE
-- ============================================================
-- The service role bypasses RLS and must never be exposed in the browser.
-- Public registration, QR validation, claim confirmation and reversal will
-- be implemented through server-side operations with explicit validation,
-- audit logging and GDPR-aware data handling.
