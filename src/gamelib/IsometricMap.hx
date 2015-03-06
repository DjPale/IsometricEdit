package gamelib;

import luxe.Sprite;
import luxe.Vector;

import phoenix.geometry.Geometry;

import gamelib.TileSheetAtlased;

using gamelib.RectangleUtils;

typedef VectorSerialize = {
    x: Float,
    y: Float
};

typedef MapTileSerialize = {
    pos: VectorSerialize,
    size: VectorSerialize,
    origin: VectorSerialize,
    uv: Array<Float>,
    depth: Float,
    tilesheet: Int,
};

typedef MapTile = {
    s: Sprite,
    tilesheet: Int
};

typedef MapEntrySerialize = {
    pos: String, 
    tile: MapTileSerialize
};

typedef IsometricMapSerialize = {
    width: Int,
    height: Int,
    snap: Int,
    sheets: Array<TileSheetAtlasedSerialize>,
    map: Array<MapEntrySerialize>
};

class IsometricMap
{
    public var sheets : TileSheetCollection;

	var grid : Map<String,MapTile>;
    public var graph : Graph;

	public var base_width(default, null) : Int;
	public var base_height(default, null) : Int;

	var grid_snap : Int = 1;
	var grid_mult : Int = 1;

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	public var width_half(default, null) : Int;
	public var height_half(default, null) : Int;

    public function new(?_base_width:Int = 64, ?_base_height:Int = 32, ?_grid_snap:Int = 1)
    {
        sheets = new TileSheetCollection();
        grid = new Map<String,Sprite>();
        graph = new Graph(null);

    	base_width = _base_width;
    	base_height = _base_height;

		set_snap(_grid_snap);
    }

    public function display_graph(batcher:phoenix.Batcher)
    {
        graph.display(batcher); 
    }

    public function rebuild_graph(sheet:TileSheetAtlased)
    {
        graph.clear();

        for (tile in grid)
        {
            var idx = sheet.get_tile_from_rect(tile.uv);
            var g = sheet.atlas[idx].graph;

            if (g != null)
            {
                graph.merge(g, tile.pos.clone().subtract(tile.origin));
            }
        }
    }

    public function destroy()
    {
        for (v in grid)
        {
            v.destroy();
        }

        graph.destroy();
        sheets.destroy();

        sheets = null;
        graph = null;
        grid = null;
    }

    inline function vector_to_pair(v:Vector) : VectorSerialize
    {
        return { x: v.x, y: v.y };
    }

    inline function pair_to_vector(p:VectorSerialize)
    {
        return new Vector(p.x, p.y);
    }
    
    inline function tile_to_json_data(s:Sprite) : MapTileSerialize
    {
        if (s == null) return null;

        var sheet_id = sheets.sheet_id_from_texture(s.texture);

        return {
            pos: vector_to_pair(s.pos),
            size: vector_to_pair(s.size),
            origin: vector_to_pair(s.origin),
            uv: s.uv.to_array(),
            depth: s.depth,
            tilesheet: sheet_id
        };
    }

    public function to_json_data() : IsometricMapSerialize
    {
        var t_grid = new Array<MapEntrySerialize>();

        for (k in grid.keys())
        {
            var s = grid.get(k);

            t_grid.push({ pos: k, tile: tile_to_json_data(s) });
        }

        return { width: base_width, height: base_height, snap: grid_snap, sheets: sheets.to_json_data(), map: t_grid };
    }

    public static function from_json_data(data:IsometricMapSerialize, batcher:phoenix.Batcher) : IsometricMap
    {
        if (data == null || batcher == null) return null;

        var m = new IsometricMap(data.width, data.height, data.snap);

        for (t in data.map)
        {
            m.create_tile(t, batcher);
        }

        return m;
    }

