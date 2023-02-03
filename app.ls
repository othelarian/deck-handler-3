# UTILS ######################################

c-elt = (tag, attrs, txt, html) ->
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

q-sel = (s, a = no) ->
  if a then document.querySelectorAll s
  else document.querySelector s

# SPECIFICS ##################################

deck-creation = !->
  hide-errs \create
  #
  # TODO: get the deck datas
  #
  # TODO: validate the custom deck if needed
  #
  #
  # TODO: for now only trigger a 52-card deck creation (v0.1.0)
  #
  deck = gen-deck \s
  rnd = rand-deck deck.length
  #
  DH.store = {d: deck, s: deck, p: 0}
  DH.game = {t: 'c', r: rnd, m: [{t: \rnd, v: rnd}]}
  #
  # TODO: if \u (custom) then add d: deck to DH.game
  #
  #
  dispile = q-sel '#deck-play-dispile'
  unless dispile.classList.contains \plh
    dispile.classList.add \plh
    dispile.innerHTML = 'discard<br/>pile'
  #
  # TODO: inform about the state of the sock
  #
  #
  qSel '#deck-play-draw' .removeAttribute 'disabled'
  #
  DH.show \play

gen-deck = (type) ->
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

hide-errs = (s) !->
  for err in q-sel "\#deck-#{s}-menu .err", yes then err.style.display = \none

insert-card = (v, s) !->
  txt = switch DH.game.t
    when \t, \c, \cj, \s, \sj
      if DH.game.t is \t and v[0] is \T
        if v[1] is \0 then 'Excuse' else "Triumph #{v.substring(1)}"
      else if (DH.game.t is \cj or DH.game.t is \sj) and v[1] is \W
        if v[0] is \R then '&hearts;Red Joker&diams;'
        else '&spades;Black Joker&clubs;'
      else
        col = switch v[0]
          when \S then '&spades;'
          when \H then '&hearts;'
          when \C then '&clubs;'
          when \D then '&diams;'
        "#{v.substring(1)}&nbsp;#col"
    when \p then "Triumph #v"
    when \u
      #
      # TODO
      #
      'not ready'
      #
  q-sel s .innerHTML = ["<div class='card-#c'>#txt</div>" for c in ['top','body','bottom']].join('')

play-actions = (act) !-> switch act
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
    dispile = q-sel '#deck-play-dispile'
    if dispile.classList.contains \plh
      dispile.classList
        ..remove \plh
        ..add \front
    c =
      if DH.store.s.length is 1 then
        qSel '#deck-play-pot'
          ..classList.remove \back
          ..classList.add \plh
        qSel '#deck-play-draw' .setAttribute 'disabled', true
        DH.store.s[0]
      else
        c = DH.store.s[DH.game.r[DH.store.p]]
        DH.store.p += 1
        DH.game.m.push {t: \draw}
        DH.store.s = DH.store.s.filter (e) ~> e != c
        c
    insert-card c, '#deck-play-dispile'
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

rand-deck = (size) -> [Math.floor(Math.random! * top) for top from size to 2 by -1]

# CORE #######################################

Actions =
  create: (act) !-> switch act
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
    when \load
      hide-errs \load
      #
      # TODO
      #
      console.log 'load -> load'
      #
  main: (act) !-> switch act
    when \create then DH.show \create
    when \load then DH.show \load
    when \play then deck-creation! # TODO: temporary
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
    insert-card v, '#deck-play-dispile'
  #

init-deck = !->
  if swinit? then swinit!
  DH.show \main

# OUTPUTS ####################################

window.DH = DH
window.init-deck = init-deck
