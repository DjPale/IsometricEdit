import luxe.States;
import luxe.Sprite;
import luxe.options.SpriteOptions;
import luxe.Input;
import luxe.Vector;
import luxe.Rectangle;

import luxe.Vector;

import Main;

typedef TileDef =
{
	map_pos : Vector,
	pos : Vector,
	size : Vector,
	origin: Vector,
	centered : Bool,
	uv : Rectangle
}

class EditView extends State
{
	var global : GlobalData;

    var spr : Sprite;
    var map : IsometricMap;

    var MOD_STICKY_TIME : Float = 0.2;
    var mod_key_timer : Float;

    var UNDO_MAX : Int = 10;
    var undo_buffer : Array<TileDef>;

    var dragging : Bool;
    var zoom_mod : Bool;

    var batcher : phoenix.Batcher;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'EditView' });

		map = new IsometricMap();

		undo_buffer = new Array<TileDef>();

		global = _global;

		batcher = _batcher;
		/* = new Camera({
			camera_name: 'edit',
			viewport: new Rectangle(0, 0, Luxe.screen.w, Luxe.screen.h)
			});
		*/
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

                Luxe.timer.schedule(0.1, function() { toggle_selector(); });
            }
            );
	}

    function place_tile(template:Sprite)
    {
    	if (template == null) return;

    	var mpos = map.screen_to_iso(template.pos);

    	remove_tile(mpos);

        var new_tile = new Sprite({name_unique: true});
        new_tile.centered = template.centered;
        new_tile.pos = template.pos.clone();
        new_tile.size = template.size.clone();
        new_tile.texture = global.sheet.image;
        new_tile.uv = template.uv.clone();
        new_tile.origin = template.origin.clone();

        map.set_tile(new_tile, mpos);
    }

    function remove_tile(pos:Vector)
    {
    	var old = map.get_tile(pos);

    	var prev_tile : TileDef = null;

    	if (old != null)
    	{
    		prev_tile = { map_pos: pos, pos: old.pos, size: old.size, origin: old.origin, uv: old.uv, centered: old.centered };
    	}
    	else
    	{
    		prev_tile = { map_pos: pos, pos: null, size: null, origin: null, uv: null, centered: false };
    	}

    	undo_buffer.push(prev_tile);

    	if (undo_buffer.length > UNDO_MAX)
    	{
    		undo_buffer.shift();
    	}

    	map.remove_tile(pos);
    }

    function restore_tile()
    {
    	if (undo_buffer.length == 0) return;

    	trace('restore_tile');

    	var def = undo_buffer.pop();

    	if (def.map_pos != null && def.pos == null)
    	{
    		map.remove_tile(def.map_pos);
    		return;
    	}

    	var new_tile = new Sprite({ name_unique: true });
    	new_tile.centered = def.centered;
    	new_tile.pos = def.pos;
    	new_tile.size = def.size;
    	new_tile.texture = global.sheet.image;
    	new_tile.uv = def.uv;
    	new_tile.origin = def.origin;

    	map.set_tile(new_tile, def.map_pos);
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
    		enable();
    	}
    	else
    	{
    		disable();
    		global.views.enable('SelectorView');
    	}
    }

    override function onmousedown(e:luxe.MouseEvent)
    {
    	if (!MyUtils.inside_me(batcher.view, e.pos)) return;

    	if (e.button == luxe.MouseButton.middle)
    	{
    		dragging = true;
    	}
    }

    override function onmouseup(e:luxe.MouseEvent)
    {
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
        	dragging = false;
        }
    }

    override function onmousemove(e:luxe.MouseEvent)
    {
    	if (dragging)
    	{
    		batcher.view.pos.add(new Vector(-e.xrel, -e.yrel));
    	}

        if (spr == null) return;

        var p = batcher.view.screen_point_to_world(e.pos);
        p.add(new Vector(-map.base_width, map.base_height));

        var mp = map.screen_to_iso(p);

        spr.pos = map.iso_to_screen(mp);
    }

    override function onmousewheel(e:luxe.MouseEvent)
    {
    	var dir = MyUtils.sgn(e.y);

    	if (zoom_mod)
    	{
    		batcher.view.zoom += 0.15 * -dir;

    		return;
    	}

        if (global.sheet.current_group_empty())
        {
            global.sheet.set_index_ofs(dir);
        }
        else
        {
            global.sheet.set_group_index_ofs(dir);
        }


        update_sprite();
    }

    override function onkeydown(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.lctrl || e.keycode == Key.rctrl)
    	{
    		zoom_mod = true;
    	}
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.lctrl || e.keycode == Key.rctrl || e.mod.lctrl || e.mod.rctrl)
    	{
    		mod_key_timer = e.timestamp;
    		zoom_mod = false;
    	}

    	var mod_key_delta = (e.timestamp - mod_key_timer);

    	#if luxe_web
    	mod_key_delta /= 1000.0;
    	#end

    	//trace('$mod_key_delta');

    	if (e.keycode == Key.key_1)
    	{
    		map.set_snap(1);
    	} 
    	else if (e.keycode == Key.key_2)
    	{
    		map.set_snap(2);
    	}
    	else if (e.keycode == Key.key_3)
    	{
    		map.set_snap(3);
    	}
    	else if (mod_key_delta < MOD_STICKY_TIME && e.keycode == Key.key_z)
    	{
    		restore_tile();
    	}
    	else if (e.keycode == Key.space)
    	{
    		toggle_selector();
    	}
        else
        {
            global.sheet.select_group(e.keycode);
            trace('selected group ' + e.keycode);
        }
    }

    override function update(dt:Float) 
    {
    } //update
}