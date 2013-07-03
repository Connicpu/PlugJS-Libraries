class PlayerInput
  class InputCallbackEvent
    constructor: (@player, @message, @cancelled = no, @valid = true, @invalidMessage = "") ->

  class ChatbarSession extends EventHandler
    constructor: (@player, @message, @callback) ->
      throw "Only a player can do that" unless @player instanceof org.bukkit.entity.Player
      @player.sendMessage "\xA7e#{message}"
      @player.sendMessage "\xA7eType /cancel to escape"
      super()

    toString: -> "HI DER MAH!"

    onRegister: ->
      @register player, 'chat', @onChat
      @register player, 'command', @onCommand

    onCommand: (event) ->
      message = _s event.message
      return unless event.player.name.equals @player.name
      return unless /^\/cancel\b/i.test message
      event.cancelled = yes
      callbackEvent = new InputCallbackEvent @player, "", yes
      @callback callbackEvent
      @finalize()

    onChat: (event) ->
      return unless event.player is @player
      event.cancelled = yes
      message = _s event.message
      callbackEvent = new InputCallbackEvent @player, message
      @callback callbackEvent
      unless callbackEvent.valid
        event.player.sendMessage callbackEvent.invalidMessage
        return
      @finalize()

  class BookSession extends EventHandler

  awaitChatMessage: (player, message, finished, validCallback) ->
    new ChatbarSession player, message, (event) ->
      if event.cancelled
        player.sendMessage "\xA7eCancelled"
      else
        player.sendMessage "\xA77>> #{event.message}"
        validCallback event
      finished event if event.valid
