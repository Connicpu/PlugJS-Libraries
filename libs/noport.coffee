lastDamages = registerHash "lastDamages"

registerEvent entity, "damage", (event) ->
  lastDamages[event.entity.entityId] = new java.util.Date().time if event.entity instanceof org.bukkit.entity.Player

registerEvent js, "teleport", (event) ->
  return unless lastDamages[event.player.entityId]?
  now = new java.util.Date().time
  difference = now - lastDamages[event.player.entityId]

  if difference < 10.seconds.ago
    event.cancelled = true
    event.cancelMessage = "\xA7cYou cannot teleport if you have taken damage in the last 10 seconds"