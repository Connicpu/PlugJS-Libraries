class AutoBroadcast
  messages = JsPersistence.tryGet "auto_broadcast_messages", []

  getMessages: -> messages
  addMessage: (message) -> messages.push message
  removeMessage: (index) -> messages.splice index, 1

  message_index = 0
  doOnTicks 2.minutes.of.ticks, ->
    return if messages.length < 1
    Bukkit.server.broadcastMessage messages[message_index++]
    message_index = 0 if message_index >= messages.length
