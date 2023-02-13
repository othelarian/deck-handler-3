# UTILS ######################################

function c-elt tag, attrs, txt, html
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

# SPECIFICS ##################################

!function deck-creation
  hide-errs \create
  t = qSel '#deck-create-type' .value
  #rv = qSel '#deck-create-river' .checked # TODO: to reactivate with the pug code
  #
  rv = false
  #
  # TODO: validate the custom deck if needed
  #
  #
  p = gen-deck t
  rnd = rand-deck p.length
  s = set-sequence p, rnd
  DH.store = {p, s, i: 0, rv: [], d: [], sel: \dis}
  DH.game = {t, rv, hds: no, m: [{t: \rnd, v: rnd}]}
  if t is \u
    #
    # TODO: add DH.game the custom deck
    #
    DH.game.c = []
    #
  #
  # TODO: if \u (custom) then add d: deck to DH.game
  #
  #
  dispile = q-sel '#deck-play-dispile'
  unless dispile.classList.contains \plh
    dispile.classList.add \plh
    dispile.innerHTML = 'discard<br/>pile'
  qSel '#deck-play-draw' .removeAttribute 'disabled'
  qSel '#deck-play-dispile' .setAttribute \style ''
  #
  #qSel '#deck-play-draw-select' .value = \dis
  #
  #
  DH.show \play

function gen-deck type
  if type is \p then [x for x to 21]
  else
    lmt = switch type
      when \c, \cj, \t then 1
      when \s, \sj then 7
    heads = if type is \t then [\J \C \Q \K] else [\J \Q \K]
    base = ["#c#v" for c in [\S \H \C \D] for v in ([x for x from lmt to 10].concat heads)]
    if type is \t then base = base.concat ["T#x" for x to 21]
    else if type is \cj or type is \sj then base = base.concat [\RW, \BW]
    base

!function hide-errs s
  for err in q-sel "\#deck-#{s}-menu .err", yes then err.style.display = \none

!function insert-card v, node
  [txt, col, alt] = switch DH.game.t
    when \t, \c, \cj, \s, \sj
      if DH.game.t is \t and v[0] is \T
        if v[1] is \0 then ['Excuse', \gold, void]
        else ["Triumph #{v.substring(1)}", \gold, v.substring(1)]
      else if (DH.game.t is \cj or DH.game.t is \sj) and v[1] is \W
        if v[0] is \R then ['&hearts;Red Joker&diams;', \black, void]
        else ['&spades;Black Joker&clubs;', \red, void]
      else
        [fam, col] = switch v[0]
          when \S then ['&spades;', \black]
          when \H then ['&hearts;', \red]
          when \C then ['&clubs;', \black]
          when \D then ['&diams;', \red]
        ct = switch v[1]
          when \K then "King<br/>#fam"
          when \Q then "Queen<br/>#fam"
          when \C then "Cav.<br/>#fam"
          when \J then "Jack<br/>#fam"
          else void
        ["#{v.substring(1)}&nbsp;#fam", col, ct]
    when \p then ["Triumph #v", \gold, v]
    when \u
      #
      # TODO
      #
      'not ready'
      #
  r = (c) ->
    if c is \body then
      if alt? then alt else txt
    else txt
  node
    ..innerHTML = ["<div class='card-#c'>#{r c}</div>" for c in [\top \body \bottom]].join('')
    ..setAttribute \style, "color:#col;border-color:#col"

