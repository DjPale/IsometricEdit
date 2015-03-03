package gamelib.behaviors;

import luxe.Component;
import luxe.Vector;
import luxe.Rectangle;

import gamelib.Graph;

using gamelib.RectangleUtils;

typedef PathingTarget = {
	node: GraphNode,
	pos: Vector,
	source: GraphNode
}

class PathingBehavior extends Component
{
	var graph : Graph;

	var target : PathingTarget;

	var moving : Bool;

	var speed : Float = 10.0;

	public function new(_graph:Graph, ?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		graph = _graph;
	}

	public function set_graph(_graph:Graph)
	{
		graph = _graph;
		//TODO: hmmm.. we might need to reset something here
	}

	public function set_speed(s:Float)
	{
		speed = s;
	}

	public function start_random_patrol(sp:GraphNode)
	{
		if (sp == null) return;

		target = { node: sp, pos: sp.rect.mid(), source: null };

		moving = true;

		trace('start random patrol -> ${target.pos}');
	}

	public function stop()
	{
		moving = false;
	}

	public function resume()
	{
		moving = true;
	}

	function move_towards(tgt_pos:Vector, step:Float) : Float
	{
		if (tgt_pos == null) return 0;

		var d = tgt_pos.clone().subtract(pos);
		d.normalize();
		d.multiplyScalar(step);

		pos.add(d);

		var a = luxe.utils.Maths.degrees(d.angle2D) + 180;

		return a;
	}

	function check_dest(node:GraphNode, source:GraphNode)
	{
		if (node == null) return;

		if (node.rect.point_inside(pos))
		{
			var edges = graph.get_edges_for_node(node);

			//trace(edges);

			if (edges != null)
			{
				var rem_idx = null;

				// if more than one edge, remove the one we are coming from
				if (edges.length > 1 && source != null)
				{

					for (e in edges)
					{
						if (e.p0 == source || e.p1 == source)
						{
							rem_idx = e;
							break;
						}
					}
				}

				if (rem_idx != null)
				{
					edges.remove(rem_idx);
				}

				var idx = Luxe.utils.random.int(0, edges.length);
				var edge = edges[idx];
				var ep = graph.endpoint(node, edge);
				target = { node: ep, pos: ep.rect.mid(), source: node };

				trace('reached destination, new target -> ${target.pos}');

			}
			else
			{
				moving = false;
				target = null;

				trace('help! at empty node. nowhere to go!');
			}
		}
	}

	var loop_cnt : Int = 0;

	public override function update(dt:Float)
	{
		if (target == null) return;

		check_dest(target.node, target.source);	

		if (!moving || target == null) return;

		var a = move_towards(target.pos, dt * speed);

		loop_cnt++;
		if (loop_cnt % 120 == 0) trace('angle = ' + Math.round(loop_cnt));
	}
}