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
		private var idleCountdown:Timer; //timer for idle
		
		public static var parserLoaded = false;  //Tells you whether the metadata is available or not.
		public static var language:int = 0; //language mode. 0: English, 1: Spanish
		public static var rating:Rating;
		
		/* button containers */
		private var cont_toStats:TouchSprite;
		private var cont_toRating:TouchSprite;
		private var cont_lang:TouchSprite;
		
		public function Main() {
			settingsPath = "application.xml";
		}
		//testing
		override protected function initialize():void {
			idleCountdown = new Timer(45000, 1);
			
			cont_toStats = new TouchSprite();
			cont_toRating = new TouchSprite();
			cont_lang = new TouchSprite();
			
			cont_lang.addChild(button_lang);
			addChild(cont_lang);
			
			cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
			cont_lang.addEventListener(TouchEvent.TOUCH_UP, lang_up, false, 0, true);
			
			rating = new Rating();
			//Damn straight, hard coded screen positioning for Rating class, don't judge
			rating.x = 960;
			rating.y = 540;			
			addChild(rating);
			
			var a:Array = rating.getImages();
			for(var i:int = 0; i < a.length; ++i){
				trace(a[i]);
			}
			
			
			ImageParser.addEventListener(Event.COMPLETE, imageParserLoaded, false, 0, true);
			ImageParser.settingsPath = "Soapbox.xml";
			//stage.displayState = StageDisplayState.FULL_SCREEN; 
		}
		
		/* ------ Logical Functions ------- */
		
		public function resetSession():void {
			rating.resetSession();
		}
		
		public function changeLang():void {
			if (language == 0) {
				language = 1;
			} else {
				language = 0;
			}
		}
		
		/* ------ Interface/Animation Functions ------- */
		private function lang_dwn(e:TouchEvent):void {
			if ( language == 0) { //in English mode
				button_lang.gotoAndStop("esp_down");
			} else {
				button_lang.gotoAndStop("eng_down");
			}
		}	
		
		private function lang_up(e:TouchEvent):void {
			if ( language == 0) { //in English mode
				button_lang.gotoAndStop("eng_up");
				changeLang(); //switch to Spanish
			} else {
				button_lang.gotoAndStop("esp_up");
				changeLang(); //switch to English
			}
		}
		
		private function imageParserLoaded(e:Event):void{
			parserLoaded = true;
			//var photo:Photo = new Photo(1);
			//addChild(photo);
		}
	}
	
}
