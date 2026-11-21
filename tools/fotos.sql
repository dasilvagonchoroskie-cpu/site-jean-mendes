-- Fotos do site do Dr. Jean Mendes: galeria de trabalhos + foto nas publicações.
-- Rodar UMA vez no Supabase: SQL Editor > New query > colar tudo > Run.
-- Pode rodar de novo sem problema (usa "if not exists" / "drop policy if exists").

-- 1) Foto opcional em cada publicação
alter table public.posts add column if not exists image_url text;

-- 2) Galeria de trabalhos
create table if not exists public.gallery (
  id          bigint generated always as identity primary key,
  image_url   text not null,
  caption     text not null default '',
  position    integer not null default 0,
  live        boolean not null default true,
  created_at  timestamptz not null default now()
);

alter table public.gallery enable row level security;

drop policy if exists "galeria: todos veem as no ar" on public.gallery;
create policy "galeria: todos veem as no ar" on public.gallery
  for select using (live = true or exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "galeria: admin insere" on public.gallery;
create policy "galeria: admin insere" on public.gallery
  for insert to authenticated
  with check (exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "galeria: admin altera" on public.gallery;
create policy "galeria: admin altera" on public.gallery
  for update to authenticated
  using (exists (select 1 from public.admins a where a.user_id = auth.uid()))
  with check (exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "galeria: admin apaga" on public.gallery;
create policy "galeria: admin apaga" on public.gallery
  for delete to authenticated
  using (exists (select 1 from public.admins a where a.user_id = auth.uid()));

-- 3) Armazenamento das fotos (público para leitura, só admin grava)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = true, file_size_limit = 5242880,
      allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "fotos: admin envia" on storage.objects;
create policy "fotos: admin envia" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'fotos' and exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "fotos: admin altera" on storage.objects;
create policy "fotos: admin altera" on storage.objects
  for update to authenticated
  using (bucket_id = 'fotos' and exists (select 1 from public.admins a where a.user_id = auth.uid()));

drop policy if exists "fotos: admin apaga" on storage.objects;
create policy "fotos: admin apaga" on storage.objects
  for delete to authenticated
  using (bucket_id = 'fotos' and exists (select 1 from public.admins a where a.user_id = auth.uid()));
-- Leitura: o bucket é público, então as fotos abrem pelo link sem política extra.
