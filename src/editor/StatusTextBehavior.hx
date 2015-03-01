package editor;

import luxe.Component;
import luxe.Text;

class StatusTextBehavior extends Component
{
	var status : Text;

	var grid : String = '?';
	var tile: Int = -1;
	var group: String = '?';
	var postxt : String = '?';

	public function new()
	{
		super();

		Luxe.events.listen('IsometricMap.Snap', function(str:String) { set_grid(str); });
		Luxe.events.listen('TileSheetAtlased.TileId', function(idx:Int) { set_tile(idx); });
		Luxe.events.listen('TileSheetAtlased.GroupId', function(str:String) { set_group(str); });
	}

	override function init()
	{
		status = cast entity;

		update_text();
	}

	public function update_text()
	{
		if (status != null)
		{
			status.text = 'Grid: $grid - Tile: $tile - Group: $group\n$postxt';
		}
	}

	public function set_grid(_grid:String)
	{
		grid = _grid;
		update_text();
	}

	public function set_group(_group:String)
	{
		group = _group;
		update_text();
	}

	public function set_tile(_tile:Int)
	{
		tile = _tile;
		update_text();
	}

	public function set_postxt(_postxt:String)
	{
		postxt = _postxt;
		update_text();
	}

	public function show(show:Bool)
	{
		if (status != null)
		{
			status.visible = show;
		}
	}
}