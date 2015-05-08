package editor.views;

import luxe.States;
import luxe.Sprite;
import luxe.options.SpriteOptions;
import luxe.Input;
import luxe.Vector;
import luxe.Rectangle;
import luxe.Entity;
import luxe.Vector;

import snow.system.input.Keycodes;

import Main;
import gamelib.TileSheetAtlased;
import gamelib.IsometricMap;
import gamelib.Graph;
import gamelib.MyUtils;

import editor.behaviors.TileTooltipBehavior;

import gamelib.behaviors.PathingBehavior;

using gamelib.RectangleUtils;

typedef TileUndo =
{
	map_pos : Vector,
	pos : Vector,
	size : Vector,
	origin: Vector,
	centered : Bool,
	uv : Rectangle,
    tilesheet: Int,
    depth: Float
};

typedef TileCursor =
{
    spr: Sprite,
    graph: Graph
};

class EditView extends State
{
	var global : GlobalData;
    var map : IsometricMap;

    var tile : TileCursor;
    var tooltip : TileTooltipBehavior;

    var mod_key_timer : Float;

    var UNDO_MAX : Int = 10;
    var undo_buffer : Array<TileUndo>;

    var dragging : Bool;
    var zoom_mod : Bool;

    var batcher : phoenix.Batcher;
    var graph_batcher : phoenix.Batcher;

    var prev_pos : Vector;

