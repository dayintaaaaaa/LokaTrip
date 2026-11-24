create or replace function public.admin_decide_wisata(
  p_id_wisata integer,
  p_decision text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status public.status_approve_enum;
  v_admin_id integer;
  v_row jsonb;
begin
  if not private.is_admin() then raise exception 'AKSES_DITOLAK'; end if;
  v_admin_id := private.current_admin_id();
  v_status := case p_decision
    when 'approve' then 'Y'::public.status_approve_enum
    when 'pending' then 'N'::public.status_approve_enum
    when 'reject' then 'R'::public.status_approve_enum
    else null
  end;
  if v_status is null then raise exception 'KEPUTUSAN_TIDAK_VALID'; end if;
  update public.wisata as w
    set status_approve = v_status, id_admin = v_admin_id
    where w.id_wisata = p_id_wisata
    returning to_jsonb(w) into v_row;
  if v_row is null then raise exception 'WISATA_TIDAK_DITEMUKAN'; end if;
  insert into public.riwayat_aktivitas_admin
    (id_admin, aksi, target_tabel, target_id, detail)
    values (v_admin_id, 'wisata_' || p_decision, 'wisata',
      p_id_wisata::text, jsonb_build_object('status_approve', v_status::text));
  return v_row;
end;
$$;

create or replace function public.admin_decide_dokumen(
  p_id_dokumen integer,
  p_decision text,
  p_note text default null,
  p_expiry date default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status public.status_approve_enum;
  v_admin_id integer;
  v_row jsonb;
begin
  if not private.is_admin() then raise exception 'AKSES_DITOLAK'; end if;
  v_admin_id := private.current_admin_id();
  v_status := case p_decision
    when 'approve' then 'Y'::public.status_approve_enum
    when 'pending' then 'N'::public.status_approve_enum
    when 'reject' then 'R'::public.status_approve_enum
    else null
  end;
  if v_status is null then raise exception 'KEPUTUSAN_TIDAK_VALID'; end if;
  update public.dokumen as d
    set status_approve = v_status,
        id_admin = v_admin_id,
        diperiksa_pada = now(),
        catatan_admin = coalesce(p_note, d.catatan_admin),
        masa_berlaku_sampai = coalesce(p_expiry, d.masa_berlaku_sampai)
    where d.id_dokumen = p_id_dokumen
    returning to_jsonb(d) into v_row;
  if v_row is null then raise exception 'DOKUMEN_TIDAK_DITEMUKAN'; end if;
  insert into public.riwayat_aktivitas_admin
    (id_admin, aksi, target_tabel, target_id, detail)
    values (v_admin_id, 'dokumen_' || p_decision, 'dokumen',
      p_id_dokumen::text, jsonb_build_object('status_approve', v_status::text));
  return v_row;
end;
$$;

grant execute on function public.admin_decide_wisata(integer, text) to authenticated;
grant execute on function public.admin_decide_dokumen(integer, text, text, date) to authenticated;
