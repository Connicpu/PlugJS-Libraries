class bye_have_a_great_time
  sound = new CustomSoundEffect "https://dl.dropboxusercontent.com/u/47432776/spout/sound/bye_have_a_great_time.ogg"
  recentlyPlayed = {}

  registerEvent player, 'move', (event) ->
    if recentlyPlayed[event.player.name] and event.player.velocity.y > -0.1
      recentlyPlayed[event.player.name] = no
      return

    return if recentlyPlayed[event.player.name]
    return unless event.player.velocity.y < -0.5
    return unless heightAboveGround(event.player) > 6

    recentlyPlayed[event.player.name] = yes
    sound.playFor event.player
