class DisplayNames
  customization = JsPersistence.tryGet "joinCustomization", {}
  stripColor = (input) ->
    return null unless input?
    return input.replace /(\&|\xA7)[0-9a-fk-o]/i, ''
  __s = (input) ->
    return null unless input?
    return _s input

  class UserOptions
    constructor: (@player) ->
      @player = @player.name if @player instanceof org.bukkit.entity.Player
      @player = _s @player
      unless customization[@player]?
        customization[@player] = {}
        JsPersistence.save()
      @update()

    update: () ->
      JsPersistence.save()
      return unless (player = gplr(@player))?
      player.displayName = @name ? player.displayName
      player.playerListName = if @listColor? then "\xA7#{@listColor}#{player.displayName}" else player.displayName
      player.title = @title ? player.playerListName if "Spout".plugin?

    @prop 'name',
      get: () -> customization[@player].name ? null
      set: (value) -> 
        customization[@player].name = stripColor __s value || null
        @update()
    @prop 'listColor',
      get: () -> customization[@player].listColor ? null
      set: (value) -> 
        customization[@player].listColor = __s value || null
        @update()
    @prop 'joinMessage',
      get: () -> customization[@player].joinMessage ? null
      set: (value) -> 
        customization[@player].joinMessage = __s value || null
        @update()
    @prop 'leaveMessage',
      get: () -> customization[@player].leaveMessage ? null
      set: (value) -> 
        customization[@player].leaveMessage = __s value || null
        @update()
    @prop 'title',
      get: () -> customization[@player].title ? null
      set: (value) -> 
        customization[@player].title = __s value || null
        @update()

    @prop 'geoIP',
      get: () ->
        geo = new GeoIP gplr(@player)
        geo = geo.toJSON()
        unless geo.country.name?
          geo.country.name = "The Moon"
          geo.country.code = "MN"
        if /^United/i.test geo.country.name
          geo.country.name = "The #{geo.country.name}"
        return geo

  @User = @::User = (player) -> new UserOptions player

  registerEvent player, 'join', (event) ->
    options = new UserOptions event.player.name

    if options.joinMessage?
      event.joinMessage = options.joinMessage
    else
      geoip = options.geoIP
      event.joinMessage = "\xA7eWelcome \xA7a#{event.player.displayName}\xA7e, who is joining us from \xA7a#{geoip.country.name}"

    bukkit_sync -> options.update()
