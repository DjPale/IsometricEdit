import luxe.Component;
import luxe.Sprite;
import luxe.Text;
import luxe.Rectangle;

import phoenix.Batcher;

class TileTooltipBehavior extends Component
{
	var tile : Sprite;
	var txt_top : Text;
	var txt_bottom : Text;
	var batcher : Batcher;

	public function new(_batcher:Batcher)
	{
		super();
		batcher = _batcher;
	}

	public override function init()
	{
		tile = new Sprite({
			batcher: batcher,
			parent: entity,
			color: new luxe.Color(1, 1, 1, 0.75),
			visible: false
			});

	}

	public function set_tile(actual:Sprite)
	{
		if (actual == null)
		{
			tile.visible = false;
			return;
		}

		tile.visible = true;
		tile.texture = actual.texture;
		tile.uv = actual.uv.clone();
		tile.size = actual.size.clone();
	}

	/*
	public function set_tile(img:phoenix.Texture, rect:Rectangle)
	{

	}
	*/

}