# BörnieMeter - The Virtual Pace Keeper

Garmin Data field to keep track of your current effort measured in Börnie.

Börnie, short Bö, is the internationally recognized reference unit for W/kg, 
1 Bö equals 3.375W/kg.

If the real-world Börnie does not ride in your group, BörnieMeter will help you
keeping track of your power output.

## Function

BörnieMeter calculates your personal Börnie value every second. If you exceed
the upper threshold (1.1 Bö) for more than a given interval (5s) an alarm will
be triggered. The Alarm is reset when pedaling for the interval below the lower
threshold (default 0.95 Bö)

### Settings

* ``hysteresis``: interval until alarm is raised or reset. Default 5s
* ``Upper Threshold``: value in Bö that starts triggering the alarm after
  ``hysteresis`` - default 1.1 Bö
* ``Lower Threshold``: threshold under which alarm will be reset after
  ``hysteresis`` - default 0.95 Bö

### Permissions

* User Profile - for reading your weight to calculate your personal
  Börnie-Rating.

* Datafield Alert - for acustic alarms.

## Changelog

### v1.0.0 Initial version

Shows current boernie value for user weight and raises alarms if threshold is 
exceeded for given hysteresis.

- configrurable tresholds and hysteresis length

### v1.1.0 Average Boernies

Do not display current boernie value but average across 3s to avoid 
fluctuation of displayed value.
