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

import TileSheetAtlased;

typedef GlobalData = {
    sheet: TileSheetAtlased,
    views : States,
    status: StatusTextBehavior,
    ui : Batcher,
    font: BitmapFont
}

typedef SelectEvent = {
    index: Int,
    group: String
}


class Main extends luxe.Game 
{
    var global_data : GlobalData = { sheet: new TileSheetAtlased(), views: null, status: null, ui: null, font: null };
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
        global_data.sheet.image = Luxe.loadTexture('assets/tiles.png');
        //global_data.sheet.image.filter = FilterType.nearest;
        global_data.sheet.atlas = new Array<TileData>();

        global_data.font = Luxe.resources.find_font('ubuntu-mono');
        trace(global_data.font);

        var xml = Xml.parse(Luxe.loadText('assets/tiles.xml').text);
        var fast = new haxe.xml.Fast(xml.firstElement());

        for (st in fast.nodes.SubTexture)
        {
            global_data.sheet.atlas.push({
                graph: null, 
                rect: 
                    new Rectangle(Std.parseFloat(st.att.x), Std.parseFloat(st.att.y), 
                    Std.parseFloat(st.att.width), Std.parseFloat(st.att.height)) 
                    });
        }
   
        setup();
    }

    function setup()
    {
        var c = new luxe.Camera({camera_name: 'selector_cam'});
        var b = Luxe.renderer.create_batcher({
            name: 'selector',
            camera: c.view,
            layer: 1
            });

        var detail = Luxe.renderer.create_batcher({
            name: 'detail',
            layer: 2
            });

        var ui = Luxe.renderer.create_batcher({ 
            name: 'ui',
            layer: 3
            });

        global_data.ui = ui;

        var status = new Text({
            name: 'status',
            batcher: ui,
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

        views.add(new EditView(global_data, Luxe.renderer.batcher));
        views.add(new SelectorView(global_data, b));
        views.add(new PathEditView(global_data, detail));

        views.set('EditView');
    }

    override function update(dt:Float) 
    {
    } //update
    
} //Main
