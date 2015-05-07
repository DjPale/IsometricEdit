package editor.views;

import luxe.States;
import luxe.Sprite;
import luxe.Entity;
import luxe.Vector;
import luxe.Camera;
import luxe.Input;
import phoenix.Batcher;

import snow.system.input.Keycodes;

import gamelib.MyUtils;
import gamelib.TileSheetAtlased;

import editor.behaviors.TileSelectorBehavior;
import editor.behaviors.TileTooltipBehavior;

import Main;

typedef DataBuffer =  { type: String, data: Dynamic };

class SelectorView extends State
{
	var global : GlobalData;

	var selector : Sprite;
	var selector_comp : TileSelectorBehavior;

	var tooltip : TileTooltipBehavior;

	var batcher : Batcher;

	var dragging : Bool;

	var current : TileSheetAtlased;

	var data_buffer : DataBuffer = null;

	var event_id_assign : String = '';
	var event_id_detail : String = '';

	var zoom_mod : Bool = false;
	var mod_key_timer : Float;

	public function new(global_data:GlobalData, _batcher:Batcher)
	{
		super({ name: 'SelectorView' });

		global = global_data;

		batcher = _batcher;

		reset_zoom();
	}

	function reset_zoom()
	{
		batcher.view.zoom = 0.25;
		batcher.view.pos.x = -1050;
		batcher.view.pos.y = 720;
	}

	function refresh_selector()
	{
		current = global.map.sheets.current;
		selector_comp.set_sheet(current);
		update_tooltip();
	}

	function display()
	{
		current = global.map.sheets.current;

		selector = new Sprite({
			name: 'selector',
			centered: false,
			texture: current.image,
			batcher: batcher,
			});

		//selector.pos = new Vector(Luxe.screen.w - selector.size.x, Luxe.screen.h / 2 - selector.size.y / 2);

		selector_comp = new TileSelectorBehavior(current, batcher);
		selector.add(selector_comp);

		var tooltip_spr = new Entity({
			name: 'selector_tt'
			});

		tooltip = tooltip_spr.add(new TileTooltipBehavior(global.ui, global.font));

		event_id_assign = Luxe.events.listen('assign', group_assign);
		event_id_detail = Luxe.events.listen('detail', path_edit);
	}

	function hide()
	{
		if (selector != null)
		{
			selector.destroy();
			selector = null;
		}

		if (tooltip != null)
		{
			tooltip.entity.destroy();
			tooltip = null;
		}

		Luxe.events.disconnect(event_id_assign);
		Luxe.events.disconnect(event_id_detail);
	}

	function group_assign(e:SelectEvent)
	{
		if (e != null && e.group != null && e.index >= 0)
		{
			var ret = current.add_idx_to_group(e.group, e.index, true);
			trace('add to group = $ret');

			selector_comp.hide_indicators();
			selector_comp.show_indicators(current.get_group(e.group));

			update_tooltip();
		}
	}

	function path_edit(e:SelectEvent)
	{
		disable();
		global.views.enable('PathEditView', { index: { tilesheet: e.tilesheet, tile: e.index }, previous: 'SelectorView' });
	}

	function update_tooltip()
	{
	    var mouse = Luxe.screen.cursor.pos;
		var pos = batcher.view.screen_point_to_world(mouse);
		var idx = current.get_tile_idx(pos);

		if (idx >= 0)
		{
			var r = current.atlas[idx].rect;

			var ofsX = 0.0;
			var ofsY = 0.0;
			if (mouse.x > Luxe.screen.w / 2)
			{
				ofsX = -r.w;
			}
			else
			{
				ofsX = r.w;
			}

			if (mouse.y > Luxe.screen.h / 2)
			{
				ofsY = -r.w / 4;
			}
			else
			{
				ofsY = r.w / 4;
			}

			tooltip.set_new_tile(current.image, r);
			tooltip.entity.pos = new Vector(mouse.x + ofsX, mouse.y + ofsY);

			var a = current.get_groups_for_idx(idx);

			if (a != null)
			{
				tooltip.set_text('groups', a.join(','));
			}
			else
			{
				tooltip.set_text(null, null);
			}
		}
		else
		{
			tooltip.show(false);
		}
	}

	function save_tilesheet()
	{
		trace('Try to save sheet...');

		#if luxe_web
		MyUtils.ShowMessage('Sorry, cannot save sheet on web target!\nMaybe add a text field or something later...');
		return;
		#end

	    #if desktop
	    // pending https://github.com/underscorediscovery/snow/issues/65
	    // var ff = { extension: 'json', desc: 'JSON file' };
	    var path = Luxe.core.app.io.module.dialog_save('Save sheet as...');

	    if (path == null || path.length == 0)
	    {
	        trace('Could not save file - dialog_save failed or canceled');
	        return;
	    }

	    var s_sheet = current.to_json_data();

	    try
	    {
	        sys.io.File.saveContent(path, haxe.Json.stringify(s_sheet, null, "\t"));
	    }
	    catch(e:Dynamic)
	    {
	        MyUtils.ShowMessage('Failed to save file "$path", I think because "$e"', 'save_sheet');
	        return;
	    }

	    trace('Sheet saved! :D');

	    #else
	    MyUtils.ShowMessage('Cannot save sheets for non-desktop targets :(', 'save_sheet');
	    return;
	    #end
	}

