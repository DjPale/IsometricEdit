import luxe.Rectangle;

import phoenix.Texture;

class TileSheetAtlased
{
	public var image : Texture;
    public var atlas : Array<Rectangle>;

    var atlas_pos : Int = 0;

    public function new()
    {
    	atlas = new Array<Rectangle>();
    }

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