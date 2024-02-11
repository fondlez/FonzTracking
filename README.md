# FonzTracking - World of Warcraft Addon

FonzTracking is an addon for World of Warcraft to reset minimap Tracking changes 
after shapeshifting. It has been tested on TBC (2.4.3) and WotLK (3.3.5a).

Performing certain shapeshifts, e.g. Druid's Cat Form, will also make an
unexpected change in the minimap Tracking type, such as enabling 
Track Humanoids. The purpose of this addon is that after such a forced change on 
shapeshifting, it resets the Tracking back to whatever it was previously if 
possible or tracking type "None" (empty) otherwise.

## Bonus Features
- if you select a minimap Tracking type, it should save your selection across 
reload screens and even relogging.

## Notes - default WoW behaviors without this addon

In TBC, forced tracking changes after shapeshifting should occur regardless of 
the selected Tracking type, except profession-based tracking such as Find Herbs,
Find Minerals and Find Fish. 

In WotLK, forced tracking change should only occur if None is selected.

The addon behaves the same regardless of when forced tracking changes occur.

## Known Issues

* [TBC] **queued GCD** - to (re)set Tracking the addon has to queue up a
command to act after a standard global cooldown (GCD) time period of 1.5 
seconds. So, if you are fast to act immediately after shapeshifting, the addon
may not work as expected or you have to wait the GCD for your abilities to act. 
For this reason, to not interfere with abilities, e.g. powershifting, the addon 
is disabled during combat. 

In WotLK, changing tracking has no GCD cost, though the appearance of minimap
dots still has a small delay. The addon's tracking change timing and combat 
restrictions described above still apply.

## Credits

The original idea and implementation for this addon were by 
**[fondlez](https://github.com/fondlez)**.

### Other Addons

* **[DruidTrackDisable](https://www.wowinterface.com/downloads/info11691-DruidTrackDisable.html)** - this addon from early Wotlk tries to do the basic and similar purpose but 
does not reliably work on the TBC 2.4.3 client.