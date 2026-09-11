-- Eclipse 2026 Distribution
-- Migração: remove deduplicação por NIF e passa para email
--
-- Decisão de produto: recolher o NIF não é necessário para resolver
-- o problema de deduplicação. O email é suficiente e minimiza os
-- dados pessoais tratados (privacy by design).

-- Tornar nif_hash opcional (mantém coluna para não perder histórico)
alter table public.participants
  alter column nif_hash drop not null;

-- Remover unicidade do nif_hash
alter table public.participants
  drop constraint if exists participants_nif_hash_key;

-- Garantir unicidade por email (nova chave de deduplicação)
alter table public.participants
  add constraint participants_email_key unique (email);