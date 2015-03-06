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

	public function sheet_id_from_texture(img:phoenix.Texture) : Int
	{
		var i = 0;
		for (s in sheets)
		{
			if (s.image == img) return i;
			i++;
		}

		return -1;
	}

	public function get_sheet_id(id:Int) : TileSheetAtlased
	{
		if (id >= 0 && id < sheets.length) return sheets[id];

		return null;
	}

	public function add(sheet:TileSheetAtlased) : TileSheetAtlased
	{
		sheets.push(sheet);

		return sheet;
	}

	public static function from_json_data(data:Array<TileSheetAtlasedSerialize>) : TileSheetCollection
	{
		var ret = new TileSheetCollection();

		if (data != null)
		{
			for (ts in data)
			{
				var sheet = TileSheetAtlased.from_json_data(ts);
				ret.add(sheet);
			}
		}

		return ret;
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