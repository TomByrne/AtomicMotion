/**
 * Authors: Tom & Mikel Byrne 2007, 2013
 */

package atomic;

import msignal.Signal;
import haxe.Timer;

@:build(LazyInst.check())
class Motion{
	
	public static var immediateCalculation:Bool = false;
	
	private static var SMALL_NUMBER:Float = 0.000001;
	private static var E = Math.exp(1);
	
	@lazyInst
    public var motionBegan:Signal1<Motion>;
	
	@lazyInst
    public var motionChanged:Signal1<Motion>;
	
	@lazyInst
    public var motionEnded:Signal1<Motion>;
	
	//@lazyInst
    //public var speedChanged:Signal1<Motion>;
	public var speed(get,set) : Float;
	private function get_speed():Float{
		preCalculate();
		if(speedInvalid){
			speedInvalid = false;
			var time:Float = _elapsedTime;
			if(_hasDuration)time = time*(_calcDuration/_duration);
			//_speed =  (Z1*A*Math.pow(E,Z1*time))+(Z2*B*Math.pow(E,Z2*time));
			if(time!=0){
				_speed = ((_initialSpeed*FastMath.cos(H*time))-(L*FastMath.sin(H*time)))*Math.pow(E,(-_decceleration/mass)*time);
			}
		}
		return _speed;
	}
	private function set_speed(to:Float):Float{
		//_startValue = value;
		//preCalcInvalid = true;
		//_initialSpeed = to;
		setInitialSpeed(to, true);
		//LazyInst.exec(speedChanged.dispatch(this));
		return to;
	}
	
	@lazyInst
    public var valueChanged:Signal1<Motion>;
	public var value(get,set) : Float;
	private function get_value():Float{
		this.validateValue();
		return _value;
	}
	private function set_value(to:Float):Float{
		_startValue = _value = to;
		if(FastMath.isNaN(_destination))_destination = to;
		invalidatePreCalc();
		LazyInst.exec(valueChanged.dispatch(this));
		return to;
	}
	
	public var duration(get,set) : Float;
	private function get_duration():Float{
		if(!FastMath.isNaN(_duration))return _duration;
		else{
			preCalculate();
			return _calcDuration;
		}
	}
	private function set_duration(to:Float):Float{
		if (_duration == to) return to;
		
		_duration = to;
		_hasDuration = !FastMath.isNaN(to);
		if (!_playing) invalidatePreCalc();
		else invalidatePostCalc();
		return to;
	}
	
	public var destination(get,set) : Float;
	private function get_destination():Float{
		return _destination;
	}
	private function set_destination(to:Float):Float{
		if (_destination == to) return to;
		
		_destination = to;
		this.validateValue();
		if(!_playing) invalidatePreCalc();
		else invalidatePostCalc(); 
		return to; 
	}
	
	public var mass(get,set) : Float;
	private function get_mass():Float{
		return _mass;
	}
	private function set_mass(to:Float):Float{
		_mass = to;
		_mass2 = FastMath.max(_mass,SMALL_NUMBER);
		invalidatePhysics();
		return to;
	}
	
	public var acceleration(get,set) : Float;
	private function get_acceleration():Float{
		return _acceleration;
	}
	private function set_acceleration(to:Float):Float{
		_acceleration = to;
		_acceleration2 = FastMath.max(_acceleration, SMALL_NUMBER) * 2;
		invalidatePhysics();
		return to;
	}
	
	public var decceleration(get,set) : Float;
	private function get_decceleration():Float{
		return _decceleration;
	}
	private function set_decceleration(to:Float):Float{
		_decceleration = to;
		invalidatePhysics();
		return to;
	}
	
	public var rounding(get,set) : Float;
	private function get_rounding():Float{
		return _rounding;
	}
	private function set_rounding(to:Float):Float{
		_rounding = to;
		_rounding2 = FastMath.max(SMALL_NUMBER, _rounding);
		_hasRounding = !FastMath.isNaN(to);
		if (!_playing) invalidatePreCalc();
		else invalidatePostCalc();
		return to;
	}
	
	private var _startValue:Float = 0;
	private var _elapsedTime:Float = 0;
	private var _initialSpeed:Float = 0;	// v
	private var _acceleration:Float = 0;	// k
	private var _acceleration2:Float = 0;	// k
	private var _decceleration:Float = 0;	// b
	private var _mass:Float = 0;			// m
	private var _mass2:Float = 0;			// m
	private var _destination:Float;			// x1
	private var _duration:Float;
	private var _calcDuration:Float;
	private var _hasDuration:Bool;
	private var _value:Float = 0;
	private var _speed:Float = 0;
	private var _rounding:Float;		// r
	private var _rounding2:Float;		// r
	private var _hasRounding:Bool = false;		// r
	private var _playing:Bool = false;
	
