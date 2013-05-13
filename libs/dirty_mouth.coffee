replacers = [
  [/fuck/i, 'frik']
  [/\bass/i, 'bass']
  [/shit/i, 'shite']
  [/fag(g)?(ot)?/i, "bob saggot"]
]

registerPermission "js.censor.bypass", "false"

registerEvent player, "chat", (event) ->
  return if event.cancelled or event.player.hasPermission "js.censor.bypass"

  message = _s(event.message)

  for replacer in replacers
    message = message.replace(replacer[0], replacer[1])

  event.message = message

registerEvent player, "command", (event) ->
  message = _s(event.message)
  return unless /^\/me\b/i.test(message)

  