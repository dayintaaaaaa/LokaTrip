create or replace function private.sync_mitra_email_after_auth_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email is distinct from old.email then
    update public.admin_wisata
    set email = new.email
    where lower(email) = lower(old.email);
  end if;

  return new;
end;
$$;

revoke all on function private.sync_mitra_email_after_auth_change() from public;

drop trigger if exists sync_mitra_email_after_auth_change on auth.users;
create trigger sync_mitra_email_after_auth_change
after update of email on auth.users
for each row
when (old.email is distinct from new.email)
execute function private.sync_mitra_email_after_auth_change();
