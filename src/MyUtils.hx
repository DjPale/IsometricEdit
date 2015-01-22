class MyUtils
{
	public static inline function sgn(num:Int) : Int
	{
		var dir = 0;
        if (num > 0)
        {
            dir = 1;
        }
        else if (num < 0)
        {
            dir = -1;
        }

        return dir;
	}

	public static inline function inside_me(camera:phoenix.Camera, pos:luxe.Vector) : Bool
	{
		return (camera.viewport.point_inside(pos));
	}
}