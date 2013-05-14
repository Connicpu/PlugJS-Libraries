replacers = [
  [/fuck/i, 'frik']
  [/\bass/i, 'bass']
  [/shit/i, 'shite']
  [/fag(g)?(ot|et)?/i, "bob saget"]
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