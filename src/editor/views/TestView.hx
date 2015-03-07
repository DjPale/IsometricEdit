package editor.views;

import luxe.States;
import luxe.Vector;
import luxe.Scene;
import luxe.Sprite;
import luxe.Input;
import luxe.tween.Actuate;

import gamelib.IsometricMap;
import gamelib.behaviors.PathingBehavior;

import Main;

using gamelib.RectangleUtils;

class TestView extends State 
{
	var car_scene : Scene = new Scene('car_scene');

	var batcher : phoenix.Batcher;

	var global : GlobalData;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;
	}

	override function onenabled<T>(map:T)
    {
    	trace('enable test');
    	display(cast map);
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable test');
    	hide();
    } //ondisabled

	override function onkeyup(e:luxe.KeyEvent)
	{
		if (e.keycode == Key.space || e.keycode == Key.escape)
		{
			disable();
			Luxe.timer.schedule(0.1, return_prev);
		}
	}

	function return_prev()
	{
		global.views.enable('EditView');
	}

    function hide()
    {
    	car_scene.empty();
    	global.ui.enabled = true;
    }

    function display(map:IsometricMap)
    {
    	global.ui.enabled = false;

    	for (i in 0...10)
        {
            var target = map.graph.get_random_node();

            if (target != null)
            {
                var car = new Sprite({
                    name: 'car',
                    name_unique: true,
                    batcher: batcher,
                    centered: true,
                    scene: car_scene
                    });

                var ofs = new Vector(map.base_width * 0.5, map.base_height * 1.5);

                car.events.listen('PathingBehavior.Direction', 
                    function(tgt:PathingTarget) 
                    {
                        var spr = tgt.sprite;
                        spr.texture = Luxe.loadTexture('assets/tests/ambulance_${tgt.direction}.png');
                        spr.size = new Vector(spr.texture.width, spr.texture.height);
                    });

                // car.events.listen('PathingBehavior.Move',
                //     function(spr:Sprite)
                //     {
                //         var pos = spr.pos.clone().add(ofs);
                        
                //         var tile = map.get_tile_world(pos);
                //         if (tile != null)
                //         {
                //             //tile.color = new luxe.Color(1.0, 1.0, 1.0, 0.5);
                //             spr.depth = tile.depth + 0.1;
                //         }
                //     });

                var test_car = car.add(new PathingBehavior(map.graph));

                var speed = 50 + Luxe.utils.random.float(-25, 25);
                test_car.set_speed(speed);

                //Actuate.tween(car.scale, 1.0 - (speed / 100), { y: 1.5 } ).repeat().reflect().ease(luxe.tween.easing.Sine.easeIn);

                test_car.pos = target.rect.mid();
                test_car.start_random_patrol(target);
            }
        }
    }
}