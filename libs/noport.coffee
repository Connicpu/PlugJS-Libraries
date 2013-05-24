class noport
  lastDamages = registerHash "lastDamages"

  registerEvent entity, "damage", (event) ->
    lastDamages[event.entity.entityId] = TimeSpan::now if event.entity instanceof org.bukkit.entity.Player

  registerEvent js, "teleport", (event) ->
    return unless lastDamages[event.player.entityId]?

    if lastDamages[event.player.entityId] > 10.seconds.ago
      event.cancelled = true
      timeTil = ((lastDamages[event.player.entityId] + 10.seconds.of.time) - TimeSpan::now).milliseconds.to_seconds
      event.cancelMessage = "\xA7cYou cannot teleport if you have taken damage in the last 10 seconds. You may teleport again in #{timeTil}."
