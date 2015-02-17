import luxe.Rectangle;
import luxe.Vector;

class RectangleUtils
{
	public static function to_array(r:Rectangle) : Array<Float>
	{
		var rect = new Array<Float>();

		rect.push(r.x);
		rect.push(r.y);
		rect.push(r.w);
		rect.push(r.h);

		return rect;
	}

	public static function from_array(a:Array<Float>) : Rectangle
	{
		if (a == null || a.length != 4) return null;

		return new Rectangle(a[0], a[1], a[2], a[3]);
	}

	public static inline function create_mid_square(pos:Vector, size:Float) : Rectangle
	{
		return new Rectangle(pos.x - size / 2, pos.y - size / 2, size, size);
	}

	public static inline function mid(r:Rectangle) : Vector
	{
		return new Vector(r.x + r.w / 2, r.y + r.h / 2);
	}
}