import luxe.States;
import luxe.Sprite;
import luxe.Vector;

import Main;

class SelectorView extends State
{
	var glob : GlobalData;

	var selector : Sprite;

	public function new(global_data:GlobalData)
	{
		super({ name: 'SelectorView' });

		glob = global_data;
	}

	function display()
	{
		var img = glob.sheet.image;

		selector = new Sprite({
			name: 'selector',
			texture: img,
			depth: 10000,
			centered: false
			});

		selector.scale = new Vector(0.25, 0.25);
		//selector.pos = new Vector(Luxe.screen.w - selector.size.x, Luxe.screen.h / 2 - selector.size.y / 2);

		var selector_comp = new TileSelectorBehavior(glob.sheet);
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
}