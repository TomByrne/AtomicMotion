package test;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.Lib;
import openfl.display.FPS;
import test.demos.Particle2dDemo;

/**
 * ...
 * @author Tom Byrne
 */

class Demos extends Sprite 
{
	var inited:Bool;
	var demo:Particle2dDemo;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
		
		demo.setSize(stage.stageWidth, stage.stageHeight);
	}
	
	function update(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
		
		demo.update();
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
		
		
		demo = new Particle2dDemo();
		addChild(demo);
		
		addChild(new FPS());
	}

	function added(e) 
	{
		demo.setSize(stage.stageWidth, stage.stageHeight);
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		stage.addEventListener(Event.ENTER_FRAME, update);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Demos());
	}
}
