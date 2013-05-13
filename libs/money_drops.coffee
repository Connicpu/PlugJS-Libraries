# This library relies on metadata.js and js_persistence.js

# Permissions
# * moneydrops.banksign.create default: op
# * moneydrops.banksign.destroy default: op
# * moneydrops.banksign.use default: true
# 

# Drop rates
# * Evaluated last to first so later items take priority
# * See the default values for clues on how to edit the others ;)
# * Entity types taken from http://jd.bukkit.org/rb/doxygen/d5/d27/namespaceorg_1_1bukkit_1_1entity.html

money_drop_rates =
  Creature:
    base: 1
    variance: 1
    chance: 0.5

  Monster:
    base: 3
    variance: 1
    chance: 0.9

  Enderman:
  	base: 10
  	variance: 0
  	chance: 1

# Change this to what you want to appear on 
# * the money as your treasury name. If you change
# * this after money has started circulating, it will
# * invalidate all previously generated banknotes

treasuryName = "Server Treasury"

# Load the backend
eval(read_file('./plugins/PlugJS/libs/money_drops_lib.js'))