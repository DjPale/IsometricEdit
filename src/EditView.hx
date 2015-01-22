import luxe.States;
import luxe.Sprite;
import luxe.options.SpriteOptions;
import luxe.Input;
import luxe.Vector;
import luxe.Rectangle;

import luxe.Vector;

import Main;

class EditView extends State
{
	var global : GlobalData;

    var spr : Sprite;
    var map : IsometricMap;

    var boundaries : Rectangle;

	public function new(_global:GlobalData)
	{
		super({ name: 'EditView' });

		map = new IsometricMap();

		global = _global;

		boundaries = new Rectangle(250, 0, Luxe.screen.w - 250, Luxe.screen.h);
	}

	override function init()
	{
        trace('EditView init');
		var spr_opt : SpriteOptions = {};
        spr_opt.name = "template";
        spr_opt.texture = global.sheet.image;
        spr = new Sprite(spr_opt);
        spr.centered = false;
        spr.depth = 1000;

        update_sprite();

        Luxe.events.listen('select', 
            function(e:SelectEvent) 
            {
                if (e.index != -1)
                {
                    global.sheet.set_index(e.index); 
                    update_sprite(); 
                }
            }
            );

        map.show_grid();
	}

    function place_tile(template:Sprite)
    {
    	if (template == null) return;

    	var mpos = map.screen_to_iso(template.pos);

        var new_tile = new Sprite({name_unique: true});
        new_tile.centered = template.centered;
        new_tile.pos = template.pos.clone();
        new_tile.size = template.size.clone();
        new_tile.texture = template.texture;
        new_tile.uv = template.uv.clone();
        new_tile.origin = template.origin.clone();

        map.set_tile(new_tile, mpos);
    }

    function remove_tile(pos:Vector)
    {
    	map.remove_tile(pos);
    }

    override function onmousemove(e:luxe.MouseEvent)
    {
        if (spr == null) return;

        var p = e.pos;
        p.add(new Vector(-map.base_width, map.base_height));

        if (!boundaries.point_inside(p)) return;

        var mp = map.screen_to_iso(p);

        spr.pos = map.iso_to_screen(mp);
    }

    override function onmousewheel(e:luxe.MouseEvent)
    {
        var dir = 0;
        if (e.y > 0)
        {
            dir = 1;
        }
        else if (e.y < 0)
        {
            dir = -1;
        }

        global.sheet.set_index_ofs(dir);
        update_sprite();
    }

    function update_sprite()
    {
        var r = global.sheet.get_current();
        trace(r);

        spr.size.x = r.w;
        spr.size.y = r.h;
        spr.uv.copy_from(r);

        spr.color.a = 0.6;

        spr.origin = new Vector(0, r.h);
    }

    function toggle_selector()
    {
    	if (global.views.enabled('SelectorView'))
    	{
    		global.views.disable('SelectorView');
    	}
    	else
    	{
    		global.views.enable('SelectorView');
    	}
    }

    override function onmouseup(e:luxe.MouseEvent)
    {
        if (!boundaries.point_inside(e.pos)) return;

        if (e.button == luxe.MouseButton.left)
        {
            place_tile(spr);
        }
        else if (e.button == luxe.MouseButton.right)
        {
            remove_tile(map.screen_to_iso(spr.pos));
        }
        else if (e.button == luxe.MouseButton.middle)
        {
        	toggle_selector();
        }
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.key_1)
    	{
    		map.set_zoom(1);
    	} 
    	else if (e.keycode == Key.key_2)
    	{
    		map.set_zoom(2);
    	}
    	else if (e.keycode == Key.key_3)
    	{
    		map.set_zoom(3);
    	}
    }

    override function update(dt:Float) 
    {
    } //update
}