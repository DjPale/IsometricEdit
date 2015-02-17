import luxe.Input;

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

    public static inline function valid_group_key(keycode:Int) : Bool
    {
        return ((keycode >= Key.key_0 && keycode <= Key.key_9) || 
            (keycode >= Key.key_a && keycode <= Key.key_z));
    }

    public static function ShowMessage(msg:String, ?title:String = null)
    {
        trace(msg);
        Luxe.core.app.window.simple_message(msg, title);
    }
}