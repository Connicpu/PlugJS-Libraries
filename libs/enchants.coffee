getEnchant = (name) ->
  return org.bukkit.enchantments.Enchantment[name.toUpperCase()]  if enumContains(org.bukkit.enchantments.Enchantment, name.toUpperCase())
  return org.bukkit.enchantments.Enchantment.PROTECTION_FIRE  if /(protection(_)?fire)|(fire(_)?protection)/i.test(name)
  return org.bukkit.enchantments.Enchantment.PROTECTION_FALL  if /(protection(_)?fall)|(fall(_)?protection)/i.test(name)
  return org.bukkit.enchantments.Enchantment.PROTECTION_EXPLOSIONS  if /(protection(_)?explosion)|(explosion(s)?(_)?protection)/i.test(name)
  return org.bukkit.enchantments.Enchantment.PROTECTION_PROJECTILE  if /(protection(_)?projectile)|(projectile(_)?protection)/i.test(name)
  return org.bukkit.enchantments.Enchantment.PROTECTION_ENVIRONMENTAL  if /protection/i.test(name)
  return org.bukkit.enchantments.Enchantment.OXYGEN  if /oxygen/i.test(name)
  return org.bukkit.enchantments.Enchantment.WATER_WORKER  if /(water(_)?worker)|aqua(_)?affinity/i.test(name)
  return org.bukkit.enchantments.Enchantment.THORNS  if /thorn/i.test(name)
  return org.bukkit.enchantments.Enchantment.DAMAGE_ALL  if /sharp/i.test(name)
  return org.bukkit.enchantments.Enchantment.DAMAGE_UNDEAD  if /smite/i.test(name)
  return org.bukkit.enchantments.Enchantment.DAMAGE_ARTHROPODS  if /arthro/i.test(name)
  return org.bukkit.enchantments.Enchantment.KNOCKBACK  if /knock/i.test(name)
  return org.bukkit.enchantments.Enchantment.FIRE_ASPECT  if /fire/i.test(name)
  return org.bukkit.enchantments.Enchantment.LOOT_BONUS_MOBS  if /fortune(_)?mob/i.test(name)
  return org.bukkit.enchantments.Enchantment.LOOT_BONUS_BLOCKS  if /fortune/i.test(name)
  return org.bukkit.enchantments.Enchantment.DIG_SPEED  if /dig|effic/i.test(name)
  return org.bukkit.enchantments.Enchantment.SILK_TOUCH  if /silk/i.test(name)
  return org.bukkit.enchantments.Enchantment.DURABILITY  if /dura|unbreak/i.test(name)
registerCommand
  name: "enchant",
  description: "Enchants the item you're holding!",
  usage: "\xA7cUsage: /<command> <enchantment> <level>",
  permission: registerPermission("enchants.enchant", "op"),
  permissionMessage: "\xA7cYou do not have sufficient permissions to use that.", 
  (sender, label, args) ->
    return false  if args.length isnt 2 or new Number(args[1]) is NaN
    enchant = getEnchant(args[0])
    unless enchant
      sender.sendMessage "\xA7cCouldn't find an enchantment by that name."
      return
    item = sender.itemInHand
    if item.typeId < 1
      sender.sendMessage "\xA7cYou attempted to enchant air, however all you got was the sound of your windbag."
      return
    item.addUnsafeEnchantment enchant, new Number(args[1])
    sender.playSound sender.location, Sound.BURP, 1, 1
    sender.sendMessage "\xA7aEnchanted with " + enchant.name + "!"
