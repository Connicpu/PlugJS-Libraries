parties = JsPersistence.tryGet "chat_parties", {}

parties.players ||= {}
parties.groups ||= {}

isInPartyChat = (player) ->
  parties.players[player.name] and parties.groups[parties.players[player.name]]

disablePartyChat = (player) ->
  parties.players[player.name] = undefined

partyChat = (event) ->
  party = parties.groups[parties.players[event.player.name]]
  
  event.format = formatChat adminFormat, formatInformation event, { party: party.name }

  for player in _a event.recipients
    event.recipients.remove player if party.users.indexOf _s player.name == -1

Party = (name, owner, options) ->
  @name = name
  @owner = _s owner.name
  @users = [ @owner ]
  @invites = []
  @password = options.password
  @inviteOnly = options.inviteOnly
  @membersInvite = options.membersInvite

Party.Invite = (party, sender, recipient) ->
  @party = party.name
  @sender = _s sender.name
  @recipient = _s recipient.name || recipient