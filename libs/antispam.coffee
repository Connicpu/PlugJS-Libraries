class AntiSpam
  spams = registerHash "antispams"

  class Spam
    constructor: (@player, @message) ->

  class SpamGroup
    constructor: (@player) ->
    onMessage: (@message) ->
    @prop 'spamLevel',
      get: ->
