const CACHE_NAME = 'deck-handler-3-cache'
const OFFLINE_URL = '/deck-handler-3/index.html'

self.addEventListener 'install', (evt) !~>
  evt.waitUntil(( !~>>
    cache = await caches.open CACHE_NAME
    cache.add(new Request OFFLINE_URL, {cache: 'reload'})
  )())

self.addEventListener 'activate', (evt) !~>
  evt.waitUntil(( !~>>
    if self.registration.navigationPreload?
      t = await self.registration.navigationPreload.enable!
  )())
  self.clients.claim!

self.addEventListener 'fetch', (evt) !~>
  void