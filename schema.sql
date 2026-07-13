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
  social_link text,
  referred_by text,                            -- invite-only: who sent them
  extras jsonb,                                -- self-paced profile questions                             -- personal site, Substack, IG, LinkedIn, RedNote, etc.
  birthdate date,
  current_city text,
  answers jsonb not null default '{}'::jsonb,  -- question index -> answer text
  pledge numeric,                              -- 随喜 signal (not a charge)
  season jsonb,                                -- seasonal declaration: {season, tags, line}
  mastermind jsonb,                            -- accountability opt-in: {focus, hopes}
  letter jsonb,                                -- seasonal letter: {season, title, text, sharedToSolei, sentTo, sentAt}
  address_book jsonb,                          -- personal contacts for letters: [{name, email}]
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

-- ------------------------------------------------------------
-- Safe re-run additions: if the applications table was created
-- from an earlier version of this file, these add the newer
-- columns without touching existing data. Harmless to re-run.
-- ------------------------------------------------------------
alter table applications add column if not exists social_link text;
alter table applications add column if not exists referred_by text;
alter table applications add column if not exists extras jsonb;
alter table applications add column if not exists letter jsonb;
alter table applications add column if not exists address_book jsonb;

-- ------------------------------------------------------------
-- Change tracking: every save (autosave, profile edits, season
-- updates) already bumps updated_at via the app's saveDraft()
-- call. That's your lightweight audit trail — Table Editor,
-- sorted by updated_at, shows who touched their profile last
-- and when. A full field-level history (old value -> new value
-- per edit) is a v2 feature: it needs a separate append-only
-- log table and a trigger, worth adding once edits are common
-- enough to want a real diff view.
-- ------------------------------------------------------------
alter table applications add column if not exists season jsonb;
alter table applications add column if not exists mastermind jsonb;
