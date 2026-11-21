-- Fotos do site do Dr. Jean Mendes: galeria de trabalhos + foto nas publicações.
-- Registro do que JÁ FOI APLICADO no Supabase (projeto jean-mendes-site),
-- migração "fotos_galeria_e_imagem_nas_publicacoes".
-- Só precisa rodar de novo num projeto novo (SQL Editor > colar tudo > Run).
-- Pode rodar mais de uma vez sem problema.
-- Depende da função public.is_admin() e da tabela public.admins, que já existem.

-- 1) Foto opcional em cada publicação
alter table public.posts add column if not exists image_url text;
alter table public.posts drop constraint if exists posts_image_url_len;
alter table public.posts add constraint posts_image_url_len check (image_url is null or char_length(image_url) <= 500);

-- 2) Galeria de trabalhos
create table if not exists public.gallery (
  id          bigint generated always as identity primary key,
  image_url   text not null check (char_length(image_url) between 1 and 500),
  caption     text not null default '' check (char_length(caption) <= 120),
  position    integer not null default 0,
  live        boolean not null default true,
  created_at  timestamptz not null default now()
);

alter table public.gallery enable row level security;

grant select on public.gallery to anon, authenticated;
grant insert, update, delete on public.gallery to authenticated;

drop policy if exists "publico le galeria no ar" on public.gallery;
create policy "publico le galeria no ar" on public.gallery
  for select to anon, authenticated using (live);

drop policy if exists "admin le toda a galeria" on public.gallery;
create policy "admin le toda a galeria" on public.gallery
  for select to authenticated using (public.is_admin());

drop policy if exists "admin cria galeria" on public.gallery;
create policy "admin cria galeria" on public.gallery
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admin altera galeria" on public.gallery;
create policy "admin altera galeria" on public.gallery
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin apaga galeria" on public.gallery;
create policy "admin apaga galeria" on public.gallery
  for delete to authenticated using (public.is_admin());

-- 3) Armazenamento das fotos: leitura pública pelo link, escrita só do admin
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = true, file_size_limit = 5242880,
      allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "admin envia fotos" on storage.objects;
create policy "admin envia fotos" on storage.objects
  for insert to authenticated with check (bucket_id = 'fotos' and public.is_admin());

drop policy if exists "admin altera fotos" on storage.objects;
create policy "admin altera fotos" on storage.objects
  for update to authenticated using (bucket_id = 'fotos' and public.is_admin()) with check (bucket_id = 'fotos' and public.is_admin());

drop policy if exists "admin apaga fotos" on storage.objects;
create policy "admin apaga fotos" on storage.objects
  for delete to authenticated using (bucket_id = 'fotos' and public.is_admin());

-- O admin precisa listar os arquivos para apagar/trocar com segurança
drop policy if exists "admin le fotos" on storage.objects;
create policy "admin le fotos" on storage.objects
  for select to authenticated using (bucket_id = 'fotos' and public.is_admin());
