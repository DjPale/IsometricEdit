import luxe.Sprite;
import luxe.Vector;

import phoenix.geometry.Geometry;

class IsometricMap
{
	var grid : Map<String,Sprite> = new Map<String,Sprite>();

	public var base_width(default, null) : Int;
	public var base_height(default, null) : Int;

	var grid_zoom : Int = 1;

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	public var width_half(default, null) : Int;
	public var height_half(default, null) : Int;

    public function new(?_base_width:Int = 64, ?_base_height:Int = 32, ?_grid_zoom:Int = 2)
    {
    	base_width = _base_width;
    	base_height = _base_height;

		set_zoom(_grid_zoom);
    }

    public function set_zoom(zoom:Int)
    {
    	if (zoom >= 1 && zoom <= 4)
    	{
    		width = base_width * (1 << (zoom - 1));
    		height = base_height * (1 << (zoom - 1));

    		width_half = Std.int(width / 2);
    		height_half = Std.int(height / 2);

    		trace('grid ' + width + 'x' + height + ' - ' + zoom);

    		show_grid();
    	}
    }

    public function set_tile(tile:Sprite, pos:Vector)
    {
        remove_tile(pos);

        tile.depth = pos.y + pos.x;

        grid.set(_key(pos), tile);
    }

    public function remove_tile(pos:Vector, ?_destroy:Bool = true) : Bool
    {
        var k = _key(pos);
        var v = grid.get(k);

        if (v != null && _destroy) v.destroy();

        return grid.remove(k);
    }

    inline function _key(p:Vector)
    {
        return Std.int(p.x) + '-' + Std.int(p.y);
    }

    public inline function screen_to_iso(p:Vector) : Vector
    {
        var mx = Std.int(((p.x / width_half) + (p.y / height_half)) / 2);
        var my = Std.int(((p.y / height_half) - (p.x / width_half)) / 2);

        return new Vector(mx, my);
    }

    public inline function iso_to_screen(p:Vector) : Vector
    {
        var sx = (p.x - p.y) * width_half;
        var sy = (p.x + p.y) * height_half;

        return new Vector(sx, sy);
    }

    var geom : Array<Geometry> = new Array<Geometry>();

    public function hide_grid()
    {
    	while (geom.length > 0)
    	{
    		Luxe.renderer.batcher.remove(geom.shift());
    	}
    }

    public function show_grid()
    {
    	hide_grid();

    	var xw = Std.int(Luxe.screen.w / width * 2);
    	var yw = Std.int(Luxe.screen.h / height * 2);

    	for (x in 0...xw)
    	{
    		for (y in 0...yw)
    		{
    			var i = iso_to_screen(new Vector(x, y));
    			i.x += Luxe.screen.w / 2 + base_width / 2;
    			i.y += -Luxe.screen.h / 2 + base_height;
    			var i2 = i.clone();
    			i2.y -= height_half;

    			geom.push(Luxe.draw.circle({
    				x: i.x,
    				y: i.y,
    				r: 4,
    				}));

    			geom.push(Luxe.draw.line({
    				p0: i,
    				p1: i2,
    				}));
    		}
    	}
    }
}