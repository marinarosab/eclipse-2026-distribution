-- Eclipse 2026 Distribution
-- Seed: organização base, pontos de distribuição e inventory
-- Correr no SQL Editor do Supabase após as migrations 20260814 e 20260815.

insert into public.organizations (id, name, slug)
values (
  '00000000-0000-0000-0000-000000000001',
  'Eclipse 2026',
  'eclipse-2026'
)
on conflict (slug) do nothing;

insert into public.distribution_points (id, organization_id, name, address, city, status)
values
  (
    '00000000-0000-0000-0001-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Lisboa — Club da Visão',
    'Avenida de Roma, 5',
    'Lisboa',
    'active'
  ),
  (
    '00000000-0000-0000-0001-000000000002',
    '00000000-0000-0000-0000-000000000001',
    'Leiria — Club da Visão',
    'Rua Dr. Correia Mateus, 23',
    'Leiria',
    'active'
  ),
  (
    '00000000-0000-0000-0001-000000000003',
    '00000000-0000-0000-0000-000000000001',
    'Porto — Club da Visão',
    'Rua de Santa Catarina, 112',
    'Porto',
    'active'
  )
on conflict (id) do nothing;

insert into public.inventory (distribution_point_id, initial_quantity)
values
  ('00000000-0000-0000-0001-000000000001', 0),
  ('00000000-0000-0000-0001-000000000002', 0),
  ('00000000-0000-0000-0001-000000000003', 0)
on conflict (distribution_point_id) do nothing;