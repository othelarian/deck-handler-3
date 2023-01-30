bach = require 'bach'
chokidar = require 'chokidar'
fse = require 'fs-extra'
live = require 'livescript'
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
      when 'html', 'icon' then pug.renderFile in_file, cfg
      when 'sass'
        style = if cfg.release then 'compressed' else 'expanded'
        (sass.compile in_file, {style}).css
    #
    # TODO: add coffee and ls here
    #
    #
    fse.writeFileSync "#{cfg.dest}/#{out_file}", rendered
    #
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
    when 'html' then [cfg.app.html.src, cfg.app.html.out]
    when 'icon' then [cfg.icon.src, cfg.icon.out]
    when 'sass' then [cfg.app.style.src, cfg.app.style.out]
    #
    # TODO: adding coffee and ls here
    #
  #
  timed = await timeDiff in_file, out_file
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
  #
  # TODO
  #
  #
  console.log 'get args'
  #
  [makeIcon]
  #

makeIcon = (cb) ->
  await fse.mkdirs "#{cfg.dest}/#{cfg.icon.dir}"
  runExec 'icon', cb



# TASKS ###############################

task 'test_cake', '', (opts) ->
  checkEnv opts
  #
  # TODO: test manifest
  #
  console.log 'test icon'
  #
  #(bach.series makeIcon) (e, _) -> if e? then console.log e
  #

task 'build', '', (opts) ->
  checkEnv opts
  #
  console.log 'building... (no, kidding ^^)'
  #
  # TODO: if -g or -r, get terser
  #
  args = getArgs()
  #
  #
  #

task 'clean', '', (opts) ->
  checkEnv opts
  console.log "cleaning `#{cfg.dest}`..."
  fse.remove "./#{cfg.dest}", (e) ->
    if e? then console.log e
    else console.log "`#{cfg.dest}` removed successfully"

task 'serve', '', (opts) ->
  #
  # TODO: create the dev server
  #
  console.log 'serving... (nada)'
  #
