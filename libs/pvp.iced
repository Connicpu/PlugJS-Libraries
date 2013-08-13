class Pvp
  blacklisted_worlds = [ "creative" ]

  getDuels = ->
    duelHash = registerHash "duels"
    duelHash.duels ||= []
    duelHash.duels
  duels = getDuels()

  class DuelState
    constructor: (@isDueling) ->

    NOT_DUELING: new DuelState no
    REQUEST_SENT: new DuelState no
    INITIALIZING: new DuelState yes
    DUELING: new DuelState yes
    DONE: new DuelState no

  class Duel extends EventHandler
    @prop 'duelState',
      get: -> @__duelState__
      set: (value) ->
        @__duelState__ = value
        @finalize() if value is DuelState::DONE

    constructor: (@challenger, @defender) ->
      @cancel = no
      @duelState = DuelState::REQUEST_SENT
      @ensureOnlyDuel()

      @challenger.sendMessage "\xA7bDuel request sent..."
      @defender.sendMessage "\xA7b#{@challenger.displayName}\xA7r\xA7b wishes to duel you. Right click them to accept!"
      super()

      await bukkit_sync defer(), null, 20.seconds.of.ticks
      return unless @duelState is DuelState::REQUEST_SENT

      @duelState = DuelState::DONE
      sendMessageTo [@challenger, @defender], "\xA7cDuel cancelled"

    onRegister: ->
      @register player, 'interactEntity', @playerInteract
      @register player, 'move', @disableCreative
      @register player, 'command', @disableCommands
      @register js, 'pvp', @handlePvp
      @register player, 'death', @playerDeath

    playerInteract: (event) ->
      return unless @duelState is DuelState::REQUEST_SENT
      return unless event.player is @defender
      return unless event.rightClicked is @challenger

      @duelState = DuelState::INITIALIZING

      secondsRemaining = 3
      sendMessageTo [@challenger, @defender], "\xA7bPrepare to duel in..."

      while secondsRemaining
        sendMessageTo [@challenger, @defender], "\xA7b#{secondsRemaining}..."
        await bukkit_sync defer(), null, 1.second.of.ticks
        --secondsRemaining

      sendMessageTo [@challenger, @defender], "\xA7aGO!"
      @duelState = DuelState::DUELING

    disableCreative: (event) ->
      return if event.player.gameMode is GameMode.SURVIVAL
      event.player.gameMode = GameMode.SURVIVAL

    disableCommands: (event) ->
      return unless @duelState.isDueling
      event.cancelled = yes

    handlePvp: (event) ->
      return unless event.damager is @challenger or event.damager is @defender
      return unless event.player is @challenger or event.player is @defender

      event.cancelled = no if @duelState is DuelState::DUELING

    playerDeath: (event) ->
      return unless event.entity is @challenger or event.entity is @defender

      Respawns::queueRespawn event.entity, event.entity.location.clone()
      @keepInventoryOnDeath event
      @duelState = DuelState::DONE

      loser = event.entity
      winner = if loser is @challenger then @defender else @challenger

      event.deathMessage = "\xA7b#{loser.displayName} has been defeated in battle by #{winner.displayName}!"
      winner.sendMessage "\xA7aYou have been awarded $10 for winning"
      addMoneyToPlayer winner, 10

    keepInventoryOnDeath: (event) ->
      event.drops.clear()
      inventory = event.entity.inventory
      contents = inventory.contents
      armor = inventory.armorContents
      inventory.clear()

      await bukkit_sync defer(), null, 10

      inventory.contents = contents
      inventory.armorContents = armor

    ensureOnlyDuel: ->
      checkDuel = (player) ->
        duel = Pvp::getDuel player
        return unless duel?
        switch duel.duelState
          when DuelState::NOT_DUELING then return
          when DuelState::REQUEST_SENT then duel.cancel()
          when DuelState::INITIALIZING then throw "Already dueling"
          when DuelState::DUELING then throw "Already dueling"
          when DuelState::DONE then return

      checkDuel @challenger
      checkDuel @defender

    cancel: ->
      @duelState = DuelState::DONE

      switch @duelState
        when DuelState::REQUEST_SENT
          @cancel = yes
          @challenger.sendMessage "\xA7cDuel request with #{@defender.displayName}\xA7r\xA7c cancelled"
        when DuelState::INITIALIZING
          @cancel = yes
          @challenger.sendMessage "\xA7cDuel request with #{@defender.displayName}\xA7r\xA7c cancelled"
          @defender.sendMessage "\xA7cDuel request with #{@challenger.displayName}\xA7r\xA7c cancelled"
        when DuelState::DUELING
          @cancel = yes
          @challenger.sendMessage "\xA7cDuel with #{@defender.displayName}\xA7r\xA7c cancelled"
          @defender.sendMessage "\xA7cDuel with #{@challenger.displayName}\xA7r\xA7c cancelled"

    registerEvent player, 'interactEntity', (event) ->

  getDuel: (player) ->
    Enumerable.From(duels).Where((duel) -> duel.challenger is player or duel.defender is player).FirstOrDefault()

  getDuelState: (player) ->
    duel = Pvp::getDuel player
    return DuelState::NOT_DUELING unless duel?
    return duel.duelState

  isDueling: (player) ->
    duel = Pvp::getDuel player
    duel? and duel.duelState.isDueling

  duelClass: Duel
