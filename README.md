# Site e painel do Dr. Jean Mendes

- `index.html`: site público (PWA).
- `painel/`: painel do Dr. Jean (PWA), com login.
- O banco de dados fica no Supabase. A chave que aparece nos arquivos é a chave pública (publishable), feita para ficar no navegador. Nunca colocar aqui a chave secret nem a senha do banco.
- Publicação: a cada envio para o ramo `main`, o GitHub Actions publica no GitHub Pages.

## Fotos (galeria de trabalhos e foto nas publicações)

- No painel, aba **Galeria**: envia várias fotos de uma vez, com legenda, ordem, esconder e apagar. No site aparecem na seção **Trabalhos**.
- Em cada publicação há o campo **Foto (opcional)**.
- As fotos são reduzidas no próprio celular (lado maior 1600 px) e ficam no Supabase Storage, bucket público `fotos`. Só quem está na tabela `admins` consegue enviar ou apagar.
- **Banco (já aplicado no Supabase `jean-mendes-site`):** `tools/fotos.sql` é o registro do que foi criado: tabela `gallery`, coluna `posts.image_url`, bucket `fotos` e as políticas, todas com `is_admin()`. Só precisa rodar de novo num projeto novo. Pode rodar mais de uma vez sem problema.
