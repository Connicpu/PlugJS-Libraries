
adminChatList = JsPersistence.tryGet "adminChat", {}

registerPermission "js.adminchat", "op"

isInAdminChat = (player) ->
  adminChatList[player.name] and player.hasPermission "js.adminchat"

disableAdminChat = (player) ->
  adminChatList[player.name] = undefined

adminChat = (event) ->
  event.format = formatChat adminFormat, formatInformation event
  for player in _a event.recipients
    event.recipients.remove player unless player.hasPermission "js.adminchat"

registerCommand {
    name: "adminchat"
    description: "Administrative party chat."
    usage: "\xA7e/<command> [message?]"
    premission: "js.adminchat"
    permissionMessage: "\xA7cYou do not have sufficient permissions to use that."
    aliases: [ "a" ]
  },
  (sender, label, args) ->
    unless args.length
      adminChatList[sender.name] = not adminChatList[sender.name]
      sender.sendMessage "\xA7bAdmin chat #{boolOnOff adminChatList[sender.name]}"
      disablePartyChat sender if disablePartyChat
      return

    message = args.join(" ")
    isAChat = adminChatList[sender.name]
    adminChatList[sender.name] = true
    sender.chat(message)
    adminChatList[sender.name] = isAChat
    yes
