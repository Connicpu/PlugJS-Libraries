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

listParties = (player) ->
  for party in parties.groups
    party unless (party.users.indexOf _s player.name) == -1

isInParty = (player, name) ->
  parties = listParties player
  for party in parties
    return true if party.name == name
  return false

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

registerCommand {
    name: "party"
    description: "Party commands"
    usage: "\xA7e/<command> <partyname|join|create|leave>"
  },
  (sender, label, args) ->
    unless args[0]
      if parties.players[event.player.name]
        parties.players[event.player.name] = undefined
        sender.sendMessage "\xA7eNow talking in global chat"
        return

      myParties = listParties sender

      if not myParties.length
        sender.sendMessage "\xA7aYou aren't a member of any parties"
        return

      writeParty = (party) ->
        whiteSpace = ""
        for i in [1..16 - party.length]
          whiteSpace += ' '
        sender.sendMessage "\xA7a- #{party.name}#{whiteSpace} -"

      sender.sendMessage "\xA7a--------------------"
      sender.sendMessage "\xA7a-   My parties     -"
      sender.sendMessage "\xA7a--------------------"
      for party in myParties
        writeParty party

      sender.sendMessage "\xA7a--------------------"

    switch args[0]
      when "join"
        ''
      when "create"
        ''
      when "leave"
        ''
      else
        if isInParty sender, args[0]
          ''
        else
          sender.sendMessage "\xA7cYou aren't in that party"
