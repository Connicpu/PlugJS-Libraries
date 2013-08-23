class Permissions
  throw "Vault not found!" unless 'Vault'.plugin?
  vault = getPlugin "Vault"

  chatProviderService = loader.server.servicesManager.getRegistration vault.class.classLoader.loadClass "net.milkbowl.vault.chat.Chat"
  throw "Error loading vault chat provider" unless chatProviderService.provider?
  chatProvider = chatProviderService.provider

  permissionProviderService = loader.server.servicesManager.getRegistration vault.class.classLoader.loadClass "net.milkbowl.vault.permission.Permission"
  throw "Error loading vault permission provider" unless permissionProviderService.provider?
  permissionProvider = permissionProviderService.provider

  @prop 'supportsGroups', get: () -> permissionProvider.hasGroupSupport()
  @prop 'superPermsCompatible', get: () -> permissionProvider.hasSuperPermsCompat()

  @::getPlayer = (player) -> new PlayerInfo player
  @getPlayer = @::getPlayer

  class PlayerInfo
    constructor: (@player) ->
      @player = (gplr(@player) ? Bukkit.server.getOfflinePlayer @player) unless @player instanceof org.bukkit.command.CommandSender
    getGroups: (world) ->
      unless world?
        permissionProvider.getPlayerGroups @player
      else
        permissionProvider.getPlayerGroups world, @player.name
    getPrimaryGroup: (world) ->
      permissionProvider.getPrimaryGroup world
    has: (permission, world) ->
      unless world?
        permissionProvider.has @player, permission
      else
        permissionProvider.has world, @player.name, permission
    add: (permission, world) ->
      unless world?
        permissionProvider.playerAdd @player, permission
      else
        permissionProvider.playerAdd world, @player.name, permission
    remove: (permission, world) ->
      unless world?
        permissionProvider.playerRemove @player, permission
      else
        permissionProvider.playerRemove world, @player.name, permission
    isInGroup: (group, world) ->
      unless world?
        permissionProvider.playerInGroup @player, group
      else
        permissionProvider.playerInGroup world, @player.name, group
    addGroup: (group, world) ->
      unless world?
        permissionProvider.playerAddGroup @player, group
      else
        permissionProvider.playerAddGroup world, @player.name, group
    removeGroup: (group, world) ->
      unless world?
        permissionProvider.playerRemoveGroup @player, group
      else
        permissionProvider.playerRemoveGroup world, @player.name, group

    getPrefix: (world) ->
      unless world?
        chatProvider.getPlayerPrefix @player
      else
        chatProvider.getPlayerPrefix world, @player.name
    setPrefix: (value, world) ->
      if world is undefined
        chatProvider.setPlayerPrefix @player, value
      else if world is null
        chatProvider['setPlayerPrefix(java.lang.String,java.lang.String,java.lang.String)'] world, @player.name, value
      else
        chatProvider.setPlayerPrefix world, @player.name, value

    getSuffix: (world) ->
      unless world?
        chatProvider.getPlayerSuffix @player
      else
        chatProvider.getPlayerSuffix world, @player.name
    setSuffix: (value, world) ->
      if world is undefined
        chatProvider.setPlayerSuffix @player, value
      else if world is null
        chatProvider['setPlayerSuffix(java.lang.String,java.lang.String,java.lang.String)'] world, @player.name, value
      else
        chatProvider.setPlayerSuffix world, @player.name, value

    class PlayerOptionInfoNoWorld
      constructor: (@pinfo, @node, @def) ->
        @player = @pinfo.player
      @prop 'boolean', 
        get: () -> chatProvider.getPlayerInfoBoolean @player, @node, @def
        set: (value) -> chatProvider.setPlayerInfoBoolean @player, @node, value
      @prop 'string', 
        get: () -> _s chatProvider.getPlayerInfoString @player, @node, @def
        set: (value) -> chatProvider.setPlayerInfoString @player, @node, value
      @prop 'double', 
        get: () -> chatProvider.getPlayerInfoDouble @player, @node, @def
        set: (value) -> chatProvider.setPlayerInfoDouble @player, @node, value
      @prop 'integer', 
        get: () -> chatProvider.getPlayerInfoInteger @player, @node, @def
        set: (value) -> chatProvider.setPlayerInfoInteger @player, @node, @def
    class PlayerOptionInfoWithWorld
      constructor: (@pinfo, @node, @world, @def) ->
        @player = @pinfo.player
      @prop 'boolean', 
        get: () -> chatProvider.getPlayerInfoBoolean @world, @player.name, @node, @def
        set: () -> chatProvider.setPlayerInfoBoolean @world, @player.name, @node, value
      @prop 'string', 
        get: () -> _s chatProvider.getPlayerInfoString @world, @player.name, @node, @def
        set: () -> chatProvider.setPlayerInfoString @world, @player.name, @node, value
      @prop 'double', 
        get: () -> chatProvider.getPlayerInfoDouble @world, @player.name, @node, @def
        set: () -> chatProvider.setPlayerInfoDouble @world, @player.name, @node, value
      @prop 'integer', 
        get: () -> chatProvider.getPlayerInfoInteger @world, @player.name, @node, @def
        set: () -> chatProvider.setPlayerInfoInteger @world, @player.name, @node, value

    getInfo: (node, def, world) -> if world? then new PlayerOptionInfoWithWorld @, node, world, def else new PlayerOptionInfoNoWorld @, node, def

    @prop 'primaryGroup', get: () -> @getPrimaryGroup null
    @prop 'groups', get: () -> _a @getGroups null
    @prop 'prefix',
      get: () -> _s @getPrefix null
      set: (value) -> @setPrefix value, null
    @prop 'suffix',
      get: () -> _s @getSuffix null
      set: (value) -> @setSuffix value, null

  promotion_disabled = no

  disablePromotion: -> promotion_disabled = yes
  enablePromotion: -> promotion_disabled = no

  promote: (user) ->
    throw "Promotion is temporarily disabled" if promotion_disabled

    perm = Permissions::getPlayer(user)
    group = _s perm.groups[0]
    throw "You've already accepted the rules :P" unless group is 'default'
    perm.removeGroup group
    perm.addGroup 'Member'
    Bukkit.server.broadcastMessage "\xA7eThe player \xA7b#{user.displayName}\xA7e is now a \xA7bMember\xA7e ^.^"
