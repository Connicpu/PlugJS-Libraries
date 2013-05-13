function emeta(item,func) {
    var meta = item.itemMeta;
    if (typeof func === 'string') {
        eval(func);
    } else {
        func(meta);
    }
    item.itemMeta = meta;
}
function ilore(item,lore) {
    emeta(item,function(l){l.lore = lore});
}
function alore(item,newlore) {
    var olore = item.itemMeta.lore;
    var lore = [];
    if (olore != null) {
        for (var i = 0; i < olore.size(); ++i) {
            lore[lore.length] = olore.get(i);
        }
    }
    
    for (var i = 0; i < newlore.length; ++i) {
        lore[lore.length] = newlore[i];
    }
    ilore(item, lore);
}
function countAndRemoveByMeta(inv, meta) {
    var count = 0;
    for (var i = 0; i < 36; ++i) {
        var item = inv.getItem(i);
        if (item != null) {
            if (meta.equals(item.itemMeta)) {
                count += item.amount;
                inv.clear(i);
            }
        }
    }
    return count;
}
function countByMeta(inv, meta) {
    if (inv instanceof org.bukkit.inventory.Inventory) {
        inv = inv.contents;
    }
    var count = 0;
    for (var i = 0; i < inv.length; ++i) {
        var item = inv[i];
        if (item != null) {
            if (meta.equals(item.itemMeta)) {
                count += item.amount;
            }
        }
    }
    return count;
}