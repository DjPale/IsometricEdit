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
    font: BitmapFont
}

typedef SelectEvent = {
    tilesheet: Int,
    index: Int,
    group: String
}

class Main extends luxe.Game 
{
    var global_data : GlobalData = { map: null, views: null, status: null, ui: null, font: null };
    var views : States;

    override function ready()
    {
        views = new States({ name: 'views' });

        global_data.views = views;

        var json_asset = Luxe.loadJSON('assets/parcel.json');

        var preload = new Parcel();
        preload.from_json(json_asset.json);

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
        global_data.font = Luxe.resources.find_font('assets/fonts/ubuntu-mono.fnt');

        // Add default sheet
        var sheet_tex = Luxe.loadTexture('assets/tiles.png');
        var sheet = TileSheetAtlased.from_xml_data(sheet_tex, Luxe.loadText('assets/tiles.xml').text);
        global_data.map.sheets.add(sheet);

        sheet_tex = Luxe.loadTexture('assets/tiles2.png');
        sheet = TileSheetAtlased.from_xml_data(sheet_tex, Luxe.loadText('assets/tiles2.xml').text);
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
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone(),
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
