class FunCommands
  registerCommand {
      name: "me"
      description: "Broadcasts into chat as if you were doing the action"
      usage: "\xA7eUsage: /<command> <action>"
      permission: registerPermission("js.fun.me", "true")
      permissionMessage: "\xA7cYou do not have sufficient permissions to use that."
    }, 
    (sender, label, args) ->
      message = args.join(" ")
      displayName = undefined
      if sender instanceof org.bukkit.command.ConsoleCommandSender
        displayName = "\xA7c*Console"
      else if sender instanceof org.bukkit.command.RemoteConsoleCommandSender
        displayName = "\xA7c*Rcon"
      else if sender instanceof org.bukkit.command.BlockCommandSender
        displayName = "[@]"
      else
        displayName = sender.displayName
      loader.server.broadcastMessage "\xA75* " + displayName + " \xA7r\xA75" + message

  registerPermission "js.fun.ride.block", "op"
  registerPermission "js.fun.ride.block.bypass", "op"
  registerCommand
    name: "ride",
    description: "Places you on top of another player",
    usage: "\xA7eUsage: /<command> <player>",
    permission: registerPermission("js.fun.ride", "true"),
    permissionMessage: "\xA7cYou do not have sufficient permissions to use that.",
    (sender, label, args) ->
      unless sender instanceof org.bukkit.entity.Player
        sender.sendMessage "\xA7cUnable to use this command at Console."
        return
      return false unless args.length is 1
      target = gplr(args[0])
      if target.hasPermission("js.fun.ride.block") and not sender.hasPermission("js.fun.ride.block.bypass")
        sender.sendMessage "\xA7cYou don't have permission to ride this player."
        return
      if target.name is sender.name
        sender.sendMessage "\xA7cWhy would you attempt to ride yourself? (Please, don't answer that.)"
        return
      target.passenger = sender

  registerCommand
    name: "eject",
    description: "Gets anything off of you, and gets you out of anything",
    usage: "\xA7eUsage: /eject", 
    (sender, label, args) ->
      sender.leaveVehicle() if sender.vehicle
      sender.eject() if sender.passenger

  registerCommand
    name: "give",
    description: "Gives another player an item",
    usage: "\xA7eUsage: /<command> <player> <item[:data]> [amount]",
    permission: registerPermission("js.fun.give.others", "op"),
    permissionMessage: "\xA7cYou do not have sufficient permissions to use that.",
    (sender, label, args) ->
      unless args.length >= 2 and args.length <= 3
        return false

      player = gplr(args[0])

      throw "Player not found" unless player?

      amount = 1
      data = 0

      itemId = if args[1].split(':').length == 2
        split = args[1].split(':')
        data = split[1]
        getItemId(split[0])
      else getItemId(args[1])
      throw "Can't find item '#{args[1]}'" if itemId == -1

      itemId = Material['getMaterial(int)'] itemId

      data = new ItemColor(data, itemId).value

      amount = args[2] if args[2]

      item = itemStack(itemId, amount, data)
      player.inventory.addItem [ item ]

      amount = 'Infinite' if amount < 0

      if itemId == itemId.WOOL
        type = "#{new ItemColor(data).woolName} wool"
      else if itemId == itemId.INK_SACK
        type = "#{new ItemColor(data).dyeName} dye"
      else
        type = _s item.type
      player.sendMessage "\xA7eYou were given #{amount} x #{type.toTitleCase()} by #{sender.displayName}"
      sender.sendMessage "\xA7eGiving #{amount} x #{type.toTitleCase()} to #{player.displayName}"

  registerCommand
    name: "item",
    description: "Spawns item(s) to your inventory.",
    usage: "\xA7eUsage: /<command> <item[:data]> [amount]",
    permission: registerPermission("js.fun.give", "op", [
      { permission: "js.fun.give.others", value: true }
    ]),
    permissionMessage: "\xA7cYou do not have sufficient permissions to use that.",
    aliases: [ "i" ],
    (sender, label, args) ->
      unless sender instanceof org.bukkit.entity.Player
        sender.sendMessage "\xA7cYou cannot execute that command from this input field."
        return

      unless args.length >= 1 and args.length <= 2
        return false

      amount = 1
      data = 0

      itemId = if args[0].split(':').length == 2
        split = args[0].split(':')
        data = split[1]
        getItemId(split[0])
      else getItemId(args[0])
      throw "Can't find item '#{args[0]}'" if itemId == -1

      itemId = Material['getMaterial(int)'] itemId

      data = new ItemColor(data, itemId).value

      amount = args[1] if args[1]

      item = itemStack(itemId, amount, data)
      sender.inventory.addItem [ item ]

      amount = 'Infinite' if amount < 0

      if item.type == item.type.WOOL
        type = "#{new ItemColor(data).woolName()} wool"
      else if item.type == item.type.INK_SACK
        type = "#{new ItemColor(data).dyeName()} dye"
      else
        type = _s item.type
      sender.sendMessage "\xA7eGiven #{amount} x #{type.toTitleCase()}"

  registerPermission "js.fun.teleport.others", "op"
  registerCommand
    name: "tp",
    description: "Teleport yourself to someone.",
    usage: "\xA7eUsage: /<command> [-s] [players] <target>",
    permission: registerPermission("js.fun.teleport", "op", [
      { permission: "js.fun.teleport.others", value: on }
    ]),
    permissionMessage: "\xA7cYou do not have sufficient permissions to use that.",
    aliases: [ "teleport" ],
    flags: on,
    (sender, label, args, flags) ->
      return false unless sender instanceof org.bukkit.entity.Player or args.length > 1
      teleport = if flags.indexOf('s') != -1
        (entity, location) -> 
          safeTeleport entity, location
          entity.sendMessage "\xA7eTeleported!"
      else
        (entity, location) ->
          entity.sendMessage "\xA7eTeleported!"
          entity.teleport location

      players = if args.length > 1 then selectPlayers args.slice(0, args.length - 1), sender else [ sender ]

      unless players.length
        sender.sendMessage "\xA7cNone of the players listed were found."
        return

      target = selectTarget args[args.length - 1], sender

      teleport player, target for player in players

      sender.sendMessage "\xA7ePlayer(s) teleported" unless players.indexOf(sender) != -1

  registerPermission("js.fun.teleport.call", "true", [
    { permission: "js.fun.teleport", value: on }
  ])

  #registerCommand
  #  name: "bring",
  #  description: "Go to and be brought by other players",
  #  aliases: [ "call" ],
  #  (sender, label, args) ->
      

  registerCommand
    name: "ping",
    description: "Test the server's latency.",
    usage: "\xA7e/<command>",
    aliases: [ "pong" ],
    (sender, label, args) ->
      if label == "ping"
        sender.sendMessage "\xA7ePong!"
      else
        sender.sendMessage "\xA7eI hear #{sender.displayName}\xA7e likes cute asian boys"

  registerCommand
    name: "setspawn",
    description: "Sets the spawn",
    usage: "\xA7e/<command>",
    permission: registerPermission("js.fun.setspawn", "op"),
    permissionMessage: "\xA7cNo can do boss",
    aliases: [ "setworldspawn" ],
    (sender, label, args) ->
      throw "Only a player can do that" unless sender instanceof org.bukkit.entity.Player
      sender.world.setSpawnLocation sender.location.x, sender.location.y, sender.location.z

   #registerCommand
   # name: "spawn",
   # description: "Takes you to the spawnpoint of the world you are currently in.",
   # usage: "\xA7e/<command>",
   # permission: registerPermission("js.fun.spawn", "true"),
   # permissionMessage: "\xA7cYou do not have sufficient permissions to use that.",
   # aliases: [ "tpspawn" ],
   # (sender, label, args) ->
   #   safeTeleport sender, sender.world.spawnLocation

  registerEvent player, 'command', (event) ->
    event.message = "/mv spawn" if /^\/spawn$/i.test(event.message)

  registerPermission "js.kickall.override", "op"
  registerPermission "js.kickall", "op"

  registerCommand
    name: "kickall",
    description: "Kicks all players from the server.",
    usage: "\xA7e/<command>",
    permission: "js.kickall",
    permissionMessage: "\xA7cWhat are you doing??",
    (sender, label, args) ->
      for player in _a Bukkit.server.onlinePlayers
        player.kickPlayer(args.join ' ') unless player.hasPermission "js.kickall.override" 

  registerCommand
    name: "censor",
    description: "Displays information about the chat censor",
    usage: "\xA7e/<command>",
    permission: "js.censor.info",
    permissionMessage: "\xA7cNo can do, buckaroo",
    (sender, label, args) ->
      sender.sendMessage "\xA7c[CHAT CENSOR INFORMATION]"
      sender.sendMessage "\xA7bCensor definitions created by Nathan, please contact Nyoung3 if you wish to propose a change or addition."

  class NetherLightSession extends EventHandler
    constructor: (@player) ->
      super()
    onRegister: ->
      @register player, 'interact', @onInteract
    onInteract: (event) ->
      return unless event.player is @player
      return unless event.action is event.action.RIGHT_CLICK_BLOCK
      @finalize()

      block = event.clickedBlock
      upperblock = block.getRelative org.bukkit.block.BlockFace.UP
      throw "That's not obsidian or netherrack xD" unless block.type is Material.OBSIDIAN or block.type is Material.NETHERRACK
      throw "It needs air above it for the fire!" unless upperblock.type is Material.AIR
      upperblock.type = Material.FIRE

  registerCommand
    name: "netherlight",
    description: "Lights your nether portal!",
    usage: "/<command>",
    aliases: [ "nl", "nlight", "netlit" ],
    (sender, label, args) ->
      sender.sendMessage "\xA7eRight click the obsidian or netherrack you want to light"
      new NetherLightSession sender

#  registerPermission "js.muteall.override", "op"
#  registerPermission "js.muteall", "op"
#
#  mutedPlayers = registerHash "muted_players"
#
#  registerCommand
#    name: "muteall",
#    description: "mute all players on the server",
#    usage: "\xA7e/<command> [-fu]",
#    permission: "js.muteall",
#    permissionMessage: "\xA7cYou do not have sufficient permission to do that",
#    flags: on,
#    (sender, label, args, flags) ->
#
#     if flags.indexOf('u') is -1
#       for player in _a Bukkit.server.onlinePlayers
#          unless player.hasPermission 'js.muteall.override' or flags.indexOf('f') is -1
#            mutedPlayers[player.name.toLowerCase()] = yes
#            player.sendMessage "\xA7e#{sender.name} has muted the server."
#      else
#        for player in _a Bukkit.server.onlinePlayers
#          mutedPlayers[player.name.toLowerCase()] = no
#
#  registerEvent player, 'chat', (event) ->
#    for player in _a event.recipients
#      event.recipients.remove player if mutedPlayers[player.name.toLowerCase()]
