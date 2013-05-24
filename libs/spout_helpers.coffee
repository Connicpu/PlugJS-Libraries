SpoutManager = getPlugin("Spout").class.classLoader.loadClass("org.getspout.spoutapi.SpoutManager").getMethod("getInstance").invoke(null)

class CustomSoundEffect
  cache = SpoutManager.getFileManager()
  sounds = SpoutManager.getSoundManager()
  constructor: (@url, @notify) ->
    @notify = off unless @notify?
    cache.addToCache plugin, @url
  play: (location, distance, volume) ->
    if location and distance and volume
      sounds.playGlobalCustomSoundEffect plugin, @url, @notify, location, distance, volume
    else if location and distance
      sounds.playGlobalCustomSoundEffect plugin, @url, @notify, location, distance
    else if location
      sounds.playGlobalCustomSoundEffect plugin, @url, @notify, location
    else
      sounds.playGlobalCustomSoundEffect plugin, @url, @notify
    true
  playFor: (player, location, distance, volume) ->
    if location and distance and volume
      sounds.playCustomSoundEffect plugin, player, @url, @notify, location, distance, volume
    else if location and distance
      sounds.playCustomSoundEffect plugin, player, @url, @notify, location, distance
    else if location
      sounds.playCustomSoundEffect plugin, player, @url, @notify, location
    else
      sounds.playCustomSoundEffect plugin, player, @url, @notify
    true