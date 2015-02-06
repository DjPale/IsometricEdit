import luxe.Component;
import luxe.Sprite;
import luxe.Text;
import luxe.Rectangle;
import luxe.Vector;
import luxe.Color;

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
			//color: new luxe.Color(1, 1, 1, 0.75),
			visible: false
			});

		txt_top = new Text({
			text: '-- TOP TEXT --',
			point_size: 16,
			parent: entity,
			batcher: batcher,
			pos: new Vector(-20, -20),
            outline: 1.0,
            outline_color: new luxe.Color(0, 0, 0, 1),
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone(),
			visible: false,
            align: TextAlign.center
			});

		txt_bottom = new Text({
			text: '-- BOTTOM TEXT -- ',
			point_size: 16,
			parent: entity,
			batcher: batcher,
			pos: new Vector(-20, 20),
            outline: 1.0,
            outline_color: new luxe.Color(0, 0, 0, 1),
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone(),
            visible: false,
            align: TextAlign.center
			});

	}

	public inline function show(visible:Bool)
	{
		tile.visible = visible;
		txt_bottom.visible = visible;
		txt_top.visible = visible;		
	}

	public function set_tile(actual:Sprite, ?top:String = null, ?bottom:String = null)
	{
		if (tile == null || actual == null)
		{
			return;
		}

		tile.visible = true;
		tile.texture = actual.texture;
		tile.uv = actual.uv.clone();
		tile.size = actual.size.clone();

		if (top != null)
		{
			txt_top.visible = true;
			txt_top.text = top;
		}

		if (bottom != null)
		{
			txt_bottom.visible = true;
			txt_bottom.text = bottom;
		}
	}

	public function set_text(top:String, bottom:String)
	{
		if (top != null)
		{
			txt_top.text = top;
		}

		txt_top.visible = (top != null);

		if (bottom != null)
		{
			txt_bottom.text = bottom;
		}

		txt_bottom.visible = (bottom != null);
	}

	public function set_new_tile(img:phoenix.Texture, rect:Rectangle)
	{
		if (tile == null || img == null || rect == null)
		{
			return;
		}

		tile.visible = true;
		tile.texture = img;
		tile.uv = rect.clone();
		tile.size = new Vector(rect.w, rect.h);
	}
}