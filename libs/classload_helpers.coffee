loadClass = (classPath) ->
  classInfo = plugin.class.classLoader.loadClass classPath
  class BukkitClass
    constructor: () ->
      constructors = classInfo.constructors
      throw "No known constructors" if constructors.length == 0
      
String.prop 'plugin', get: () -> getPlugin @

cls =
  toString: () ->
    output = ""
    for i in [1..100]
      output += " \n"
    output