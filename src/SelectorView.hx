import luxe.States;
import luxe.Sprite;
import luxe.Entity;
import luxe.Vector;
import luxe.Camera;
import luxe.Input;

import phoenix.Batcher;

import Main;

class SelectorView extends State
{
	var global : GlobalData;

	var selector : Sprite;
	var selector_comp : TileSelectorBehavior;

	var tooltip : TileTooltipBehavior;

	var batcher : Batcher;

	var dragging : Bool;

	var event_id_assign : String = '';
	var event_id_detail : String = '';

	public function new(global_data:GlobalData, _batcher:Batcher)
	{
		super({ name: 'SelectorView' });

		global = global_data;

		batcher = _batcher;

		batcher.view.zoom = 0.3;
		batcher.view.pos.x = -1050;
		batcher.view.pos.y = 720;
	}

	function display()
	{
		var img = global.sheet.image;

		selector = new Sprite({
			name: 'selector',
			texture: img,
			centered: false,
			batcher: batcher,
			});

		//selector.pos = new Vector(Luxe.screen.w - selector.size.x, Luxe.screen.h / 2 - selector.size.y / 2);

		selector_comp = new TileSelectorBehavior(global.sheet, batcher);
		selector.add(selector_comp);

		var tooltip_spr = new Entity({
			name: 'selector_tt'
			});

		tooltip = tooltip_spr.add(new TileTooltipBehavior(global.ui, global.font));

		event_id_assign = Luxe.events.listen('assign', group_assign);
		event_id_detail = Luxe.events.listen('detail', path_edit);
	}

	function group_assign(e:SelectEvent)
	{
		if (e != null && e.group != null && e.index >= 0)
		{
			var ret = global.sheet.add_idx_to_group(e.group, e.index, true);
			trace('add to group = $ret');

			selector_comp.hide_indicators();
			selector_comp.show_indicators(global.sheet.get_group(e.group));

			update_tooltip();
		}
	}

	function path_edit(e:SelectEvent)
	{
		disable();
		global.views.enable('PathEditView', e.index);
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

	function update_tooltip()
	{
	    var mouse = Luxe.screen.cursor.pos;
		var pos = batcher.view.screen_point_to_world(mouse);
		var idx = global.sheet.get_tile_idx(pos);

		if (idx >= 0)
		{
			var r = global.sheet.atlas[idx].rect;

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

			tooltip.set_new_tile(global.sheet.image, r);
			tooltip.entity.pos = new Vector(mouse.x + ofsX, mouse.y + ofsY);

			var a = global.sheet.get_groups_for_idx(idx);

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

	override function onkeyup(e:luxe.KeyEvent)
	{
		if (e.keycode == Key.space || e.keycode == Key.escape)
		{
			disable();
			global.views.enable('EditView');
		}
		else if (MyUtils.valid_group_key(e.keycode))
		{
			var grp = snow.input.Keycodes.Keycodes.name(e.keycode);
			var exists = global.sheet.select_group(grp);
			selector_comp.hide_indicators();

			if (exists)
			{
				selector_comp.show_indicators(global.sheet.get_group(grp));
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

    override function onmousewheel(e:luxe.MouseEvent)
    {
		batcher.view.zoom += 0.1 * -MyUtils.sgn(e.y);  	
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