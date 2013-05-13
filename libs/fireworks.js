var fw = {
    mk: function(loc, effects, power) {
        if (typeof(loc) === 'string') {
            loc = gplr(loc).location;
        } else if (loc instanceof org.bukkit.entity.Player) {
            loc = loc.location;
        }
        var item = new org.bukkit.inventory.ItemStack(org.bukkit.Material.FIREWORK, 1);
        var fm = item.itemMeta;
        var builder = fw.cfb();
        if (effects != null) {
            for (var i in effects) {
                var effect = effects[i];
                effect = effect(builder);
            }
            fm.addEffect(builder.build());
        }
        if (power != null){ fm.power = power; } else { fm.power = 1; }
        
        var firework = spawnEntity("FIREWORK", loc);
        firework.fireworkMeta = fm;
        
        return firework;
    },
    b: function(){return org.bukkit.FireworkEffect.builder();},
    red: function(builder) {
        return builder.color(255,0,0);
    },
    green: function(builder) {
        return builder.color(0,255,0);
    },
    blue: function(builder) {
        return builder.color(0,0,255);
    },
    yellow: function(builder) {
        return builder.color(255,255,0);
    },
    rgb: function(r, g, b) {
        return function(builder) {
            return builder.color(r, g, b);
        }
    },
    randcolor: function(builder_) {
        if (typeof(builder_) === 'number') {
            if (builder_ > 255) builder_ = 255;
            return function(builder) {
                for (var i = 0; i < builder_; ++i) {
                    builder = builder.color(Math.random() * 255, Math.random() * 255, Math.random() * 255);
                }
                return builder;
            }
        }
        return builder_.color(Math.random() * 255, Math.random() * 255, Math.random() * 255);
    },
    fadered: function(builder) {
        return builder.fade(255,0,0);
    },
    fadegreen: function(builder) {
        return builder.fade(0,255,0);
    },
    fadeblue: function(builder) {
        return builder.fade(0,0,255);
    },
    fadeyellow: function(builder) {
        return builder.fade(255,255,0);
    },
    fadergb: function(r, g, b) {
        return function(builder) {
            return builder.fade(r, g, b);
        }
    },
    faderandcolor: function(builder_) {
        if (typeof(builder_) === 'number') {
            if (builder_ > 255) builder_ = 255;
            return function(builder) {
                for (var i = 0; i < builder_; ++i) {
                    builder = builder.fade(Math.random() * 255, Math.random() * 255, Math.random() * 255);
                }
                return builder;
            }
        }
        return builder_.fade(Math.random() * 255, Math.random() * 255, Math.random() * 255);
    },
    ball: function(builder) {
        return builder.type("BALL");
    },
    largeball: function(builder) {
        return builder.type("BALL_LARGE");
    },
    star: function(builder) {
        return builder.type("STAR");
    },
    burst: function(builder) {
        return builder.type("BURST");
    },
    creeper: function(builder) {
        return builder.type("CREEPER");
    },
    flicker: function(builder) {
        return builder.flicker(true);
    },
    cfb: function() {
        obj = {
            build: function() { return obj.b.build(); },
            color: function(r,g,b) {
                obj.b = obj.b.withColor(org.bukkit.Color.fromRGB(r,g,b));
                return obj;
            },
            fade: function(r,g,b) {
                obj.b = obj.b.withFade(org.bukkit.Color.fromRGB(r,g,b));
                return obj;
            },
            trail: function(yn) {
                obj.b = obj.b.trail(yn);
                return obj;
            },
            flicker: function(yn) {
                obj.b = obj.b.flicker(yn);
                return obj;
            },
            type: function(fwtype) {
                fwtype = org.bukkit.FireworkEffect.Type[fwtype];
                obj.b = obj.b["with"](fwtype);
                return obj;
            },
        }
        obj.b = fw.b();
        return obj;
    }
};