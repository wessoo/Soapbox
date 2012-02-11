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
		
		public static var language:int = 0; //language mode. 0: English, 1: Spanish
		
		public function Main() {
			settingsPath = "application.xml";
		}
		
		override protected function initialize():void {
			var r:Rating = new Rating();
			var a:Array = r.getImages();
			for(var i:int = 0; i < a.length; ++i){
				trace(a[i]);
			}
		}

	}
	
}
