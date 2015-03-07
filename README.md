# IsometricEdit
(**Very**) Simple graphical editor for placing Iso spritesheets. Made especially for the wonderful [Kenney.nl](http://kenney.nl) Isometric assets!
It uses a grid as guide, but the tiles stores its own positions. There are no max limits to maps (other than theoretical). Note that the tile sizes are read directly from the atlas and thus they are not limited to a fixed tile size.

NB! The formats are highly non-optimized and a bit stupid (too much info per map tile instead of more information on the tile). In all reality, only the index number should be stored...

Oh, and currently one spritesheet is loaded from assets :P

## Disclaimer
It's most likely not bug-free so usage is solely your own responsibility obviously.

## License
The source code is licensed under the MIT license

## Not supported
The following main features are currently not supported yet - which is probably a breaking point for most people :P
- Loading of custom spritesheets (ye ye, will do it!)
- No save / load of tile sheets (will be implemented)
- No layers (will maybe be implemented)
- No use of standard Luxe map (may be implemented, but needs some extensions to support arbitrary tile sizes)
- No object editor (hey! starting to get demanding, are we?)

## Quick Guide

### Editor basics
- Place tiles with left mouse button
- Scroll through tiles with scroll wheel (depending on group selection)
- Change tilesheets with `Ctrl` right mouse button
- Delete tile with right mouse button
- Zoom by holding `Ctrl` and use scroll wheel
- Pan by holding down middle mouse button and moving the mouse
- Select groups with `a..z` and `0..9` (also cycles through different sheets if they have similar groups)
- See the section for Shortcut keys for additional info
- Open and save maps as JSON-files using `Ctrl-o` and `Ctrl-s`. Note that sprite sheet JSON data are also embedded in the map files for now (NOT the image).

### Selector basics
- Bring up tile selector / group editor with `Tab`
- Either select a tile for editing with left mouse button (closes selector)
- Assign group with keys `a..z` or `0..9`
- Bring up tile path editor with right mouse button
- Switch tile sheets with mouse wheel
- Zoom by holding down `Ctrl` and use scroll wheel
- Open and save tile sheets using `Ctrl-o` and `Ctrl-s`. Note that you can open either JSON-files which contains grouping and tile path information; or you can open texture atlases in XML format. When saving, a JSON-file + the image is saved to the same folder.

### Path basics
- `Ctrl` + Left click to start a new path, add more nodes with left click.
- Left click and hold to drag node positons after they have been placed
- Right click cancels node insertion for the current path or deletes an existing node
- Zoom by holding down `Ctrl` and use scroll wheel
- Displace offset (origin) of tile by `Ctrl` and middle mouse button

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
- `Ctrl-r` rebuilds the path graph based on the latest tile data
- `0..9` and `a..z` selects the group. Use mouse wheel to scroll through all tiles

#### Tile selector / Group editor

- `a..z` and `0..9` assigns or removes a tile to the group given by the key
- `Tab` or `Esc` exits without selection
- `Ctrl-o` opens a new tile sheet in either JSON format - or an XML texture atlas (only when compiled to native targets)
- `Ctrl-s` save a tile sheet in JSON format (the image will not be saved, sorry!) (only when compiled to native targets)
- `Ctrl-x` resets camera position and zoom to original setting

#### Path editor

- `Tab` or `Esc` exits
- `Ctrl-x` resets camera zoom and origin to original setting

#### Test mode

- `Space` or `Esc` exits
