if (!economy) {
    throw "Economy not found!"
}

(function(){
    var keys = [];
    for (var i in money_drop_rates) {
        keys.push(i);
    }
    keys.reverse();
    var _drop_rates = {};
    for (var i  in keys) {
        _drop_rates[keys[i]] = money_drop_rates[keys[i]];
    }
    money_drop_rates = _drop_rates;
})();

var derpItemStack = new org.bukkit.inventory.ItemStack(1);
var money_hundreds = derpItemStack.itemMeta;
var money_fifties = derpItemStack.itemMeta;
var money_twenties = derpItemStack.itemMeta;
var money_tens = derpItemStack.itemMeta;
var money_fives = derpItemStack.itemMeta;
var money_ones = derpItemStack.itemMeta;
money_hundreds.displayName = "\xA72$100";
money_hundreds.setLore(["\xA77Issued by " + treasuryName]);
money_fifties.displayName = "\xA72$50";
money_fifties.setLore(["\xA77Issued by " + treasuryName]);
money_twenties.displayName = "\xA72$20";
money_twenties.setLore(["\xA77Issued by " + treasuryName]);
money_tens.displayName = "\xA72$10";
money_tens.setLore(["\xA77Issued by " + treasuryName]);
money_fives.displayName = "\xA72$5";
money_fives.setLore(["\xA77Issued by " + treasuryName]);
money_ones.displayName = "\xA72$1";
money_ones.setLore(["\xA77Issued by " + treasuryName]);

function moneyToItemStacks(amount) {
    //log('starting');
    with (new JavaImporter(org.bukkit,org.bukkit.inventory)) {
        //log('imported classes');
        items = [];
        var latestStack = null;
        //log('starting hundreds');
        while (amount >= 100) {
            amount -= 100;
            //log('subtracting 100, we now have ' + amount);
            if (latestStack == null) {
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_hundreds;
            } else if (latestStack.amount >= 64) {
                items[items.length] = latestStack;
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_hundreds;
            } else {
                ++latestStack.amount;
            }
        }
        if (latestStack != null) {
            items[items.length] = latestStack;
            latestStack = null;
        }
        //log('starting fifties');
        while (amount >= 50) {
            amount -= 50;
            //log('subtracting 50, we now have ' + amount);
            if (latestStack == null) {
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_fifties;
            } else if (latestStack.amount >= 64) {
                items[items.length] = latestStack;
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_fifties;
            } else {
                ++latestStack.amount;
            }
        }
        if (latestStack != null) {
            items[items.length] = latestStack;
            latestStack = null;
        }
        //log('starting twenties');
        while (amount >= 20) {
            amount -= 20;
            //log('subtracting 20, we now have ' + amount);
            if (latestStack == null) {
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_twenties;
            } else if (latestStack.amount >= 64) {
                items[items.length] = latestStack;
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_twenties;
            } else {
                ++latestStack.amount;
            }
        }
        if (latestStack != null) {
            items[items.length] = latestStack;
            latestStack = null;
        }
        //log('starting tens');
        while (amount >= 10) {
            amount -= 10;
            //log('subtracting 10, we now have ' + amount);
            if (latestStack == null) {
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_tens;
            } else if (latestStack.amount >= 64) {
                items[items.length] = latestStack;
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_tens;
            } else {
                ++latestStack.amount;
            }
        }
        if (latestStack != null) {
            items[items.length] = latestStack;
            latestStack = null;
        }
        //log('starting fives');
        while (amount >= 5) {
            amount -= 5;
            //log('subtracting 5, we now have ' + amount);
            if (latestStack == null) {
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_fives;
            } else if (latestStack.amount >= 64) {
                items[items.length] = latestStack;
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_fives;
            } else {
                ++latestStack.amount;
            }
        }
        if (latestStack != null) {
            items[items.length] = latestStack;
            latestStack = null;
        }
        //log('starting ones');
        while (amount >= 1) {
            amount -= 1;
            //log('subtracting 1, we now have ' + amount);
            if (latestStack == null) {
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_ones;
            } else if (latestStack.amount >= 64) {
                items[items.length] = latestStack;
                latestStack = new ItemStack(Material.PAPER, 1);
                latestStack.itemMeta = money_ones;
            } else {
                ++latestStack.amount;
            }
        }
        if (latestStack != null) {
            items[items.length] = latestStack;
            latestStack = null;
        }
        
        //log('done');
        //log('returning');
        return items;
    }
}
function countAllMoney(inv) {
    moneyToAdd = 0;
    moneyToAdd += countByMeta(inv, money_hundreds) * 100;
    moneyToAdd += countByMeta(inv, money_fifties) * 50;
    moneyToAdd += countByMeta(inv, money_twenties) * 20;
    moneyToAdd += countByMeta(inv, money_tens) * 10;
    moneyToAdd += countByMeta(inv, money_fives) * 5;
    moneyToAdd += countByMeta(inv, money_ones) * 1;
    return moneyToAdd;
}
function removeAllMoney(inv) {
    moneyToAdd = 0;
    moneyToAdd += countAndRemoveByMeta(inv, money_hundreds) * 100;
    moneyToAdd += countAndRemoveByMeta(inv, money_fifties) * 50;
    moneyToAdd += countAndRemoveByMeta(inv, money_twenties) * 20;
    moneyToAdd += countAndRemoveByMeta(inv, money_tens) * 10;
    moneyToAdd += countAndRemoveByMeta(inv, money_fives) * 5;
    moneyToAdd += countAndRemoveByMeta(inv, money_ones) * 1;
    return moneyToAdd;
}
function pullMoneyFromInventory(inventory, amount) {
    var totalMoney = removeAllMoney(inventory);
    if (totalMoney < amount) {
        addMoneyToPlayer(inventory.holder, totalMoney);
        return false;
    }
    
    var remainder = totalMoney - amount;
    addMoneyToPlayer(inventory.holder, remainder);
    return true;
}
function addMoneyToPlayer(player, amount) {
    money = moneyToItemStacks(amount);
    
    var remainder = player.inventory.addItem(money).values().toArray();
    if (remainder.length > 0) {
        var credit = countAllMoney(remainder);
        economy.depositPlayer(player.name, credit);
        player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7cNot all the money fit in your inventory.");
        player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] $" + credit + " \xA7ehas been credited to your account");
    }
}

