import luxe.States;
import luxe.Vector;
import luxe.Sprite;
import luxe.Input;
import luxe.Rectangle;

import phoenix.Batcher;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;

import Main;

typedef Vertex = {
	g: RectangleGeometry,
	rect: Rectangle,
	size: Float
};

class PathEditView extends State
{
	var global : GlobalData;
	var batcher : Batcher;

	var tile : Sprite;
	var vertices : Array<Vertex>;

	public function new(_global:GlobalData, _batcher:Batcher)
	{
		super({ name: 'PathEditView' });

		global = _global;
		batcher = _batcher;

		vertices = new Array<Vertex>();
	}

	function display(idx:Int)
	{
		var r = global.sheet.atlas[idx];

		tile = new Sprite({
			name: 'path_sprite',
			texture: global.sheet.image,
			batcher: batcher,
			depth: 10,
			scale: new Vector(2, 2),
			uv: r,
			size: new Vector(r.w, r.h),
			pos: new Vector(Luxe.screen.w / 2 - r.w / 2, Luxe.screen.h / 2 - r.h / 2)
			});
	}

	/*
	constraint points to tile size box
	leftclick on empty / no existing
		- start new segment
	leftclick on intersection -advanced
		- create and merge?
	leftclick on existing
		- get path id
		- drag
	rightclick when in path edit
		- stop editing
	rightclick on existing
		- delete and merge
	doubleclick in middle - advanced
		- add new node
	mousewheel
		- resize connector point

	check chain

	*/

	var cur:Vertex = null;
	var SIZE:Float = 5;

	function new_segment(mp:Vector) : Vertex
	{
		/*
		var line = null;

		if (create_line)
		{
		    line = Luxe.draw.line({
				p0: mp.clone(),
				p1: mp.clone(),
				depth: tile.depth + 0.1,
				batcher: batcher,
				});
		}
		*/

	    var size = SIZE;
	    var rect = new Rectangle(mp.x - size / 2, mp.y - size / 2, size, size);

 		var geom = Luxe.draw.rectangle({
 			x: rect.x,
 			y: rect.y,
 			w: rect.w,
 			h: rect.h,
 			depth: tile.depth + 0.1,
 			batcher: batcher,
		});

 		return { g: geom, rect: rect, size: size };
	}

	function get_vertex(mp:Vector) : Vertex
	{
		for (s in vertices)
		{
			if (s.rect.point_inside(mp))
			{
				return s;
			}	
		}

		return null;
	}

    override function onmouseup(e:luxe.MouseEvent)
    {
    	var mp = e.pos;

    	if (drag != null)
    	{
    		drag = null;
    		return;
    	}

    	if (e.button == MouseButton.left)
    	{
	    	if (cur == null)
	    	{
	    		cur = new_segment(mp);
	    		vertices.push(cur);
	    		cur = new_segment(mp );
	    	}
	    	else
	    	{
	    		vertices.push(cur);
	    		cur = new_segment(mp);
	    	}
    	}
    	else if (e.button == MouseButton.right)
    	{
    		if (cur != null)
    		{
    			delete_vertex(cur);
    			cur = null;
    		}
    		else
    		{
    			var v = get_vertex(mp);

    			if (v != null)
    			{
    				delete_vertex(v, true);
    			} 
    		}
    	}

    }

    inline function delete_vertex(v:Vertex, ?from_array:Bool = false)
    {
    	v.g.drop(true);

    	if (from_array)
    	{
    		vertices.remove(v);
    	}
    }

    var drag : Vertex = null;

    override function onmousedown(e:luxe.MouseEvent)
    {
    	var mp = e.pos;

    	if (e.button == MouseButton.left)
    	{
	    	var v = get_vertex(mp);
	    	if (v != null)
			{
				drag = v;
			}
		}
    }

    override function onmousewheel(e:luxe.MouseEvent)
    {
    	var mp = e.pos;
    	var v = null;

    	if (drag != null)
    	{
    		v = drag;
    	}
    	else if (cur != null)
    	{
    		v = cur;
    	}
    	else
    	{
    		v = get_vertex(mp);
    	}

    	if (v != null)
    	{
    	    v.size += MyUtils.sgn(e.yrel);
    		SIZE = v.size;
    		refresh_vertex(v, mp);
    	}
    }

    override function onmousemove(e:luxe.MouseEvent)
    {
    	var mp = e.pos;

    	if (drag != null)
    	{
	    	refresh_vertex(drag, mp);
    	}
    	else
    	{
	    	refresh_vertex(cur, mp);
    	}

    }

    function refresh_vertex(v:Vertex, mp:Vector)
    {
    	if (v != null)
    	{
    		v.rect.x = mp.x - v.size / 2;
    		v.rect.y = mp.y - v.size / 2;
    		v.rect.w = v.size;
    		v.rect.h = v.size;
    		v.g.set({ x: v.rect.x, y: v.rect.y, w: v.rect.w, h: v.rect.h });
    	}
    }

    override function onenabled<T>(tile:T)
    {
    	trace('enable path edit with id=$tile');
    	display(cast tile);
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable path edit');
    } //ondisabled  
}