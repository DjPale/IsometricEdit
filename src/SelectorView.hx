import luxe.States;
import luxe.Sprite;
import luxe.Vector;
import luxe.Camera;
import luxe.Input;

import phoenix.Batcher;

import Main;

class SelectorView extends State
{
	var glob : GlobalData;

	var selector : Sprite;

	var batcher : Batcher;

	var dragging : Bool;

	public function new(global_data:GlobalData, _batcher:Batcher)
	{
		super({ name: 'SelectorView' });

		glob = global_data;

		batcher = _batcher;

		batcher.view.zoom = 0.3;
		batcher.view.pos.x = -1050;
		batcher.view.pos.y = 720;
	}

	function display()
	{
		var img = glob.sheet.image;

		selector = new Sprite({
			name: 'selector',
			texture: img,
			centered: false,
			batcher: batcher,
			});

		//selector.pos = new Vector(Luxe.screen.w - selector.size.x, Luxe.screen.h / 2 - selector.size.y / 2);

		var selector_comp = new TileSelectorBehavior(glob.sheet, batcher.view);
		selector.add(selector_comp);
	}

	function hide()
	{
		if (selector != null)
		{
			selector.destroy();
			selector = null;			
		}
	}

	override function onkeyup(e:luxe.KeyEvent)
	{
		if (e.keycode == Key.space || e.keycode == Key.escape)
		{
			disable();
			glob.views.enable('EditView');
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
    }
}