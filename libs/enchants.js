function getEnchant(name) {
    if (enumContains(org.bukkit.enchantments.Enchantment, name.toUpperCase())) return org.bukkit.enchantments.Enchantment[name.toUpperCase()];
    
    if (/(protection(_)?fire)|(fire(_)?protection)/i.test(name)) return org.bukkit.enchantments.Enchantment.PROTECTION_FIRE;
    if (/(protection(_)?fall)|(fall(_)?protection)/i.test(name)) return org.bukkit.enchantments.Enchantment.PROTECTION_FALL;
    if (/(protection(_)?explosion)|(explosion(s)?(_)?protection)/i.test(name)) return org.bukkit.enchantments.Enchantment.PROTECTION_EXPLOSIONS;
    if (/(protection(_)?projectile)|(projectile(_)?protection)/i.test(name)) return org.bukkit.enchantments.Enchantment.PROTECTION_PROJECTILE;
    if (/protection/i.test(name)) return org.bukkit.enchantments.Enchantment.PROTECTION_ENVIRONMENTAL;
    
    if (/oxygen/i.test(name)) return org.bukkit.enchantments.Enchantment.OXYGEN;
    if (/(water(_)?worker)|aqua(_)?affinity/i.test(name)) return org.bukkit.enchantments.Enchantment.WATER_WORKER;
    if (/thorn/i.test(name)) return org.bukkit.enchantments.Enchantment.THORNS;
    if (/sharp/i.test(name)) return org.bukkit.enchantments.Enchantment.DAMAGE_ALL;
    if (/smite/i.test(name)) return org.bukkit.enchantments.Enchantment.DAMAGE_UNDEAD;
    if (/arthro/i.test(name)) return org.bukkit.enchantments.Enchantment.DAMAGE_ARTHROPODS;
    if (/knock/i.test(name)) return org.bukkit.enchantments.Enchantment.KNOCKBACK;
    if (/fire/i.test(name)) return org.bukkit.enchantments.Enchantment.FIRE_ASPECT;
    
    if (/fortune(_)?mob/i.test(name)) return org.bukkit.enchantments.Enchantment.LOOT_BONUS_MOBS;
    if (/fortune/i.test(name)) return org.bukkit.enchantments.Enchantment.LOOT_BONUS_BLOCKS;
    if (/dig|effic/i.test(name)) return org.bukkit.enchantments.Enchantment.DIG_SPEED;
    if (/silk/i.test(name)) return org.bukkit.enchantments.Enchantment.SILK_TOUCH;
    if (/dura|unbreak/i.test(name)) return org.bukkit.enchantments.Enchantment.DURABILITY;
}

registerCommand({
        name: "enchant",
        description: "Enchants the item you're holding!",
        usage: "\xA7cUsage: /<command> <enchantment> <level>",
        permission: registerPermission("enchants.enchant", "op"),
        permissionMessage: "\xA7cI'm sorry dave, but I'm afraid I cannot let you do that"
    }, function(sender, label, args) {
        if (args.length != 2 || new Number(args[1]) == NaN) {
            return false;
        }
        
        var enchant = getEnchant(args[0]);
        if (!enchant) {
            sender.sendMessage("\xA7cCouldn't find an enchantment by that name");
            return;
        }
        
        var item = sender.itemInHand;
        if (item.typeId < 1) {
            sender.sendMessage("\xA7cYou can't enchant air lol");
            return;
        }
        
        item.addUnsafeEnchantment(enchant, new Number(args[1]));
        sender.sendMessage("\xA7aEnchanted with " + enchant.name + "!");
    });