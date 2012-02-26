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
		private var timeout:Timer; //timer for idle
		private var timeoutWarn:Timer; //timer for notifying time out
		
		public static var parserLoaded = false;  //Tells you whether the metadata is available or not.
		public static var language:int = 0; //language mode. 0: English, 1: Spanish
		public static var rating:Rating;
		
		/* dynamic interface components */
		private static var shader:Shade;
		private static var blocker_fullscreen:Blocker;
		
		/* button containers */
		private var cont_toStats:TouchSprite;
		private var cont_toRating:TouchSprite;
		private var cont_lang:TouchSprite;
		private var cont_shader:TouchSprite;
		private var cont_blocker_fullscreen:TouchSprite;
		
		public function Main() {
			settingsPath = "application.xml";
		}
		//testing
		override protected function initialize():void {
			timeout = new Timer(45000, 1);
			
			cont_toStats = new TouchSprite();
			cont_toRating = new TouchSprite();
			cont_lang = new TouchSprite();
			
			cont_lang.addChild(button_lang);
			addChild(cont_lang);
			
			cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
			cont_lang.addEventListener(TouchEvent.TOUCH_UP, lang_up, false, 0, true);
			
			//shader
			shader = new Shade();
			cont_shader = new TouchSprite();
			cont_shader.addChild(shader);
			shader.alpha = 0;
			
			//blocker
			blocker_fullscreen = new Blocker();
			cont_blocker_fullscreen = new TouchSprite();
			cont_blocker_fullscreen.addChild(blocker_fullscreen);
			
			/*rating = new Rating();			
			rating.x = 960; //Damn straight, hard coded screen positioning for Rating class, don't judge
			rating.y = 540;			
			addChild(rating);*/
			
			addEventListener("shiftUp", shiftUp);
			addEventListener("shiftDown", shiftDown);
			
			//Start parsing Soapbox.xml for its metadata
			ImageParser.addEventListener(Event.COMPLETE, imageParserLoaded, false, 0, true);
			ImageParser.settingsPath = "Soapbox.xml";
		}
		
		/* -------------------------------------------- */
		/* ------------ Logical Functions ------------- */
		/* -------------------------------------------- */
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
		
		/* -------------------------------------------- */
		/* ------ Interface/Animation Functions ------- */
		/* -------------------------------------------- */
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

		private function shiftUp(e:Event):void {
			Tweener.addTween( background_texture, { y: background_texture.y - 300, time: 1 } );
			Tweener.addTween( cont_lang, { y: cont_lang.y - 300, time: 1} );
		}
		
		private function shiftDown(e:Event):void {
			Tweener.addTween( background_texture, { y: background_texture.y + 300, time: 1 } );
			Tweener.addTween( cont_lang, { y: cont_lang.y + 300, time: 1} );
		}
		
		public function shadeOn():void {
			addChild(cont_shader);
			Tweener.addTween(shader, { alpha: 1, time: 0.5 } );
		}
		
		public function shadeOff():void {
			trace("call off shader");
			Tweener.addTween(shader, { delay: 1, alpha: 0, time: 0.5, onComplete: function() { removeChild(cont_shader) } } );
		}
		
		public function blockerOn():void {
			addChild(cont_blocker_fullscreen);
			cont_blocker_fullscreen.visible = true;
		}
		
		public function blockerOff():void {
			removeChild(cont_blocker_fullscreen);
			cont_blocker_fullscreen.visible = false;
		}
		
		private function imageParserLoaded(e:Event):void{
			parserLoaded = true;
			
			rating = new Rating();
			//Damn straight, hard coded screen positioning for Rating class, don't judge
			rating.x = 960;
			rating.y = 540;			
			addChild(rating);
		}
	}
	
}
