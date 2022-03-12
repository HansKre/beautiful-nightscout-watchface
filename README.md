# Beautiful Nightscout Watchface for Garmin Watches

## Deployment

- go to apps.garmin.com
- upload new version to publish

## Backlog

### v1
- read default color, positions, font-sizes from settings.xml (Monkey C-XML-Parser?)
- Rename bg to glucose
- implement robust property-getters:
  - https://github.com/douglasr/connectiq-samples/blob/master/snippets/get_properties.mc
  - https://github.com/douglasr/connectiq-samples/blob/master/snippets/get_properties2.mc
- add trend arrows
- color for bg
- sundown / sunrise:
  - https://github.com/douglasr/connectiq-samples/blob/master/libraries/solar-events/SunCalc.mc
- steps icon
- battery icon
- calories field + icon
- left of glucose: elapsed time since last update
- right of glucose: trend
- remove unneeded settings / properties, e.g. configuration of background color

### v2
- trend: +/- last 15mins, last 30mins
- battery
- make all settings configurable
