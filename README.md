# FonzTracking - World of Warcraft Addon

FonzTracking is an addon for World of Warcraft (2.4.3 client) to reset minimap 
Tracking changes after shapeshifting.

Performing certain shapeshifts, e.g. Druid's Cat Form, will also make an
expected change in the minimap Tracking type, such as enabling Track Humanoids.
The purpose of this addon is that after such a forced change on shapeshifting,
it resets the Tracking back to whatever it was previously if possible or 
tracking type "None" (empty) otherwise.

## Bonus Features
- if you select a minimap Tracking type, it should save your selection across 
reload screens and even relogging.

## Known Issues
* **queued GCD** - to (re)set Tracking the addon has to queue up a
command to act after a standard global cooldown (GCD) time period of 1.5 
seconds. So, if you are fast to act immediately after shapeshifting, the addon
may not work as expected or you have to wait the GCD for your abilities to act. 
For this reason, to not interfere with abilities, e.g. powershifting, the addon 
is disabled during combat.

## Credits

The original idea and implementation for this addon were by 
**[fondlez](https://github.com/fondlez)**.

### Other Addons

* **[DruidTrackDisable](https://www.wowinterface.com/downloads/info11691-DruidTrackDisable.html)** - this addon from early Wotlk tries to do the basic and similar purpose but 
does not reliably work on the TBC 2.4.3 client.