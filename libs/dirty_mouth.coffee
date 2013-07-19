replacers = [
  # Chat Censor
  [/(mother)?(butt)?fuck(er)?(ing)?/ig, ""]
  [/\b(fat)?(jack)?ass(es)?(crack)?(hole)?(hat)?(bag)?(bandit)?(lick(er)?)?|arse(hole)?/ig, ""]
  [/(bull)?(dip)?shit(head)?/ig, ""]
  [/\b(mc)?fag(g)?(ot|et|it)?/ig, ""]
  [/(god)?dam(nit)?(mit)?/ig, ""]
  [/bitch(y)?(es)?/ig, ""]
  [/(thunder)?cunt(licker)?|c u n t|c.u.n.t|c,u,n,t|c_u_n_t|kunt|clit(face)?/ig, ""]
  [/\bslut|whore/ig, ""]
  [/pussy(s)?|pussie(s)?/ig, ""]
  [/\btwat(s|lips)?/ig, ""]
  [/\bdick(hole)?(muncher)?(head)?(weed)?(bag)?(beater(s)?)?(juice)?(milk)?(s)?(wad)?(wod)?|(ding)?dong|penis|pen15|cock(sucker)?(burger)?(face)?(head)?(jockey)?(knocker)?(master)?(monkey)?(waffle)?/ig, ""]
  [/\btit(ty)?(s)?(bag(s)?)?(ties)?/ig, ""]
  [/douche(bag(gery)?)?/gi, ""]
  [/\bcum(dumpster)?(bubble)?|jizz|skeet|semen|/ig, ""]
  [/nigg(er)?(ah)?|niglet/gi, ""]
  [/rape(d)?/gi, ""]
  [/\bbeaner/gi, ""]
  [/\blowjob|blow job/gi, ""]
  [/\bboner/gi, ""]
  [/\bcameltoe|camel toe|coochie|coochy|cooter|gooch|kooch(ie)?|kootch(ie)?|muff(diver)?|panooch|pissflaps|/gi, ""]
  [/\bChink|Chinc|Chode|choad|gook/gi, ""]
  [/\bcunnilingus/gi, ""]
  [/\bdildo|dyke|fudgepacker/gi, ""]
  [/homodumbshit|honkey|humping|lesbo|lezzie/gi, ""]
  [/queef|queer(bait|hole)?/gi, ""]
  [/rimjob/gi, ""]
  [/schlong|skank|splooge/gi, ""]
  [/\bvag|vajayjay|vjay|vjayjay/gi, ""]
  [/\bwank(er|job)?|wetback/gi, ""]
  [/\bI will kill you/gi, ""]
  # General Chat Error Fixes - Things that annoy us
  [/conor|conner|coner|connar/gi, "Connor"]
  [/conor(cpu)?|conner(cpu)?|coner(cpu)?|connar(cpu)?/gi, "Connorcpu"]
  [/nyoung(3)?/gi, "Nathan"]
  [/\bbann\b/gi, "ban"]
  [/\bbronie\b/gi, "brony"]
  # Misc
  # Easter Eggs
  [/abcdefghijklmnopqrstuvwxyz/gi, "I can type the alphabet!"]
  [/123456789(0|10)?/gi, "I can count!"]
  # IP addresses
  [/^(((([1]?\d)?\d|2[0-4]\d|25[0-5])\.){3}(([1]?\d)?\d|2[0-4]\d|25[0-5]))|([\da-fA-F]{1,4}(\:[\da-fA-F]{1,4}){7})|(([\da-fA-F]{1,4}:){0,5}::([\da-fA-F]{1,4}:){0,5}[\da-fA-F]{1,4})$/gi, 
    (input) -> input.replace(/[0-9]/ig, "#{Math.round(Math.random()*9)}"]
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