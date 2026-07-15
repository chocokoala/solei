-- ============================================================
-- SOLEI — save function
-- Run this once in Supabase: SQL Editor -> paste -> Run.
--
-- Why this exists: the app needs to WRITE applications but must
-- never be able to READ them (privacy). Row-level security makes
-- that combination awkward for updates — the update can't find a
-- row it isn't allowed to see, so it silently does nothing.
-- This function runs as the table owner, so writes work, while
-- reads stay blocked for everyone. It also does insert-or-update
-- in one atomic step, which removes any race between saves.
-- ============================================================

create or replace function save_application(payload jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into applications (
    id, status, full_name, email, birthdate, current_city, social_link,
    referred_by, extras, answers, pledge, season, mastermind, letter,
    address_book, stints, updated_at
  ) values (
    (payload->>'id')::uuid,
    coalesce(nullif(payload->>'status',''), 'draft'),
    nullif(payload->>'full_name',''),
    nullif(payload->>'email',''),
    nullif(payload->>'birthdate','')::date,
    nullif(payload->>'current_city',''),
    nullif(payload->>'social_link',''),
    nullif(payload->>'referred_by',''),
    coalesce(payload->'extras', '{}'::jsonb),
    coalesce(payload->'answers', '{}'::jsonb),
    nullif(payload->>'pledge','')::numeric,
    payload->'season',
    payload->'mastermind',
    payload->'letter',
    coalesce(payload->'address_book', '[]'::jsonb),
    coalesce(payload->'stints', '[]'::jsonb),
    now()
  )
  on conflict (id) do update set
    status        = excluded.status,
    full_name     = excluded.full_name,
    email         = excluded.email,
    birthdate     = excluded.birthdate,
    current_city  = excluded.current_city,
    social_link   = excluded.social_link,
    referred_by   = excluded.referred_by,
    extras        = excluded.extras,
    answers       = excluded.answers,
    pledge        = excluded.pledge,
    season        = excluded.season,
    mastermind    = excluded.mastermind,
    letter        = excluded.letter,
    address_book  = excluded.address_book,
    stints        = excluded.stints,
    updated_at    = now();
end;
$$;

grant execute on function save_application(jsonb) to anon, authenticated;

-- Same treatment for introduction requests (insert-only).
create or replace function create_intro_request(
  p_to_member text, p_message text, p_from_name text, p_from_email text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into intro_requests (to_member, message, from_name, from_email)
  values (p_to_member, p_message, p_from_name, p_from_email);
end;
$$;

grant execute on function create_intro_request(text, text, text, text) to anon, authenticated;

-- ---------- verify it works as the website's role ----------
-- Should return the row WITH the email filled in.
select save_application(jsonb_build_object(
  'id', '74eba64c-f3f8-47d0-97c9-debaa6e5ab3b',
  'status', 'submitted',
  'full_name', 'hi coco',
  'email', 'function-test@example.com',
  'current_city', 'Amsterdam, Netherlands'
));

select id, status, full_name, email, current_city
from applications
where id = '74eba64c-f3f8-47d0-97c9-debaa6e5ab3b';
