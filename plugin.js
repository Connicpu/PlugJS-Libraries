libraries = [
    "fireworks",
    "enchants",
    "bukkit_helpers",
    "eval_helpers",
    "geoip",
    "money_drops",
    "fun_commands",
    "dirty_mouth",
    "group_chats.coffee",
    "chatcolors.coffee",
    "noport.coffee",
    "safety_first",
    "bye_have_a_great_time",
    "code_attachments.coffee"
];
var debug_messages = false;

function log(msg, level, verbose) {
    if (verbose && !debug_messages) return;
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
var exports = {
};
var iced;
var CoffeeScript;
function loadLib(lib) {
    log("Loading core script " + lib, '2', 'verbose');
    load("./plugins/PlugJS/core/" + lib);
}

loadLib("js_persistence.js");
loadLib("lang_helpers.js");
loadLib("core.js");
loadLib("async.js");
loadLib("tt_war_helpers.js");
loadLib("coffee-script.js");
loadLib("iced.js");
loadLib("icedlib.js");
loadLib("econ.js");
loadLib("metadata.js");

iced = exports.iced;

for (var i in libraries) {
    require(libraries[i], "libs");
}

log("Finised loading scripts", '2');

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