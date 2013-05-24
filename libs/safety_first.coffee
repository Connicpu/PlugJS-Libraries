class safety_first
  joinLogs = registerHash "joinLogs"

  registerEvent player, "join", (event) ->
    joinLogs[event.player.entityId] = TimeSpan::now

  registerEvent entity, "damage", (event) ->
    return unless joinLogs[event.entity.entityId] > 10.seconds.ago
    event.cancelled = true
