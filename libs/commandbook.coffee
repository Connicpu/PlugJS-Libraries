class CommandBook
  @components = -> "CommandBook".plugin.componentManager
  @homesComponent = -> CommandBook.components().getComponent "CommandBook".plugin.class.classLoader.loadClass "com.sk89q.commandbook.locations.HomesComponent"
  @homes = -> CommandBook.homesComponent().manager
  @getHome = (player) ->
    player = _s player.name unless typeof(player) is 'string'
    locations = _a CommandBook.homes().getLocations(null)
    Enumerable.From(locations).Where((x) -> player is _s x.name).FirstOrDefault() ? null
