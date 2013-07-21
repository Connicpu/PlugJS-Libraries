registerEvent player, 'move', (event) ->
  perm = Permissions::getPlayer event.player
  group = _s perm.groups[0]
  return unless group is 'default'
  return unless event.player.location.x < 272
  event.player.teleport cloneLocation event.player.location,
    x: 279,
    y: 67,
    z: 443.5,
    yaw: 90,
    pitch: 0
  event.player.sendMessage "\xA7cDon't leave the spawn before you get promoted!"
