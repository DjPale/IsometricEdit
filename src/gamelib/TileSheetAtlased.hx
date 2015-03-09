package gamelib;

import luxe.Vector;
import luxe.Rectangle;

import phoenix.Texture;

import gamelib.Graph;

import haxe.io.Path;

using gamelib.RectangleUtils;

typedef TileData = {
    rect: Rectangle,
    graph: Graph
};

typedef TileSheetAtlasedSerialize = {
    name: String,
    image: String,
    atlas: Array<TileDataSerialize>,
    groups: Array<GroupSerialize>
};

typedef GroupSerialize = { 
    k: String, 
    v: Array<Int> 
};

typedef TileDataSerialize = {
    graph: GraphSerialize,
    rect: Array<Float>
};

class TileSheetAtlased
{
	public var image(default, null) : Texture;
    public var atlas(default, null) : Array<TileData>;
    public var name(default, null) : String;
    public var index(default, default) : Int;

    var groups : Map<String,Array<Int>>;
    var group_path : String;
    var group_cur_idx : Int = 0;
    var group_cycle_idx : Int = 0;

    var atlas_pos : Int = 0;

    public function new(_name:String)
    {
        name = _name;
    	atlas = new Array<TileData>();
        groups = new Map<String,Array<Int>>();
    }

    public function destroy()
    {
        while (atlas.length > 0)
        {
            var a = atlas.pop();
            if (a.graph != null) a.graph.destroy();
        }

        image = null;
        atlas = null;
        groups = null;
    }

    public inline function get_current_path() : String
    {
        return group_path;
    }

    public function to_json_data() : TileSheetAtlasedSerialize
    {
        var t_atlas = new Array<TileDataSerialize>();

        for (a in atlas)
        {
            var t_g = null;

            if (a.graph != null)
            {
                t_g = a.graph.to_json_data(); 
            }

            t_atlas.push({ rect: a.rect.to_array(), graph: t_g });
        }

        var t_groups = new Array<GroupSerialize>();
        for (k in groups.keys())
        {
            t_groups.push({ k: k, v: groups[k] }); 
        }

        return { name: name, image: image.asset.id, atlas: t_atlas, groups: t_groups };
    }

    public static function from_json_data(data:TileSheetAtlasedSerialize) : TileSheetAtlased
    {
        if (data == null) return null;

        var sheet = new TileSheetAtlased(data.name);

        sheet.image = Luxe.resources.find_texture(data.image);

        if (sheet.image == null) return null;

        for (a in data.atlas)
        {
            sheet.atlas.push({
                graph: Graph.from_json_data(a.graph),
                rect: RectangleUtils.from_array(a.rect)
                });
        }

        for (g in data.groups)
        {
            sheet.set_idxs_to_group(g.k, g.v);
        }

        return sheet;
    }

    public static function from_xml_data(_image:phoenix.Texture, _xml:String) : TileSheetAtlased
    {
        var xml = Xml.parse(_xml);

        if (xml == null) return null;

        var sheet = new TileSheetAtlased(Path.withoutDirectory(_image.id));
        sheet.image = _image;

        var fast = new haxe.xml.Fast(xml.firstElement());
        
        for (st in fast.nodes.SubTexture)
        {
           sheet.atlas.push({
                graph: null, 
                rect: 
                    new Rectangle(Std.parseFloat(st.att.x), Std.parseFloat(st.att.y), 
                    Std.parseFloat(st.att.width), Std.parseFloat(st.att.height)) 
                    });
        }

        return sheet;
    }

    public function set_idxs_to_group(grp:String, idxs:Array<Int>)
    {
        groups.set(grp, idxs);
    }

    public function add_idx_to_group(grp:String, idx:Int, ?toggle:Bool = false) : Bool
    {
        if (grp == null || idx < 0 || idx >= atlas.length)
        {
            return false;
        }

        var a = groups.get(grp);
        if (a != null)
        {
            if (a.indexOf(idx) == -1)
            {
                a.push(idx);
                return true;
            }
            else
            {
                if (toggle)
                {
                    a.remove(idx);
                }

                return false;
            }
        }
        else
        {
            a = new Array<Int>();
            a.push(idx);
            groups.set(grp, a);

            return true; 
        }
    }

