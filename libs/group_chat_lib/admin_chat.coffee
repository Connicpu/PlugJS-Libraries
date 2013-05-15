
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
    description: "Goes to admin chat!"
    usage: "\xA7e/<command> [message?]"
    premission: "js.adminchat"
    permissionMessage: "\xA7cNo can do, boss"
    aliases: [ "a" ]
  },
  (sender, label, args) ->
    unless args.length
      adminChatList[sender.name] = not adminChatList[sender.name]
      sender.sendMessage "\xA7bAdmin chat #{boolOnOff adminChatList[sender.name]}"
      return

    disablePartyChat sender if disablePartyChat

    message = args.join(" ")