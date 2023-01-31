bach = require 'bach'
chokidar = require 'chokidar'
fse = require 'fs-extra'
livescript = require 'livescript'
pug = require 'pug'
sass = require 'sass'
sharp = require 'sharp'
{ minify } = require 'terser'

cfg = require('./config').cfg

# OPTIONS #############################

option '-r', '--release', ''
option '-g', '--github', ''
option '-f', '--force', 'override time test'

# COMMON FUNS #########################

checkEnv = (opts) ->
  [cfg.dest, cfg.release, cfg.github] =
    if opts.github then [cfg.dest_path.github, true, true]
    else if opts.release then [cfg.dest_path.release, true, false]
    else [cfg.dest_path.debug, false, false]
  cfg.force = opts.force?
  cfg.watching = false

doExec = (in_file, out_file, selected) ->
  try
    rendered = switch selected
      when 'app', 'sw_init', 'sw_script'
        code = await fse.readFile in_file, {encoding: 'utf-8'}
        out = livescript.compile code, {}
        if cfg.release then out = (await minify out).code
        out
      when 'html', 'icon' then pug.renderFile in_file, cfg
      when 'manifest' then JSON.stringify require("./#{in_file}").manifest cfg
      when 'style'
        style = if cfg.release then 'compressed' else 'expanded'
        (sass.compile in_file, {style}).css
    fse.writeFileSync out_file, rendered
    if selected is 'icon'
      icn_path = cfg.icon.dir
      sh = sharp "#{cfg.dest}/#{cfg.icon.out}"
      resizing = (size) ->
        await sh.resize(size).toFile "#{cfg.dest}/#{cfg.icon.dir}/icon_#{size}.png"
      resizing size for size in cfg.pwa.icon_sizes
    traceExec selected
  catch e
    console.log "doExec '#{selected}' => Something went wrong!!!\n\n\n#{e}"

runExec = (selected, cb) ->
  [in_file, out_file] = switch selected
    when 'app' then [cfg.app.code.src, cfg.app.code.out]
    when 'html' then [cfg.app.html.src, cfg.app.html.out]
    when 'icon' then [cfg.icon.src, cfg.icon.out]
    when 'manifest' then ['manifest.coffee', "#{cfg.pwa.name}.webmanifest"]
    when 'style' then [cfg.app.style.src, cfg.app.style.out]
    when 'sw_init' then [cfg.sw.init.src, cfg.sw.init.out]
    when 'sw_script' then [cfg.sw.script.src, cfg.sw.script.out]
  out_file = "#{cfg.dest}/#{out_file}"
  timed = await timeDiff out_file, in_file
  if not cfg.force and timed then console.log "'#{selected}' => already compiled"
  else doExec in_file, out_file, selected
  if cfg.watching then watchExec in_file, out_file, selected
  cb null, 11

timeDiff = (gen_file, src_file) ->
  getTime = (path) ->
    try
      (await fse.stat path).mtimeMs
    catch
      0
  gen_time = await getTime gen_file
  src_time = await getTime src_file
  gen_time > src_time

traceExec = (name) ->
  stmp = new Date().toLocaleString()
  console.log "#{stmp} / #{name} => compilation done"

watchExec = (to_watch, out_file, selected) ->
  watcher = chokidar.watch to_watch
  watcher.on 'change', => doExec(to_watch, out_file, selected)
  watcher.on 'error', (err) => console.log "CHOKIDAR ERROR\n#{err}"

# ACTIONS FUNS ########################

getArgs = ->
  args = [makeIcon, makeHtml, makeStyle, makeApp]
  if cfg.github then args = args.concat [makeManifest, makeSWi, makeSWs]
  args

launchServer = (cb) ->
  console.log 'launching dev server...'
  app = (require 'connect')()
  app.use((require 'serve-static') "./#{cfg.dest}")
  (require 'http').createServer(app).listen 5000
  console.log 'dev server running on port 5000'

makeApp = (cb) -> runExec 'app', cb

makeIcon = (cb) ->
  await fse.mkdirs "#{cfg.dest}/#{cfg.icon.dir}"
  runExec 'icon', cb

makeHtml = (cb) -> runExec 'html', cb

makeManifest = (cb) -> runExec 'manifest', cb

makeSWi = (cb) -> runExec 'sw_init', cb

makeSWs = (cb) -> runExec 'sw_script', cb

makeStyle = (cb) -> runExec 'style', cb

# TASKS ###############################

task 'build', '', (opts) ->
  checkEnv opts
  building = ->
    console.log "building the app... (#{cfg.dest})"
    (bach.series.apply null, getArgs()) (e, _) ->
      if e? then console.log e
      else
        console.log 'building done'
        if cfg.github then console.log 'github dir ready to be pushed'
        else if cfg.release
          zipping = ->
            console.log 'zipping...'
            admzip = require 'adm-zip'
            try
              zip = new admzip()
              zip.addLocalFolder cfg.dest
              zip.writeZip cfg.zipname
              console.log "==========> itch zip ready: #{cfg.zipname}"
            catch e
              console.log "Something went wrong while zipping\n\n#{e}"
          aftercheck = (e) ->
            if not e?
              console.log 'removing old zip'
              fse.rmSync cfg.zipname
            zipping()
          await fse.access cfg.zipname, fse.constants.F_OK, aftercheck
  if cfg.release
    console.log 'release/github mode, cleaning before compiling'
    fse.remove "./#{cfg.dest}", (e) ->
      if e? then console.log e
      else building()
  else building()

task 'clean', '', (opts) ->
  checkEnv opts
  console.log "cleaning `#{cfg.dest}`..."
  fse.remove "./#{cfg.dest}", (e) ->
    if e? then console.log e
    else console.log "`#{cfg.dest}` removed successfully"

task 'serve', '', (opts) ->
  checkEnv opts
  if cfg.release then console.log 'No way to serve in release/github mode!'
  else
    cfg.watching = true
    args = getArgs()
    args.push launchServer
    (bach.parallel.apply null, args) (e, _) -> if e? then console.log e
