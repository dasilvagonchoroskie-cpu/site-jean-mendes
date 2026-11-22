-- Texto opcional nas publicações do site do Dr. Jean Mendes.
-- Registro do que JÁ FOI APLICADO no Supabase (projeto jean-mendes-site),
-- migração "posts_body_opcional". Pode ser publicada só com foto,
-- mas não pode ficar sem texto e sem foto ao mesmo tempo.

alter table public.posts drop constraint if exists posts_body_check;
alter table public.posts alter column body set default '';
alter table public.posts drop constraint if exists posts_body_len;
alter table public.posts add constraint posts_body_len check (char_length(body) <= 5000);
alter table public.posts drop constraint if exists posts_texto_ou_foto;
alter table public.posts add constraint posts_texto_ou_foto check (char_length(body) >= 1 or image_url is not null);
