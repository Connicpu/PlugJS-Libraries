max_owned_parties = 5

parties = JsPersistence.tryGet "chat_parties", {}

parties.players ||= {}
parties.groups ||= {}

isInPartyChat = (player) ->
  parties.players[player.name] and Party.get player

disablePartyChat = (player) ->
  parties.players[player.name] = undefined

partyChat = (event) ->
  party = Party.get event.player

  log party.displayName, 'b'
  
  event.format = formatChat partyFormat, formatInformation event, { party: party.displayName }

  for player in _a event.recipients
    if (i = party.users.indexOf _s player.name) == -1
      log player
      log i
      event.recipients.remove player 

listParties = (player) ->
  for k,party of parties.groups
    party unless (party.users.indexOf _s player.name) == -1

isInParty = (player, name) ->
  name = name.toLowerCase()
  for party in listParties player
    return true if party.name == name
  return false

class Party
  constructor: (name, owner, @password, @inviteOnly, @membersInvite) ->
    @name = name.toLowerCase()
    @displayName = name
    @owner = _s owner.name
    @users = [ @owner ]
    @invites = []

  hasInvite: (player) ->
    for invite in @invites
      return true if invite.recipient == _s player.name
    false

  removeInvite: (invite) ->
    @invites.splice @invites.indexOf(invite), 1

  @ownedBy: (player) ->
    player = player.name if player instanceof org.bukkit.entity.Player
    player = _s player

    for name,party of parties.groups
      party if party.owner is player

  @get: (name) ->
    return undefined if not name

    if name instanceof org.bukkit.entity.Player
      Party.get parties.players[name.name]
    else
      parties.groups[name.toLowerCase()]

  class Invite
    constructor: (party, sender, recipient) ->
      @party = party.name
      @sender = _s sender.name
      @recipient = _s recipient.name || recipient

registerCommand
  name: "party",
  description: "Party commands",
  usage: "\xA7e/<command> <partyname|off|join|create|leave|delete|invite>",
  aliases: [ "p" ],
  flags: on,
  (sender, label, args, flags) ->
    unless args[0]
      myParties = listParties sender

      if not myParties.length
        sender.sendMessage "\xA7aYou aren't a member of any parties"
        return false

      writeParty = (party) ->
        whiteSpace = ""
        for i in [1..16 - party.name.length]
          whiteSpace += ' '
        sender.sendMessage "\xA7a- #{party.name}"

      sender.sendMessage "\xA7a-- My parties --"
      for party in myParties
        writeParty party

      sender.sendMessage "\xA7eYou are talking in #{Party.get(sender).displayName}" if Party.get sender

      return
    switch args[0]
      when "help"
        return false
      when "join"
        unless args.length == 2
          sender.sendMessage "\xA7eUsage: /party join [party name]"
        party = Party.get args[1]
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
        if args.length < 2
          sender.sendMessage "\xA7e/party create <name> [-i] [-m] [password]"
          return
        if Party.get args[1]
          sender.sendMessage "\xA7cA party with that name already exists"
          return
        unless Party.ownedBy(sender).length < max_owned_parties
          sender.sendMessage "\xA7cYou may only own #{max_owned_parties} parties"
          return

        party = new Party args[1], sender, args[2], flags.indexOf('i') != -1, flags.indexOf('m') != -1
        sender.sendMessage "\xA7a=> #{party}"
      when "off"
        parties.players[sender.name] = undefined
        sender.sendMessage "\xA7eNow talking in global chat"
      when "leave"
        if args.length < 2
          sender.sendMessage "\xA7e/party leave <name>"
          return
        unless isInParty sender, args[1]
          sender.sendMessage "\xA7cYou aren't in a party by the name of '#{args[1]}'"
          return

        party = Party.get args[1]

        if party.owner is _s sender.name
          sender.sendMessage "\xA7cYou can't leave your own party, you must delete it"

        userIndex = party.users.indexOf _s sender.name
        party.users.splice userIndex, 1
      when "delete"
        ''
      else
        if isInParty sender, args[0]
          disableAdminChat sender if disableAdminChat
          party = Party.get args[0]
          parties.players[sender.name] = party.name
          sender.sendMessage "\xA7aYou are now talking in #{party.displayName}"
        else
          sender.sendMessage "\xA7cYou aren't in that party, type /party to list the parties you are in"

    JsPersistence.save()