registerPermission("moneydrops.banksign.create", "op");
registerPermission("moneydrops.banksign.destroy", "op");
registerPermission("moneydrops.banksign.use", "true");

registerEvent(player, "interact", function(event) {
    if (event.hasBlock() && event.clickedBlock.state instanceof org.bukkit.block.Sign && event.action == event.action["RIGHT_CLICK_BLOCK"]) {
        if (event.clickedBlock.state.getLine(0) == "\xA7b\xA7o[Bank]") {
            if (!event.player.hasPermission("moneydrops.banksign.use")) {
                return;
            }
            var player = event.player;
            if (event.clickedBlock.state.getLine(1) == "\xA73Deposit") {
                if (event.clickedBlock.state.getLine(2) == "\xA7eAll") {
                    var moneyToAdd = removeAllMoney(player.inventory);
                    var response = economy.deposit(player.name, moneyToAdd);
                    player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7eDeposited \xA72$" + moneyToAdd);
                    player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7eYou now have a balance of \xA72$" + response.balance);
                    event.player.updateInventory();
                } else {
                    var amt = new Number(new String(event.clickedBlock.state.getLine(2)).substr(3));
                    if (pullMoneyFromInventory(player.inventory, amt)) {
                        var response = economy.deposit(player.name, amt);
                        player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7eDeposited \xA72$" + amt);
                        player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7eYou now have a balance of \xA72$" + response.balance);
                        event.player.updateInventory();
                    } else {
                        player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7cNot enough funds!");
                    }
                }
            } else if (event.clickedBlock.state.getLine(1) == "\xA73Withdraw") {
                var amt = new Number(new String(event.clickedBlock.state.getLine(2)).substr(3));
                if (economy.has(player.name, amt)) {
                    var response = economy.withdraw(player.name, amt);
                    addMoneyToPlayer(player, amt);
                    player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7eWithdrew \xA72$" + amt);
                    player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7eYou now have a balance of \xA72$" + response.balance);
                    event.player.updateInventory();
                } else {
                    player.sendMessage("\xA72[\xA7b\xA7oBank\xA7r\xA72] \xA7cNot enough funds!");
                }
            }
        }
    }
});

registerEvent(block, "bbreak", function(event) {
    if (event.block.state instanceof org.bukkit.block.Sign) {
        if (event.block.state.getLine(0) == "\xA7b\xA7o[Bank]") {
            if (!event.player.hasPermission("moneydrops.banksign.destroy")) {
                event.player.sendMessage("\xA7cYou don't have permission to break that sign");
                event.cancelled = true;
            }
        }
    }
});

registerEvent(block, "signChange", function(event) {
    if (event.getLine(0).equalsIgnoreCase("[Bank]") && event.player.hasPermission('moneydrops.banksign.create')) {
        event.cancelled = false;
        if (event.getLine(1).equalsIgnoreCase("Withdraw")) {
            if (!/^\$([\d]+)$/.test(event.getLine(2))) {
                delayTask(function(){event.block.breakNaturally();});
                event.player.sendMessage("\xA7cIncorrect format");
                return;
            }
            event.setLine(1, "\xA73Withdraw");
            event.setLine(2, "\xA7e" + event.getLine(2));
        } else if (event.getLine(1).equalsIgnoreCase("Deposit")) {
            if (!/^\$([\d]+)|All$/i.test(event.getLine(2))) {
                delayTask(function(){event.block.breakNaturally();});
                event.player.sendMessage("\xA7cIncorrect format");
                return;
            }
            event.setLine(1, "\xA73Deposit");
            if (/^All$/i.test(event.getLine(2))) {
                event.setLine(2, "\xA7eAll");
            } else {
                event.setLine(2, "\xA7e" + event.getLine(2));
            }
        } else {
            delayTask(function(){event.block.breakNaturally();});
            event.player.sendMessage("\xA7cIncorrect format");
            return;
        }
        event.setLine(0, "\xA7b\xA7o[Bank]");
        event.player.sendMessage("\xA7cBank sign created!");
    }
});

registerEvent(entity, "death", function(event) {
    for (var i in money_drop_rates) {
        var rate = money_drop_rates[i];
        if (event.entity instanceof org.bukkit.entity[i]) {
            if (Math.random() > rate.chance/100) continue;
            var amount = rate.base;
            var modifier = (Math.random() - 0.5)*(rate.variance * 2) + 0.5;
            
            var items = moneyToItemStacks(amount + modifier);
            event.drops.addAll(items);
            return;
        }
    }
});