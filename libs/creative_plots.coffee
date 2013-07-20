class CreativePlots
  plot_size = 60
  road_size = 5
  plot_world = 'creative'
  plot_ownerships = JsPersistence.tryGet 'creative_plots', {}

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
    generate: ->
      CreativePlots::GeneratePlot @x, @y, yes, yes
    refreshPlot: ->
      CreativePlots::GeneratePlot @x, @y, yes, no
    fixRoads: ->
      CreativePlots::GeneratePlot @x, @y, no, yes

  materials = [
    { depth: 1,  material: 7 }
    { depth: 18, material: 3 }
    { depth: 1,  material: 2 }
  ]
  road_materials = [
    { depth: 1,  material: 7 }
    { depth: 18, material: 3 }
    { depth: 1,  center_material: 44, edge_material: 43 }
    { depth: 1,  center_material: 0,  edge_material: 85 }
  ]

  @::GetPlotCenter = (px, py) ->
    cloneLocation Bukkit.server.getWorld('creative').spawnLocation,
      x: (plot_size + road_size) * px,
      y: (plot_size + road_size) * py,
      z: 0

  @::GeneratePlot = (px, py, generateLand, generateRoad) ->
    y = -1
    center = CreativePlots::GetPlotCenter px, py

    if generateLand is on
      for material in materials
        for d in [ 1 .. material.depth ]
          ++y
          for x in [ center.x - (plot_size / 2) - 1 .. center.x + (plot_size / 2) ]
            for z in [ center.z - (plot_size / 2) - 1 .. center.z + (plot_size / 2) ]
              loc = cloneLocation center,
                x: x,
                y: y,
                z: z
              loc.block.typeId = material.material

    y = -1
    if generateRoad is on
      renderStretch = (dir, sta, sta_m) ->

      for material in road_materials
        for d in [ 1 .. material.depth ]
          # left side
          renderStretch 'x', 'z', -1


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
