package test.demos;
import atomic.Motion;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import test.demos.Particle2dDemo.Particle;

class Particle2dDemo extends AbstractDemo
{
	private var _particles:Array<Particle>;
	
	private var _clickArea:Sprite;

	public function new() 
	{
		super();
		
		_clickArea = new Sprite();
		_clickArea.graphics.beginFill(0xeeeeee);
		_clickArea.graphics.drawRect(0, 0, 100, 100);
		_clickArea.useHandCursor = true;
		addChild(_clickArea);
		
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		_particles = new Array<Particle>();
		
		for (i in 0 ... 300) {
			var part:Particle = new Particle(2 + Math.random() * 10, Math.random(), Math.random(), positionParticle);
			//part.go(Math.random(), Math.random());
			_particles.push(part);
			addChild(part);
			part.x = part.xMotion.value * _width;
			part.y = part.yMotion.value * _height;
		}
	}
	
	private function onMouseMove(e:MouseEvent):Void 
	{
		var mouseX:Float = this.mouseX / _width;
		var mouseY:Float = this.mouseY / _height;
		for (part in _particles) {
			
			var dir:Float = Math.random() * Math.PI * 2;
			var dist:Float = Math.random() * 0.05;
			
			var x:Float = (dist * Math.cos(dir)) + mouseX;
			var y:Float = (dist * Math.sin(dir)) + mouseY;
			part.go(x, y);
			
			//part.go(mouseX + 0.1*Math.random() - 0.05, mouseY + 0.1*Math.random() - 0.05);
		}
	}
	
	function positionParticle(particle:Particle):Void 
	{
		//particle.go(Math.random(), Math.random());
	}
	
	override public function setSize(w:Float, h:Float):Void {
		super.setSize(w, h);
		_clickArea.width = w;
		_clickArea.height = h;
	}
	
	override public function update():Void {
		for (part in _particles) {
			
			var newX = part.xMotion.value * _width;
			var newY = part.yMotion.value * _height;
			
			if (Math.abs(part.x - newX) > 30 || Math.abs(part.y - newY) > 30) {
				part.x = part.x;
			}
			part.x = newX;
			part.y = newY;
		}
	}
}

class Particle extends Shape {
	public var xMotion:Motion;
	public var yMotion:Motion;
	var onMoveComplete:Particle -> Void;
	
	private var xFin:Bool = true;
	private var yFin:Bool = true;
	
	public function new(size:Float, x:Float, y:Float, onMoveComplete:Particle->Void) {
		super();
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, size);
		
		this.onMoveComplete = onMoveComplete;
		
		xMotion = new Motion(size, 20/size, 20/size);
		xMotion.value = x;
		xMotion.motionEnded.add(onXMotionEnded);
		
		yMotion = new Motion(size, 20/size, 20/size);
		yMotion.value = y;
		yMotion.motionEnded.add(onYMotionEnded);
	}
	
	function onXMotionEnded(motion:Motion) 
	{
		xFin = true;
		if(yFin)onMoveComplete(this);
	}
	
	function onYMotionEnded(motion:Motion) 
	{
		yFin = true;
		if(xFin)onMoveComplete(this);
	}
	public function go(x:Float, y:Float):Void {
		xFin = false;
		yFin = false;
		xMotion.go(x);
		yMotion.go(y);
	}
}