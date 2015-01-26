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

	function find_tile(pos:Vector) : Int
	{
		if (sprite == null) return -1;

		var atlas_pos = -1;

		for (i in 0...sheet.atlas.length)
		{
			var rect = sheet.atlas[i].clone();

			rect.x *= sprite.scale.x;
			rect.y *= sprite.scale.y;
			rect.w *= sprite.scale.x;
			rect.h *= sprite.scale.y;

			if (rect.point_inside(pos))
			{
				atlas_pos = i;
				break;
			}
		}

		return atlas_pos;
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
		var new_tile = find_tile(wpos);

		trace("I think I found pos " + new_tile);

		var sel_event : SelectEvent = { index: new_tile, code: -1 };

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
		var wpos = camera.screen_point_to_world(Luxe.screen.cursor.pos);
		var new_tile = find_tile(wpos);

		var sel_event : SelectEvent = { index: new_tile, code: e.keycode };

		sheet.select_group(e.keycode);
		trace('select group ' + e.keycode);

		var ret = sheet.add_idx_to_group(new_tile);
		trace('add to group = $ret');

		Luxe.events.fire('assign', sel_event);
	}		
}