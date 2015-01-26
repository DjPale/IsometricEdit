import luxe.Rectangle;

import phoenix.Texture;

class TileSheetAtlased
{
	public var image : Texture;
    public var atlas : Array<Rectangle>;

    var groups : Map<String,Array<Int>>;
    var group_path : Array<Int>;
    var group_cur_idx : Int = 0;
    var group_cycle_idx : Int = 0;

    var atlas_pos : Int = 0;

    public function new()
    {
    	atlas = new Array<Rectangle>();
        groups = new Map<String,Array<Int>>();
        group_path = new Array<Int>();
    }

    public inline function get_current_path() : String
    {
        return group_path.join('.');
    }

    public function add_idx_to_group(idx:Int) : Bool
    {
        if (group_path.length == 0 || idx < 0 || idx >= atlas.length)
        {
            return false;
        }

        var k = get_current_path();
        var a = groups.get(k);
        if (a != null)
        {
            if (a.indexOf(idx) == -1)
            {
                a.push(idx);
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            a = new Array<Int>();
            a.push(idx);
            groups.set(k, a);
            return true; 
        }
    }

    function get_current_group() : Array<Int>
    {
        if (group_path.length == 0)
        {
            return null;
        }

        var k = get_current_path();
        var a = groups.get(k);

        return a;
    }

    public function current_group_empty() : Bool
    {
        if (group_path.length == 0)
        {
            return true;
        }
        else
        {
            var a = get_current_group();

            if (a == null || a.length == 0)
            {
                return true;
            }
        }

        return false;
    }

    public function set_group_index_ofs(offset:Int) : Int
    {
        var a = get_current_group();
        trace('current group = $a, try to go $offset');

        if (a == null || a.length == 0)
        {
            return -1;
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

        return atlas_pos;
    }

    public function select_group(grp:Int)
    {
        group_path[group_cur_idx] = grp;
        group_cycle_idx = 0;
    }

    public function inc_group_level()
    {
        if (group_cur_idx <= group_path.length)
        {
            group_cur_idx++;
            group_cycle_idx = 0;
        }
    }

    public function dec_group_level()
    {
        if (group_path.length > 0 && group_cur_idx >= group_path.length)
        {
            group_path.pop();
            group_cur_idx--;
            group_cycle_idx = 0;
        }
    }

/*
    public function select_groups(grp:Array<Int>)
    {
        if (grp != null && grp.length > 0)
        {
            group_path = grp;
            group_cur_idx = grp.length - 1;
            group_cycle_idx = 0;
        }
    }
*/

    public function set_index_ofs(idx:Int)
    {
        if (idx == 0) return;

        var len =  atlas.length;

        if (len == 0) return;

        atlas_pos += idx;

        if (atlas_pos >= len) atlas_pos = 0;
        if (atlas_pos < 0) atlas_pos = len - 1;

    }

    public function set_index(idx:Int)
    {
    	if (idx >= 0 && idx < atlas.length)
    	{
    		atlas_pos = idx;
    	}
    }

    public function get_current() : Rectangle
    {
    	if (atlas_pos >= 0 && atlas_pos < atlas.length)
    	{
    		return atlas[atlas_pos];
    	}

    	return null;
    }
}