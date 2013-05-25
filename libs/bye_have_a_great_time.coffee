class bye_have_a_great_time
  sound = new CustomSoundEffect "https://dl.dropboxusercontent.com/u/47432776/spout/sound/bye_have_a_great_time.ogg"
  recentlyPlayed = {}

  @prop 'sound', get: () -> sound

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

#class its_only_a_game_why_you_heff_to_be_mad
#  sound = new CustomSoundEffect "https://dl.dropboxusercontent.com/u/47432776/spout/sound/is_only_a_game_why_you_heff_to_be_mad.ogg"
#
#  registerEvent player, "death", (event) ->
#    sound.playFor event.entity