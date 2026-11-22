-- Public catalogue RLS policies call this helper; anonymous sessions resolve
-- to NULL because they have no Auth email claim.
grant execute on function private.current_mitra_id() to anon;
