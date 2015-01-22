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
		if (e.button == MouseButton.left)
		{
			var wpos = camera.screen_point_to_world(e.pos);

			var new_tile = find_tile(wpos);

			trace("I think I found pos " + new_tile);

			Luxe.events.fire('select', { index: new_tile });
		}
	}		
}