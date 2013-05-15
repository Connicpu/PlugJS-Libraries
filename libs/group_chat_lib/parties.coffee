parties = JsPersistence.tryGet "chat_parties", {}

parties.players ||= {}
parties.groups ||= {}

isInPartyChat = (player) ->
  parties.players[player.name] and parties.groups[parties.players[player.name]]

disablePartyChat = (player) ->
  parties.players[player.name] = undefined

partyChat = (event) ->
  party = parties.groups[parties.players[event.player.name]]
  
