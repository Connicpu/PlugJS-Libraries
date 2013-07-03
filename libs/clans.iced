class Clans
  clans = JsPersistence.tryGet "Clans", {}

  class @Charter
    constructor: (@owner, @name, @description) ->
      @owner = _s @owner.name
      @name = _s @name
      @signatories = [ @owner ]

    @prop 'item',
      get: ->
        item = itemStack Material.WRITTEN_BOOK, 1
        meta = item.itemMeta
        meta.title = "#{@name} clan charter"
        meta.author = @owner
        meta.pages = [
          "\xA78-- Clan Description --\xA7r\n#{@description}",
          "\xA7b-- Signatories --\n#{"\xA74#{player}" for player in @signatories}"
        ]
        item.itemMeta = meta
        item

  class @Clan
    constructor: (@charter) ->

  registerEvent player, 'command', (event) ->
    message = _s event.message
    return unless /^\/poop\b/i.test message
    event.cancelled = true
    await PlayerInput::awaitChatMessage event.player, "Who's the worst musician ever?", defer(response), (event) ->
      unless /justin bieber/i.test event.message
        event.valid = no
        event.invalidMessage = "That is not correct!"
    return if response.cancelled
    event.player.sendMessage "Hooray! We both think #{response.message} is the worse musician ever!"
