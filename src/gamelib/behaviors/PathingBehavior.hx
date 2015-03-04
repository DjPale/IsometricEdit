package gamelib.behaviors;

import luxe.Component;
import luxe.Vector;
import luxe.Rectangle;
import luxe.Sprite;

import gamelib.Graph;

using gamelib.RectangleUtils;

typedef PathingTarget = {
	sprite: Sprite,
	node: GraphNode,
	pos: Vector,
	source: GraphNode,
	direction: String
}

class PathingBehavior extends Component
{
	var graph : Graph;

	var target : PathingTarget;

	var moving : Bool;

	var speed : Float = 10.0;

	var deg_to_dir = ['S','SW','W','NW','N','NE','E','SE'];

	var spr : Sprite;

	public function new(_graph:Graph, ?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		graph = _graph;
	}

	public override function init()
	{
		spr = cast entity;
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

		target = { node: sp, pos: sp.rect.mid(), source: null, direction: '', sprite: null };

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

	var loop_cnt = 0;
	function move_towards(tgt_pos:Vector, step:Float)
	{
		if (tgt_pos == null) return;

		var d = tgt_pos.clone().subtract(pos);

		if (d.length < 10)
		{
			step *= (d.length / 10);
		}

		d.normalize();
		d.multiplyScalar(step);

		pos.add(d);

		if (loop_cnt++ % 60 == 0) entity.events.fire('PathingBehavior.Move', spr);
	}

	function check_dest(node:GraphNode, source:GraphNode)
	{
		if (node == null) return;

		if (node.rect.point_inside(pos))
		{
			var edges = graph.get_edges_for_node(node);

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

				var d = ep.rect.mid().subtract(pos);
				d.normalize();
				var a = luxe.utils.Maths.degrees(d.angle2D) + 180; 
				a = (a + 90) % 360;
				a = Math.round(a / 45) % 8;

				target = { node: ep, pos: ep.rect.mid(), source: node, direction: deg_to_dir[Std.int(a)], sprite: spr };

				entity.events.fire('PathingBehavior.Direction', target);
			}
			else
			{
				moving = false;
				target = null;

				trace('help! at empty node. nowhere to go!');
			}
		}
	}

	public override function update(dt:Float)
	{
		if (target == null) return;

		check_dest(target.node, target.source);	

		if (!moving || target == null) return;

		move_towards(target.pos, dt * speed);
	}
}