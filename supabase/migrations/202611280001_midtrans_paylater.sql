begin;

-- Midtrans Akulaku payments are recorded as PayLater in LokaTrip.
alter type public.metode_bayar_enum add value if not exists 'paylater';

notify pgrst, 'reload schema';

commit;