    function get_current_group() : Array<Int>
    {
        if (group_path == null)
        {
            return null;
        }

        var k = get_current_path();
        var a = groups.get(k);

        return a;
    }

    public function get_groups_for_idx(idx:Int) : Array<String>
    {
        var ret : Array<String> = null;

        for (k in groups.keys())
        {
            if (groups.get(k).indexOf(idx) != -1)
            {
                if (ret == null)
                {
                    ret = new Array<String>();
                }

                ret.push(k);
            }
        }

        return ret;
    }

    public inline function has_group(grp:String) : Bool
    {
        return (grp != null && groups.exists(grp));
    }

    public function get_group(grp:String) : Array<Int>
    {
        if (grp == null) return null;

        return groups.get(grp);
    }

    public function set_group_index_ofs(offset:Int) : Int
    {
        if (group_path == null)
        {
            no_group();
            return set_index_ofs(offset);
        }

        var a = get_current_group();
        trace('current group array = $a, try to go $offset');

        if (a == null)
        {
            no_group();
            return set_index_ofs(offset);
        }

        group_cycle_idx += offset;

        if (group_cycle_idx >= a.length)
        {
            group_cycle_idx = 0;
        }
        else if (group_cycle_idx < 0)
        {
            group_cycle_idx = a.length - 1;
        }

        atlas_pos = a[group_cycle_idx];

        Luxe.events.queue('TileSheetAtlased.TileId', { tilesheet: index, tile: atlas_pos });

        return atlas_pos;
    }

    public function select_group(grp:String) : Bool
    {
        if (grp == null || !groups.exists(grp))
        {
            no_group();
            return false;
        }

        group_path = grp;
        group_cycle_idx = 0;

        trace('try select group path = $group_path');

        set_group_index_ofs(0);

        Luxe.events.queue('TileSheetAtlased.GroupId', get_current_path());

        return true;
    }

    public function no_group()
    {
        group_path = null;

        Luxe.events.queue('TileSheetAtlased.GroupId', '-');
    }

    public inline function get_tile_idx(pos:Vector, ?scale:Vector = null) : Int
    {
        var atlas_pos = -1;

        for (i in 0...atlas.length)
        {
            var rect = atlas[i].rect;

            if (scale != null)
            {
                rect = rect.clone();

                rect.x *= scale.x;
                rect.y *= scale.y;
                rect.w *= scale.x;
                rect.h *= scale.y;
            }

            if (rect.point_inside(pos))
            {
                atlas_pos = i;
                break;
            }
        }

        return atlas_pos;
    }

    public function get_tile_from_rect(rect:Rectangle) : TileData
    {
        for (i in 0...atlas.length)
        {
            if (atlas[i].rect.equal(rect))
            {
                return atlas[i];
            }
        }

        return null;
    }

    public function get_tile_id_from_rect(rect:Rectangle) : Int
    {
         for (i in 0...atlas.length)
         {
             if (atlas[i].rect.equal(rect))
             {
                 return i;
             }
         }

         return -1;       
    }

    public function set_index_ofs(idx:Int)
    {
        if (idx == 0) return atlas_pos;

        var len =  atlas.length;

        if (len == 0) return atlas_pos;

        atlas_pos += idx;

        if (atlas_pos >= len) atlas_pos = 0;
        if (atlas_pos < 0) atlas_pos = len - 1;

        Luxe.events.queue('TileSheetAtlased.TileId', { tilesheet: index, tile: atlas_pos });

        return atlas_pos;
    }

    public function set_index(idx:Int)
    {
    	if (idx >= 0 && idx < atlas.length)
    	{
            no_group(); 

    		atlas_pos = idx;

            Luxe.events.queue('TileSheetAtlased.TileId', { tilesheet: index, tile: atlas_pos });
    	}
    }

    public function get_current_tile() : TileData
    {
    	if (atlas_pos >= 0 && atlas_pos < atlas.length)
    	{
    		return atlas[atlas_pos];
    	}

    	return null;
    }
}