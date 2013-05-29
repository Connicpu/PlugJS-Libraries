class bye_have_a_great_time
  throw "SpoutPlugin not found!" unless 'Spout'.plugin?
  sound = new CustomSoundEffect "https://dl.dropboxusercontent.com/u/47432776/spout/sound/bye_have_a_great_time.ogg"
  recentlyPlayed = {}

  @sound = sound

  registerEvent spout, 'tick', (event) ->
    for world in _a Bukkit.server.worlds
      for entity in _a world.entities
        continue unless entity instanceof org.bukkit.entity.LivingEntity

        if recentlyPlayed[entity.entityId] and entity.velocity.y > -0.1
          recentlyPlayed[entity.entityId] = no
          continue

        continue if recentlyPlayed[entity.entityId]
        continue unless entity.velocity.y < -0.3
        continue unless heightAboveGround(entity) > 10

        recentlyPlayed[entity.entityId] = yes
        for player in _a Bukkit.server.onlinePlayers
          if player is entity
            sound.playFor player
          else
            sound.playFor player, entity.location, 50

  registerEvent player, 'quit', (event) ->
    sound.play()

