class bye_have_a_great_time
  throw "SpoutPlugin not found!" unless 'Spout'.plugin?
  sound = new CustomSoundEffect "https://dl.dropboxusercontent.com/u/47432776/spout/sound/bye_have_a_great_time.ogg"
  recentlyPlayed = {}

  @sound = sound

  registerEvent player, 'move', (event) ->
    if recentlyPlayed[event.player.name] and event.player.velocity.y > -0.1
      recentlyPlayed[event.player.name] = no
      return

    return if recentlyPlayed[event.player.name]
    return unless event.player.velocity.y < -0.3
    return unless heightAboveGround(event.player) > 10

    recentlyPlayed[event.player.name] = yes
    sound.playFor event.player
    for p in _a Bukkit.server.onlinePlayers
      continue if p == event.player
      sound.playFor p, event.player.location, 100

  registerEvent player, 'quit', (event) ->
    sound.play()

