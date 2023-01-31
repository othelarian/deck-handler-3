# UTILS ######################################

qSel = (s, a = no) ->
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
  deck = gen-deck \c
  rnd = rand-deck deck.length
  #
  DH.game = {t: 'c', d: deck, r: rnd, m: [{t: \rnd, v: rnd}]}
  #
  #
  dispile = qSel '#deck-play-dispile'
  unless dispile.classList.contains \plh
    dispile.classList.add \plh
    dispile.innerHTML = 'discard<br/>pile'
  #
  # TODO: inform about the state of the sock
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
  for err in qSel "\#deck-#{s}-menu .err", yes then err.style.display = \none

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
  qSel s .innerHTML = ["<div class='card-#c'>#txt</div>" for c in ['top','body','bottom']].join('')

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
      console.log(qSel '#deck-create-type' .value)
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
  play: (act) !-> switch act
    when \quit then DH.veil 'play-quit' on
    when \quitno then DH.veil 'play-quit' off
    when \quityes
      DH.game = void
      DH.show \main
      DH.veil 'play-quit' off
    when \save
      #
      # TODO
      #
      void
      #
    when \draw
      #
      # TODO
      #
      console.log 'draw'
      #
      dispile = qSel '#deck-play-dispile'
      if dispile.classList.contains \plh
        dispile.classList.remove \plh
        dispile.classList.add \front
      #
      insert-card \S2 '#deck-play-dispile'
      #
    when \shuffle then console.log 'not ready yet' # TODO
  save: (act) !-> switch act
    when \back then DH.show \play
    when \dl
      #
      # TODO
      #
      void
      #
    when \copy
      #
      # TODO
      #
      void
      #

DH =
  action: void
  game: void
  past: ''
  show: (n) !->
    if DH.past isnt '' then qSel "\#deck-#{DH.past}-menu" .style.display = \none
    DH.action = Actions[n]
    qSel "\#deck-#{n}-menu" .style.display = \block
    DH.past = n
  veil: (n,active) !->
    qSel '#deck-veil' .style.display = if active then \block else \none
    qSel "\#deck-veil-#n" .style.display = if active then \block else \none
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

