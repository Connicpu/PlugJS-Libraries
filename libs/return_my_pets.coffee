registerCommand
  name: "returnmypets"
  description: "Returns all animals you own to you",
  usage: "\xA7e/<command>",
  aliases: [ "returnpets", "rmp" ],
  (sender, label, args) ->
    entities = for entity in _a sender.world.entities
      continue unless entity instanceof org.bukkit.entity.Tameable
      continue unless entity.owner is sender
      entity.eject() if entity.passenger isnt null
      entity.leaveVehicle() if entity.vehicle isnt null
      continue unless entity.teleport sender.location
      entity
    sender.sendMessage "\xA7e#{entities.length} pet(s) found and teleported to you"

