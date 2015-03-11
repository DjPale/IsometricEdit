package editor.views;

import luxe.States;
import luxe.Vector;
import luxe.Sprite;
import luxe.Input;

import phoenix.Batcher;

import Main;
import gamelib.Graph;
import gamelib.TileSheetAtlased;
import gamelib.TileSheetCollection;
import gamelib.MyUtils;

typedef PathEditViewParams = {
    index: TileIndex,
    previous: String
}

class PathEditView extends State
{
	var global : GlobalData;
	var batcher : Batcher;

    var tileindex : TileIndex;
	var tiledata : TileData;
	var tile : Sprite;
    var pos_rect : phoenix.geometry.Geometry;
	var graph : Graph;

	var cur:GraphEdge = null;
    var drag : GraphNode = null;

    var zoom_mod = false;

    var offset : Vector;

    var previous : String = 'EditView';

    var mod_key_timer : Float;

	var MINSIZE:Float = 5;
	var SIZE:Float = 10;
	var MAXSIZE:Float = 20;

	public function new(_global:GlobalData, _batcher:Batcher)
	{
		super({ name: 'PathEditView' });

		global = _global;
		batcher = _batcher;
	}

	function display(index:TileIndex)
	{
        var sheet = global.map.sheets.get_sheet(index.tilesheet);

		tiledata = sheet.atlas[index.tile];

		var r = tiledata.rect;

		offset = new Vector(Luxe.screen.w / 2 - r.w / 2, Luxe.screen.h / 2 - r.h / 2);

		tile = new Sprite({
			name: 'path_sprite',
			texture: sheet.image,
			batcher: batcher,
			depth: 10,
			uv: r,
			centered: false,
			size: new Vector(r.w, r.h),
			pos: offset.clone(),
            origin: tiledata.offset.clone()
			});

        pos_rect = Luxe.draw.rectangle({
            batcher: batcher,
            x: offset.x,
            y: offset.y,
            w: r.w,
            h: r.h,
            depth: 9
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

        tileindex = index;

        reset_zoom();

		global.status.set_tile(index);
	}

    function reset_zoom()
    {
        batcher.view.zoom = 2.0;
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
            tiledata.offset = tile.origin.clone();
			tile.destroy();
		}

        if (pos_rect != null)
        {
            pos_rect.drop(true);
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

    function adjust_origin(pos:Vector)
    {
        tile.origin.add(pos);
        tile.pos = tile.pos.clone();

        tiledata.offset = tile.origin.clone();
        global.map.refresh_positions(tileindex);
    }

    function reset_origin()
    {
        reset_zoom();

        tile.origin = new Vector();
        tile.pos = tile.pos.clone();

        tiledata.offset = new Vector();
        global.map.refresh_positions(tileindex);
    }

    override function onmouseup(e:luxe.MouseEvent)
    {
    	var mp = batcher.view.screen_point_to_world(e.pos);

   		drag_end_action(mp);

        if (zoom_mod)
        {
            return;
        }

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
    	if (zoom_mod && e.button == MouseButton.left)
    	{
            var mp = batcher.view.screen_point_to_world(e.pos);
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

        if (mod_key_delta < global.mod_sticky)
        {
            if (e.keycode == Key.key_d)
            {
                return_prev();
            }
            else if (e.keycode == Key.key_x)
            {
                reset_origin();
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
        }
        else if (e.keycode == Key.tab || e.keycode == Key.escape)
		{
            return_prev();
		}
	}

	function return_prev()
	{
        disable();
        Luxe.timer.schedule(0.1, function() { global.views.enable(previous); });
	}

    override function onenabled<T>(params:T)
    {
        var p : PathEditViewParams = cast params;

    	trace('enable path edit with idx=${p.index}');
        previous = p.previous;
    	display(p.index);
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	hide();
    	trace('disable path edit');
    } //ondisabled  
}