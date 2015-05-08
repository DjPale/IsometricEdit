# IsometricEdit
(**Very**) Simple graphical editor for placing tiles from isometric texture atlases on staggered isometric maps. Made especially for the wonderful [Kenney.nl](http://kenney.nl) isometric assets! It is implemented using [Haxe](http://haxe.org/) and the new excellent [luxe](http://luxeengine.com/) framework. It snaps to a grid as guide, but the tiles stores its own positions as sprites. There are no max limits to maps (other than theoretical). Note that the tile sizes are read directly from the atlas and thus they are not limited to a fixed tile size.

Tested and built for Windows, Mac and Linux. Web version also works, but it is limited with regards to save/load and shortcut keys.

## Main features
- Use the super-cool isometric tiles by Kenney.nl 'out-of-the-box' (included)
- Supports arbitrary tile sizes (but the snap is 64x32)
- Open and save maps in JSON format
- Mouse / shortcut-key based for a quick workflow
- Flexible grouping system for quick selection of tiles
- Create local paths on tiles and they are auto-connected on the global map
- Global offsets on tiles to easily construct complex building structures
- Individual tile depth adjustments to tweak special cases
- No max width / height on maps - not sure if this is a feature or confusing :)

## Not supported
The following main features are currently not supported yet
- No layers (will maybe be implemented)
- Not possible to delete tilesheets once they're loaded
- No use of standard Luxe map (may be implemented, but needs some extensions to support arbitrary tile sizes)
- No object editor for pre-determined objects (hey! starting to get demanding, are we?)

