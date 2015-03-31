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

### Editor basics
- Place tiles with left mouse button
- Scroll through tiles with scroll wheel (depending on group selection)
- Change tilesheets with `Ctrl` right mouse button
- Delete tile with right mouse button
- Zoom by holding `Ctrl` and use scroll wheel
- Pan by holding down middle mouse button and moving the mouse
- Select groups with `a..z` and `0..9` (also cycles through different sheets if they have similar groups)
- See the section for Shortcut keys for additional info
- Open and save maps as JSON-files using `Ctrl-o` and `Ctrl-s`. Note that sprite sheet JSON data are also embedded in the map files for 
now (NOT the image).
- Adjust offsets of tile under cursor with `Ctrl` and arrow keys (does not affect tile in tilesheet, this can be done in the editor). NB! This will be overwritten by adjusting the offset of the tile in the tile sheet.
- To tag a position, use `F1..F12`.

### Selector basics
- Bring up tile selector / group editor with `Tab`
- Either select a tile for editing with left mouse button (closes selector)
- Toggle group assignment with keys `a..z` or `0..9`
- Bring up tile path editor with right mouse button
- Switch tile sheets with mouse wheel
- Zoom by holding down `Ctrl` and use scroll wheel
- Open and save tile sheets using `Ctrl-o` and `Ctrl-s`. Note that you can open either JSON-files which contains grouping and tile path information; or you can open texture atlases in XML format. Note that the texture file name is assumed to be the exact same as the base name with extension `.png`. If another tilesheet with the same image exists, it will be overwritten.

### Path basics
- `Ctrl` + Left click to start a new path, add more nodes with left click.
- Left click and hold to drag node positons after they have been placed
- Right click cancels node insertion for the current path or deletes an existing node
- Zoom by holding down `Ctrl` and use scroll wheel
- Adjust offsets of tile under cursor with `Ctrl` and arrow keys. NB! This will overwrite any individual tile adjustements for instances of the tile in the map.

### Test basics
- Watch the cute cars drive around

### Shortcut Keys

In general, `Ctrl` is used for most editor commands. The notable exception being `Tab` which brings up the tile selector / group and `Space` which toggles test mode.

#### Editor

The base grid size is currently `64x32` which allows for fine placement.

- `Tab` brings up the tile selector / group editor
- `Space` toggles test mode by putting small cars that drive around on the map
- `Ctrl-c` selects the tile under the tile cursor (cancels group selection)
- `Ctrl-z` undo last changes (has a small undo stack)
- `Ctrl-1..3` changes the current grid snap level from 1 (default) through 3
- `Ctrl-x` resets camera and zoom to (0,0)
- `Ctrl-k` kills map data and loads default tilesheet
- `Ctrl-t` toggle visibility of status text + tile tooltip
- `Ctrl-q` raise tile depth of tile under tile cursor by 1
- `Ctrl-a` lower tile depth of tile under tile cursor by 1
- `Ctrl-s` save map as JSON (only when compiled to native targets)
- `Ctrl-o` open map from JSON (only when compiled to native targets)
- `Ctrl-g` shows and hides the path graph
- `Ctrl-r` rebuilds the path graph based on the latest tile data and applies offsets
- `Ctrl-d` brings up the path editor for the tag under the tile cursor
- `Ctrl-arrows` adjust individual tile offset
- `F1..F12` tag current map location with a given number from 0 to 11
- `0..9` and `a..z` selects the group. Use mouse wheel to scroll through all tiles in group. Invalid selection selects all tiles

#### Tile selector / Group editor

- `a..z` and `0..9` assigns or removes a tile to the group given by the key
- `Tab` or `Esc` exits without selection
- `Ctrl-o` opens a new tile sheet in either JSON format - or an XML texture atlas (only when compiled to native targets)
- `Ctrl-s` save a tile sheet in JSON format (the image will not be saved, sorry!) (only when compiled to native targets)
- `Ctrl-x` resets camera position and zoom to original setting

#### Path editor

- `Tab` or `Esc` or `Ctrl-d` exits
- `Ctrl-x` resets camera zoom and origin to original setting
- `Ctrl-arrows` adjust global tile offset

#### Test mode

- `Space` or `Esc` exits
