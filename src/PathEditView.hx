import luxe.States;
import luxe.Vector;
import luxe.Sprite;
import luxe.Input;

import phoenix.Batcher;

import Main;
import Graph;
import TileSheetAtlased;

class PathEditView extends State
{
	var global : GlobalData;
	var batcher : Batcher;

	var tiledata : TileData;
	var tile : Sprite;
	var graph : Graph;

	var cur:GraphEdge = null;
    var drag : GraphNode = null;

    var zoom_mod = false;

    var offset : Vector;

	var MINSIZE:Float = 10;
	var SIZE:Float = 20;
	var MAXSIZE:Float = 30;

	public function new(_global:GlobalData, _batcher:Batcher)
	{
		super({ name: 'PathEditView' });

		global = _global;
		batcher = _batcher;
	}

	function display(idx:Int)
	{
		tiledata = global.sheet.atlas[idx];

		var r = tiledata.rect;

		offset = new Vector(Luxe.screen.w / 2 - r.w / 2, Luxe.screen.h / 2 - r.h / 2);

		tile = new Sprite({
			name: 'path_sprite',
			texture: global.sheet.image,
			batcher: batcher,
			depth: 10,
			uv: r,
			centered: false,
			size: new Vector(r.w, r.h),
			pos: offset.clone()
			});

		graph = tiledata.graph;

		if (graph != null)
		{
			graph.offset(offset.x, offset.y);
			graph.display(batcher);
		}
		else
		{
			graph = tiledata.graph = new Graph(batcher, tile.depth + 1);
		}

		batcher.view.zoom = 2.0;

		global.status.set_tile(idx);
	}

	function hide()
	{
		if (graph != null)
		{
			graph.display(null);
			graph.offset(-offset.x, -offset.y);
			if (graph.is_empty())
			{
				graph = tiledata.graph = null;
			}
		}

		if (tile != null)
		{
			tile.destroy();
		}
	}

	/*
		- leftclick to place node
		- leftclick on node to create edge
			- leftclick to connect
		- right click on node to delete (implicitly deletes connected edges)
		- right click on edge deletes edge

		- mousewheel to adjust size of node (for connection)

		- ctrl-p create standard nodes (deletes old nodes)
		- ctrl-a and q raise and lower depth of node under cursor..
		- ctrl-z for undo?

	*/
    function cancel_edge(edge:GraphEdge)
    {
    	if (edge == null)
    	{
    		return;
    	}

    	//delete_edge(edge);
    	graph.delete_node(edge.p1);

    	cur = null;
    }

    function decide_node_action(pos:Vector)
    {
    	var n = graph.get_node(pos);

    	// check to see if we are touching another
    	if (n != null && cur != null && n != cur.p1)
    	{
    		var del = cur.p1;
    		cur.p1 = n;
    		graph.delete_node(del);
    		cur = null;
    		return;
    	}

    	// TODO: check if we need to split a line segment

    	if (n != null)
    	{
    		cur = graph.new_edge_and_node(n, SIZE);
    		return;
    	}

    	if (cur == null)
    	{
    		var node = graph.new_node(pos, SIZE);
    		cur = graph.new_edge_and_node(node, SIZE);
    		return;
    	}

    	cur = graph.new_edge_and_node(cur.p1, SIZE);
    }

    function decide_move_action(pos:Vector)
    {
    	if (drag != null)
    	{
    		graph.refresh_node(drag, pos);
    		return;
    	}

    	if (cur == null)
    	{
    		return;
    	}

    	graph.refresh_node(cur.p1, pos); 
    }

    function drag_end_action(pos:Vector)
    {
    	drag = null;
    }

    function decide_node_size_action(pos:Vector, size:Float)
    {
    	var n : GraphNode = null;

    	if (cur != null)
    	{
    		n = cur.p1;
    	}
    	else
    	{
    		n = graph.get_node(pos);

    		if (n == null)
    		{
    			return;
    		}
    	}

    	n.size += size;

    	if (n.size < MINSIZE) n.size = MINSIZE;
    	if (n.size > MAXSIZE) n.size = MAXSIZE;

    	SIZE = n.size;

    	graph.refresh_node(n, pos);
    }

    function decide_delete_action(pos:Vector)
    {
    	if (cur != null)
    	{
    		cancel_edge(cur);
    		cur = null;
    		return;
    	}

    	var n = graph.get_node(pos);

    	if (n != null)
    	{
	    	graph.delete_node(n);
    		return;
    	}
    }

    function decide_drag_start_action(pos:Vector)
    {
    	var n = graph.get_node(pos);

    	if (n != null)
    	{
    		drag = n;
    	}
    }

    override function onmouseup(e:luxe.MouseEvent)
    {
    	var mp = batcher.view.screen_point_to_world(e.pos);

   		drag_end_action(mp);

    	if (e.button == MouseButton.left)
    	{
    		decide_node_action(mp);
    	}
    	else if (e.button == MouseButton.right)
    	{	
    		decide_delete_action(mp);
    	}
    }

    override function onmousedown(e:luxe.MouseEvent)
    {
    	var mp = batcher.view.screen_point_to_world(e.pos);

    	if (e.button == MouseButton.middle)
    	{
    		decide_drag_start_action(mp);
    	}
    }

    override function onmousewheel(e:luxe.MouseEvent)
    {
    	if (zoom_mod)
    	{
    		batcher.view.zoom += 0.15 * -MyUtils.sgn(e.y);
    		return;
    	}

    	var mp = batcher.view.screen_point_to_world(e.pos);

    	decide_node_size_action(mp, MyUtils.sgn(e.yrel));
    }

    override function onmousemove(e:luxe.MouseEvent)
    {
    	var mp = batcher.view.screen_point_to_world(e.pos);

    	var tilePos = mp.clone();
    	tilePos.subtract(offset);

    	global.status.set_postxt('World:(${Math.fround(mp.x)},${Math.fround(mp.y)}) - Tile:(${Math.fround(tilePos.x)},${Math.fround(tilePos.y)})');

    	decide_move_action(mp);
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
		zoom_mod = false;

		if (e.keycode == Key.space || e.keycode == Key.escape)
		{
			disable();
			Luxe.timer.schedule(0.1, return_prev);
		}
	}

	function return_prev()
	{
		global.views.enable('SelectorView');
	}

    override function onenabled<T>(tile:T)
    {
    	trace('enable path edit with id=$tile');
    	display(cast tile);
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	hide();
    	trace('disable path edit');
    } //ondisabled  
}