chatFormat = "\xA7r<:prefix:displayName:suffix\xA7r> :chatcolor:message"
adminFormat = "\xA7r\xA7b(:displayName\xA7r\xA7b)\xA7r :message"

eventParams = [
  "prefix"
  "suffix"
  "chatcolor"
  "displayName"
]

ignoreList = JsPersistence.tryGet "ignoreList", {}
adminChatList = JsPersistence.tryGet "adminChat", {}

registerPermission "js.adminchat", "op"

ignoreList = (sender, rlist) ->
  list = ignoreList[sender.name] ||= []
  for player in list
    continue unless gplr player
    rlist.remove gplr player
  for player,list in ignoreList
    continue unless gplr player
    rlist.remove gplr player unless list.indexOf _s(sender.name) == -1

formatChat = (format, fmtEvent) ->
  for param in eventParams
    format = format.replace(":#{param}", fmtEvent[param] || "")
  format.replace(":message", "%2$s")

formatInformation = (event) ->
  fmtEvent =
    prefix: ''
    suffix: ''
    displayName: event.player.displayName
    player: event.player
  callEvent js, "chatFormat", fmtEvent
  fmtEvent

standardChat = (event) ->
  event.format = formatChat chatFormat, formatInformation event
  ignoreList event.player, event.recipients

adminChat = (event) ->
  event.format = formatChat adminFormat, formatInformation event
  for player in _a event.recipients
    event.recipients.remove player unless player.hasPermission "js.adminchat"

registerEvent player, "chat", (event) ->
  if adminChatList[event.player.name]
    adminChat event
  else
    standardChat event

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

    message = args.join(" ")
