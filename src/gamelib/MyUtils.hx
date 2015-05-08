package gamelib;

import luxe.Input;
import luxe.Vector;

typedef VectorSerialize = {
    x: Float,
    y: Float
};

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

    public static inline function valid_group_key(e:luxe.KeyEvent) : Bool
    {
        return !(e.mod.lctrl || e.mod.rctrl || e.mod.lmeta || e.mod.rmeta) && ((e.keycode >= Key.key_0 && e.keycode <= Key.key_9) ||
            (e.keycode >= Key.key_a && e.keycode <= Key.key_z));
    }

    public static inline function valid_tag_key(e:luxe.KeyEvent) : Bool
    {
        return !(e.mod.lctrl || e.mod.rctrl || e.mod.lmeta || e.mod.rmeta) && (e.keycode >= Key.f1 && e.keycode <= Key.f12);
    }

    public static inline function key_to_tag(e:luxe.KeyEvent) : Int
    {
        return (e.keycode - Key.f1);
    }

    public static function ShowMessage(msg:String, ?title:String = null)
    {
        trace(msg);
        Luxe.core.app.window.simple_message(msg, title);
    }

    public static inline function vector_to_pair(v:Vector) : VectorSerialize
    {
        return { x: v.x, y: v.y };
    }

    public static inline function vector_from_pair(p:VectorSerialize) : Vector
    {
        return new Vector(p.x, p.y);
    }
}
