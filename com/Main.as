package com {
	import adobe.utils.ProductManager;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
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
		private var countdown:Timer;
		private var soapbox_xml:XML;
		private var myLoader:URLLoader;
		public static var parserLoaded = false;  //Tells you whether the metadata is available or not.
		public static var language:int = 0; //language mode. 0: English, 1: Spanish
		public static var rating:Rating;
		public static var ranking:Ranking;
		public var screen:int = 1; //1: home. 2: rating. 3: ranking.
		public var countdown_sec:int = 10;

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
		private var cont_resetanimation:TouchSprite;
		
		private static var SCREEN_HEIGHT:int = 1080;
		private static var SCREEN_WIDTH:int = 1920;
		private static var BG_START_POS:int = 1330;
		private static var RATING_Y_POS:int = 540;
		private static var RATING_X_POS:int = 960;
		private static var RANKING_X_POS:Number = -956.75;
		private static var RANKING_Y_POS:Number = 535.15;
		private static var LANDINGTEXT_Y:int;
		private static var LOGO_Y:int;
		private static var LANDINGTEXT_X:int;
		private static var LOGO_X:int;
		private static var BG_YPOS:int;
		private static var TORATING_YPOS:int;
		private static var TOSTATS_YPOS:int;
		private static var LANDTXT_YPOS:int;
		private static var LOGO_YPOS:int;
		
		public static var uID:String = new Date().valueOf().toString().substr(0, 10);

		public function Main() {
			settingsPath = "application.xml";
		}
		//testing
		override protected function initialize():void {
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.displayState = StageDisplayState.FULL_SCREEN;

			timeout = new Timer(46000, 1); //NOTE: Set to 21 seconds for testing
			timeoutWarn = new Timer(35000, 1);
			countdown = new Timer(1000, 10);
			//timeout = new Timer(16000, 1); 
			//timeoutWarn = new Timer(5000, 1);

			timeout.addEventListener(TimerEvent.TIMER, timeout_reset);
			timeoutWarn.addEventListener(TimerEvent.TIMER, startCountdown);
			countdown.addEventListener(TimerEvent.TIMER, count_down);

			//Reading interface text from XML
			myLoader = new URLLoader();
			myLoader.load(new URLRequest("soapbox_interfacetext.xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);
			//End interface text from XML

			//Language presets
			landing_text.txt_header_esp.alpha = landing_text.txt_landing_esp.alpha = 0;
			button_torating.button_name_esp.alpha = 0;
			button_tostats.btxt_view_esp.alpha = button_tostats.btxt_home_esp.alpha = 0;
			txt_timeout.txt_tap_esp.alpha = txt_timeout.txt_timeout_esp.alpha = 0;
			//End language presets

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
			shader.x = 1920/2;
			shader.y = 1080/2;
			shader.alpha = 0;
			cont_shader.addEventListener(TouchEvent.TOUCH_DOWN, shader_dwn, false, 0, true);
			cont_shader.addEventListener(TouchEvent.TOUCH_UP, shader_up, false, 0, true);
			
			//blocker
			blocker_fullscreen = new Blocker();
			blocker_fullscreen.x = 1920/2;
			blocker_fullscreen.y = 1080/2;
			cont_blocker_fullscreen = new TouchSprite();
			cont_blocker_fullscreen.addChild(blocker_fullscreen);

			//reset animation
			cont_resetanimation = new TouchSprite();
			cont_resetanimation.addChild(effect_resetanimation);
			timelineWatcher = new TimelineWatcher(effect_resetanimation);
            timelineWatcher.addEventListener(TimelineEvent.LABEL_REACHED, resetanim_done);

            //coming soon bubble COMING SOON TEMP
            bubble_comingsoon.alpha = 0;
            bubble_comingsoon.scaleX = bubble_comingsoon.scaleY = 0.8;

			//other presets
			txt_timeout.alpha = 0;
			effect_resetanimation.alpha = 0;

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

			addEventListener(TouchEvent.TOUCH_DOWN, anyTouch); //registering any touch on the screen
			addEventListener("shiftUp", shiftUp);
			addEventListener("shiftDown", shiftDown);
			addEventListener("endSession", endSession);
			addEventListener("reset_animate", reset_animate);
			addEventListener("deactivateLang", deactivateLang);
			addEventListener("activateLang", activateLang);
			addEventListener("suspend_timeout", suspend_timeout);
			addEventListener("resume_timeout", resume_timeout);

			//Start parsing Soapbox.xml for its metadata
			ImageParser.addEventListener(Event.COMPLETE, imageParserLoaded, false, 0, true);
			ImageParser.settingsPath = "Soapbox.xml";

			/*rating = new Rating();
			rating.x = RATING_X_POS;
			rating.y = RATING_Y_POS + SCREEN_HEIGHT;			
			addChild(rating);*/
		}
		
		/* -------------------------------------------- */
		/* ------------ Logical Functions ------------- */
		/* -------------------------------------------- */
		public function resetSession():void {
			rating.resetSession();

		}
		
		public function changeLang():void {
			var uR:URLRequest = new URLRequest("http://localhost/userdata.php");
	        var uV:URLVariables = new URLVariables();
	        var now:Date = new Date();

			if (language == 0) { //to Spanish
				language = 1;

				//COLLECT DATA
	            uV.uid = uID;
	            uV.changeTo = "Spanish";
	            uV.changeLang = "true";
	            uV.date = now.toString();
	            uR.data = uV;
				//END COLLECT DATA

				landing_text.txt_header_esp.alpha = landing_text.txt_landing_esp.alpha = 0;
				button_torating.button_name_esp.alpha = 0;
				button_tostats.btxt_view_esp.alpha = button_tostats.btxt_home_esp.alpha = 0;

				//HOME
				//english off
				Tweener.addTween(landing_text.txt_header_eng, {alpha: 0, time: 1});
				Tweener.addTween(landing_text.txt_landing_eng, {alpha: 0, time: 1});
				Tweener.addTween(button_torating.button_name_eng, {alpha: 0, time: 1});
				Tweener.addTween(button_tostats.btxt_view_eng, {alpha: 0, time: 1});
				Tweener.addTween(button_tostats.btxt_home_eng, {alpha: 0, time: 1});
				txt_timeout.txt_tap.alpha = txt_timeout.txt_timeout.alpha = 0;
				//spanish on
				Tweener.addTween(landing_text.txt_header_esp, {alpha: 1, time: 1});
				Tweener.addTween(landing_text.txt_landing_esp, {alpha: 1, time: 1});
				Tweener.addTween(button_torating.button_name_esp, {alpha: 1, time: 1});
				Tweener.addTween(button_tostats.btxt_view_esp, {alpha: 1, time: 1});
				Tweener.addTween(button_tostats.btxt_home_esp, {alpha: 1, time: 1});
				txt_timeout.txt_tap_esp.alpha = txt_timeout.txt_timeout_esp.alpha = 1;
				//RANKING
				ranking.changeLang(1);
				//RATING
				rating.changeLang(1);

			} else { //to English
				language = 0;

				//COLLECT DATA
	            uV.uid = uID;
	            uV.changeTo = "English";
	            uV.changeLang = "true";
	            uV.date = now.toString();
	            uR.data = uV;
				//END COLLECT DATA

				//HOME
				//english on
				Tweener.addTween(landing_text.txt_header_eng, {alpha: 1, time: 1});
				Tweener.addTween(landing_text.txt_landing_eng, {alpha: 1, time: 1});
				Tweener.addTween(button_torating.button_name_eng, {alpha: 1, time: 1});
				Tweener.addTween(button_tostats.btxt_view_eng, {alpha: 1, time: 1});
				Tweener.addTween(button_tostats.btxt_home_eng, {alpha: 1, time: 1});
				txt_timeout.txt_tap.alpha = txt_timeout.txt_timeout.alpha = 1;
				//spanish off
				Tweener.addTween(landing_text.txt_header_esp, {alpha: 0, time: 1});
				Tweener.addTween(landing_text.txt_landing_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_torating.button_name_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_tostats.btxt_view_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_tostats.btxt_home_esp, {alpha: 0, time: 1});
				txt_timeout.txt_tap_esp.alpha = txt_timeout.txt_timeout_esp.alpha = 0;
				//RANKING
				ranking.changeLang(0);
				//RATING
				rating.changeLang(0);
			}

			var uL:URLLoader = new URLLoader(uR);
		}

		private function bold(input:String):String{
			return "<B>" + input + "</B>";
		}

		private function processXML(e:Event):void {
			soapbox_xml = new XML(e.target.data);
			//trace(soapbox_xml);
			//trace(soapbox_xml.english);
			//trace(soapbox_xml.other);
			//trace(soapbox_xml.Content.English.landingbody);
			//dummy.htmlText = bold(soapbox_xml.Content.English.landingbody);
		}

		/* -------------------------------------------- */
		/* ------ Interface/Animation Functions ------- */
		/* -------------------------------------------- */
		private function anyTouch(e:TouchEvent):void {
			if(screen == 2 || screen == 3) {
				timeoutWarn.reset();
				timeoutWarn.start();
				timeout.reset();
				timeout.start();
			}

			//COMING SOON TEMP
			/*if(bubble_comingsoon.alpha == 1) {
				Tweener.addTween(bubble_comingsoon, { alpha: 0, time: 1 } );
				Tweener.addTween(bubble_comingsoon, { scaleX: 0.8, scaleY: 0.8, time: 1 } );
			}*/
		}

		private function timeout_reset(e:TimerEvent):void {
			trace("reset");

			if(screen == 2) {
				rating.timeoutReset();

				Tweener.addTween(shader, { alpha: 0, time: 0.5, onComplete: shadeOff});
				Tweener.addTween(txt_timeout, { alpha: 0, time: 1} );
				countdown.reset();
				countdown_sec = 10;
			} else if (screen == 3) {
				Tweener.addTween(shader, { alpha: 0, time: 0.5, onComplete: shadeOff});
				Tweener.addTween(txt_timeout, { alpha: 0, time: 1} );
				countdown.reset();
				countdown_sec = 10;

				timeoutWarn.reset();
				timeout.reset();
				
				screen = 1;
				Tweener.addTween(background_texture, {x: 0, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_torating, {x: 960, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_tostats, {x: 110, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(landing_text, {x: LANDINGTEXT_X, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(graphic_logo, {x: LOGO_X, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(ranking, {x: -956.75, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(cont_lang, { alpha: 0, time: 0.5, onComplete: function() {
					button_lang.x = 1832.35;
					button_lang.y = 955;
				} });
				Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});
			}

		}

		private function count_down(e:TimerEvent):void {
			//trace(countdown_sec);
			txt_timeout.txt_counter.htmlText = bold(countdown_sec.toString());
			countdown_sec--;
		}

		private function startCountdown(e:TimerEvent):void {
			//trace("starting countdown");
			shadeOn();
			txt_timeout.txt_counter.text = 10;
			addChild(txt_timeout);
			Tweener.addTween(txt_timeout, { alpha: 1, time: 1, delay: 1} );
			countdown.start();
		}		

		private function shader_dwn(e:TouchEvent):void {

		}

		private function shader_up(e:TouchEvent):void {
			Tweener.addTween(shader, { alpha: 0, time: 0.5, onComplete: shadeOff});
			Tweener.addTween(txt_timeout, { alpha: 0, time: 1} );
			countdown.reset();
			countdown_sec = 10;
		}

		private function torating_dwn(e:TouchEvent):void {
			button_torating.gotoAndStop("down");

			cont_tostats.removeEventListener(TouchEvent.TOUCH_DOWN, tostats_dwn);
			cont_tostats.removeEventListener(TouchEvent.TOUCH_UP, tostats_up);
			cont_lang.removeEventListener(TouchEvent.TOUCH_DOWN, lang_dwn);
			cont_lang.removeEventListener(TouchEvent.TOUCH_UP, lang_up);
		}	
		
		private function torating_up(e:TouchEvent):void {
			button_torating.gotoAndStop("up");
			uID = new Date().valueOf().toString().substr(0, 10);

			//COLLECT DATA
			var uR:URLRequest = new URLRequest("http://localhost/userdata.php");
            var uV:URLVariables = new URLVariables();
            uV.uid = uID;
            uV.session = "true";
            var now:Date = new Date();
            uV.date = now.toString();
            uR.data = uV;
			var uL:URLLoader = new URLLoader(uR);
			//END COLLECT DATA

			if(screen == 1) {
				timeout.start();
				timeoutWarn.start();
				screen = 2;

				Tweener.addTween(background_texture, {y: 1330 - 1080, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(rating, {y: RATING_Y_POS, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_torating, {y: 950.55 - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_tostats, {y: 952.2 - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(landing_text, {y: LANDINGTEXT_Y - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(graphic_logo, {y: LOGO_Y - SCREEN_HEIGHT, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(cont_lang, { alpha: 0, time: 0.5});
				Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});

				Tweener.addTween(this, {delay: 1.5, onComplete: function() { 
					cont_tostats.addEventListener(TouchEvent.TOUCH_DOWN, tostats_dwn, false, 0, true);
					cont_tostats.addEventListener(TouchEvent.TOUCH_UP, tostats_up, false, 0, true);
					cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
					cont_lang.addEventListener(TouchEvent.TOUCH_UP, lang_up, false, 0, true);
				}});

				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: function() {
					blockerOff();
					rating.graphic_fakebg.alpha = 1;
					rating.showInstructions();
				} } );
			}
		}

		private function tostats_dwn(e:TouchEvent):void {
			button_tostats.gotoAndStop("down");

			cont_torating.removeEventListener(TouchEvent.TOUCH_DOWN, torating_dwn);
			cont_torating.removeEventListener(TouchEvent.TOUCH_UP, torating_up);
			cont_lang.removeEventListener(TouchEvent.TOUCH_DOWN, lang_dwn);
			cont_lang.removeEventListener(TouchEvent.TOUCH_UP, lang_up);
		}	
		
		private function tostats_up(e:TouchEvent):void {
			button_tostats.gotoAndStop("up");

			//COLLECT DATA
			var uR:URLRequest = new URLRequest("http://localhost/userdata.php");
            var uV:URLVariables = new URLVariables();
            uV.viewRankings = "true";
            var now:Date = new Date();
            uV.date = now.toString();
            uR.data = uV;
			var uL:URLLoader = new URLLoader(uR);
			//END COLLECT DATA
			
			Tweener.addTween(this, {delay: 1.5, onComplete: function() { 
				cont_torating.addEventListener(TouchEvent.TOUCH_DOWN, torating_dwn, false, 0, true);
				cont_torating.addEventListener(TouchEvent.TOUCH_UP, torating_up, false, 0, true);
				cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
				cont_lang.addEventListener(TouchEvent.TOUCH_UP, lang_up, false, 0, true);
			}});

			if(screen == 1) {
				timeout.start();
				timeoutWarn.start();
				screen = 3;

				screen = 3;
				Tweener.addTween(background_texture, {x: SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_torating, {x: 960 + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_tostats, {x: 110 + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(landing_text, {x: LANDINGTEXT_X + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(graphic_logo, {x: LOGO_X + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(ranking, {x: -956.75 + SCREEN_WIDTH, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(cont_lang, { alpha: 0, time: 0.5, onComplete: function() {
					button_lang.x = 57.75;
					button_lang.y = 985.95;
					addChild(bubble_comingsoon);
					bubble_comingsoon.y = 1010;
					bubble_comingsoon.x = 220;
				} });
				Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});
			} else if (screen == 3) {
				timeoutWarn.reset();
				timeout.reset();

				screen = 1;
				Tweener.addTween(background_texture, {x: 0, time: 1.5, transition: "easeInOutQuart", onComplete: function(){
								 ranking.reOrder();
								 }});
				Tweener.addTween(button_torating, {x: 960, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(button_tostats, {x: 110, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(landing_text, {x: LANDINGTEXT_X, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(graphic_logo, {x: LOGO_X, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(ranking, {x: -956.75, time: 1.5, transition: "easeInOutQuart" });
				Tweener.addTween(cont_lang, { alpha: 0, time: 0.5, onComplete: function() {
					button_lang.x = 1832.35;
					button_lang.y = 955;
					bubble_comingsoon.x = 1680.5;
					bubble_comingsoon.y = 977.6;
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

			//COMING SOON TEMP
			/*cont_torating.removeEventListener(TouchEvent.TOUCH_DOWN, torating_dwn);
			cont_torating.removeEventListener(TouchEvent.TOUCH_UP, torating_up);
			cont_tostats.removeEventListener(TouchEvent.TOUCH_DOWN, tostats_dwn);
			cont_tostats.removeEventListener(TouchEvent.TOUCH_UP, tostats_up);*/
		}	
		
		private function lang_up(e:TouchEvent):void {
			if ( language == 0) { //in English mode
				button_lang.gotoAndStop("eng_up");
				changeLang(); //switch to Spanish
			} else {
				button_lang.gotoAndStop("esp_up");
				changeLang(); //switch to English
			}

			//COMING SOON TEMP
			/*button_lang.gotoAndStop("esp_up");
			Tweener.addTween(bubble_comingsoon, { alpha: 1, time: 1 } );
			Tweener.addTween(bubble_comingsoon, { scaleX: 1, scaleY: 1, time: 1, transition: "easeOutElastic" } );

			Tweener.addTween(bubble_comingsoon, { alpha: 0, time: 1, delay: 4 } );
			Tweener.addTween(bubble_comingsoon, { scaleX: 0.8, scaleY: 0.8, time: 1, delay: 4 } );

			cont_torating.addEventListener(TouchEvent.TOUCH_DOWN, torating_dwn, false, 0, true);
			cont_torating.addEventListener(TouchEvent.TOUCH_UP, torating_up, false, 0, true);
			cont_tostats.addEventListener(TouchEvent.TOUCH_DOWN, tostats_dwn, false, 0, true);
			cont_tostats.addEventListener(TouchEvent.TOUCH_UP, tostats_up, false, 0, true);*/
		}

		private function reset_animate(e:Event):void {
			addChild(cont_resetanimation);
			Tweener.addTween(effect_resetanimation, {alpha: 1, time: 3.5, delay: 1});
			
			effect_resetanimation.badge1.gotoAndStop("on");
			effect_resetanimation.badge2.gotoAndStop("on");
			effect_resetanimation.badge3.gotoAndStop("on");
			effect_resetanimation.badge4.gotoAndStop("on");
			effect_resetanimation.badge5.gotoAndStop("on");
			effect_resetanimation.badge6.gotoAndStop("on");
			
			//turn on/off badges
			if(rating.currentBadge == 1) {
				effect_resetanimation.badge2.gotoAndStop("off");
				effect_resetanimation.badge3.gotoAndStop("off");
				effect_resetanimation.badge4.gotoAndStop("off");
				effect_resetanimation.badge5.gotoAndStop("off");
				effect_resetanimation.badge6.gotoAndStop("off");
			} else if (rating.currentBadge == 2) {
				effect_resetanimation.badge3.gotoAndStop("off");
				effect_resetanimation.badge4.gotoAndStop("off");
				effect_resetanimation.badge5.gotoAndStop("off");
				effect_resetanimation.badge6.gotoAndStop("off");
			} else if (rating.currentBadge == 3) {
				effect_resetanimation.badge4.gotoAndStop("off");
				effect_resetanimation.badge5.gotoAndStop("off");
				effect_resetanimation.badge6.gotoAndStop("off");
			} else if (rating.currentBadge == 4) {
				effect_resetanimation.badge5.gotoAndStop("off");
				effect_resetanimation.badge6.gotoAndStop("off");
			} else if (rating.currentBadge == 5) {
				effect_resetanimation.badge6.gotoAndStop("off");
			}

			//where to skip to
			if(rating.sendBadges) {
				Tweener.addTween(this, {delay: 2, onComplete: function() { effect_resetanimation.gotoAndPlay("play"); }});
			} else {
				effect_resetanimation.gotoAndStop("thanks");
				Tweener.addTween(this, {delay: 2, onComplete: function() { effect_resetanimation.gotoAndPlay("thanks"); }});
			}
		}

		private function resetanim_done(e:TimelineEvent):void {
			if (e.currentLabel === "end") {
				Tweener.addTween(effect_resetanimation, {alpha: 0, time: 2, onComplete: function() { 
					effect_resetanimation.gotoAndStop(1);
					effect_resetanimation.badge1.gotoAndStop("on");
					effect_resetanimation.badge2.gotoAndStop("on");
					effect_resetanimation.badge3.gotoAndStop("on");
					effect_resetanimation.badge4.gotoAndStop("on");
					effect_resetanimation.badge5.gotoAndStop("on");
					effect_resetanimation.badge6.gotoAndStop("on");
					removeChild(cont_resetanimation); 
				}});
			} else if (e.currentLabel === "step1") {
				if(rating.currentBadge == 1) {
					effect_resetanimation.badge2.gotoAndStop("off");
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 2) {
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 3) {
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 4) {
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 5) {
					effect_resetanimation.badge6.gotoAndStop("off");
				}
			} else if (e.currentLabel === "step2") {
				if(rating.currentBadge == 1) {
					effect_resetanimation.badge2.gotoAndStop("off");
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 2) {
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 3) {
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 4) {
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 5) {
					effect_resetanimation.badge6.gotoAndStop("off");
				}
			} else if (e.currentLabel === "step3") {
				if(rating.currentBadge == 1) {
					effect_resetanimation.badge2.gotoAndStop("off");
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 2) {
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 3) {
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 4) {
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 5) {
					effect_resetanimation.badge6.gotoAndStop("off");
				}
			} else if (e.currentLabel === "step4") {
				if(rating.currentBadge == 1) {
					effect_resetanimation.badge2.gotoAndStop("off");
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 2) {
					effect_resetanimation.badge3.gotoAndStop("off");
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 3) {
					effect_resetanimation.badge4.gotoAndStop("off");
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 4) {
					effect_resetanimation.badge5.gotoAndStop("off");
					effect_resetanimation.badge6.gotoAndStop("off");
				} else if (rating.currentBadge == 5) {
					effect_resetanimation.badge6.gotoAndStop("off");
				}
			}
		}

		private function deactivateLang(e:Event):void {
			cont_lang.removeEventListener(TouchEvent.TOUCH_DOWN, lang_dwn);
			cont_lang.removeEventListener(TouchEvent.TOUCH_UP, lang_up);
		}

		private function activateLang(e:Event):void {
			cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
			cont_lang.addEventListener(TouchEvent.TOUCH_UP, lang_up, false, 0, true);
		}

		private function suspend_timeout(e:Event):void {
			timeout.reset();
			timeoutWarn.reset();
		}

		private function resume_timeout(e:Event):void {
			timeout.start();
			timeoutWarn.start();
		}

		private function endSession(e:Event):void {
			Tweener.addTween(rating, {y: RATING_Y_POS + SCREEN_HEIGHT, time: 2, transition: "easeInOutQuart" });
			screen = 1;
			
			timeout.reset();
			timeoutWarn.reset();
			countdown.reset();
			
			Tweener.addTween(background_texture, {y: BG_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(button_torating, {y: TORATING_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(button_tostats, {y: TOSTATS_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(landing_text, {y: LANDTXT_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(graphic_logo, {y: LOGO_YPOS, time: 2, transition: "easeInOutQuart" });
			Tweener.addTween(cont_lang, { alpha: 0, time: 0.5});
			Tweener.addTween(cont_lang, { alpha: 1, time: 1, delay: 1.5});
			
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
			ranking.updateRatings();
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
			//Tweener.addTween(shader, { delay: 1, alpha: 0, time: 0.5, onComplete: function() { removeChild(cont_shader); } } );
			removeChild(cont_shader);
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
			
			ranking = new Ranking();
			ranking.x = RANKING_X_POS;
			ranking.y = RANKING_Y_POS;
			addChildAt(ranking, getChildIndex(cont_tostats) - 1);
			
			rating = new Rating();
			//Damn straight, hard coded screen positioning for Rating class, don't judge
			rating.x = RATING_X_POS;
			rating.y = RATING_Y_POS + SCREEN_HEIGHT;			
			addChild(rating);
		}
	}
	
}
