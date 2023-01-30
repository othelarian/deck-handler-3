exports.manifest = (cfg) ->
  gen_icons = []
  genfn = (elt, i) ->
    r = {src: "icons/icon_#{elt}.png", sizes: "#{elt}x#{elt}", type: 'image/png'}
    if cfg.pwa.icon_mask[i] then r.purpose = 'maskable'
    gen_icons.push r
  genfn elt, i++ for elt, i in cfg.pwa.icon_sizes
  gen_icons.push {src: 'icons/icon.svg', sizes: cfg.pwa.icon_svg}
  # manifest
  background_color: cfg.pwa.background_color
  description: cfg.pwa.description
  display: cfg.pwa.display
  icons: gen_icons
  lang: cfg.pwa.lang
  name: cfg.pwa.name
  scope: cfg.pwa.scope
  'short-name': cfg.pwa.name
  start_url: cfg.pwa.start_url
  theme_color: cfg.pwa.theme_color