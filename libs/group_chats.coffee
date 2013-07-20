# Chat formats

chatFormat = "\xA7r<:clantag\xA7r:prefix:displayName:suffix\xA7r> :chatcolor:message"
adminFormat = "\xA7r\xA7b(:displayName\xA7r\xA7b)\xA7r :message"
partyFormat = "\xA7r\xA79(:party\xA7r\xA79)\xA7r \xA7a(:displayName\xA7r\xA7a)\xA7r :message"

# Chat parameters
chatFormatParams = [
  "prefix"
  "suffix"
  "chatcolor"
  "displayName"
  "clantag"
  "party"
]

require 'group_chat_lib/general.coffee'
require 'group_chat_lib/admin_chat.coffee'
require 'group_chat_lib/parties.coffee'

registerEvent player, "chat", (event) ->
  if /^##/i.test(_s event.message) and event.player.hasPermission "js.broadcast"
    event.message = event.message.substr 2
    event.format = formatChat "\xA74\xA7l[ANNOUNCEMENT]\xA7r\xA7b :message", formatInformation event
  else if isInAdminChat event.player
    adminChat event
  else if isInPartyChat event.player
    partyChat event
  else
    standardChat event