play-actions = (act, opts = {}) !-> switch act
  when \quit then DH.veil 'play-quit' on
  when \quitno then DH.veil 'play-quit' off
  when \quityes
    DH.game = void
    DH.show \main
    DH.veil 'play-quit' off
  when \save
    q-sel '#deck-save-text' .value = JSON.stringify DH.game
    DH.show \save
  when \draw
    d =
      if opts.d? then opts.d
      else
        #
        # TODO: dispile is only affected if no river, no hands, or direct selection
        #
        \d # 'd' for discard pile, 'r' for river, 'h#{nb}' for the hand
        #
    if DH.store.s.length is 1
      qSel('#deck-play-pot').classList
        ..remove \back
        ..add \plh
      qSel '#deck-play-draw' .setAttribute 'disabled', true
    c = DH.store.s.shift!
    DH.store.i += 1
    trg =
      if not DH.game.rv and not DH.game.hds #or DH.store.sel is \dis
        dispile = q-sel '#deck-play-dispile'
        if dispile.classList.contains \plh
          dispile.classList
            ..remove \plh
            ..add \front
        DH.store.rv.push c
        dispile
      else
        #
        # TODO
        #
        'oups'
        #
    DH.game.m.push {t: \draw, d}
    insert-card c, trg
  when \reset then DH.veil 'play-reset' on
  when \resetno then DH.veil 'play-reset' off
  when \resetyes
    #
    # TODO: handle the reset
    #
    console.log 'reset (not ready)'
    #
    DH.veil 'play-reset' off
  when \shuffleall
    #
    # TODO
    #
    console.log 'not ready yet'
    #
    #
    #

function rand-deck size then [Math.floor(Math.random! * top) for top from size to 2 by -1]

function set-sequence b, r
  acc = []
  rng = (l, i) ->
    acc.push l[i]
    l.filter (_, id) ~> id != i
  acc.push (r.reduce rng, b)[0]
  acc

# CORE #######################################

Actions =
  create: (act, opts = {}) !-> switch act
    when \cancel
      hide-errs \create
      DH.show \main
    when \create then deck-creation!
    when \custom
      #
      # TODO
      #
      console.Log 'not ready'
      #
    when \hm, \hp
      #
      # TODO
      #
      console.log 'hp / hd'
      #
    when \update
      #
      # TODO
      #
      console.log(q-sel '#deck-create-type' .value)
      #
  load: (act) !-> switch act
    when \cancel
      hide-errs \load
      DH.show \main
    when \file
      #
      # TODO: handle event from input type=file
      #
      console.log opts
      f = console.log opts.target.files[0]
      #if f.type isnt 'application/json' then
      #
    when \load
      hide-errs \load
      #
      # TODO
      #
      #
      console.log 'load -> load'
      #
  main: (act) !-> switch act
    when \create then DH.show \create
    when \load
      qSel '#deck-load-load' .setAttribute \disabled ''
      DH.show \load
  play: play-actions
  save: (act) !-> switch act
    when \back then DH.show \play
    when \copy
      navigator.clipboard.writeText q-sel('#deck-save-text').value
      DH.veil 'save-copy' on
    when \copyok then DH.veil 'save-copy' off
    when \dl
      attrs =
        href: 'data:text/plain;charset=utf-8,'+(q-sel '#deck-save-text' .value)
        download: 'dh3_save.json'
      a = c-elt \a, attrs
      a.style.display = \none
      document.body.appendChild a
      a.click!
      document.body.removeChild a
      DH.veil 'save-dl' on
    when \dlok then DH.veil 'save-dl' off

DH =
  action: void
  game: void
  init: !->
    qSel '#deck-load-file' .addEventListener \change, (evt) !~>
      DH.action \file evt.target.files[0]
    qSel '#deck-load-text' .addEventListener \keyup, (evt) !~>
      #DH.action \area evt
      # TODO
      #
      console.log 'load text'
      console.log evt
      #
  past: ''
  show: (n) !->
    if DH.past isnt '' then q-sel "\#deck-#{DH.past}-menu" .style.display = \none
    DH.action = Actions[n]
    q-sel "\#deck-#{n}-menu" .style.display = \block
    DH.past = n
  store: void
  veil: (n,active) !->
    q-sel '#deck-veil' .style.display = if active then \block else \none
    q-sel "\#deck-veil-#n" .style.display = if active then \block else \none
  #
  # TODO: remove after test
  #
  call: (v) !->
    #insert-card v, '#deck-play-dispile'
    console.log rand-deck 10
  #

init-deck = !->
  if swinit? then swinit!
  DH.init!
  DH.show \main

# OUTPUTS ####################################

window.DH = DH
window.init-deck = init-deck
