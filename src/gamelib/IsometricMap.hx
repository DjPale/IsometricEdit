package gamelib;

import luxe.Sprite;
import luxe.Vector;

import phoenix.geometry.Geometry;

import gamelib.TileSheetAtlased;

import gamelib.MyUtils;

using gamelib.RectangleUtils;

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
        grid = new Map<String,MapTile>();
        graph = new Graph(null);

    	base_width = _base_width;
    	base_height = _base_height;

		set_snap(_grid_snap);
    }

    public function display_graph(batcher:phoenix.Batcher)
    {
        graph.display(batcher); 
    }

    public function rebuild_graph()
    {
        graph.clear();

        for (tile in grid)
        {
            var t = sheets.get_tile_for_sprite(tile.s);
            if (t != null && t.graph != null)
            {
                graph.merge(t.graph, tile.s.pos.clone().subtract(tile.s.origin));
            }
        }
    }

    public function destroy()
    {
        for (v in grid)
        {
            v.s.destroy();
        }

        graph.destroy();
        sheets.destroy();

        sheets = null;
        graph = null;
        grid = null;
    }
   
    inline function tile_to_json_data(s:Sprite) : MapTileSerialize
    {
        if (s == null) return null;

        var sheet_id = sheets.sheet_id_from_texture(s.texture);

        return {
            pos: MyUtils.vector_to_pair(s.pos),
            size: MyUtils.vector_to_pair(s.size),
            origin: MyUtils.vector_to_pair(s.origin),
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
            var s = grid.get(k).s;

            t_grid.push({ pos: k, tile: tile_to_json_data(s) });
        }

        return { width: base_width, height: base_height, snap: grid_snap, sheets: sheets.to_json_data(), map: t_grid };
    }

    public static function from_json_data(data:IsometricMapSerialize, batcher:phoenix.Batcher) : IsometricMap
    {
        if (data == null || batcher == null) return null;

        var m = new IsometricMap(data.width, data.height, data.snap);

        for (s in data.sheets)
        {
            m.sheets.add(TileSheetAtlased.from_json_data(s));
        }

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

    public function get_tile(pos:Vector) : MapTile
    {
    	var k = _key(pos);
        var v = grid.get(k);

        return v;
    }

    public function get_tile_world(pos:Vector) : MapTile
    {
        for (tile in grid)
        {
            if (tile.s.point_inside(pos))
            {
                return tile;
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

    public function set_tile(tile:Sprite, pos:Vector, _graph:Graph = null)
    {
        if (tile == null) return;

        var sheet_id = sheets.sheet_id_from_texture(tile.texture);

        remove_tile(pos);

        //tile.depth = Std.parseFloat(pos.y + '.' + pos.x);
        tile.depth = depth(pos);

        grid.set(_key(pos), { s: tile, tilesheet: sheet_id });

        graph.merge(_graph, tile.pos.clone().subtract(tile.origin));
    }

    //TODO: messy
    public function create_tile(data:MapEntrySerialize, batcher:phoenix.Batcher)
    {
        var sheet_id = data.tile.tilesheet;

        var sheet = sheets.get_sheet(sheet_id);

        if (sheet == null)
        {
            trace('Warning! Could not find sheet with id $sheet_id');
            return;
        }

        var s = new Sprite({
            name_unique: true,
            texture: sheet.image,
            centered: false,
            origin: MyUtils.vector_from_pair(data.tile.origin),
            pos: MyUtils.vector_from_pair(data.tile.pos),
            size: MyUtils.vector_from_pair(data.tile.size),
            uv: RectangleUtils.from_array(data.tile.uv),
            depth: data.tile.depth,
            batcher: batcher
            });

        //TODO: omg!
        var td = sheet.get_tile_from_rect(s.uv);

        grid.set(data.pos, { s: s, tilesheet: sheet_id });

        graph.merge(td.graph, s.pos.clone().subtract(s.origin));
    }

    public function remove_tile(pos:Vector, ?_destroy:Bool = true) : Bool
    {
        var k = _key(pos);
        var v = grid.get(k);

        if (v == null) return false;

        var ret = grid.remove(k);

        var tile = sheets.get_tile_for_sprite(v.s);    
        if (tile != null && tile.graph != null) rebuild_graph();

        if (_destroy) v.s.destroy();

        return ret;
    }

    inline function _key(p:Vector)
    {
        return Std.int(p.x * grid_mult) + '-' + Std.int(p.y * grid_mult);
    }

    public function change_depth_ofs(pos:Vector, depth:Int) : Bool
    {
        var tile = get_tile(pos);
        if (tile != null)
        {
            tile.s.depth += depth;
            return true;
        }

        return false;
    }

    public function adjust_origin(pos:Vector, ofs:Vector) : Bool
    {
        var tile = get_tile(pos);
        if (tile != null)
        {
            tile.s.origin.add(ofs);
            tile.s.pos = tile.s.pos.clone();
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