package test.demos;
import flash.display.Sprite;

class AbstractDemo extends Sprite
{
	var _width:Float;
	var _height:Float;

	public function new() 
	{
		super();
		
	}
	
	public function setSize(w:Float, h:Float):Void {
		_width = w;
		_height = h;
	}
	public function update():Void {
		
	}
}