    public function set_snap(snap:Int)
    {
    	if (snap >= 1 && snap <= 4)
    	{
    		grid_mult = (1 << (snap - 1));

    		width = base_width * grid_mult;
    		height = base_height * grid_mult;

    		width_half = Std.int(width / 2);
    		height_half = Std.int(height / 2);

            Luxe.events.queue('IsometricMap.Snap', '$width x $height ($snap)');

    		trace('grid ' + width + 'x' + height + ' - ' + snap);
    	}
    }

    public function get_tile(pos:Vector) : Sprite
    {
    	var k = _key(pos);
        var v = grid.get(k);

        return v;
    }

    public function get_tile_world(pos:Vector) : Sprite
    {
        for (spr in grid)
        {
            if (spr.point_inside(pos))
            {
                return spr;
            }
        }

        return null;
    }

    public inline function get_depth_str(pos:Vector, actual:Float) : String
    {
        var cur = depth(pos);
        var d = actual - cur;

        if (d == 0)
        {
            return '$cur';
        }
        else if (d > 0)
        {
            return '$cur+$d';
        }
        else
        {
            return '$cur$d';
        }
    } 

    public inline function depth(pos:Vector) : Float
    {
        return Math.abs(pos.y) * grid_mult + Math.abs(pos.x) * grid_mult;
    }

    public function set_tile(tile:Sprite, pos:Vector, sheet:TileSheetAtlased, _graph:Graph = null)
    {
        remove_tile(pos, sheet);

        //tile.depth = Std.parseFloat(pos.y + '.' + pos.x);
        tile.depth = depth(pos);

        grid.set(_key(pos), tile);

        graph.merge(_graph, tile.pos.clone().subtract(tile.origin));
    }

    //TODO: messy
    public function create_tile(sheet:TileSheetAtlased, data:MapEntrySerialize, batcher:phoenix.Batcher)
    {
        var s = new Sprite({
            name_unique: true,
            texture: sheet.image,
            centered: false,
            origin: pair_to_vector(data.tile.origin),
            pos: pair_to_vector(data.tile.pos),
            size: pair_to_vector(data.tile.size),
            uv: RectangleUtils.from_array(data.tile.uv),
            depth: data.tile.depth,
            batcher: batcher
            });

        //TODO: omg!
        var idx = sheet.get_tile_from_rect(s.uv);
        var td = sheet.atlas[idx];

        grid.set(data.pos, s);

        graph.merge(td.graph, s.pos.clone().subtract(s.origin));
    }

    public function remove_tile(pos:Vector, sheet:TileSheetAtlased, ?_destroy:Bool = true) : Bool
    {
        var k = _key(pos);
        var v = grid.get(k);
        var g = null;

        if (v != null)
        {
            var idx = sheet.get_tile_from_rect(v.uv);
            g = sheet.atlas[idx].graph;

            if (_destroy) v.destroy();
        }

        var ret = grid.remove(k);

        if (g != null) rebuild_graph(sheet);

        return ret;
    }

    inline function _key(p:Vector)
    {
        return Std.int(p.x * grid_mult) + '-' + Std.int(p.y * grid_mult);
    }

    public function change_depth_ofs(pos:Vector, depth:Int) : Bool
    {
        var s = get_tile(pos);
        if (s != null)
        {
            s.depth += depth;
            return true;
        }

        return false;
    }

    public inline function screen_to_iso(p:Vector) : Vector
    {
        /*
        var mx = Std.int(((p.x / width_half) + (p.y / height_half)) / 2);
        var my = Std.int(((p.y / height_half) - (p.x / width_half)) / 2);
        */
        var px = Std.int(p.x / width_half);
        var py = Std.int(p.y / height_half); 

        var mx = Std.int((px + py) / 2);
        var my = Std.int((py - px) / 2);

        return new Vector(mx, my);
    }

    public inline function iso_to_screen(p:Vector) : Vector
    {
        var sx = (p.x - p.y) * width_half;
        var sy = (p.x + p.y) * height_half;

        return new Vector(sx, sy);
    }
}