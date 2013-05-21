class GeoIP
  class Country
    constructor: (@geoip) ->
    @prop 'geoip', 
      writable: true
    @prop 'name', 
      get: () -> _s @geoip.countryName
    @prop 'code', 
      get: () -> _s @geoip.countryCode
  class Coordinates
    constructor: (@geoip) ->
    @prop 'geoip', 
      writable: true
    @prop 'longitude', 
      get: () -> _n @geoip.longitude
    @prop 'latitude',
      get: () -> _n @geoip.latitude
  class LocalCodes
    constructor: (@geoip) ->
    @prop 'geoip', 
      writable: true
    @prop 'dma',
      get: () -> _s @geoip.dma_code
    @prop 'area',
      get: () -> _s @geoip.area_code
    @prop 'metro',
      get: () -> _s @geoip.metro_code
    @prop 'postal',
      get: () -> _s @geoip.postalCode

  constructor: (addr) ->
    addr = java.net.InetAddress.getByName addr if typeof addr == 'string'
    addr = addr.address if addr instanceof org.bukkit.entity.Player
    addr = addr.address if addr instanceof java.net.InetSocketAddress
    @geoip = @lookup.getLocation(addr) || {}

  geoPlugin = getPlugin "GeoIPTools"
  throw "Geo IP Plugin not found" unless plugin?

  @prop 'geoip', 
    writable: true
  @prop 'lookup', 
    get: () -> geoPlugin.geoIPLookup

  @prop 'country', 
    get: () -> new Country @geoip
  @prop 'region',
    get: () -> _s @geoip.region
  @prop 'city',
    get: () -> _s @geoip.city
  @prop 'coordinates',
    get: () -> new Coordinates @geoip
  @prop 'codes',
    get: () -> new LocalCodes @geoip

  toJSON: () ->
    country:
      name: @country.name
      code: @country.code
    region: @region
    city: @city
    coordinates:
      latitude: @coordinates.latitude
      longitude: @coordinates.longitude
    codes:
      dma: @codes.dma
      area: @codes.area
      metro: @codes.metro
      postal: @codes.postal
