class CreativePlots
  plot_size = 80
  road_size = 5
  plot_world = 'creative'
  plot_ownerships = JsPersistence.tryGet 'creative_plots', {}
  plot_height = 20
  all_builds = registerHash 'all_builds'

  @Ownerships = plot_ownerships

  materials = [
    { depth: 1, material: 7 }
    { depth: 9, material: 3 }
    { depth: 9, material: 3 }
    { depth: 1, material: 2 }
  ]
  road_materials = [
    { depth: 1, material: 7 }
    { depth: 18, center_material: 20, edge_material: 7 }
    { depth: 1, center_material: 44, edge_material: 43 }
    { depth: 1, center_material: 0, edge_material: 139, breakAtCenter: 1 }
    { depth: 1, center_material: 0, edge_material: 101, breakAtCenter: 1 }
    { depth: 5, material: 0 }
  ]

  class @PlotOwnership
    constructor: (@x, @y, @owner) ->
      @owner = _s @owner.name if @owner instanceof org.bukkit.entity.Player
      @invites = []

    @prop 'hashCode', 
      get: -> PlotOwnership.GetHashCode @x, @y
    @prop 'plot',
      get: -> new CreativePlots.Plot @x, @y
    @GetHashCode = (x,y) -> "#{x},#{y},#{plot_world}"
    @CountByOwner = (owner) ->
      count = 0
      for hash, plot of plot_ownerships
        ++count if plot.owner is owner
      count
    @MaxOwnedBy = (owner) ->
      rankNumber = ->
        return 3 if SpecialUsers::IsVip owner
        return 2 if SpecialUsers::IsVeteran owner
        return 1
      permsNumber = ->
        Permissions::getPlayer(owner).getInfo("js.extraplots", 0, Bukkit.server.getWorld plot_world).integer

      return rankNumber() + permsNumber()
    fromJson: (json) ->
      js = JSON.parse json
      own = new PlotOwnership js.x, js.y, js.owner
      own.invites = js.invites ? []
      own
    renderSigns: (worldEdit, player) ->
      getText = ->
      if @owner is 'CONSOLE'
        getText = -> "\n\xA75Spawn Plot"
      else if @owner is 'STAFF'
        getText = -> "\n\xA75Reserved for\n\xA75Staff use"
      else
        _owner = @owner
        getText = -> "\n\xA75Plot owned by\n\xA74#{_owner}"

      CreativePlots::GeneratePlotSigns worldEdit, player, @x, @y, getText
    teleport: (player) ->
      center = CreativePlots::GetPlotCenter @x, @y
      center.y = plot_height + 1
      player.teleport center
    invite: (playername) ->
      return no if @invites.indexOf(playername) isnt -1
      @invites.push playername
      JsPersistence.save()
      yes
    uninvite: (playername) ->
      return no unless @invites.indexOf(playername) isnt -1
      index = @invites.indexOf playername
      @invites.splice index, 1
      JsPersistence.save()
      yes

  for k, v of plot_ownerships
    plot_ownerships[k] = CreativePlots.PlotOwnership::fromJson JSON.stringify v

  class @Plot
    constructor: (@x, @y) ->
    generate: (player) ->
      CreativePlots::GeneratePlot player, @x, @y, yes, yes, yes
    refreshPlot: (player) ->
      CreativePlots::GeneratePlot player, @x, @y, yes, no, no
    fixRoads: (player) ->
      CreativePlots::GeneratePlot player, @x, @y, no, yes, yes
    @prop 'isClaimed',
      get: -> plot_ownerships[CreativePlots.Plot.GetHashCode @x, @y]?
    @prop 'ownership',
      get: -> plot_ownerships[CreativePlots.Plot.GetHashCode @x, @y]
    @GetHashCode = (x,y) -> "#{x},#{y},#{plot_world}"
    @prop 'hashCode', 
      get: -> CreativePlots.PlotOwnership.GetHashCode @x, @y
    placeSigns: (worldEdit, player) ->
      return unless @isClaimed
      @ownership.renderSigns worldEdit, player
    getPlotForLocation: (location) ->
      return null unless location.world.name.equalsIgnoreCase plot_world

      lx = location.x
      ly = location.z

      mod_dist = plot_size + road_size
      half_min = 0.51 - (1 / mod_dist) * (road_size / 2)
      half_max = 0.49 + (1 / mod_dist) * (road_size / 2)

      sx = lx / mod_dist
      sy = ly / mod_dist

      x_1mod = Math.abs sx % 1
      y_1mod = Math.abs sy % 1

      return null if (half_min < x_1mod < half_max) or (half_min < y_1mod < half_max)

      x = Math.round(sx)
      y = Math.round(sy)

      new CreativePlots.Plot x, y
    claimForPlayer: (name) ->
      ownership = new CreativePlots.PlotOwnership @x, @y, _s name
      plot_ownerships[ownership.hashCode] = ownership
    clearOwnership: ->
      plot_ownerships[@hashCode] = undefined

    buildanywhereperm = registerPermission "js.plots.buildanywhere", "op"

    blockBuild = (event) ->
      return if all_builds[event.player.name]
      return unless event.block.location.world.name.equalsIgnoreCase plot_world

      plot = CreativePlots.Plot::getPlotForLocation event.block.location
      name = _s event.player.name
      unless plot? and plot.isClaimed
        event.cancelled = yes
        return
      plot = plot.ownership

      isOwner = plot.owner is name
      isInvited = plot.invites.indexOf(name.toLowerCase()) isnt -1
      event.cancelled = not (isOwner or isInvited)

    registerEvent block, 'bbreak', blockBuild

    registerEvent block, 'place', blockBuild

    registerEvent player, 'teleport', (event) ->
      return if event.to.world.name.equalsIgnoreCase plot_world
      return if event.player.gameMode is GameMode.SURVIVAL
      return if event.player.hasPermission "js.cancreativesurvival"
      event.player.gameMode = GameMode.SURVIVAL

    registerCommand
      name: "togglecreativebuild",
      description: "Toggles whether you can build in creative",
      usage: "/<command>",
      permission: buildanywhereperm,
      permissionMessage: "You can't do that >.<",
      (sender, label, args) ->
        all_builds[sender.name] = !all_builds[sender.name]
        sender.sendMessage "\xA7aCreative Building set to #{all_builds[sender.name]}"

    registerCommand
      name: "gotoplot",
      description: "Takes you to your plot!",
      usage: "/<command> [#] [name]",
      (sender, label, args) ->
        skip = _n(args[0] ? 1)
        user = args[1] ? _s sender.name
        plot = null

        for hash, the_plot of plot_ownerships
          continue unless the_plot.owner is user
          continue if --skip
          plot = the_plot

        throw "We couldn't find plot ##{skip} owned by #{if user is _s sender.name then 'you' else user}" unless plot?

        plot.teleport sender
        sender.sendMessage "\xA7eTeleported!"

    registerCommand
      name: "creativeplot",
      description: "Allows you to invite or uninvite players to build in your plot",
      usage: "/<command> <invite|uninvite|gocreative> [name]",
      aliases: ["cp", "cplot"],
      (sender, label, args) ->
        throw "You can only use this command in the creative world!" unless sender.world.name.equalsIgnoreCase plot_world
        if args[0] is 'gocreative'
          sender.gameMode = GameMode.CREATIVE
          return yes
        return no unless args.length is 2
        return no if args[0] isnt 'invite' and args[0] isnt 'uninvite'

        plots = CreativePlots::allPlotsForPlayer sender
        throw "You don't have any plots!" if plots.length is 0

        args[1] = args[1].toLowerCase()

        successes = for plot in plots
          plot[args[0]] args[1]

        anyadd = no
        for success in successes
          anyadd ||= success

        if anyadd
          sender.sendMessage "\xA7ePlayer '\xA7a#{args[1]}\xA7e' has been #{args[0]}d from your plot(s)"
        else
          throw "Player '#{args[1]} is already #{args[0]}d #{if args[1] is 'invite' then 'to' else 'from'} your plot(s)"


  class @WorldEdit
    class JTypes
      @classLoader = "WorldEdit".plugin.class.classLoader
      @bukkitWorld = @classLoader.loadClass "com.sk89q.worldedit.bukkit.BukkitWorld"
      @vector = @classLoader.loadClass "com.sk89q.worldedit.Vector"
      @cube = @classLoader.loadClass "com.sk89q.worldedit.regions.CuboidRegion"
      @singleBlock = @classLoader.loadClass "com.sk89q.worldedit.patterns.SingleBlockPattern"
      @baseBlock = @classLoader.loadClass "com.sk89q.worldedit.blocks.BaseBlock"
      @localWorld = @classLoader.loadClass "com.sk89q.worldedit.LocalWorld"

      @bukkitWorldCon = @bukkitWorld.getDeclaredConstructor [ org.bukkit.World ]
      @vectorCon = @vector.getDeclaredConstructor [ java.lang.Double.TYPE, java.lang.Double.TYPE, java.lang.Double.TYPE ]
      @cubeCon = @cube.getDeclaredConstructor [ @localWorld, @vector, @vector ]
      @singleBlockCon = @singleBlock.getDeclaredConstructor [ @baseBlock ]
      @baseBlockCon = @baseBlock.getDeclaredConstructor [ java.lang.Integer.TYPE ]

    @JTypes = JTypes

    constructor: (player) ->
      @worldEdit = "WorldEdit".plugin.worldEdit
      @consolePlayer = "WorldEdit".plugin.wrapPlayer player
      @session = @worldEdit.getSession @consolePlayer
      @editSession = @session.createEditSession @consolePlayer
      @localWorld = JTypes.bukkitWorldCon.newInstance [ Bukkit.server.getWorld plot_world ]

    getLoc: (x, y, z) -> JTypes.vectorCon.newInstance [ new java.lang.Double(x), new java.lang.Double(y), new java.lang.Double(z) ]
    getCubeRegion: (pos1, pos2) -> JTypes.cubeCon.newInstance [ @localWorld, pos1, pos2 ]
    setMaterial: (region, pattern) -> @editSession.setBlocks region, pattern
    getSinglePattern: (typeId) -> JTypes.singleBlockCon.newInstance [ JTypes.baseBlockCon.newInstance [ new java.lang.Integer typeId ] ]

  GetPlotCenter: (px, py) ->
    cloneLocation Bukkit.server.getWorld(plot_world).spawnLocation,
      x: (plot_size + road_size) * px,
      y: 0,
      z: (plot_size + road_size) * py

  GeneratePlot: (player, px, py, generateLand, generateRoad, cleanGen) ->
    center = CreativePlots::GetPlotCenter px, py
    worldEdit = new CreativePlots.WorldEdit player

    gx1 = center.x - (plot_size / 2) + 1
    gx2 = center.x + (plot_size / 2) + 0
    gz1 = center.z - (plot_size / 2) + 1
    gz2 = center.z + (plot_size / 2) + 0

    renderMat = (cube, mat, edge = no) ->
      type = mat.material ? (if edge then mat.edge_material else mat.center_material)
      worldEdit.setMaterial cube, worldEdit.getSinglePattern type

    roadPass = (mat, shiftFunc) ->
      renderMat shiftFunc(), mat, yes
      
      for i in [ 2 .. road_size - 1 ]
        renderMat shiftFunc(), mat, no

      renderMat shiftFunc(), mat, yes

    renderCorner = (opt) ->
      renderMat opt.getCube(), opt.mat, yes
      for i in [ 2 .. road_size - 1 ]
        opt.shiftX()
        renderMat opt.getCube(), opt.mat, no

      opt.shiftX()
      renderMat opt.getCube(), opt.mat, yes

      for i in [ 2 .. road_size - 1 ]
        opt.shiftZ()

        for i in [ 1 .. road_size ]
          renderMat opt.getCube(), opt.mat, no
          opt.shiftX()

      opt.shiftZ()

      renderMat opt.getCube(), opt.mat, yes
      for i in [ 2 .. road_size - 1 ]
        opt.shiftX()
        renderMat opt.getCube(), opt.mat, no

      opt.shiftX()
      renderMat opt.getCube(), opt.mat, yes

    y = 0
    if generateLand is on
      for mat in materials
        continue if mat.cleanGenOnly and not cleanGen
        pos1 = worldEdit.getLoc gx1, y, gz1
        y += mat.depth - 1
        pos2 = worldEdit.getLoc gx2, y, gz2
        cube = worldEdit.getCubeRegion pos1, pos2
        renderMat cube, mat
        ++y

    y = 0
    if generateRoad is on
      for mat in road_materials
        continue if mat.cleanGenOnly and not cleanGen

        y1 = y
        y2 = y + mat.depth - 1

        # --x
        sx = -1
        roadPass mat, ->
          pos1 = worldEdit.getLoc gx1 - 1 - (++sx), y1, gz1
          pos2 = worldEdit.getLoc gx1 - 1 - (sx), y2, gz2
          cube = worldEdit.getCubeRegion pos1, pos2

        # ++x
        sx = -1
        roadPass mat, ->
          pos1 = worldEdit.getLoc gx2 + 1 + (++sx), y1, gz1
          pos2 = worldEdit.getLoc gx2 + 1 + (sx), y2, gz2
          cube = worldEdit.getCubeRegion pos1, pos2

        # --z
        sz = -1
        roadPass mat, ->
          pos1 = worldEdit.getLoc gx1, y1, gz1 - 1 - (++sz)
          pos2 = worldEdit.getLoc gx2, y2, gz1 - 1 - (sz)
          cube = worldEdit.getCubeRegion pos1, pos2

        # ++z
        sz = -1
        roadPass mat, ->
          pos1 = worldEdit.getLoc gx1, y1, gz2 + 1 + (++sz)
          pos2 = worldEdit.getLoc gx2, y2, gz2 + 1 + (sz)
          cube = worldEdit.getCubeRegion pos1, pos2

        # Corner BL
        sx = 0
        sz = 0

        pos1 = -> worldEdit.getLoc gx1 - 1 - sx, y1, gz1 - 1 - sz
        pos2 = -> worldEdit.getLoc gx1 - 1 - sx, y2, gz1 - 1 - sz

        renderCorner
          mat: mat,
          getCube: -> worldEdit.getCubeRegion pos1(), pos2(),
          shiftX: -> ++sx,
          shiftZ: -> sx = 0; ++sz

        # Corner BR
        sx = 0
        sz = 0

        pos1 = -> worldEdit.getLoc gx2 + 1 + sx, y1, gz1 - 1 - sz
        pos2 = -> worldEdit.getLoc gx2 + 1 + sx, y2, gz1 - 1 - sz

        renderCorner
          mat: mat,
          getCube: -> worldEdit.getCubeRegion pos1(), pos2(),
          shiftX: -> ++sx,
          shiftZ: -> sx = 0; ++sz

        # Corner TL
        sx = 0
        sz = 0

        pos1 = -> worldEdit.getLoc gx1 - 1 - sx, y1, gz2 + 1 + sz
        pos2 = -> worldEdit.getLoc gx1 - 1 - sx, y2, gz2 + 1 + sz

        renderCorner
          mat: mat,
          getCube: -> worldEdit.getCubeRegion pos1(), pos2(),
          shiftX: -> ++sx,
          shiftZ: -> sx = 0; ++sz

        # Corner TR
        sx = 0
        sz = 0

        pos1 = -> worldEdit.getLoc gx2 + 1 + sx, y1, gz2 + 1 + sz
        pos2 = -> worldEdit.getLoc gx2 + 1 + sx, y2, gz2 + 1 + sz

        renderCorner
          mat: mat,
          getCube: -> worldEdit.getCubeRegion pos1(), pos2(),
          shiftX: -> ++sx,
          shiftZ: -> sx = 0; ++sz

        if mat.breakAtCenter?
          getCube = -> worldEdit.getCubeRegion pos1(), pos2()
          airMat = { material: 0 }

          #left
          pos1 = -> worldEdit.getLoc center.x - mat.breakAtCenter + 1, y1, gz1 - 1
          pos2 = -> worldEdit.getLoc center.x + mat.breakAtCenter, y2, gz1 - 1
          renderMat getCube(), airMat

          pos1 = -> worldEdit.getLoc center.x - mat.breakAtCenter + 1, y1, gz1 - (road_size)
          pos2 = -> worldEdit.getLoc center.x + mat.breakAtCenter, y2, gz1 - (road_size)
          renderMat getCube(), airMat

          #right
          pos1 = -> worldEdit.getLoc center.x - mat.breakAtCenter + 1, y1, gz2 + 1
          pos2 = -> worldEdit.getLoc center.x + mat.breakAtCenter, y2, gz2 + 1
          renderMat getCube(), airMat

          pos1 = -> worldEdit.getLoc center.x - mat.breakAtCenter + 1, y1, gz2 + (road_size)
          pos2 = -> worldEdit.getLoc center.x + mat.breakAtCenter, y2, gz2 + (road_size)
          renderMat getCube(), airMat

          #top
          pos1 = -> worldEdit.getLoc gx1 - 1, y1, center.z - mat.breakAtCenter + 1
          pos2 = -> worldEdit.getLoc gx1 - 1, y2, center.z + mat.breakAtCenter
          renderMat getCube(), airMat

          pos1 = -> worldEdit.getLoc gx1 - (road_size), y1, center.z - mat.breakAtCenter + 1
          pos2 = -> worldEdit.getLoc gx1 - (road_size), y2, center.z + mat.breakAtCenter
          renderMat getCube(), airMat

          #bottom
          pos1 = -> worldEdit.getLoc gx2 + 1, y1, center.z - mat.breakAtCenter + 1
          pos2 = -> worldEdit.getLoc gx2 + 1, y2, center.z + mat.breakAtCenter
          renderMat getCube(), airMat

          pos1 = -> worldEdit.getLoc gx2 + (road_size), y1, center.z - mat.breakAtCenter + 1
          pos2 = -> worldEdit.getLoc gx2 + (road_size), y2, center.z + mat.breakAtCenter
          renderMat getCube(), airMat

        y += mat.depth

    try new CreativePlots.Plot(px, py).placeSigns worldEdit, player
    try new CreativePlots.Plot(px - 1, py).placeSigns worldEdit, player
    try new CreativePlots.Plot(px + 1, py).placeSigns worldEdit, player
    try new CreativePlots.Plot(px, py + 1).placeSigns worldEdit, player
    try new CreativePlots.Plot(px, py - 1).placeSigns worldEdit, player

    'Hooray!'

  GeneratePlotSigns: (worldEdit, player, px, py, getText) ->
    center = CreativePlots::GetPlotCenter px, py

    gx1 = center.x - (plot_size / 2) + 1
    gx2 = center.x + (plot_size / 2) + 0
    gz1 = center.z - (plot_size / 2) + 1
    gz2 = center.z + (plot_size / 2) + 0

    y = 0
    signMat = null
    for mat in road_materials
      unless mat.breakAtCenter?
        y += mat.depth
        continue
      signMat = mat
      break

    renderSign = (block, data) ->
      sb.type = Material.WALL_SIGN
      sb.data = data
      lines = getText().split '\n'
      sign = sb.state

      sign.setLine 0, (lines[0] ? '').substr 0, 16
      sign.setLine 1, (lines[1] ? '').substr 0, 16
      sign.setLine 2, (lines[2] ? '').substr 0, 16
      sign.setLine 3, (lines[3] ? '').substr 0, 16

      sign.update yes

    # North
    sb = cloneLocation center,
      x: center.x + 1 + signMat.breakAtCenter,
      y: y,
      z: gz1 - 2
    sb = sb.block

    await deferForWorldedit worldEdit, sb.x, sb.y, sb.z, defer()

    renderSign sb, 2

    # South
    sb = cloneLocation center,
      x: center.x - signMat.breakAtCenter,
      y: y,
      z: gz2 + 2
    sb = sb.block

    await deferForWorldedit worldEdit, sb.x, sb.y, sb.z, defer()

    renderSign sb, 3

    # West
    sb = cloneLocation center,
      x: gx1 - 2,
      y: y,
      z: center.z - signMat.breakAtCenter
    sb = sb.block

    await deferForWorldedit worldEdit, sb.x, sb.y, sb.z, defer()

    renderSign sb, 4

    # East
    sb = cloneLocation center,
      x: gx2 + 2,
      y: y,
      z: center.z + 1 + signMat.breakAtCenter
    sb = sb.block

    await deferForWorldedit worldEdit, sb.x, sb.y, sb.z, defer()

    renderSign sb, 5

  firstUnclaimedPlot: ->
    evaluateRing = (radius) ->
      # North (--z)
      z = -radius
      for x in [ -radius + 1 .. radius - 1 ]
        plot = new CreativePlots.Plot x, z
        return plot unless plot.isClaimed

      # South (++z)
      z = radius
      for x in [ -radius + 1 .. radius - 1 ]
        plot = new CreativePlots.Plot x, z
        return plot unless plot.isClaimed

      # West (--x)
      x = -radius
      for z in [ -radius + 1 .. radius - 1 ]
        plot = new CreativePlots.Plot x, z
        return plot unless plot.isClaimed

      # East (++z)
      x = radius
      for z in [ -radius + 1 .. radius - 1 ]
        plot = new CreativePlots.Plot x, z
        return plot unless plot.isClaimed

      # Corners
      # Northwest
      plot = new CreativePlots.Plot -radius, -radius
      return plot unless plot.isClaimed

      # Northeast
      plot = new CreativePlots.Plot -radius, radius
      return plot unless plot.isClaimed
      
      # Southwest
      plot = new CreativePlots.Plot radius, -radius
      return plot unless plot.isClaimed
      
      #Southeast
      plot = new CreativePlots.Plot radius, radius
      return plot unless plot.isClaimed

    doRings = (radius) ->
      return evaluateRing(radius) ? doRings(++radius)

    return doRings 1

  deferForWorldedit = (worldEdit, x, y, z, callback) ->
    block = Bukkit.server.getWorld(plot_world).getBlockAt x, y, z
    block.typeId = 0 if block.typeId is 19

    await bukkit_sync defer(), null, 2

    pos1 = worldEdit.getLoc x, y, z
    pos2 = worldEdit.getLoc x, y, z
    cube = worldEdit.getCubeRegion pos1, pos2
    pattern = worldEdit.getSinglePattern 19
    worldEdit.setMaterial cube, pattern

    await async defer()

    checkSponge = (x, y, z) ->
      block = Bukkit.server.getWorld(plot_world).getBlockAt x, y, z
      block.typeId

    notSponge = yes
    while notSponge
      await bukkit_sync checkSponge, defer(newType), 2, [x, y, z]
      break if newType is 19

    bukkit_sync callback

  plotsOwnedBy: (player) ->
    amount = 0
    for hash, plot of plot_ownerships
      continue unless plot?
      ++amount if plot.owner is _s player.name
    amount

  createPlotForPlayer: (player) ->
    maxPlots = CreativePlots.PlotOwnership.MaxOwnedBy player
    ownedPlots = CreativePlots::plotsOwnedBy player

    throw "You already own your maximum number of plots!" unless ownedPlots < maxPlots

    plot = CreativePlots::firstUnclaimedPlot()
    ownership = new CreativePlots.PlotOwnership plot.x, plot.y, player
    plot_ownerships[ownership.hashCode] = ownership
    JsPersistence.save()

    center = CreativePlots::GetPlotCenter plot.x, plot.y
    center.y = plot_height + 1
    cblock = center.block

    player.sendMessage "\xA7eYour plot is being generated..."

    worldEdit = new CreativePlots.WorldEdit player
    plot.generate player
    await deferForWorldedit worldEdit, cblock.x, cblock.y, cblock.z, defer()
    cblock.typeId = 0

    player.sendMessage "\xA7eWelcome to your new plot!"

    player.teleport center

  allPlotsForPlayer: (player) ->
    name = _s player.name
    for hash, plot of plot_ownerships
      if plot.owner is name then plot else continue

class SpecialUsers
  @::veterans = JSON.parse read_file "./js/veterans.json"
  @::vips = JSON.parse read_file "./js/vips.json"

  IsVip: (name) ->
    name = _s name.name if name instanceof org.bukkit.entity.Player
    for vip in SpecialUsers::vips
      return yes if vip is _s name
    no
  IsVeteran: (name, orVip = yes) ->
    name = _s name.name if name instanceof org.bukkit.entity.Player
    for vet in SpecialUsers::veterans
      return yes if vet is _s name
    orVip and SpecialUsers::IsVip name