	function open_tilesheet()
	{
		trace('Try to open sheet...');

		#if luxe_web
		MyUtils.ShowMessage('Sorry, cannot open sheets on web target!\nMaybe add a text field or something later...');
		return;
		#end

		#if desktop
		// pending https://github.com/underscorediscovery/snow/issues/65
		// var ff = [{ extension: 'json', desc: 'JSON file' }];
		var path = Luxe.core.app.io.module.dialog_open('Open sheet...');

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
		    MyUtils.ShowMessage('Failed to open file "$path", I think because "$e"', 'open_sheet');
		    return;
		}

		var ext = haxe.io.Path.extension(path);

		var img_path : String = '<unknown>';
		data_buffer = { type: null, data: null };

		if (ext.toLowerCase() == 'xml')
		{
			data_buffer.type = 'xml';
			data_buffer.data = content;
			img_path = haxe.io.Path.withExtension(path, 'png');
		}
		else
		{
			data_buffer.type = 'json';

			try
	        {
	            data_buffer.data = haxe.Json.parse(content);
	        }
	        catch(e:Dynamic)
	        {
	            MyUtils.ShowMessage('Failed to parse JSON file, invalid format ($e)', 'open_sheet');
	            return;
	        }

	        if (data_buffer == null)
	        {
	        	MyUtils.ShowMessage('Failed to parse JSON file for some unknown reason', 'open_sheet');
	        	return;
	        }

	        img_path = cast (data_buffer.data).image;
		}

		if (!sys.FileSystem.exists(img_path))
		{
			MyUtils.ShowMessage('Failed to find the image path or could not find corresponding image - $img_path');
			return;
		}

		disable();

		var img = Luxe.resources.load_texture(img_path).then(tilesheet_image_loaded);

		#else
		MyUtils.ShowMessage('Cannot open sheets for non-desktop targets :(', 'open_sheet');
		return;
		#end
	}

	function tilesheet_image_loaded(texture:phoenix.Texture)
	{
		if (texture == null) return;

		if (data_buffer != null && data_buffer.data != null)
		{
			var sheet = null;

			if (data_buffer.type == 'xml')
			{
				sheet = TileSheetAtlased.from_xml_data(texture, data_buffer.data);
			}
			else
			{
				sheet = TileSheetAtlased.from_json_data(data_buffer.data);
			}

			if (sheet != null)
			{
				var sheet_r = global.map.sheets.add(sheet);
				trace('Added new sheet "${sheet_r.name}" with index ${sheet_r.index}');
			}
			else
			{
				MyUtils.ShowMessage('Could not open data file for tilesheet :(');
			}
		}

		enable();
	}

	override function onkeyup(e:luxe.KeyEvent)
	{
    if (e.keycode == Key.lctrl || e.keycode == Key.rctrl || e.mod.rctrl || e.mod.lctrl ||
				e.keycode == Key.lmeta || e.keycode == Key.rmeta || e.mod.lmeta || e.mod.rmeta)
    {
        mod_key_timer = e.timestamp;
        zoom_mod = false;
    }

		var mod_key_delta = (e.timestamp - mod_key_timer);

		#if luxe_web
		mod_key_delta /= 1000.0;
		#end

		if (mod_key_delta < global.mod_sticky)
		{
			if (e.keycode == Key.key_x)
			{
			    reset_zoom();
			}
			else if (e.keycode == Key.key_o)
			{
				open_tilesheet();
			}
			else if (e.keycode == Key.key_s)
			{
				save_tilesheet();
			}
		}
		else
		{
			if (e.keycode == Key.tab || e.keycode == Key.escape)
			{
				disable();
				global.views.enable('EditView');
			}
			else if (MyUtils.valid_group_key(e))
			{
				var grp = Keycodes.name(e.keycode);
				var exists = current.select_group(grp);
				selector_comp.hide_indicators();

				if (exists)
				{
					selector_comp.show_indicators(current.get_group(grp));
				}
			}
		}
	}

    override function onenabled<T>(ignored:T)
    {
    	trace('enable selector');
    	display();
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable selector');
    	hide();
    } //ondisabled

    override function onmouseup(e:luxe.MouseEvent)
    {
    	if (e.button == MouseButton.middle)
    	{
    		dragging = false;
    	}
    }

    override function onmousedown(e:luxe.MouseEvent)
    {
    	if (e.button == MouseButton.middle)
    	{
    		dragging = true;
    	}
    }

    override function onkeydown(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.lctrl || e.keycode == Key.rctrl ||
				  e.keycode == Key.lmeta || e.keycode == Key.rmeta)
    	{
    		zoom_mod = true;
    	}
    }

    override function onmousewheel(e:luxe.MouseEvent)
    {
    	var dir = MyUtils.sgn(e.y);

    	if (zoom_mod)
    	{
			batcher.view.zoom += 0.1 * -dir;
			return;
		}

		var new_sheet = global.map.sheets.set_sheet_ofs(dir);

		if (new_sheet != current) refresh_selector();
    }

    override function onmousemove(e:luxe.MouseEvent)
    {
    	if (dragging)
    	{
    		var d = 1.0;
    		var z = batcher.view.zoom;

    		if (z < 1.0)
    		{
    			z  = (1.0 - z);
    			z *= 5.0;
    		}

    		batcher.view.pos.add(new Vector(-e.xrel * z, -e.yrel * z));
    	}
    	else if (tooltip != null)
    	{
    		update_tooltip();
    	}
    }
}
