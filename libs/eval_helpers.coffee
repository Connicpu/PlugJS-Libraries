registerEvent js, "extensions", (event) ->
  event.ext.p = event.sender
  event.ext.loc = event.sender.location
  event.ext.i = event.sender.itemInHand
  event.ext.world = event.sender.world
  event.ext.pl = _a loader.server.onlinePlayers
  event.ext.en = org.bukkit.entity;

  for player in event.ext.pl
    event.ext[player.name] = player if not event.ext[player.name]

registerEvent js, "evalComplete", (event) ->
  