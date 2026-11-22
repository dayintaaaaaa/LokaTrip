-- Mitra passwords belong only in Supabase Auth, never in public.admin_wisata.
alter table public.admin_wisata alter column password drop not null;
