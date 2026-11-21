// Service worker: guarda a tela no aparelho para abrir rápido e com internet fraca.
// Para forçar a atualização depois de mudar a tela, troque o número da VERSAO.
const VERSAO = 'jm-painel-v5';
const BASE = new URL('./', self.location).pathname;
const ARQUIVOS = ['./', 'index.html', 'manifest.webmanifest', 'icons/icon-192.png', 'icons/icon-512.png', 'simbolo.webp'];

self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(VERSAO).then(function (c) { return c.addAll(ARQUIVOS); }).then(function () { return self.skipWaiting(); }));
});

self.addEventListener('activate', function (e) {
  e.waitUntil(
    caches.keys().then(function (ks) {
      return Promise.all(ks.filter(function (k) { return k.indexOf('jm-painel-') === 0 && k !== VERSAO; }).map(function (k) { return caches.delete(k); }));
    }).then(function () { return self.clients.claim(); })
  );
});

self.addEventListener('fetch', function (e) {
  var req = e.request;
  if (req.method !== 'GET') return;
  var url = new URL(req.url);
  var mesmaOrigem = url.origin === self.location.origin;
  if (mesmaOrigem && (url.pathname.indexOf('/api/') === 0)) return;
  var fontes = url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com';
  if (!mesmaOrigem && !fontes) return;
  if (req.mode === 'navigate') {
    // Abrir a tela: busca a versão nova na internet; sem internet, usa a guardada no aparelho.
    e.respondWith(
      fetch(req).then(function (res) {
        if (res && res.ok) { var c = res.clone(); caches.open(VERSAO).then(function (ca) { ca.put(req, c); }); }
        return res;
      }).catch(function () {
        return caches.match(req).then(function (m) { return m || caches.match('index.html'); });
      })
    );
    return;
  }
  e.respondWith(
    caches.match(req).then(function (emCache) {
      var rede = fetch(req).then(function (res) {
        if (res && (res.ok || res.type === 'opaque')) {
          var copia = res.clone();
          caches.open(VERSAO).then(function (c) { c.put(req, copia); });
        }
        return res;
      }).catch(function () {
        return emCache || caches.match('index.html');
      });
      return emCache || rede;
    })
  );
});
