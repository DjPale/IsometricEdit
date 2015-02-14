import luxe.Vector;
import luxe.Rectangle;

import phoenix.Batcher;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;

typedef GraphNode = {
	g: RectangleGeometry,
	rect: Rectangle,
	size: Float,
	};

typedef GraphEdge = {
	l: LineGeometry,
	p0: GraphNode,
	p1: GraphNode 
	};

class Graph
{
	var nodes : Array<GraphNode>;
	var edges : Array<GraphEdge>;

	var batcher : Batcher = null;
	var depth : Float = 0;


	inline function new_Rect(pos:Vector, size:Float)
	{
		return new Rectangle(pos.x - size / 2, pos.y - size / 2, size, size);
	}

	inline function Rect_mid(r:Rectangle) : Vector
	{
		return new Vector(r.x + r.w / 2, r.y + r.h / 2);
	}

	public function new(?_batcher:Batcher = null, ?_depth:Float = null)
	{
		batcher = _batcher;
		depth = _depth;

		nodes = new Array<GraphNode>();
		edges = new Array<GraphEdge>();
	}

	public inline function is_empty() : Bool
	{
		return (nodes.length == 0 && edges.length == 0);
	}

	public function display(_batcher:Batcher)
	{
		batcher = _batcher;

		if (batcher != null)
		{
			for (n in nodes)
			{
				if (n.g == null)
				{
					n.g = Luxe.draw.rectangle({
			 			rect: n.rect,
			 			depth: depth,
			 			batcher: batcher,
						});
				}
			}

			for (e in edges)
			{
				if (e.l == null)
				{
					e.l = Luxe.draw.line({
						p0: Rect_mid(e.p0.rect),
						p1: Rect_mid(e.p1.rect),
						depth: depth,
						batcher: batcher,
						});				
				}
			}
		}
		else
		{
			for (n in nodes)
			{
				if (n.g != null) n.g.drop(true);
				n.g = null;
			}

			for (e in edges)
			{
				if (e.l != null) e.l.drop(true);
				e.l = null;
			}
		}
	}

	public function get_node(pos:Vector) : GraphNode
	{
		for (n in nodes)
		{
			if (n.rect.point_inside(pos))
			{
				return n;
			}	
		}

		return null;
	}

	public function new_node(pos:Vector, _size:Float) : GraphNode
	{
	    var size = _size;
	    var rect = new_Rect(pos, size);

 		var geom = null;

 		if (batcher != null)
 		{
	 		geom = Luxe.draw.rectangle({
	 			rect: rect,
	 			depth: depth,
	 			batcher: batcher,
			});
 		}

		var node = { g: geom, rect: rect, size: size };

		nodes.push(node);

 		return node;
	}

	public function new_edge(node:GraphNode, _size:Float) : GraphEdge
	{
		var pos = Rect_mid(node.rect);

		var line = null;

		if (batcher != null)
		{
			line = Luxe.draw.line({
				p0: pos.clone(),
				p1: pos.clone(),
				depth: depth,
				batcher: batcher,
				});
		}

		var n_node = new_node(pos, _size);
		var edge = { l: line, p0: node, p1: n_node };

		edges.push(edge);

		return edge;
	}

	public function delete_edge(edge:GraphEdge)
    {
		edges.remove(edge);

    	if (edge.l != null) edge.l.drop(true);
    	edge.l = null;
    	edge.p0 = null;
    	edge.p1 = null;
    }

    public function delete_node(node:GraphNode)
    {
    	var del_list : Array<GraphEdge> = [];

    	for (e in edges)
    	{
    		if (e.p0 == node || e.p1 == node)
    		{
    			del_list.push(e);
    		}
    	}

    	for (e in del_list)
    	{
    		delete_edge(e);
    	}

    	nodes.remove(node);

    	if (node.g != null) node.g.drop(true);

    	node.rect = null;
    	node.g = null;
    }

	public function refresh_node(v:GraphNode, mp:Vector)
    {
    	if (batcher == null)
    	{
    		return;
    	}

    	if (v != null)
    	{
    		v.rect.x = mp.x - v.size / 2;
    		v.rect.y = mp.y - v.size / 2;
    		v.rect.w = v.size;
    		v.rect.h = v.size;

    		if (v.g != null) v.g.set({ x: v.rect.x, y: v.rect.y, w: v.rect.w, h: v.rect.h });

    		for (e in edges)
    		{
    			if (e.p0 == v)
    			{
    				e.l.p0 = mp.clone();
    			}
    			else if (e.p1 == v)
    			{
    				e.l.p1 = mp.clone();
    			}
    		}
    	}
    }


}