asterisks = (input) ->
  output = ""
  output += '*' for c in input
  output

replacers = [
  # Chat Censor
  [/\bfuck/gi, 'frik']
  [/shit/gi, 'shite']
  [/nig(g)?er/gi, asterisks]
  [/\bI will kill you/gi, "I love you long time <3"]
  # General Chat Error Fixes - Things that annoy us
  [/conor|conner|coner|connar|connie/gi, "Connor"]
  [/conor(cpu)?|conner(cpu)?|coner(cpu)?|connar(cpu)?/gi, "Connorcpu"]
  [/nyoung(3)?/gi, "Nathan"]
  [/\bbann\b/gi, "ban"]
  [/\bbronie\b/gi, "brony"]
  # Misc
  # Easter Eggs
  [/abcdefghijklmnopqrstuvwxyz/gi, "I can type the alphabet!"]
  [/123456789(0|10)?/gi, "I can count!"]
  [/One(?= Direction)/i, "Two"]
  # IP addresses
  [/\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/gi, (input) -> input.replace(/[0-9]+/ig, -> "#{Math.round(Math.random() * 255)}")]
  # Repeated Characters
  [/a{4,}/gi, (input) -> input.substr(0, 3)]
  [/b{4,}/gi, (input) -> input.substr(0, 3)]
  [/c{4,}/gi, (input) -> input.substr(0, 3)]
  [/d{4,}/gi, (input) -> input.substr(0, 3)]
  [/e{4,}/gi, (input) -> input.substr(0, 3)]
  [/f{4,}/gi, (input) -> input.substr(0, 3)]
  [/g{4,}/gi, (input) -> input.substr(0, 3)]
  [/h{4,}/gi, (input) -> input.substr(0, 3)]
  [/i{4,}/gi, (input) -> input.substr(0, 3)]
  [/j{4,}/gi, (input) -> input.substr(0, 3)]
  [/k{4,}/gi, (input) -> input.substr(0, 3)]
  [/l{4,}/gi, (input) -> input.substr(0, 3)]
  [/m{4,}/gi, (input) -> input.substr(0, 3)]
  [/n{4,}/gi, (input) -> input.substr(0, 3)]
  [/o{4,}/gi, (input) -> input.substr(0, 3)]
  [/p{4,}/gi, (input) -> input.substr(0, 3)]
  [/q{4,}/gi, (input) -> input.substr(0, 3)]
  [/r{4,}/gi, (input) -> input.substr(0, 3)]
  [/s{4,}/gi, (input) -> input.substr(0, 3)]
  [/t{4,}/gi, (input) -> input.substr(0, 3)]
  [/u{4,}/gi, (input) -> input.substr(0, 3)]
  [/v{4,}/gi, (input) -> input.substr(0, 3)]
  [/w{4,}/gi, (input) -> input.substr(0, 3)]
  [/x{4,}/gi, (input) -> input.substr(0, 3)]
  [/y{4,}/gi, (input) -> input.substr(0, 3)]
  [/z{4,}/gi, (input) -> input.substr(0, 3)]
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
  return unless /^\/me|say|broadcast\b/i.test(message)

  event.message = "/me #{cleanMessage message.substr(4)}"