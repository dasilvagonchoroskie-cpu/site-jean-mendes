# Site e painel do Dr. Jean Mendes

- `index.html`: site público (PWA).
- `painel/`: painel do Dr. Jean (PWA), com login.
- O banco de dados fica no Supabase. A chave que aparece nos arquivos é a chave pública (publishable), feita para ficar no navegador. Nunca colocar aqui a chave secret nem a senha do banco.
- Publicação: a cada envio para o ramo `main`, o GitHub Actions publica no GitHub Pages.