    var ui_on : Bool = true;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher, _graph_batcher:phoenix.Batcher)
	{
		super({ name: 'EditView' });

		undo_buffer = new Array<TileUndo>();

		global = _global;
        map = global.map;

		batcher = _batcher;
        graph_batcher = _graph_batcher;
	}

	override function init()
	{
        trace('EditView init');
		var spr_opt : SpriteOptions = {};
        spr_opt.name = "template";
        spr_opt.texture = map.sheets.current.image;

        var spr = new Sprite(spr_opt);
        spr.centered = false;
        spr.depth = 1000;

        tile = { spr: spr, graph: null };

        var tooltip_spr = new Entity({
            name: 'edit_tt',
            pos: new Vector(96, Luxe.screen.h - 70),
            });

        tooltip = tooltip_spr.add(new TileTooltipBehavior(global.ui, global.font));

        Luxe.events.listen('select',
            function(e:SelectEvent)
            {
                if (e.index != -1)
                {
                    map.sheets.set_index(e.tilesheet, e.index);
                    update_sprite();
                }

                Luxe.timer.schedule(0.1, function() { toggle_view('SelectorView'); });
            }
            );

        map.display_graph(graph_batcher);


        map.sheets.set_index(0, 0);

        update_sprite();
	}

    override function onenter(map_data:Dynamic)
    {
        trace('enter edit');

        if (map_data == null) return;

        var c_map : IsometricMapSerialize = cast map_data;

        var t_map = IsometricMap.from_json_data(c_map, batcher, graph_batcher);

        if (t_map == null)
        {
            MyUtils.ShowMessage('Failed to load map data!', 'EditView');
            return;
        }

        map.destroy();
        map = t_map;

        map.display_graph(graph_batcher);
    }

    override function onenabled<T>(ignored:T)
    {
        trace('enable edit');
        display(true);
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
        trace('disable edit');
        display(false);
    } //ondisabled

    function display(show:Bool)
    {
        if (tile != null && tile.spr != null)
        {
            tile.spr.visible = show;
            update_sprite();
        }

        if (tooltip != null)
        {
            tooltip.show(show);
            update_tooltip();
        }
        //global.status.show(show);
    }

    function place_tile()
    {
        if (tile == null) return;

        var template = tile.spr;

    	if (template == null) return;

    	var mpos = map.screen_to_iso(template.pos);

    	remove_tile(mpos);

        var new_tile = new Sprite({name_unique: true});
        new_tile.centered = template.centered;
        new_tile.pos = template.pos.clone();
        new_tile.size = template.size.clone();
        new_tile.texture = template.texture;
        new_tile.uv = template.uv.clone();
        new_tile.origin = template.origin.clone();

        map.set_tile(new_tile, mpos, tile.graph);

        trace('Place tile at ' + mpos + ' depth = ' + new_tile.depth);
    }

    function remove_tile(pos:Vector)
    {
    	var old_tile = map.get_tile(pos);

    	var prev_tile : TileUndo = null;

    	if (old_tile != null)
    	{
            var old = old_tile.s;
    		prev_tile = {
                map_pos: pos,
                pos: old.pos,
                size: old.size,
                origin: old.origin,
                uv: old.uv,
                centered: old.centered,
                depth: old.depth,
                tilesheet: old_tile.tilesheet
            };
    	}
    	else
    	{
    		prev_tile = { map_pos: pos, pos: null, size: null, origin: null, uv: null, centered: false, depth: 0, tilesheet: -1 };
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
    	new_tile.texture = map.sheets.get_sheet(def.tilesheet).image;
    	new_tile.uv = def.uv;
    	new_tile.origin = def.origin;

    	map.set_tile(new_tile, def.map_pos);

        new_tile.depth = def.depth;
    }

    function update_sprite()
    {
        if (map.sheets.current == null) return;

        var t = map.sheets.current.get_current_tile();

        if (t == null) return;

        tile.spr.texture = map.sheets.current.image;

        var r = t.rect;
        tile.spr.size.x = r.w;
        tile.spr.size.y = r.h;
        tile.spr.uv.copy_from(r);

        tile.spr.color.a = 0.6;

        tile.spr.origin = new Vector(0, r.h);
        tile.spr.origin.add(t.offset);

        tile.graph = t.graph;
    }

    function toggle_view(view_name:String)
    {
    	if (global.views.enabled(view_name))
    	{
    		global.views.disable(view_name);
    		enable();
    	}
    	else
    	{
    		disable();
    		global.views.enable(view_name);
    	}
    }

    function toggle_view_param(view_name:String, param:Dynamic)
    {
        if (global.views.enabled(view_name))
        {
            global.views.disable(view_name);
            enable();
        }
        else
        {
            disable();
            global.views.enable(view_name, param);
        }
    }

    function toggle_detail_view()
    {
        var p = mouse_coords(Luxe.screen.cursor.pos);

        var mp = map.screen_to_iso(p);

        var tile = map.get_tile(mp);

        if (tile != null)
        {
            var idx = map.sheets.get_index_for_sprite(tile.s);
            if (idx != null)
            {
                toggle_view_param('PathEditView', { index: idx, previous: 'EditView' });
            }
        }
    }


    function tile_picker()
    {
        var p = mouse_coords(Luxe.screen.cursor.pos);

        var mp = map.screen_to_iso(p);

        var tile = map.get_tile(mp);

        if (tile != null)
        {
            var idx = map.sheets.get_index_for_sprite(tile.s);
            if (idx != null)
            {
                map.sheets.set_index(idx.tilesheet, idx.tile);

                update_sprite();
            }
        }
    }

    function reset_camera()
    {
        batcher.view.zoom = 1.0;
        batcher.view.pos = new Vector();

        graph_batcher.view.zoom = 1.0;
        graph_batcher.view.pos = new Vector();
    }

    function change_depth(dir:Int)
    {
        var p = mouse_coords(Luxe.screen.cursor.pos);

        var mp = map.screen_to_iso(p);

        trace('try to change depth on $mp by $dir = ' + map.change_depth_ofs(mp, dir));
    }

    function adjust_origin(ofs:Vector)
    {
        var p = mouse_coords(Luxe.screen.cursor.pos);

        var mp = map.screen_to_iso(p);

        trace('try to adjust origin on $mp by (${ofs.x},${ofs.y}) = ' + map.adjust_origin(mp, ofs));
    }

    function toggle_tag(num:Int)
    {
        var p = mouse_coords(Luxe.screen.cursor.pos);

        var mp = map.screen_to_iso(p);

        map.toggle_tag(graph_batcher, mp, num);

        trace('toggle tag on $mp with #$num');
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
            place_tile();
        }
        else if (e.button == luxe.MouseButton.right)
        {
            if (zoom_mod)
            {
                map.sheets.set_sheet_ofs(1);
                update_sprite();
            }
            else
            {
                remove_tile(map.screen_to_iso(tile.spr.pos));
            }

        }
        else if (e.button == luxe.MouseButton.middle)
        {
        	dragging = false;
        }
    }

    inline function mouse_coords(pos:Vector, ?offset:Bool = true)
    {
        var p = batcher.view.screen_point_to_world(pos);

        if (offset)
        {
            //p.add(new Vector(-map.base_width, map.base_height));
            p.add(new Vector(-map.base_width, map.base_height * 2));
        }

        return p;
    }

    function toggle_ui()
    {
        if (ui_on)
        {
            ui_on = false;
            tooltip.show(false);
            global.status.show(false);
        }
        else
        {
            ui_on = true;
            global.status.show(true);
            update_tooltip();
        }
    }

    function toggle_graph()
    {
        graph_batcher.enabled = !graph_batcher.enabled;
    }

    function refresh_map()
    {
        map.rebuild_graph();
    }

    function open_map()
    {
        trace('Try to open map...');

        #if luxe_web
        MyUtils.ShowMessage('Sorry, cannot open maps on web target!\nMaybe add a text field or something later...');
        return;
        #end

        #if desktop
        // pending https://github.com/underscorediscovery/snow/issues/65
        // var ff = [{ extension: 'json', desc: 'JSON file' }];
        var path = Luxe.core.app.io.module.dialog_open('Open map...');

        if (path == null || path.length == 0)
        {
            trace('Could not open file - dialog_open failed or canceled');
            return;
        }

        var content = null;

        try
        {
            content = sys.io.File.getContent(path);
        }
        catch(e:Dynamic)
        {
            MyUtils.ShowMessage('Failed to open file "$path", I think because "$e"', 'open_map');
            return;
        }

        var data : Dynamic = null;

        try
        {
            data = haxe.Json.parse(content);
        }
        catch(e:Dynamic)
        {
            MyUtils.ShowMessage('Failed to parse JSON file, invalid format ($e)', 'open_map');
            return;
        }

        if (data == null)
        {
            MyUtils.ShowMessage('Failed to parse JSON file, unknown error', 'open_map');
            return;
        }

        disable();

        // HACK: prepare the asset cache before de-serializing
        // A bit messy, but I think this is the best way of doing it
        var sheets : Array<TileSheetAtlasedSerialize> = cast data.sheets;
        data_buffer = { data: data, img_left: 0 };

        for (s in sheets)
        {
            if (Luxe.resources.texture(s.image) != null)
            {
                data_buffer.img_left++;
                trace('Texture "${s.image}" already loaded');
            }
            else
            {
                var lookup_path = s.image;

                if (!sys.FileSystem.exists(lookup_path))
                {
                    var dir = haxe.io.Path.directory(path);
                    var file = haxe.io.Path.withoutDirectory(lookup_path);
                    lookup_path =  haxe.io.Path.join([dir,file]);
                }

                if (sys.FileSystem.exists(lookup_path))
                {
                    data_buffer.img_left++;
                    trace('Texture "$lookup_path" needs loading');
                    s.image = lookup_path;
                }
                else
                {
                    trace('Failed to lookup texture with path "$lookup_path"');
                }
            }
        }

        if (sheets.length != data_buffer.img_left)
        {
            MyUtils.ShowMessage('Could not find all textures needed for this map, aborting load :(', 'open_map');
            enable();
            return;
        }

        for (s in sheets)
        {
            Luxe.resources.load_texture(s.image).then(map_image_loaded); 
        }
        #else
        MyUtils.ShowMessage('Cannot open maps for non-desktop targets :(', 'open_map');
        return;
        #end
    }

    function save_map()
    {
        trace('Try to save map...');

        #if luxe_web
        MyUtils.ShowMessage('Sorry, cannot save maps on web target!\nMaybe add a text field or something later...');
        return;
        #end

        #if desktop
        // pending https://github.com/underscorediscovery/snow/issues/65
        // var ff = { extension: 'json', desc: 'JSON file' };
        var path = Luxe.core.app.io.module.dialog_save('Save map as...');

        if (path == null || path.length == 0)
        {
            trace('Could not save file - dialog_save failed or canceled');
            return;
        }

        var s_map = map.to_json_data();

        try
        {
            sys.io.File.saveContent(path, haxe.Json.stringify(s_map, null, "\t"));
        }
        catch(e:Dynamic)
        {
            MyUtils.ShowMessage('Failed to save file "$path", I think because "$e"', 'save_map');
            return;
        }

        trace('Map saved! :D');

        #else
        MyUtils.ShowMessage('Cannot save maps for non-desktop targets :(', 'save_map');
        return;
        #end
    }

    var data_buffer : { data: Dynamic, img_left: Int };

    function map_image_loaded(texture:phoenix.Texture)
    {
        data_buffer.img_left--;

        if (data_buffer.img_left > 0) return;

        map_final_load_stage();
    }

    function map_final_load_stage()
    {
        var s_map = IsometricMap.from_json_data(data_buffer.data, batcher, graph_batcher);

        if (s_map != null)
        {
            trace('Ready to replace...');

            map.destroy();
            map = s_map;
        }
        else
        {
            MyUtils.ShowMessage('Something went wrong while trying to open map, sorry! :(', 'open_map');
            return;
        }

        trace('Map opened! :D');

        global.map = map;

        enable();

        map.display_graph(graph_batcher);
    }

    function update_tooltip(?_pos:Vector = null)
    {
        if (!ui_on)
        {
            return;
        }

        var mp = _pos;

        if (mp == null)
        {
            var p = mouse_coords(Luxe.screen.cursor.pos);
            mp = map.screen_to_iso(p);
        }

        var hover = map.get_tile(mp);

        if (hover != null)
        {
            var depth = map.get_depth_str(mp, hover.s.depth);
            tooltip.set_tile(hover.s, 'map: (${mp.x},${mp.y})', 'depth: $depth');
        }
        else
        {
            tooltip.show(false);
        }
    }

    function move_camera(pos:Vector)
    {
        batcher.view.pos.add(pos);
        graph_batcher.view.pos.add(pos);
    }

    function zoom_camera(z_offset:Float)
    {
        batcher.view.zoom += z_offset;
        graph_batcher.view.zoom += z_offset;
    }

    override function onmousemove(e:luxe.MouseEvent)
    {
    	if (dragging)
    	{
    		move_camera(new Vector(-e.xrel, -e.yrel));
    	}

        if (tile == null || tile.spr == null) return;

        var p = mouse_coords(e.pos);

        var mp = map.screen_to_iso(p);

        tile.spr.pos = map.iso_to_screen(mp);

        if (tile.spr.pos != prev_pos)
        {
            global.status.set_postxt('World:(' + Math.round(tile.spr.pos.x) + ',' + Math.round(tile.spr.pos.y) + ') - Map: (' + mp.x + ',' + mp.y + ')');

            update_tooltip(mp);
        }

        prev_pos = tile.spr.pos;
    }

    override function onmousewheel(e:luxe.MouseEvent)
    {
    	var dir = MyUtils.sgn(e.y);

    	if (zoom_mod)
    	{
            zoom_camera(0.15 * -dir);
    		return;
    	}

        map.sheets.current.set_group_index_ofs(dir);

        update_sprite();
    }

    override function onkeydown(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.lctrl || e.keycode == Key.rctrl ||
				  e.keycode == Key.lmeta || e.keycode == Key.rmeta)
    	{
    		zoom_mod = true;
    	}
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.lctrl || e.keycode == Key.rctrl || e.mod.lctrl || e.mod.rctrl ||
				  e.keycode == Key.lmeta || e.keycode == Key.rmeta || e.mod.lmeta || e.mod.rmeta)
    	{
    		mod_key_timer = e.timestamp;
    		zoom_mod = false;
    	}

		//trace(Key.name(e.keycode));

    	var mod_key_delta = (e.timestamp - mod_key_timer);

    	#if luxe_web
    	mod_key_delta /= 1000.0;
    	#end

    	//trace('$mod_key_delta');

        if (mod_key_delta < global.mod_sticky)
        {
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
            else if (e.keycode == Key.key_z)
            {
                restore_tile();
            }
            else if (e.keycode == Key.key_w)
            {
                change_depth(1);
            }
            else if (e.keycode == Key.key_a)
            {
                change_depth(-1);
            }
            else if (e.keycode == Key.key_x)
            {
                reset_camera();
            }
            else if (e.keycode == Key.key_c)
            {
                tile_picker();
            }
            else if (e.keycode == Key.key_t)
            {
                toggle_ui();
            }
            else if (e.keycode == Key.key_o)
            {
                open_map();
            }
            else if (e.keycode == Key.key_s)
            {
                save_map();
            }
            else if (e.keycode == Key.key_g)
            {
                toggle_graph();
            }
            else if (e.keycode == Key.key_r)
            {
                refresh_map();
            }
            else if (e.keycode == Key.key_d)
            {
                toggle_detail_view();
            }
            else if (e.keycode == Key.up)
            {
                adjust_origin(new Vector(0, 1));
            }
            else if (e.keycode == Key.down)
            {
                adjust_origin(new Vector(0, -1));
            }
            else if (e.keycode == Key.right)
            {
                adjust_origin(new Vector(-1, 0));
            }
            else if (e.keycode == Key.left)
            {
                adjust_origin(new Vector(1, 0));
            }

            update_tooltip();
        }
    	else
        {
            if (e.keycode == Key.tab)
        	{
        		toggle_view('SelectorView');
        	}
            else if (e.keycode == Key.space)
            {
                toggle_view_param('TestView', map);
            }
            else if (MyUtils.valid_group_key(e))
            {
                var group_name = Keycodes.name(e.keycode);

                map.sheets.select_group(group_name);

                trace('selected group ' + group_name);

                update_sprite();
            }
            else if (MyUtils.valid_tag_key(e))
            {
                toggle_tag(MyUtils.key_to_tag(e));
            }
        }
    }

    override function update(dt:Float)
    {
    } //update
}
