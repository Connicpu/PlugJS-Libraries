class CreativePlots
  plot_size = 100
  road_size = 5
  plot_world = 'creative'
  plot_ownerships = JsPersistence.tryGet 'creative_plots', {}

  materials = [
    { depth: 1, material: 7 }
    { depth: 18, material: 3 }
    { depth: 1, material: 2 }
    { depth: 255, material: 0, cleanGenOnly: yes }
  ]
  road_materials = [
    { depth: 1, material: 7 }
    { depth: 18, material: 3 }
    { depth: 1, center_material: 44, edge_material: 43 }
    { depth: 3, center_material: 0,  edge_material: 85, breakAtCenter: 2 }
    { depth: 1, center_material: 0,  edge_material: 85 }
    { depth: 1, material: 85 }
    { depth: 1, material: 20 }
    { depth: 255, material: 0, cleanGenOnly: yes }
  ]

  class @PlotOwnership
    constructor: (@x, @y, @owner) ->
      @owner = _s @owner.name if @owner instanceof org.bukkit.entity.Player
    @prop 'hashCode', 
      get: -> PlotOwnership.GetHashCode @x, @y
    @prop 'plot',
      get: -> new Plot @x, @y
    @GetHashCode = (x,y) -> "#{x},#{y},#{plot_world}"
    @CountByOwner = (owner) ->
      count = 0
      for hash, plot of plot_ownerships
        ++count if plot.owner is owner
      count
    @MaxOwnedBy = (owner) ->
      return 3 if SpecialUsers::IsVip owner
      return 2 if SpecialUsers::IsVeteran owner
      return 1

  class @Plot
    constructor: (@x, @y) ->
    generate: (player) ->
      CreativePlots::GeneratePlot player, @x, @y, yes, yes, yes
    refreshPlot: ->
      CreativePlots::GeneratePlot player, @x, @y, yes, no, no
    fixRoads: ->
      CreativePlots::GeneratePlot player, @x, @y, no, yes, yes

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

  @::GetPlotCenter = (px, py) ->
    cloneLocation Bukkit.server.getWorld(plot_world).spawnLocation,
      x: (plot_size + road_size) * px,
      y: 0,
      z: (plot_size + road_size) * py

  @::GeneratePlot = (player, px, py, generateLand, generateRoad, cleanGen) ->
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
          log 'derp'

        y += mat.depth

    'Hooray!'

class SpecialUsers
  @::veterans = JSON.parse read_file "./js/veterans.json"
  @::vips = JSON.parse read_file "./js/vips.json"

  @::IsVip = (name) ->
    for vip in SpecialUsers::vips
      return yes if vip is _s name
    no
  @::IsVeteran = (name, orVip = yes) ->
    for vet in SpecialUsers::veterans
      return yes if vet is _s name
    orVip and SpecialUsers::IsVip name
