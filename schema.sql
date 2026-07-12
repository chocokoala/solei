-- ============================================================
-- SOLEI — database setup
-- Run this once in Supabase: Dashboard -> SQL Editor -> New query
-- Paste everything, click Run.
-- ============================================================

-- Applications: one row per person going through the ritual.
-- Autosave writes drafts; submission flips status to 'submitted'.
create table if not exists applications (
  id uuid primary key,
  status text not null default 'draft',        -- 'draft' | 'submitted'
  full_name text,
  email text,
  birthdate date,
  current_city text,
  answers jsonb not null default '{}'::jsonb,  -- question index -> answer text
  pledge numeric,                              -- 随喜 signal, $/month (not a charge)
  stints jsonb not null default '[]'::jsonb,   -- life map: [{city, start, end}]
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Introduction requests, routed to Coco.
create table if not exists intro_requests (
  id uuid primary key default gen_random_uuid(),
  to_member text not null,
  message text not null,
  from_name text,
  from_email text,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Security (Row Level Security)
-- Visitors can WRITE applications and intro requests, but can
-- never READ anyone's data. Only you can read — via the
-- Supabase dashboard (Table Editor), which bypasses RLS.
-- This is why the anon key is safe to ship in the frontend.
-- ------------------------------------------------------------
alter table applications enable row level security;
alter table intro_requests enable row level security;

create policy "public can create applications"
  on applications for insert to anon with check (true);

-- Drafts are updated by unguessable UUID (v4) generated in the
-- browser; fine for this stage, revisit when auth is added.
create policy "public can update applications"
  on applications for update to anon using (true) with check (true);

create policy "public can create intro requests"
  on intro_requests for insert to anon with check (true);

-- Helpful index for your admissions review
create index if not exists applications_status_idx on applications (status, updated_at desc);
