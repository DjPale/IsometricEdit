# IsometricEdit
(Very) Simple text editor for placing Iso spritesheets. Made especially for the wonderful Kenney.nl Isometric assets!
It uses a grid as guide, but the tiles stores its own positions. There are no max limits to maps (other than theoretical). Note that the tile sizes are read directly from the atlas and thus they are not limited to a fixed tile size.

## Quick Guide

### Editor basics
- Place tiles with left mouse button
- Scroll through tiles with scroll wheel (depending on group selection)
- Delete tile with right mouse button
- Zoom by holding `Ctrl` and use scroll wheel
- Pan by holding down middle mouse button and moving the mouse
- Select groups with `a..z` and `0..9`
- Select tile under cursor with `,`

### Selector basics
- Bring up tile selector / group editor with `Space`
- Either select a tile for editing with left mouse button (closes selector)
- Assign group with keys `a..z` or `0..9`

### Shortcut Keys

In general, `Ctrl` is used for most editor commands. The notable exception being `Space` which brings up the tile selector / group.

#### Editor

The base grid size is currently `64x32` which allows for fine placement.

- `Space` brings up the tile selector / group editor
- `,` selects the tile under the tile cursor (cancels group selection)
- `Ctrl-z` undo last changes (has a small undo stack)
- `Ctrl-1..3` changes the current grid snap level from 1 (default) through 3
- `0..9` and `a..z` selects the main group. Use mouse wheel to scroll through all tiles
- `Shift+0..9` or and `Shift+a..z` selects the subgroup

#### Tile selector / Group editor

- `a..z` and `0..9` assigns a tile to a main group
- `Shift` assigns a tile to a subgroup (must be assigned to main group first)
