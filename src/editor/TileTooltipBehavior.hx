import luxe.Component;
import luxe.Sprite;
import luxe.Text;
import luxe.Rectangle;
import luxe.Vector;
import luxe.Color;

import phoenix.Batcher;
import phoenix.BitmapFont;

class TileTooltipBehavior extends Component
{
	var tile : Sprite;
	var txt_top : Text;
	var txt_bottom : Text;
	var batcher : Batcher;
	var font: BitmapFont;

	public function new(_batcher:Batcher, _font:BitmapFont)
	{
		super();
		batcher = _batcher;
		font = _font;
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
			point_size: 24,
			parent: entity,
			batcher: batcher,
			pos: new Vector(0, -20),
            sdf: true,
            outline: 0.8,
            outline_color: new luxe.Color(0, 0, 0, 1),
            font: font,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone(),
			visible: false,
            align: TextAlign.center,
			});

		txt_bottom = new Text({
			text: '-- BOTTOM TEXT -- ',
			point_size: 24,
			parent: entity,
			batcher: batcher,
			pos: new Vector(0, 20),
            sdf: true,
            outline: 0.8,
            outline_color: new luxe.Color(0, 0, 0, 1),
            font: font,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone(),
            visible: false,
            align: TextAlign.center
			});

	}

	public inline function show(visible:Bool)
	{
		if (tile != null) tile.visible = visible;
		if (txt_bottom != null) txt_bottom.visible = visible;
		if (txt_top != null) txt_top.visible = visible;		
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
		if (txt_top != null)
		{
			if (top != null)
			{
				txt_top.text = top;
			}

			txt_top.visible = (top != null);
		}

		if (txt_bottom != null)
		{
			if (bottom != null)
			{
				txt_bottom.text = bottom;
			}

			txt_bottom.visible = (bottom != null);
		}
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