import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Input;
import phoenix.Camera;

import Main;

class TileSelectorBehavior extends Component
{
	var sheet : TileSheetAtlased;
	var sprite : Sprite;
	var camera : Camera;

	public function new(_sheet:TileSheetAtlased, _camera:Camera, ?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		sheet = _sheet;
		camera = _camera;
	}


	override public function init()
	{
		sprite = cast entity;
	}

	override function onmousemove(e:luxe.MouseEvent)
	{
		//trace("I think I found pos " + find_tile(e.pos));
	}

	override function onmouseup(e:luxe.MouseEvent)
	{
		var wpos = camera.screen_point_to_world(e.pos);

		var new_tile = - 1;

		if (sprite != null)
		{
			sheet.get_tile_idx(wpos, sprite.size);
		}

		trace("I think I found pos " + new_tile);

		var sel_event : SelectEvent = { index: new_tile, group: null };

		if (e.button == MouseButton.left)
		{
			Luxe.events.fire('select', sel_event);
		}
		else if (e.button == MouseButton.right)
		{
			Luxe.events.fire('deselect', sel_event);
		}
	}

	override function onkeyup(e:luxe.KeyEvent)
	{
        if (!MyUtils.valid_group_key(e.keycode))
        {
        	return;
        }

		var wpos = camera.screen_point_to_world(Luxe.screen.cursor.pos);
		var new_tile = sheet.get_tile_idx(wpos);

		var group_name = snow.input.Keycodes.Keycodes.name(e.keycode);

		var sel_event : SelectEvent = { index: new_tile, group: group_name };

		Luxe.events.fire('assign', sel_event);
	}		
}