-- Run this migration and commit it before applying 004. PostgreSQL requires
-- a newly added enum value to be committed before a function uses it.
alter type public.status_approve_enum add value if not exists 'R';
