class CodeItems
  js_header = "\xA79\xA7oScripted Item"

  class CItem
    constructor: (item) ->
      meta = item.itemMeta
      return unless meta.lore?
      lore = stringArray _a meta.lore
      @isCode = js_header is lore[0]
      return unless @isCode
      _trigger = _s ChatColor.stripColor lore[1]
      for key, trigger of CodeItems::Triggers::
        @trigger = trigger if trigger.label is _trigger
      @code = lore[2].substr(2)

    createItem: (baseItem, options) ->
      code = switch options.type
        when 'iced' then NodeCompiler.CompileIced options.code
        when 'coffee' then NodeCompiler.CompileCoffee options.code
        else options.code

      meta = baseItem.itemMeta
      meta.lore = [
        js_header,
        "\xA76#{options.trigger.label}",
        "\xA77#{code}"
      ]
      baseItem.itemMeta = meta

  class Triggers
    constructor: (@label) ->

    whack_trigger: new Triggers "On-Whack!"
    interact_trigger: new Triggers "Right-click a live thingy"
    rclick_trigger: new Triggers "Right-click a block"
    move_trigger: new Triggers "Shake dat booty"

  registerEvent entity, 'damageByEntity', (event) ->
    return unless event.damager instanceof org.bukkit.entity.Player
    return unless event.damager.itemInHand.itemMeta?
    citem = new CItem event.damager.itemInHand
    return unless citem.isCode
    return unless citem.trigger is Triggers::whack_trigger

    event.cancelled = yes

    ext =
      event: event
      p: event.damager
      loc: event.damager.location
      i: event.damager.itemInHand
      world: event.damager.world
      pl: _a Bukkit.server.onlinePlayers
      en: org.bukkit.entity
      e: event.entity

    try evalInContext citem.code, ext

  registerEvent player, 'interactEntity', (event) ->
    return unless event.player.itemInHand.itemMeta?
    citem = new CItem event.player.itemInHand
    return unless citem.isCode
    return unless citem.trigger is Triggers::interact_trigger

    event.cancelled = yes

    ext =
      event: event
      p: event.player
      loc: event.player.location
      i: event.player.itemInHand
      world: event.player.world
      pl: _a Bukkit.server.onlinePlayers
      en: org.bukkit.entity
      e: event.rightClicked

    try evalInContext citem.code, ext

  registerEvent player, 'interact', (event) ->
    return unless event.action is event.action.RIGHT_CLICK_BLOCK
    return unless event.player.itemInHand.itemMeta?
    citem = new CItem event.player.itemInHand
    return unless citem.isCode
    return unless citem.trigger is Triggers::rclick_trigger

    event.cancelled = yes

    ext =
      event: event
      p: event.player
      loc: event.player.location
      i: event.player.itemInHand
      world: event.player.world
      pl: _a Bukkit.server.onlinePlayers
      en: org.bukkit.entity
      b: clickedBlock

    try evalInContext citem.code, ext

  registerEvent player, 'move', (event) ->
    return unless event.player.itemInHand.itemMeta?
    citem = new CItem event.player.itemInHand
    return unless citem.isCode
    return unless citem.trigger is Triggers::move_trigger

    event.cancelled = yes

    ext =
      event: event
      p: event.player
      loc: event.player.location
      i: event.player.itemInHand
      world: event.player.world
      pl: _a Bukkit.server.onlinePlayers
      en: org.bukkit.entity

    try evalInContext citem.code, ext

  CItem: CItem
  Triggers: Triggers
