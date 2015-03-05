package gamelib;

import gamelib.TileSheetAtlased;

class TileSheetCollection
{
	var sheets : Array<TileSheetAtlased>;
	var cur_idx : Int;

	public var current(get,null) : TileSheetAtlased;

	public function new()
	{
		sheets = new Array<TileSheetAtlased>();
	}

	public function clear()
	{

	}

	public function destroy()
	{
		clear();
		sheets = null;
	}

	public function get_current() : TileSheetAtlased
	{
		if (sheets.length == 0) return null;

		return null;
	}

	public static function from_json_data(data:Array<TileSheetAtlasedSerialize>) : TileSheetCollection
	{

	}

	public function to_json_data() : Array<TileSheetAtlasedSerialize>
	{
		var ret = new Array<TileSheetAtlasedSerialize>();

		for (s in sheets)
		{
			ret.push(s.to_json_data());
		}

		return ret;
	}
}