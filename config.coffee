icndir = 'icons'

nodepack = require './package.json'

exports.cfg =
  app:
    code: {src: 'app.ls', out: 'app.js'}
    html: {src: 'index.pug', out: 'index.html'}
    style: {src: 'style.sass', out: 'style.css'}
  dest_path:
    debug: 'dist'
    release: 'out'
    github: 'docs'
  icon:
    dir: icndir
    src: 'icon.pug'
    out: "#{icndir}/icon.svg"
  pwa:
    background_color: '#fff'
    description: nodepack.description
    display: 'standalone'
    icon_sizes: [128, 192, 256, 512]
    icon_mask: [false, false, true, true]
    icon_svg: '72x72 96x96 1024x1024'
    lang: 'en'
    name: nodepack.name
    start_url: 'index.html'
    theme_color: '#fff'
    scope: '/fluffy-racoon/'
  sw:
    init: {src: 'swinit.ls', out: 'swinit.js'}
    script: {src: 'sw.ls', out: 'sw.js'}
  version: nodepack.version
  zipname: "./deck-handler-3_#{nodepack.version.replaceAll '.', '-'}.zip"