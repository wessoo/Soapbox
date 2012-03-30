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
	import com.refunk.events.TimelineEvent;
    import com.refunk.timeline.TimelineWatcher;
	
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
		public var screen:int = 1;

		/* dynamic interface components */
		private static var shader:Shade;
		private static var blocker_fullscreen:Blocker;
		private var timelineWatcher:TimelineWatcher;	//Used to watch timeline for labels

		/* button containers */
		private var cont_tostats:TouchSprite;
		private var cont_torating:TouchSprite;
		private var cont_lang:TouchSprite;
		private var cont_shader:TouchSprite;
		private var cont_blocker_fullscreen:TouchSprite;
		
		private static var SCREEN_HEIGHT:int = 1080;
		private static var SCREEN_WIDTH:int = 1920;
		private static var BG_START_POS:int = 1330;
		private static var RATING_Y_POS:int = 540;
		private static var RATING_X_POS:int = 960;
		private static var LANDINGTEXT_Y:int;
		private static var LOGO_Y:int;
		private static var LANDINGTEXT_X:int;
		private static var LOGO_X:int;
		private static var BG_YPOS:int;
		private static var TORATING_YPOS:int;
		private static var TOSTATS_YPOS:int;
		private static var LANDTXT_YPOS:int;
		private static var LOGO_YPOS:int;

		public function Main() {
			settingsPath = "application.xml";
		}
		//testing
		override protected function initialize():void {
			timeout = new Timer(45000, 1);
			
			cont_tostats = new TouchSprite();
			cont_torating = new TouchSprite();
			cont_lang = new TouchSprite();
			
			cont_tostats.addChild(button_tostats);
			addChild(cont_tostats);
			cont_torating.addChild(button_torating);
			addChild(cont_torating);
			cont_lang.addChild(button_lang);
			addChild(cont_lang);
			
			cont_tostats.addEventListener(TouchEvent.TOUCH_DOWN, tostats_dwn, false, 0, true);
			cont_tostats.addEventListener(TouchEvent.TOUCH_UP, tostats_up, false, 0, true);
			cont_torating.addEventListener(TouchEvent.TOUCH_DOWN, torating_dwn, false, 0, true);
			cont_torating.addEventListener(TouchEvent.TOUCH_UP, torating_up, false, 0, true);
			cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
			cont_lang.addEventListener(TouchEvent.TOUCH_UP, lang_up, false, 0, true);
			
			//shader
			shader = new Shade();
			cont_shader = new TouchSprite();
			cont_shader.addChild(shader);
			shader.alpha = 0;
			
			//blocker
			blocker_fullscreen = new Blocker();
			blocker_fullscreen.x = 1920/2;
			blocker_fullscreen.y = 1080/2;
			cont_blocker_fullscreen = new TouchSprite();
			cont_blocker_fullscreen.addChild(blocker_fullscreen);

			/*timelineWatcher = new TimelineWatcher(bubble_toscreen);
            timelineWatcher.addEventListener(TimelineEvent.LABEL_REACHED, screen_bubble_done);*/

            LANDINGTEXT_Y = landing_text.y;
            LOGO_Y = graphic_logo.y;
            LANDINGTEXT_X = landing_text.x;
            LOGO_X = graphic_logo.x;
            BG_YPOS = background_texture.y;
			TORATING_YPOS = button_torating.y;
			TOSTATS_YPOS = button_tostats.y;
			LANDTXT_YPOS = landing_text.y;
			LOGO_YPOS = graphic_logo.y;

			addEventListener("shiftUp", shiftUp);
			addEventListener("shiftDown", shiftDown);
			addEventListener("endSession", endSession);

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
		private function torating_dwn(e:TouchEvent):void {
			button_torating.gotoAndStop("down");
		}	
		
		private function torating_up(e:TouchEvent):void {
			button_torating.gotoAndStop("up");

			Tweener.addTween(background_texture, {y: 1330 - 1080, time: 1.5, transition: "easeInOutQuart" });
			Tweener.addTween(rating, {y: RATING_Y_POS, time: 1.5, transition: "easeInOutQuart" });
			Tweener.addTween(button_torating, {y: 950.55 - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
			Tweener.addTween(button_tostats, {y: 952.2 - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
			Tweener.addTween(landing_text, {y: LANDINGTEXT_Y - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
			Tweener.addTween(graphic_logo, {y: LOGO_Y - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
			Tweener.addTween(cont_lang, { alpha: 0, time: 0.5});
			Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: function() {
				blockerOff();
				rating.graphic_fakebg.alpha = 1;
				rating.showInstructions();
			} } );
		}

		private function tostats_dwn(e:TouchEvent):void {
			button_tostats.gotoAndStop("down");
		}	
		
		private function tostats_up(e:TouchEvent):void {
			button_tostats.gotoAndStop("up");

			if(screen == 1) {
				screen = 3;
				Tweener.addTween(background_texture, {x: SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_torating, {x: 960 + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_tostats, {x: 110 + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(landing_text, {x: LANDINGTEXT_X + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(graphic_logo, {x: LOGO_X + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(ranking_mockup, {x: -956.75 + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(cont_lang, { alpha: 0, time: 0.5, onComplete: function() {
					button_lang.x = 75.9;
					button_lang.y = 976.8;
				} });
				Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});
			} else if (screen == 3) {
				screen = 1;
				Tweener.addTween(background_texture, {x: 0, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_torating, {x: 960, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_tostats, {x: 110, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(landing_text, {x: LANDINGTEXT_X, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(graphic_logo, {x: LOGO_X, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(ranking_mockup, {x: -956.75, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(cont_lang, { alpha: 0, time: 0.5, onComplete: function() {
					button_lang.x = 1832.35;
					button_lang.y = 950.8;
				} });
				Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});
			}

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}

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

		private function endSession(e:Event):void {
			Tweener.addTween(rating, {y: RATING_Y_POS + SCREEN_HEIGHT, time: 2, transition: "easeInOutQuart" });

			Tweener.addTween(background_texture, {y: BG_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(button_torating, {y: TORATING_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(button_tostats, {y: TOSTATS_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(landing_text, {y: LANDTXT_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(graphic_logo, {y: LOGO_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(cont_lang, { alpha: 0, time: 0.5});
			Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
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
			rating.x = RATING_X_POS;
			rating.y = RATING_Y_POS + SCREEN_HEIGHT;			
			addChild(rating);
		}
	}
	
}
