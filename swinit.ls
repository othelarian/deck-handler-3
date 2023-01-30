window.swinit = !->
  if navigator.serviceWorker?
    navigator.serviceWorker.register 'sw.js', {scope: '/deck-handler-3/'}