	private var physInvalid:Bool = true;
	private var preCalcInvalid:Bool = true;
	private var postCalcInvalid:Bool = true;
	private var valueInvalid:Bool = false;
	private var speedInvalid:Bool = false;
	
	
	// calculation caches
	private var H:Float;
	private var X2:Float;
	private var J:Float;
	private var L:Float;
	private var D:Float;
	
	public function new(?mass:Float, ?acceleration:Float, ?decceleration:Float, onWorldClock:Bool = true){
		if(!FastMath.isNaN(mass))this.mass = mass;
		if(!FastMath.isNaN(acceleration))this.acceleration = acceleration;
		if (!FastMath.isNaN(decceleration)) this.decceleration = decceleration;
		
		_destination = Math.NaN;
		_duration = Math.NaN;
		_calcDuration = Math.NaN;
		_rounding = Math.NaN;
		_rounding2 = Math.NaN;
		
		if (onWorldClock) {
			Clock.worldClock.addHandler(tick);
		}
	}
	
	private function validateValue():Void
	{
		preCalculate();
		if (!valueInvalid) return;
		
		valueInvalid = false;
		var time:Float = _elapsedTime;
		if (_hasDuration) time = _elapsedTime * (_calcDuration / _duration);
		else time = _elapsedTime;
		
		//var tempValue:Float = (A*Math.pow(E,Z1*time))+(B*Math.pow(E,Z2*time))+((g*mass)/(2*acceleration))+_destination;
		var tempValue:Float = ((X2*FastMath.cos(H*time))+(FastMath.sin(H*time)*J))*Math.pow(E,(-_decceleration/_mass2)*time)+D;
		
		if (_hasRounding) {
			tempValue = FastMath.roundTo(tempValue, _rounding2);
		}
		_value = tempValue;
	}
	
	private function restart():Void{
		stop();
		start();
		LazyInst.exec(motionChanged.dispatch(this));
	}
	public function go(?destination:Float):Void {
		if (!FastMath.isNaN(destination)) this.destination = destination;
		if (_playing) return;
		
		LazyInst.exec(motionBegan.dispatch(this));
		start();
	}
	private function start():Void{
		_playing = true;
		invalidatePreCalc();
	}
	private function tick(timeDelta:Float):Void {
		if (!_playing) return;
		
		_elapsedTime += timeDelta;
		speedInvalid = valueInvalid = true;
		LazyInst.exec(valueChanged.dispatch(this));
		if(postCalcInvalid){
			postCalcInvalid = false;
			invalidatePreCalc();
		}
		
		if (_elapsedTime >= duration) {
			stop();
			_value = _destination;
			LazyInst.exec(valueChanged.dispatch(this));
			LazyInst.exec(motionEnded.dispatch(this));
		}
	}
	public function stop():Void{
		if(_playing){
			_playing = false;
			_calcDuration = _elapsedTime = Math.NaN;
		}
	}
	private function invalidatePhysics():Void{
		physInvalid = true;
		invalidatePreCalc();
	}
	private function invalidatePreCalc():Void{
		//_initialSpeed = speed;
		setInitialSpeed(speed, false);
		_startValue = value;
		if(_playing)_elapsedTime = 0;
		preCalcInvalid = true;
		postCalcInvalid = false;
		if(immediateCalculation)preCalculate();
	}
	
	function setInitialSpeed(to:Float, doInvalidate:Bool){
		if (_hasRounding){
			to = FastMath.roundTo(to, _rounding2);
		}
		
		if (_initialSpeed != to) {
			_initialSpeed = to;
			if (doInvalidate) invalidatePreCalc();
		}
	}
	private function invalidatePostCalc():Void{
		if(!preCalcInvalid)postCalcInvalid = true;
	}
	private function preCalculate():Void{
		if (FastMath.isNaN(destination)) return;
		
		if(physInvalid){
			physInvalid = false;
			valueInvalid = true;
		
			var initH:Float = (Math.pow(_decceleration,2)/(4*Math.pow(_mass2,2)))-(_acceleration2/_mass2);
			H = Math.sqrt(FastMath.max(SMALL_NUMBER, FastMath.abs(initH)));
			
		}
		
		if(preCalcInvalid){
		
			preCalcInvalid = false;
			valueInvalid = true;
		
			D = _destination;
			
			X2 = _startValue-_destination;
			J = ((_decceleration*X2)/(_mass2*H))+(_initialSpeed/H);
			L = ((_decceleration/_mass2)*J)+(X2*H);
			
			var distance:Float = _destination - _startValue;
			if (distance < 0) distance = -distance;
			
			var time1:Float = ( -_mass / _decceleration) * Math.log(FastMath.abs(_rounding2 / X2));
			var time2:Float = ( -_mass / _decceleration) * Math.log(FastMath.abs(_rounding2 / (((_decceleration * X2) / (H * _mass)) + (_initialSpeed / H))));
			_calcDuration = FastMath.max(0, FastMath.max(time1, time2));
		}
	
	}
}