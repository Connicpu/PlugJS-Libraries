rainbowChars = [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ]
charsForRainbow = /[^ \.]/i
rainbowStart = () ->
  Math.round Math.random()*rainbowChars.length

registerPermission "js.chat.colors", "op"
registerPermission "js.chat.magic", "op"
registerPermission "js.chat.effects", "op"
registerPermission "js.chat.rainbow", "op"

registerEvent player, "chat", (event) ->
  message = _s event.message

  message = message.replace /\&z(.*?)((?=\&[0-9a-fk-o])|$)/gi, (match, g1, g2, offset, input) ->
    rainbow = ""
    position = rainbowStart() - 1
    for c in g1
      unless charsForRainbow.test c
        rainbow += c
        continue
      position = 0 if ++position >= rainbowChars.length
      rainbow += "\xA7#{rainbowChars[position]}#{c}"
    return rainbow

  message = message.replace /\&(?=[0-9a-f])/gi, '\xA7' if event.player.hasPermission "js.chat.colors"
  message = message.replace /\&(?=[k])/gi, '\xA7' if event.player.hasPermission "js.chat.magic"
  message = message.replace /\&(?=[l-o])/gi, '\xA7' if event.player.hasPermission "js.chat.effects"

  event.message = message

registerEvent js, "chatFormat", (event) ->
  playerInfo = Permissions::getPlayer(event.player)
  event.prefix = playerInfo.prefix
  event.suffix = playerInfo.suffix
  event.clantag = playerInfo.getInfo('clantag', '').string