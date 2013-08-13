class Respawns
  respawn_locations = registerHash "respawn_locations"

  queueRespawn: (player, location) ->
    respawn_locations[player.name] = location

  registerEvent player, 'respawn', (event) ->
    location = respawn_locations[event.player.name]
    return unless location?
    event.respawnLocation = location