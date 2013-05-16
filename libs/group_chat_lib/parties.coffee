parties = JsPersistence.tryGet "chat_parties", {}

parties.players ||= {}
parties.groups ||= {}

isInPartyChat = (player) ->
  parties.players[player.name] and parties.groups[parties.players[player.name]]

disablePartyChat = (player) ->
  parties.players[player.name] = undefined

partyChat = (event) ->
  party = parties.groups[parties.players[event.player.name]]
  
  event.format = formatChat adminFormat, formatInformation event, { party: party.displayName }

  for player in _a event.recipients
    event.recipients.remove player if party.users.indexOf _s player.name == -1

listParties = (player) ->
  for party in parties.groups
    party unless (party.users.indexOf _s player.name) == -1

isInParty = (player, name) ->
  name = name.toLowerCase()
  parties = listParties player
  for party in parties
    return true if party.name == name
  return false

getParty = (name) -> parties.groups[name.toLowerCase()]

Party = (name, owner, options) ->
  @name = name.toLowerCase()
  @displayName = name
  @owner = _s owner.name
  @users = [ @owner ]
  @invites = []
  @password = options.password
  @inviteOnly = options.inviteOnly
  @membersInvite = options.membersInvite
  @hasInvite = (player) ->
    for invite in @invites
      return true if recipient == _s player.name
    return false
  @removeInvite = (invite) ->
    @invites.splice @invites.indexOf(invite), 1

Party.Invite = (party, sender, recipient) ->
  @party = party.name
  @sender = _s sender.name
  @recipient = _s recipient.name || recipient

registerCommand {
    name: "party"
    description: "Party commands"
    usage: "\xA7e/<command> <partyname|off|join|create|leave|delete>"
    aliases: [ "p" ]
  },
  (sender, label, args) ->
    unless args[0]
      myParties = listParties sender

      if not myParties.length
        sender.sendMessage "\xA7aYou aren't a member of any parties"
        return false

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

      return false
    switch args[0]
      when "join"
        unless args.length == 2
          sender.sendMessage "\xA7eUsage: /party join [party name]"
        party = getParty args[1]
        unless party
          sender.sendMessage "\xA7cParty '#{args[1]}' not found"
          return

        unless party.users.indexOf(_s sender.name) == -1
          sender.sendMessage "\xA7cYou're already in that party"
          return

        if party.inviteOnly
          unless party.hasInvite sender
            sender.sendMessage "\xA7cYou need an invite to join that party"
            return
        if party.password
          unless hasInvite sender or args[2] == party.password
            sender.sendMessage "\xA7cYou need a password or invite to join that party"

        party.users.push(_s sender.name)
        parties.players[sender.name] = party.name

        disableAdminChat if disableAdminChat
        sender.sendMessage "\xA7aYou are now talking in #{party.displayName}"
      when "create"
        ''
      when "off"
        parties.players[sender.name] = undefined
        sender.sendMessage "\xA7eNow talking in global chat"
      when "delete"
        ''
      else
        if isInParty sender, args[0]
          party = parties.players[sender.name] = getParty(args[0]).name
          sender.sendMessage "\xA7aYou are now talking in #{party.displayName}"
        else
          sender.sendMessage "\xA7cYou aren't in that party, type /party to list the parties you are in"

    JsPersistence.save()
