# Solei — going live (Supabase + Vercel)

Total time: ~15 minutes. No coding required beyond pasting two values.

## Part 1 — Supabase (the database)

1. In your Supabase dashboard, open your project (or **New project** — any name, any region near you; save the database password somewhere).
2. Left sidebar → **SQL Editor** → **New query**.
3. Open `schema.sql` (in this folder), copy ALL of it, paste, click **Run**.
   You should see "Success. No rows returned."
4. Left sidebar → **Project Settings** (gear icon) → **API**. You need two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public** key — a very long string. (This one is designed to be
     public; the security rules in schema.sql are what protect the data.
     Never use the `service_role` key in the site.)
5. Open `index.html` in any text editor. Near the top of the `<script>`
   section, find:

   ```
   const SUPABASE_URL = '';
   const SUPABASE_ANON_KEY = '';
   ```

   Paste your two values between the quotes. Save.

That's it. Every application now autosaves as a draft row while people type,
flips to `submitted` when they finish, and intro requests land in their own
table. You read everything in **Table Editor** in the Supabase dashboard —
and can export any table to CSV from there with one click.

## Part 2 — Vercel (the hosting)

Yes, Vercel works great for this, it's free at this scale, and moving to your
own domain later is a settings change, not a migration.

The site is a single static file, deployed with Vercel's command line:

1. Install Node.js if you don't have it: https://nodejs.org (LTS version).
2. Open Terminal, go to this folder:  `cd path/to/solei-deploy`
3. Run:  `npx vercel`
   - First time: it opens a browser to log in / create a free Vercel account.
   - It asks a few questions — accept every default (just press Enter).
4. It prints a URL like `https://solei-xyz.vercel.app` — that's your live
   preview. When happy, run  `npx vercel --prod`  for the real URL
   (e.g. `https://solei.vercel.app`, depending on name availability).

Every time you change index.html, run `npx vercel --prod` again to update.

## Part 3 — your own domain (later)

1. Buy the domain anywhere (Namecheap, Cloudflare, Google/Squarespace...).
2. Vercel dashboard → your project → **Settings → Domains** → add it.
3. Vercel shows you one or two DNS records to add at your registrar.
   Propagates in minutes to a few hours. HTTPS is automatic.

## Sanity checklist after deploying

- Visit your live URL → Begin the ritual → answer a question, pause typing →
  the "✓ SAVED" tick should appear.
- Supabase → Table Editor → `applications` → your draft row is there,
  updating as you type.
- Finish the ritual → status flips to `submitted`.
- Open a member → Request an introduction → send → check `intro_requests`.

## What this setup does NOT do yet (v2, when you're ready)

- Login (Supabase Auth: Google SSO + magic links) — right now anyone with
  the URL can view the map/members pages, which contain only mock data, so
  there is nothing real to protect yet. Add auth before real member data
  goes in.
- Auto-sync to Google Sheets/Airtable (easy to add; CSV export from the
  dashboard covers you meanwhile).
- Payments (Stripe) — intentionally absent; the pledge is a signal.
