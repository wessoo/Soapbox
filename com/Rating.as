package com {
	import flash.events.Event;
	import flash.display.DisplayObject;	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import id.core.TouchComponent;
	import id.core.TouchSprite;
	
	import caurina.transitions.Tweener;	
	
	public class Rating extends TouchComponent {
		private var images:Array;     //the array of randomized image id's
		private var ratings:Array; 		//the array of ratings of each image
		private var currentLoc:int;   //current location in the array
		private var lastRated:int;		//tells you the last image rated
		private var reachedEnd:Boolean;  //tells you if you've reached the end of the array
		private var currentBadge:int;	//The badge that the user currently has
		private var badge1:int = 10;	//The badges that can be attained
		private var badge2:int = 25;
		private var badge3:int = 45;
		private var badge4:int = 70;
		private var badge5:int = 95;
		private var badge6:int = 120;			
		
		private var cont_endsession:TouchSprite;
		private var cont_toscreen:TouchSprite;
		private var cont_email:TouchSprite;
		private var cont_lang:TouchSprite;
		private var cont_star1:TouchSprite;
		private var cont_star2:TouchSprite;
		private var cont_star3:TouchSprite;
		private var cont_star4:TouchSprite;
			
		public function Rating() {
			super();
			
			trace("flag1");
			//initialize vars 
			images = new Array();
			ratings = new Array();
			currentLoc = -1;
			reachedEnd = false;
			currentBadge = -1;
			lastRated = -1;
			
			//initialize();
			cont_endsession = new TouchSprite();
			cont_toscreen = new TouchSprite();
			cont_email = new TouchSprite();
			cont_lang = new TouchSprite();
			cont_star1 = new TouchSprite();
			cont_star2 = new TouchSprite();
			cont_star3 = new TouchSprite();
			cont_star4 = new TouchSprite();
			
			cont_endsession.addChild(button_endsession);
			addChild(cont_endsession);
			cont_toscreen.addChild(button_toscreen);
			addChild(cont_toscreen);
			cont_email.addChild(button_email);
			addChild(cont_email);
			cont_lang.addChild(button_lang);
			addChild(cont_lang);
			cont_star1.addChild(button_star1);
			addChild(cont_star1);
			cont_star2.addChild(button_star2);
			addChild(cont_star2);
			cont_star3.addChild(button_star3);
			addChild(cont_star3);
			cont_star4.addChild(button_star4);
			addChild(cont_star4);
			
			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_lang.addEventListener(TouchEvent.TOUCH_DOWN, lang_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			
			//initialize arrays
			for(var i:int = 1; i <= 120; ++i){
				images.push(i);
				ratings.push(-1);
			}
			shuffle();
		}
		
		/*private function initialize():void{
			
		}*/
		
		override protected function createUI():void {
			
		}
		
		override public function Dispose():void {
			
		}
		
		//Randomly shuffles the images in the images array		
		private function shuffle():void{
			var n:int = images.length;
			var i:int; 
			var t:int;
			while(n > 0){
				i = Math.floor(Math.random()* n--);
				t = images[n];
				images[n] = images[i];
				images[i] = t;
			}
		}
		
		//gets the array of shuffled images
		public function getImages():Array{
			return images;
		}
		
		public function getRatings():Array{
			return ratings;
		}
		
		//gets the current location
		public function getCurrentLoc():int{
			return currentLoc;
		}
		
		//Checks to see whether you have reached the end of the array of images
		public function getReachedEnd():Boolean{
			return reachedEnd;
		}
		
		//gets the next images to rate
		public function getNext():int{
			++currentLoc;
			
			if(currentLoc > (images.length -1)){
				reachedEnd = true;
				--currentLoc;
			}
			return images[currentLoc];
		}
		
		//sets the rating for the current image
		public function setRating(r:int):Boolean{
			if(currentLoc == -1){
				return false;
			}
			else{
				ratings[currentLoc] = r;
				lastRated = currentLoc;
				return true;
			}
		}
		
		//checks, based on the current location if you have gotten a badge or not
		public function badgeCheck():Boolean{
			switch(currentLoc + 1){
				case badge1:
					currentBadge = 1;
					return true;
				case badge2:
					currentBadge = 2;
					return true;
				case badge3:
					currentBadge = 3;
					return true;
				case badge4:
					currentBadge = 4;
					return true;
				case badge5:
					currentBadge = 5;
					return true;
				case badge6:
					currentBadge = 6;
					return true;
				default:
					return false;
			}
		}
		
		//gets the current badge
		public function getCurrentBadge():int{
			return currentBadge;
		}
		
		public function endsession_dwn(e:TouchEvent):void {
			button_endsession.gotoAndStop("down");
		}
		
		public function endsession_up(e:TouchEvent):void {
			button_endsession.gotoAndStop("up");
		}
		
		public function toscreen_dwn(e:TouchEvent):void {
			button_toscreen..gotoAndStop("down");
		}
		
		public function toscreen_up(e:TouchEvent):void {
			button_toscreen..gotoAndStop("up");
		}
		
		public function email_dwn(e:TouchEvent):void {
			button_email.gotoAndStop("down");
		}
		
		public function email_up(e:TouchEvent):void {
			button_email.gotoAndStop("up");
		}
		
		public function lang_dwn(e:TouchEvent):void {
			if ( Main.language == 0) { //in English mode
				button_lang.gotoAndStop("esp_down");
			} else {
				button_lang.gotoAndStop("eng_down");
			}
		}
		
		public function lang_up(e:TouchEvent):void {
			if ( Main.language == 0) { //in English mode
				button_lang.gotoAndStop("eng_up");
			} else {
				button_lang.gotoAndStop("esp_up");
			}
		}
		
		public function star1_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
		}
		
		public function star1_up(e:TouchEvent):void {
			button_star1.gotoAndStop("up");
		}
		
		public function star2_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
		}
		
		public function star2_up(e:TouchEvent):void {
			button_star2.gotoAndStop("up");
		}
		
		public function star3_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
		}
		
		public function star3_up(e:TouchEvent):void {
			button_star3.gotoAndStop("up");
		}
		
		public function star4_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
			button_star1.gotoAndStop("down");
		}
		
		public function star4_up(e:TouchEvent):void {
			button_star4.gotoAndStop("up");
		}
		
/*		public function randomRange(minNum:Number, maxNum:Number):Number{
			return (Math.floor(Math.random()*(maxNum-minNum + 1)) + minNum);
		}*/

	}
	
}
