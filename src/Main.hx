import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.States;
import luxe.Rectangle;
import luxe.Text;

import luxe.Log.log;
import luxe.Log._debug;

import phoenix.Texture;
import phoenix.Batcher;

typedef GlobalData = {
    sheet: TileSheetAtlased,
    views : States,
    status: StatusTextBehavior,
    ui : Batcher
}

typedef SelectEvent = {
    index: Int,
    group: String
}

class Main extends luxe.Game 
{
    var global_data : GlobalData = { sheet: new TileSheetAtlased(), views: null, status: null, ui: null };
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
        global_data.sheet.atlas = new Array<Rectangle>();

        var xml = Xml.parse(Luxe.loadText('assets/tiles.xml').text);
        var fast = new haxe.xml.Fast(xml.firstElement());

        for (st in fast.nodes.SubTexture)
        {
            global_data.sheet.atlas.push(new Rectangle(Std.parseFloat(st.att.x), Std.parseFloat(st.att.y), 
                            Std.parseFloat(st.att.width), Std.parseFloat(st.att.height)));
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

        var ui = Luxe.renderer.create_batcher({ 
            name: 'ui',
            layer: 2
            });

        global_data.ui = ui;

        var status = new Text({
            name: 'status',
            batcher: ui,
            text: 'IsometricEdit',
            point_size: 16,
            pos: new luxe.Vector(10, 10),
            outline: 1.0,
            outline_color: new luxe.Color(0, 0, 0, 1),
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone(),
            });

        global_data.status = status.add(new StatusTextBehavior());

        views.add(new EditView(global_data, Luxe.renderer.batcher));
        views.add(new SelectorView(global_data, b));

        views.set('EditView');
    }

    override function update(dt:Float) 
    {
    } //update
    
} //Main
