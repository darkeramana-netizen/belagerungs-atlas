const CACHE = 'belagerungs-atlas-v2';
const OFFLINE_URLS = [
  '/',
  '/src/main.jsx',
  'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css',
  'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js',
];

const OFFLINE_HTML = `<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Belagerungs-Atlas — Offline</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{background:#060504;color:#c9a84c;font-family:Georgia,serif;
    display:flex;align-items:center;justify-content:center;
    min-height:100vh;text-align:center;padding:24px}
  .wrap{max-width:340px}
  .icon{font-size:64px;margin-bottom:20px;opacity:0.8}
  h1{font-size:22px;font-weight:normal;color:#f0e6cc;margin-bottom:12px;letter-spacing:2px}
  p{font-size:14px;color:#7a6a40;line-height:1.7;margin-bottom:20px}
  .divider{height:1px;background:linear-gradient(90deg,transparent,rgba(201,168,76,0.3),transparent);margin:20px 0}
  .hint{font-size:11px;color:#4a3a1c;letter-spacing:1px}
  button{margin-top:20px;padding:10px 28px;background:rgba(201,168,76,0.1);
    border:1px solid rgba(201,168,76,0.35);color:#c9a84c;
    font-size:13px;letter-spacing:2px;cursor:pointer;border-radius:4px;
    font-family:Georgia,serif}
  button:hover{background:rgba(201,168,76,0.18)}
</style>
</head>
<body>
<div class="wrap">
  <div class="icon">🏰</div>
  <h1>OFFLINE</h1>
  <p>Keine Verbindung zum Netz — aber der Atlas ruht hinter diesen Mauern.</p>
  <div class="divider"></div>
  <p class="hint">Beim nächsten Online-Besuch werden alle Daten neu geladen.<br>Deine gespeicherten Fortschritte bleiben erhalten.</p>
  <button onclick="location.reload()">Erneut versuchen</button>
</div>
</body>
</html>`;

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(OFFLINE_URLS).catch(() => {}))
  );
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;

  // Network first, cache fallback, offline page as last resort
  e.respondWith(
    fetch(e.request)
      .then(r => {
        const clone = r.clone();
        caches.open(CACHE).then(c => c.put(e.request, clone));
        return r;
      })
      .catch(() =>
        caches.match(e.request).then(cached => {
          if (cached) return cached;
          // Return offline page for navigation requests
          if (e.request.mode === 'navigate') {
            return new Response(OFFLINE_HTML, {
              headers: { 'Content-Type': 'text/html; charset=utf-8' },
            });
          }
        })
      )
  );
});
