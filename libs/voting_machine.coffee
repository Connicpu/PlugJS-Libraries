class VotingMachine
  __s = (input) ->
    return null unless input?
    return _s input

  class @Option
    constructor: (@options) ->
      # We need to know what material to use, and what to title it
      throw "A label and material must be specified!" unless @options.label? and @options.material?
      # Ensure that serializing this string won't fuq shit up :V
      @options.label = _s @options.label
    # Calculate results on a per-option level so I can sort them and return the first cleanly!
    calculateResults: (vote) ->
      total = 0
      for player, result of vote.results
        ++total if result.label is @options.label
      return total
    # Generate the metadata for the voting option
    getMeta: (item) ->
      meta = item.itemMeta
      meta.displayName = @options.label
      meta.lore = [ @options.information ] if @options.information?
      meta
    # Create the item which will be displayed to the player
    @prop 'item', get: () -> 
      stack = itemStack @options.material, -343, @options.data ? 0
      stack.itemMeta = @getMeta stack
      stack
    toJSON: () ->
      return json =
        label: @options.label,
        material: @options.material.id,
        data: @options.data,
        information: __s @options.information
    @fromJSON: (json) ->
      json = JSON.parse _s json
      return new VotingMachine.Option
        label: json.label
        material: Material.getMaterial(json.material)
        data: json.data
        information: json.information


  # Base voting class which all other voting types inherit from
  class Vote
    constructor: (@options) ->
      @results = {}
    show: (player) ->
      session = new VotingMachine.VoteSession @, player
      session.start()

    placeInInventory: () -> throw "Abstract class not fully implemented"
    type: () -> throw "Abstract class not fully implemented"
    @jsonConstructor = () -> throw "Abstract class not fully implemented"

    @prop 'winner',
      get: () ->
        options = @options.slice 0
        options.sort (a, b) -> a.calculateResults(@) - b.calculateResults(@)
        options[0]

    toJSON: (json = {}) ->
      json.type = @type()
      json.options = @options
      json.results = @results
      json

  @fromJSON: (json) ->
    json = JSON.parse json if typeof json is 'string'
    vote = @[json.type].jsonConstructor(json)
    vote.options = []
    vote.results = {}
    for option, index in json.options
      vote.options[index] = VotingMachine.Option.fromJSON option
    for name, result of json.results
      vote.results[name] = VotingMachine.Option.fromJSON result
    vote

  # A voting session which handles all the player interaction for voting
  class @VoteSession
    constructor: (@vote, @player) ->

    # Initialize the voting session
    start: () ->
      # Create an inventory to display the options and allow the player to read what they are voting on
      @inventory = Bukkit.server.createInventory @player, 9 * @vote.requiredRows(), @title ? "Voting Machine"

      # Populate the inventory from the voting class
      contents = @inventory.contents
      @vote.placeInInventory contents
      @inventory.contents = contents

      self = @

      # Register events to handle voting
      @clickH = registerEvent inventory, 'click', (event) ->
        return unless event.view.topInventory?
        return unless event.view.topInventory.title.equals self.inventory.title 
        return unless event.whoClicked is self.player

        event.cancelled = yes

        return unless event.slot is event.rawSlot and event.slot >= 0

        return unless event.cursor?
        return unless event.currentItem?.itemMeta?.displayName?

        getOption = () ->
          for option in self.vote.options
            return option if option.options.label is _s event.currentItem.itemMeta.displayName
          return null

        return unless (option = getOption())?

        self.vote.results[self.player.name] = option
        self.voted = yes

        event.view.close()
        self.player.sendMessage "\xA7eYou chose #{option.options.label}"
        self.player.sendMessage "\xA7eThank you for voting!"

      @closeH = registerEvent inventory, 'close', (event) ->
        self.finalize()
        self.player.sendMessage "\xA77Voting cancelled" unless self.voted

      # Display the inventory to the player
      @player.openInventory @inventory

      return @

    # Unregister the events
    finalize: () ->
      unregisterEvent inventory, 'click', @clickH
      unregisterEvent inventory, 'close', @closeH

  # Simple yes/no vote
  class @YesNoVote extends Vote
    yesVote = new VotingMachine.Option
      label: "\xA7aYes",
      material: Material.WOOL,
      data: ItemColor.fromWoolName('lime'),
    noVote = new VotingMachine.Option
      label: "\xA74No",
      material: Material.WOOL,
      data: ItemColor.fromWoolName('red'),

    type: () -> "YesNoVote"
    constructor: (@text, @title) ->
      super [ yesVote, noVote ]

    @jsonConstructor = (json) ->
      new VotingMachine.YesNoVote json.text, json.title

    toJSON: () ->
      json = super()
      json.text = __s @text
      json.title = __s @title
      json

    requiredRows: () -> 2
    placeInInventory: (contents) ->
      # Create the informative item that tells the player what they are voting on
      infoItem = itemStack Material.PAPER, -343
      infoText = @text
      infoItem.itemMeta = createItemMeta Material.PAPER, (meta) ->
        meta.displayName = "Voting information"
        meta.lore = [ infoText ]

      # Put informative item at row 1 column 5
      contents[9*0 + 4] = infoItem

      # Put yes option at row 2 column 3
      contents[9*1 + 2] = @options[0].item
      # Put no option at row 2 column 7
      contents[9*1 + 6] = @options[1].item

  class @SimpleMultiVote extends Vote
    type: () -> "SimpleMultiVote"
    constructor: (@org_options, @text, @title) ->
      options = for option in @org_options
        option.label = _s option.label
        color = option.color = _s option.color
        color = new ItemColor color, "Wool"

        new VotingMachine.Option
          label: "\xA7#{color.chatColor()}#{option.label}",
          material: Material.WOOL,
          data: color.value

      super options

    @jsonConstructor = (json) ->
      new VotingMachine.YesNoVote json.org_options, json.text, json.title

    toJSON: () ->
      json = super()
      json.text = __s @text
      json.title = __s @title
      json.org_options = @org_options
      json

    requiredRows: () -> (@options.length - @options.length % 4)/4 + 2
    placeInInventory: (contents) ->
      infoItem = itemStack Material.PAPER, -343
      infoText = @text
      infoItem.itemMeta = createItemMeta Material.PAPER, (meta) ->
        meta.displayName = "Voting information"
        meta.lore = [ infoText ]

      contents[4] = infoItem

      options = @options.slice 0

      rownum = 0
      while options.length
        ++rownum
        row = options.splice 0, 4
        switch row.length
          when 4
            contents[9*rownum + 1] = row[0].item
            contents[9*rownum + 3] = row[1].item
            contents[9*rownum + 5] = row[2].item
            contents[9*rownum + 7] = row[3].item
          when 3
            contents[9*rownum + 2] = row[0].item
            contents[9*rownum + 4] = row[1].item
            contents[9*rownum + 6] = row[2].item
          when 2
            contents[9*rownum + 2] = row[0].item
            contents[9*rownum + 6] = row[1].item
          when 1
            contents[9*rownum + 4] = row[0].item

  class @VotingMachine
    constructor: (@vote, @block) ->
      @key = "#{@block.x},#{@block.y},#{@block.z},#{@block.world.name}"
    @prop 'openCode',
      get: () -> CoffeeScript.compile """
          
        """, bare: yes


testVote = new VotingMachine.SimpleMultiVote [
    { label: "Fluttershy", color: 'yellow' }
    { label: "Rainbow Dash", color: 'lightblue' }
    { label: "Twilight Sparkle", color: 'magenta' }
    { label: "Rarity", color: 'purple' }
    { label: "Pinkie Pie", color: 'pink' }
    { label: "Applejack", color: 'orange' }
  ], "Who is best pony?"
