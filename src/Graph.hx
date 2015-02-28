import luxe.Vector;
import luxe.Rectangle;

import phoenix.Batcher;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;

using RectangleUtils;

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

typedef GraphSerialize = {
	nodes: Array<GraphNodeSerialize>,
	edges: Array<GraphEdgeSerialize>,
	depth: Float
};

typedef GraphNodeSerialize = {
	rect: Array<Float>
	};

typedef GraphEdgeSerialize = {
	p0: Int,
	p1: Int
	};

class Graph
{
	var nodes : Array<GraphNode>;
	var edges : Array<GraphEdge>;

	var batcher : Batcher = null;
	var depth : Float = 0;

	public function new(?_batcher:Batcher = null, ?_depth:Float = 0)
	{
		batcher = _batcher;
		depth = _depth;

		nodes = new Array<GraphNode>();
		edges = new Array<GraphEdge>();
	}

	public function clear()
	{
		while (edges.length > 0)
		{
			delete_edge(edges.pop());
		}

		while (nodes.length > 0)
		{
			delete_node(nodes.pop());
		}
	}

	public function destroy()
	{
		clear();

		batcher = null;
		edges = null;
		nodes = null;
	}

	public inline function is_empty() : Bool
	{
		return (nodes.length == 0 && edges.length == 0);
	}

	public function to_json_data() : GraphSerialize
	{
		var t_nodes = new Array<GraphNodeSerialize>();

		for (n in nodes)
		{
			t_nodes.push({ rect: n.rect.to_array() });
		}

		var t_edges = new Array<GraphEdgeSerialize>();

		for (e in edges)
		{
			t_edges.push({ p0: nodes.indexOf(e.p0), p1: nodes.indexOf(e.p1) });
		}

		return { nodes: t_nodes, edges: t_edges, depth: depth };
	}

	public static function from_json_data(data:GraphSerialize) : Graph
	{
		if (data == null) return null;

		var g = new Graph();

		g.depth = data.depth;

		// WARNING! No error checking and lazy coding follows - don't do this at home!
		for (n in data.nodes)
		{
			g.nodes.push({
				rect: RectangleUtils.from_array(n.rect),
				size: n.rect[3],
				g: null
				});
		}

		for (e in data.edges)
		{
			g.edges.push({
				p0: g.nodes[e.p0],
				p1: g.nodes[e.p1],
				l: null
				});
		}

		return g;
	}

	// TODO: add radius or other limiter to improve performance
	// When we add tiles, we only need to search for overlaps around the new tile
	/*
		-> Proposed algorithm
		- Params: Global graph G + local graph L
		- Add everything from L to G
	 	- Check for overlap between vertices for G and L
	 	- Create list of overlapping nodes in G (Go)
	 	- For each overlap in Go
	 		- If intersection between Go.p0 to Lo.p1 in overlap
	 			- Change edge endpoints
	 		- Else add to node remove list
		- Add each node with no edges to remove list
		- For each node in remove list
			- Remove node
	*/
	public function merge(other:Graph, ?pos:Vector = null)
	{
		if (other == null || other.is_empty()) return;

		var old_len = nodes.length;

		var ofs = pos;
		if (ofs == null) ofs = new Vector();

		for (other_n in other.nodes)
		{
			new_node(other_n.rect.mid().add(ofs), other_n.size);
		}

		for (other_e in other.edges)
		{
			var p0_idx = other.nodes.indexOf(other_e.p0);
			var p1_idx = other.nodes.indexOf(other_e.p1);

			new_edge(nodes[old_len + p0_idx], nodes[old_len + p1_idx]);
		}

		var remove : Array<GraphNode> = [];

		for (i in 0...old_len)
		{
			for (n in old_len...nodes.length)
			{
				var node_g = nodes[i];
				var node_l = nodes[n];

				if (node_g.rect.overlaps(node_l.rect))
				{
					remove.push(node_l);

					var e_g_list = get_edges_for_node(node_g);
					var e_l_list = get_edges_for_node(node_l);

					if (e_g_list == null || e_l_list == null)
					{
						trace('NB! one of the edge lists was null - should not happen! .. or maybe if you have dangling nodes :P');
						break;
					}

					for (edge_g in e_g_list)
					{
						var p0 = edge_g.p0;
						if (edge_g.p0 == node_g) p0 = edge_g.p1;

						for (edge_l in e_l_list)
						{
							var p1 = edge_l.p0;
							if (edge_l.p0 == node_l) p1 = edge_l.p1;

							if (node_g.rect.intersects_line(p0.rect.mid(), p1.rect.mid()))
							{
								new_edge(p0, p1);
								remove.push(node_g);
							}
						}
					}
				}
			}
		}

		for (r in remove)
		{
			delete_node(r);
		}
	}

	public function offset(x:Float, y:Float)
	{
		for (n in nodes)
		{
			n.rect.x += x;
			n.rect.y += y;

			if (n.g != null)
			{
				n.g.set({ rect: n.rect });
			}
		}

		for (e in edges)
		{
			if (e.l != null)
			{
				var v = new Vector(x, y);
				e.l.p0.add(v);
				e.l.p1.add(v);
			}
		}
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
						p0: e.p0.rect.mid(),
						p1: e.p1.rect.mid(),
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

	public function get_edges_for_node(n:GraphNode) : Array<GraphEdge>
	{
		var ret = null;

		for (e in edges)
		{
			if (e.p0 == n || e.p1 == n)
			{
				if (ret == null) ret = new Array<GraphEdge>();

				ret.push(e);
			}
		}

		return ret;
	}

	public function new_node(pos:Vector, _size:Float) : GraphNode
	{
	    var size = _size;
	    var rect = RectangleUtils.create_mid_square(pos, size);

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

	public function new_edge_and_node(node:GraphNode, _size:Float) : GraphEdge
	{
		var pos = node.rect.mid();
		var n_node = new_node(pos, _size);

		return new_edge(node, n_node);
	}

	public function new_edge(p0:GraphNode, p1:GraphNode) : GraphEdge
	{
		var line = null;

		if (batcher != null)
		{
			line = Luxe.draw.line({
				p0: p0.rect.mid(),
				p1: p1.rect.mid(),
				depth: depth,
				batcher: batcher,
				});
		}

		var edge = { l: line, p0: p0, p1: p1 };

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

    		if (v.g != null) v.g.set({ rect: v.rect });

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