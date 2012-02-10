package com {
	import adobe.utils.ProductManager;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.Stage;
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import id.core.ApplicationGlobals;
	import id.core.TouchSprite;
	import id.core.Application;
	import gl.events.TouchEvent;
	
	import caurina.transitions.Tweener;	
	
	public class Main extends Application {

		public function Main() {
			settingsPath = "application.xml";
		}
		
		override protected function initialize():void {
			
		}

	}
	
}
