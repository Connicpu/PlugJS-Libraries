replacers = [
  [/(mother)?fuck(er)?(ing)?/ig, ""]
  [/\bass(hole)?/ig, ""]
  [/(bull)?shit(head)?/ig, ""]
  [/fag(g)?(ot|et)?/ig, ""]
  [/(god)?dam(nit)?(mit)?/ig, ""]
  [/bitch(y)?/ig, ""]
  [/(thunder)?cunt|c u n t|c.u.n.t|c,u,n,t|c_u_n_t/ig, ""]
  [/\bslut|whore/ig, ""]
  [/pussy/ig, ""]
  [/\btwat/ig, ""]
  [/\bdick(hole)?(muncher)?(head)?(weed)?|(ding)?dong|penis|pen15|cock(sucker)?/ig, ""]
  [/\btit(s)?(bag(s)?)?(ties)?/ig, ""]
  [/douche(bag(gery)?)?/gi, ""]
  [/\bcum|jizz|skeet|semen|/ig, ""]
  [/nigg(er)?(ah)?/gi, ""]

  #[/.*/, (match) -> match.toSentenceCase()]
]

cleanMessage = (message) ->
  for replacer in replacers
    message = message.replace(replacer[0], replacer[1])
  message

registerPermission "js.censor.bypass", "false"

registerEvent player, "chat", (event) ->
  return if event.cancelled or event.player.hasPermission "js.censor.bypass"

  event.message = cleanMessage _s(event.message)

registerEvent player, "command", (event) ->
  message = _s(event.message)
  return unless /^\/me\b/i.test(message)

  event.message = "/me #{cleanMessage message.substr(4)}"