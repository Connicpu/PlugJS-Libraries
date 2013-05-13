function isInWar(player) {
    player = gplr(player).name;
    var zones = getWarzones();
    if (!zones.length) return false;
    return !!zones[0].getZoneByPlayerName(player);
}
function getWarzones() {
    var war = getPlugin("War");
    if (!war) return [];
    return _a(war.warzones);
}