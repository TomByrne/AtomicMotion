package atomic;
import atomic.Clock.HandlerLink;

class Clock
{
	private static var _worldClock:Clock;
	public static var worldClock(get, null) : Clock;
	private static function get_worldClock():Clock
	{
		if (_worldClock == null)_worldClock = new Clock();
		return _worldClock;
	}
	
	public static var defaultFps:Float = 60;
	
	
	public function new() {
		
	}
	
	private var _timer:Timer;
	
	private var _fps:Float;
	public var fps(get,set) : Float;
	private function set_fps(value:Float):Float
	{
		_fps = value;
		startTimer();
		return value;
	}
	public function get_fps():Float
	{
		return _fps;
	}
	
	public var time(get,null) : Float;
	public function get_time():Float
	{
		return (_timer==null?0:Timer.stamp() - _startTime);
	}
	
	private var _firstLink:HandlerLink;
	private var _lastLink:HandlerLink;
	public function addHandler(tickHandler:Float->Void):Void {
		var link:HandlerLink = new HandlerLink(tickHandler);
		if (_firstLink == null) {
			_firstLink = link;
			_lastLink = link;
			if (Math.isNaN(_fps)) this.fps = Clock.defaultFps;
		}else {
			_lastLink.after = link;
			_lastLink = link;
		}
	}
	public function removeHandler(tickHandler:Float->Void):Bool {
		var link:HandlerLink = _firstLink;
		while (link != null) {
			if (link.handler == tickHandler) {
				if (_lastLink == link) {
					if (_firstLink == link) {
						_lastLink = null;
						_firstLink = null;
					}else {
						_lastLink = link.before;
						_lastLink.after = null;
					}
				}else if (_firstLink == link) {
					_firstLink = link.after;
					_firstLink.before = null;
				}else {
					link.before.after = link.after.before;
					link.after.before = link.before.after;
				}
				link.after = null;
				link.before = null;
				link.handler = null;
				//pooling?
				return true;
			}
			link = link.after;
		}
		return false;
	}
	
	private var _lastTime:Float;
	private var _startTime:Float;
	function startTimer() 
	{
		if (_timer != null) {
			_timer.stop();
			_timer = null;
		}
		_timer = new Timer(Std.int(1000 / _fps));
		_timer.run = doTick;
		_lastTime = Timer.stamp();
		_startTime = _lastTime;
	}
	
	function doTick() {
		var lastTime = _lastTime;
		_lastTime = Timer.stamp();
		var timeDif = _lastTime - lastTime;
		
		var link:HandlerLink = _firstLink;
		while (link != null) {
			link.handler(timeDif);
			link = link.after;
		}
	}
}

class HandlerLink {
	public var after:HandlerLink;
	public var before:HandlerLink;
	
	public var handler:Float->Void;
	
	public function new(handler:Float->Void) {
		this.handler = handler;
	}
}