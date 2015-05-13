import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.States;
import luxe.Rectangle;
import luxe.Text;

import luxe.Log.log;
import luxe.Log._debug;

import phoenix.Texture;
import phoenix.Batcher;
import phoenix.BitmapFont;

import gamelib.IsometricMap;
import gamelib.TileSheetAtlased;
import gamelib.MyUtils;

import editor.behaviors.StatusTextBehavior;
import editor.views.EditView;
import editor.views.SelectorView;
import editor.views.PathEditView;
import editor.views.TestView;

typedef GlobalData = {
    map : IsometricMap,
    views : States,
    status: StatusTextBehavior,
    ui : Batcher,
    font: BitmapFont,
    mod_sticky: Float
}

typedef SelectEvent = {
    tilesheet: Int,
    index: Int,
    group: String
}

class Main extends luxe.Game 
{
    var global_data : GlobalData = { map: null, views: null, status: null, ui: null, font: null, mod_sticky: 0.2 };
    var views : States;

    override function config(config:luxe.AppConfig) : luxe.AppConfig
    {
        config.window.title = 'Isometric Edit';
        config.window.width = 960;
        config.window.height = 600;
        config.window.resizable = false;

        config.preload.jsons.push({id: 'assets/parcel.json'});

        Texture.default_filter = FilterType.nearest;

        #if desktop
        var args = Sys.args();
        if (args != null && args.length > 0)
        {
            if (args[0].toLowerCase() == 'linear')
            {
                Texture.default_filter = FilterType.linear;
            }
        }
        #end

        return config;
    }

    override function ready()
    {
        views = new States({ name: 'views' });

        global_data.views = views;

        var preload = new Parcel();
        preload.from_json(Luxe.resources.json('assets/parcel.json').asset.json);

        new ParcelProgress({
            parcel: preload,
            background: new luxe.Color(1, 1, 1, 0.85),
            oncomplete: stage2
            });

        preload.load();
    } //ready

    function stage2(_)
    {
        global_data.map = new IsometricMap();
        global_data.font = Luxe.resources.font('assets/fonts/ubuntu-mono.fnt');

        // Add default sheets
        var sheet = TileSheetAtlased.from_json_data(cast Luxe.resources.json('assets/kenney/landscapeTiles_sheet.json').asset.json);
        global_data.map.sheets.add(sheet);

        sheet = TileSheetAtlased.from_json_data(cast Luxe.resources.json('assets/kenney/cityTiles_sheet.json').asset.json);
        global_data.map.sheets.add(sheet);

        sheet = TileSheetAtlased.from_json_data(cast Luxe.resources.json('assets/kenney/buildingTiles_sheet.json').asset.json);
        global_data.map.sheets.add(sheet);

        setup();
    }

    function setup()
    {
        var default_batcher = Luxe.renderer.batcher;

        var graph_batcher = Luxe.renderer.create_batcher({
            name: 'graph',
            layer: 1
            });

        var selector_cam = new luxe.Camera({camera_name: 'selector_cam'});
        var selector_batcher = Luxe.renderer.create_batcher({
            name: 'selector',
            camera: selector_cam.view,
            layer: 2
            });

        var pathedit_batcher = Luxe.renderer.create_batcher({
            name: 'detail',
            layer: 3
            });

        var ui_batcher = Luxe.renderer.create_batcher({ 
            name: 'ui',
            layer: 4
            });

        global_data.ui = ui_batcher;

        var status = new Text({
            name: 'status',
            batcher: ui_batcher,
            text: 'IsometricEdit',
            point_size: 24,
            pos: new luxe.Vector(10, 10),
            sdf: true,
            outline: 0.8,
            outline_color: new luxe.Color(0, 0, 0, 1),
            font: global_data.font,
            shader: MyUtils.font_shader()
            });

        global_data.status = status.add(new StatusTextBehavior());

        views.add(new EditView(global_data, default_batcher, graph_batcher));
        views.add(new TestView(global_data, graph_batcher));
        views.add(new SelectorView(global_data, selector_batcher));
        views.add(new PathEditView(global_data, pathedit_batcher));

        views.set('EditView');//, Luxe.resources.find_json('assets/tests/test1.json').json);
    }

    override function update(dt:Float) 
    {
    } //update
    
} //Main
