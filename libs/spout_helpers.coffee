SpoutManager = getPlugin("Spout").class.classLoader.loadClass("org.getspout.spoutapi.SpoutManager").getMethod("getInstance").invoke(null)

SpoutManager.getFileManager().removeFromCache plugin, SpoutManager.getFileManager().getCache plugin

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
class CustomMusic
  cache = SpoutManager.getFileManager()
  sounds = SpoutManager.getSoundManager()
  constructor: (@url, @notify) ->
    @notify = off unless @notify?
    cache.addToCache plugin, @url
  play: (location, distance, volume) ->
    if location and distance and volume
      sounds.playGlobalCustomMusic plugin, @url, @notify, location, distance, volume
    else if location and distance
      sounds.playGlobalCustomMusic plugin, @url, @notify, location, distance
    else if location
      sounds.playGlobalCustomMusic plugin, @url, @notify, location
    else
      sounds.playGlobalCustomMusic plugin, @url, @notify
    true
  playFor: (player, location, distance, volume) ->
    if location and distance and volume
      sounds.playCustomMusic plugin, player, @url, @notify, location, distance, volume
    else if location and distance
      sounds.playCustomMusic plugin, player, @url, @notify, location, distance
    else if location
      sounds.playCustomMusic plugin, player, @url, @notify, location
    else
      sounds.playCustomMusic plugin, player, @url, @notify
    true

class Notification
  constructor: (@title, @message, @item, @time) ->
    @item ?= itemStack Material.FIREWORK, 1
    @time ?= 2.seconds.of.time

    unless @item instanceof org.bukkit.inventory.ItemStack
      @item = itemStack @item, 1
  displayFor: (player) ->
    if player.spoutCraftEnabled
      player.sendNotification @title, @message, @item, @time
    else
      player.sendMessage "\xA76[#{@title}]\xA7r #{@message}"
  display: () ->
    for player in _a Bukkit.server.onlinePlayers
      @displayFor player

  registerEvent js, "evalComplete", (event) ->
    if event.result instanceof Notification
      event.result.display()