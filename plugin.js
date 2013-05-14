libraries = [
    "js_persistence.js",
    "lang_helpers.js",
    "core.js",
    "async.js",
    "coffee-script.js",
    "bukkit_helpers.coffee",
    "eval_helpers.coffee",
    "tt_war_helpers.js",
    "async.js",
    "permissions.coffee",
    "econ.js",
    "metadata.js",
    "money_drops.coffee",
    "fireworks.js",
    "enchants.js",
    "fun_commands.coffee",
    "dirty_mouth.coffee",
    "group_chats.coffee"
];

function log(msg, level) {
    if (!level) level = "f";
    if (msg instanceof Array) {
        for (var i in msg) {
            loader.server.consoleSender.sendMessage("\xA7" + level + "[PlugJS] " + msg[i]);
        }
    } else {
        loader.server.consoleSender.sendMessage("\xA7" + level + "[PlugJS] " + msg);
    }
}
var block = {
};
var enchantment = {
};
var entity = {
};
var inventory = {
};
var painting = {
};
var player = {
};
var server = {
};
var vehicle = {
};
var weather = {
};
var world = {
};
var js = {
};
var spout = {
    screen: {},
    slot: {},
    key: {}
};

var CoffeeScript;
for (var i in libraries) {
    var lib = libraries[i];
    try {
        if (CoffeeScript && /\.coffee/i.test(lib)) {
            loadCoffee("./plugins/PlugJS/libs/" + lib);
        } else {
            load("./plugins/PlugJS/libs/" + lib);
        }
    } catch(ex) {
        loader.server.broadcast("\xA7cError loading " + lib + ":\n" + ex, "bukkit.broadcast.admin");
    }
}

/* List of events by group

- block -
bbreak
burn
canBuild
damage
dispense
fade
form
grow
ignite
physics
pistonExtend
pistonRetract
place
redstone
spread
entityForm
leavesDecay
signChange

- enchantment -
enchant
prepare

- entity -
creatureSpawn
creeperPower
breakDoor
changeBlock
combust
createPortal
damageByBlock
damageByEntity
death
explode
interact
portalEnter
regainHealth
shootBow
tame
target
targetLivingEntity
teleport
expBottle
explosionPrime
foodLevelChange
itemDespawn
itemSpawn
pigZap
potionSplash
projectileHit
projectileLaunch
sheepDye
sheepRegrow
slimeSplit

- inventory -
brew
craft
burn
smelt
click
close
open
prepareCraft

- painting -
break
breakByEntity
place

- player -
death
animation
bedEnter
bucketEmpty
bucketFill
changedWorld
chat
command
dropItem
eggThrow
expChange
fish
gamemode
interactEntity
itemHeld
join
kick
levelChange
login
move
pickupItem
portal
portal
quit
respawn
shear
teleport
sneak
sprint
velocity

- server -
mapInit
pluginDisable
pluginEnable
remoteCommand
command
ping
serviceRegister
serviceUnregister

- vehicle -
blockCollision
create
damage
destroy
entityCollision
enter
exit
move

- weather -
lightning
thunder
weather

- world -
chunkLoad
chunkPopulate
chunkUnload
portalCreate
spawnChange
structureGrow
init
load
save
unload

*/