# IsometricEdit
(Very) Simple graphical editor for placing Iso spritesheets. Made especially for the wonderful Kenney.nl Isometric assets!
It uses a grid as guide, but the tiles stores its own positions. There are no max limits to maps (other than theoretical). Note that the tile sizes are read directly from the atlas and thus they are not limited to a fixed tile size.

NB! The formats are highly non-optimized and a bit stupid (too much info per map tile instead of more information on the tile). In all reality, only the index number should be stored...

## Disclaimer
It's most likely not bug-free so usage is solely your own responsibility obviously.

## License
The source code is licensed under the MIT license

## Not supported
The following main features are currently not supported yet - which is probably a breaking point for most people :P
- No save / load of tile sheets (will be implemented)
- No global map grid (will be implemented)
- No layers (will maybe be implemented)
- No use of standard Luxe map (may be implemented, but needs some extensions to support arbitrary tile sizes)

## Quick Guide

### Editor basics
- Place tiles with left mouse button
- Scroll through tiles with scroll wheel (depending on group selection)
- Delete tile with right mouse button
- Zoom by holding `Ctrl` and use scroll wheel
- Pan by holding down middle mouse button and moving the mouse
- Select groups with `a..z` and `0..9`
- See the section for Shortcut keys for additional info

### Selector basics
- Bring up tile selector / group editor with `Space`
- Either select a tile for editing with left mouse button (closes selector)
- Assign group with keys `a..z` or `0..9`
- Bring up tile path editor with right mouse button

### Path basics
- Left click to start a new path, add more nodes with left click.
- Right click cancels node insertion for the current path or deletes an existing node
- Middle click and hold to drag node positons after they have mid placed
- Zoom by holding down `Ctrl` and use scroll wheel

### Shortcut Keys

In general, `Ctrl` is used for most editor commands. The notable exception being `Space` which brings up the tile selector / group.

#### Editor

The base grid size is currently `64x32` which allows for fine placement.

- `Space` brings up the tile selector / group editor
- `Ctrl-c` selects the tile under the tile cursor (cancels group selection)
- `Ctrl-z` undo last changes (has a small undo stack)
- `Ctrl-1..3` changes the current grid snap level from 1 (default) through 3
- `Ctrl-x` resets camera and zoom to (0,0)
- `Ctrl-t` toggle visibility of status text + tile tooltip
- `Ctrl-q` raise tile depth of tile under tile cursor by 1
- `Ctrl-a` lower tile depth of tile under tile cursor by 1
- `Ctrl-s` save map as JSON (only when compiled to native targets)
- `Ctrl-o` open map from JSON (only when compiled to native targets)
- `0..9` and `a..z` selects the group. Use mouse wheel to scroll through all tiles

#### Tile selector / Group editor

- `a..z` and `0..9` assigns or removes a tile to the group given by the key
- `Space` or `Esc` exits without selection

#### Path editor

- `Space` or `Esc` exits