## Planned features / bugs
The [issue tracker](https://github.com/DjPale/IsometricEdit/issues) contains list of bugs and enhancements. The 2 current 'serious' issues being:
- The depth calc for negative coords is not accounted for, so always build left and downwards. The top left of the start camera is (0,0)
- The graph merge algorithm is not 100% foolproof yet

## Disclaimer
It's most likely not bug-free so usage is solely your own responsibility obviously.

## License
The source code is licensed under the [MIT license](https://github.com/DjPale/IsometricEdit/blob/master/README.md). The assets from Kenney.nl are licensed under [Creative Commons Zero, CC0](http://creativecommons.org/publicdomain/zero/1.0/). He appreciates [donations](http://kenney.itch.io/kenney-donation/purchase) which I highly recommend if you want to use his work!

## Quick Guide
A brief overview of the main functions for the editors. The editor includes the following tilesheets by default:
- [Isometric Landscape](http://www.kenney.nl/assets/isometric-landscape)
- [Isometric City](http://www.kenney.nl/assets/isometric-city)
- [Isometric Buildings #1](http://www.kenney.nl/assets/isometric-buildings)

They contain some predefined information - some groups are defined and offsets for some of the building tiles.

Note that the Mac meta key <kbd>&#8984;</kbd> can be used wherever <kbd>Ctrl</kbd> key is denoted.

### Editor basics
- Place tiles with left mouse button
- Scroll through tiles with scroll wheel (depending on group selection)
- Change tilesheets with <kbd>Ctrl</kbd> and right mouse button
- Delete tile with right mouse button
- Zoom by holding <kbd>Ctrl</kbd> and use scroll wheel
- Pan by holding down middle mouse button and moving the mouse
- Select groups with <kbd>a</kbd>`..`<kbd>z</kbd> and <kbd>0</kbd>`..`<kbd>9</kbd> (also cycles through different sheets if they have similar groups)
- See the section for Shortcut keys for additional info
- Open and save maps as JSON-files using <kbd>Ctrl</kbd>`+`<kbd>o</kbd> and <kbd>Ctrl</kbd>`+`<kbd>s</kbd>. Note that sprite sheet JSON data are also embedded in the map files for 
now (NOT the image).
- Adjust offsets of tile under cursor with <kbd>Ctrl</kbd> and arrow keys (does not affect tile in tilesheet, this can be done in the editor). NB! This will be overwritten by adjusting the offset of the tile in the tile sheet.
- To tag a position, use <kbd>F1</kbd>`..`<kbd>F12</kbd>.

### Selector basics
- Bring up tile selector / group editor with <kbd>Tab</kbd>
- Either select a tile for editing with left mouse button (closes selector)
- Toggle group assignment with keys <kbd>a</kbd>`..`<kbd>z</kbd> or <kbd>0</kbd>`..`<kbd>9</kbd>
- Bring up tile path editor with right mouse button
- Switch tile sheets with mouse wheel
- Zoom by holding down <kbd>Ctrl</kbd> and use scroll wheel
- Open and save tile sheets using <kbd>Ctrl</kbd>`+`<kbd>o</kbd> and <kbd>Ctrl</kbd>`+`<kbd>s</kbd>. Note that you can open either JSON-files which contains grouping and tile path information; or you can open texture atlases in XML format. Note that the texture file name is assumed to be the exact same as the base name with extension `.png`. If another tilesheet with the same image exists, it will be overwritten.

### Path basics
- <kbd>Ctrl</kbd> + Left click to start a new path, add more nodes with left click.
- Left click and hold to drag node positons after they have been placed
- Right click cancels node insertion for the current path or deletes an existing node
- Zoom by holding down <kbd>Ctrl</kbd> and use scroll wheel
- Adjust offsets of tile under cursor with <kbd>Ctrl</kbd> and arrow keys. NB! This will overwrite any individual tile adjustements for instances of the tile in the map.

### Test basics
- Watch the cute cars drive around

### Shortcut Keys

In general, <kbd>Ctrl</kbd> is used for most editor commands. The notable exception being <kbd>Tab</kbd> which brings up the tile selector / group and <kbd>Space</kbd> which toggles test mode.

#### Editor

The base grid size is currently `64x32` which allows for fine placement.

- <kbd>Tab</kbd> brings up the tile selector / group editor
- <kbd>Space</kbd> toggles test mode by putting small cars that drive around on the map
- <kbd>Ctrl</kbd>`+`<kbd>c</kbd> selects the tile under the tile cursor (cancels group selection)
- <kbd>Ctrl</kbd>`+`<kbd>z</kbd> undo last changes (has a small undo stack)
- <kbd>Ctrl</kbd>`+`<kbd>1</kbd>`..`<kbd>3</kbd> changes the current grid snap level from 1 (default) through 3
- <kbd>Ctrl</kbd>`+`<kbd>x</kbd> resets camera and zoom to (0,0)
- <kbd>Ctrl</kbd>`+`<kbd>k</kbd> kills map data and loads default tilesheet
- <kbd>Ctrl</kbd>`+`<kbd>t</kbd> toggle visibility of status text + tile tooltip
- <kbd>Ctrl</kbd>`+`<kbd>w</kbd> raise tile depth of tile under tile cursor by 1
- <kbd>Ctrl</kbd>`+`<kbd>a</kbd> lower tile depth of tile under tile cursor by 1
- <kbd>Ctrl</kbd>`+`<kbd>s</kbd> save map as JSON (only when compiled to native targets)
- <kbd>Ctrl</kbd>`+`<kbd>o</kbd> open map from JSON (only when compiled to native targets)
- <kbd>Ctrl</kbd>`+`<kbd>g</kbd> shows and hides the path graph
- <kbd>Ctrl</kbd>`+`<kbd>r</kbd> rebuilds the path graph based on the latest tile data and applies offsets
- <kbd>Ctrl</kbd>`+`<kbd>d</kbd> brings up the path editor for the tag under the tile cursor
- <kbd>Ctrl</kbd>`+`<kbd>arrows</kbd> adjust individual tile offset
- <kbd>F1</kbd>`..`<kbd>F12</kbd> tag current map location with a given number from 0 to 11
- <kbd>0</kbd>`..`<kbd>9</kbd> and <kbd>a</kbd>`..`<kbd>z</kbd> selects the group. Use mouse wheel to scroll through all tiles in group. Invalid selection selects all tiles

#### Tile selector / Group editor

- <kbd>a</kbd>`..`<kbd>z</kbd> and <kbd>0</kbd>`..`<kbd>9</kbd> assigns or removes a tile to the group given by the key
- <kbd>Tab</kbd> or <kbd>Esc</kbd> exits without selection
- <kbd>Ctrl</kbd>`+`<kbd>o</kbd> opens a new tile sheet in either JSON format - or an XML texture atlas (only when compiled to native targets)
- <kbd>Ctrl</kbd>`+`<kbd>s</kbd> save a tile sheet in JSON format (the image will not be saved, sorry!) (only when compiled to native targets)
- <kbd>Ctrl</kbd>`+`<kbd>x</kbd> resets camera position and zoom to original setting

#### Path editor

- <kbd>Tab</kbd> or <kbd>Esc</kbd> or <kbd>Ctrl</kbd>`+`<kbd>d</kbd> exits
- <kbd>Ctrl</kbd>`+`<kbd>x</kbd> resets camera zoom and origin to original setting
- <kbd>Ctrl</kbd>`+`<kbd>arrows</kbd> adjust global tile offset

#### Test mode

- <kbd>Space</kbd> or <kbd>Esc</kbd> exits
