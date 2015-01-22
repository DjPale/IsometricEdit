import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.States;
import luxe.Rectangle;

import luxe.Log.log;
import luxe.Log._debug;

import phoenix.Texture;

typedef GlobalData = {
    sheet: TileSheetAtlased,
    views : States
}

typedef SelectEvent = {
    index: Int
}

class Main extends luxe.Game 
{
    var global_data : GlobalData = { sheet: new TileSheetAtlased(), views: null };
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
        views.add(new EditView(global_data));
        views.add(new SelectorView(global_data));

        views.set('EditView');
        views.enable('SelectorView');
    }

    override function update(dt:Float) 
    {
    } //update
    
} //Main
