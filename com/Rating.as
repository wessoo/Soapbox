﻿package com {
	import flash.display.Shader;
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
		private var images:Array;     	//the array of randomized image id's
		private var ratings:Array; 		//the array of ratings of each image
		private var currentLoc:int;		//current location in the array
		private var lastRated:int;		//tells you the last image rated
		private var reachedEnd:Boolean; //tells you if you've reached the end of the array
		private var email:String;
		private var currentBadge:int;			//The badge that the user currently has
		private static var badge1:int = 10;		//The badges that can be attained
		private static var badge2:int = 25;
		private static var badge3:int = 45;
		private static var badge4:int = 70;
		private static var badge5:int = 95;
		private static var badge6:int = 120;			
		
		/* dyanmic interface components */
		private static var hitarea_exitEmail:ExitEmail;	//hit area outside of email box and keyboard to return to Rating screen
		private static var shader:Shade;
		private static var blocker_fullscreen:Blocker;
		
		/* button containers */
		private var cont_endsession:TouchSprite;
		private var cont_toscreen:TouchSprite;
		private var cont_email:TouchSprite;
		private var cont_star1:TouchSprite;
		private var cont_star2:TouchSprite;
		private var cont_star3:TouchSprite;
		private var cont_star4:TouchSprite;
		private var cont_okemail:TouchSprite;
		private var cont_exitEmail:TouchSprite;
		private var cont_shader:TouchSprite;
		private var cont_blocker_fullscreen:TouchSprite;
		
		public function Rating() {
			super();
			
			//initialize vars 
			images = new Array();
			ratings = new Array();
			currentLoc = -1;
			reachedEnd = false;
			currentBadge = -1;
			lastRated = -1;
			email = '';
			
			cont_endsession = new TouchSprite();
			cont_toscreen = new TouchSprite();
			cont_email = new TouchSprite();
			cont_star1 = new TouchSprite();
			cont_star2 = new TouchSprite();
			cont_star3 = new TouchSprite();
			cont_star4 = new TouchSprite();
			cont_okemail = new TouchSprite();
			
			cont_endsession.addChild(button_endsession);
			addChild(cont_endsession);
			cont_toscreen.addChild(button_toscreen);
			addChild(cont_toscreen);
			cont_email.addChild(button_email);
			addChild(cont_email);
			cont_star1.addChild(button_star1);
			addChild(cont_star1);
			cont_star2.addChild(button_star2);
			addChild(cont_star2);
			cont_star3.addChild(button_star3);
			addChild(cont_star3);
			cont_star4.addChild(button_star4);
			addChild(cont_star4);
			cont_okemail.addChild(button_okemail);
			addChild(cont_okemail);
			
			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			
			button_okemail.alpha = 0;
			window_email.alpha = 0;
			window_email.height -= 100;
			window_email.width -= 100;
			
			//exit email blocker
			hitarea_exitEmail = new ExitEmail();
			cont_exitEmail = new TouchSprite();
			cont_exitEmail.addChild(hitarea_exitEmail);
			cont_exitEmail.x = -1920 / 2;
			cont_exitEmail.y = -1080 / 2;
			cont_exitEmail.addEventListener(TouchEvent.TOUCH_UP, exitEmail);
			
			//shader
			shader = new Shade();
			cont_shader = new TouchSprite();
			cont_shader.addChild(shader);
			shader.alpha = 0;
			
			//TEMP
			//shader.alpha = 1;
			//addChild(cont_shader);
			
			//blocker
			blocker_fullscreen = new Blocker();
			cont_blocker_fullscreen = new TouchSprite();
			cont_blocker_fullscreen.addChild(blocker_fullscreen);
			
			//initialize arrays
			for(var i:int = 1; i <= 120; ++i){
				images.push(i);
				ratings.push(-1);
			}
			shuffle();
			
			//addPhoto();
			currentLoc = 0; //delete when addPhoto() has been written
			getNext();
		}
		
		/*private function initialize():void{
			
		}*/
		
		override protected function createUI():void {
			
		}
		
		override public function Dispose():void {
			
		}
		
		/* ------ Logical Functions ------ */
		
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
		
		/* 
		 * Sets the rating for the current image
		 * 
		 * @param r Rating of current image
		 * @return Boolean Returns whether rating was successful or not
		 */
		public function setRating(r:int):Boolean{
			if(currentLoc == -1){
				return false;
			}else{
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
		
		public function changeLang():void {
			if (Main.language == 0) {
				
			} else {
				
			}
		}
		
		/*
		 * Resets the session. Returns currentLoc to -1, clears the ratings array.
		 */
		public function resetSession():void {
			currentLoc = -1;
			reachedEnd = false;
			currentBadge = -1;
			lastRated = -1;
			
			for (var i:int = 0; i < ratings.length; i++) {
				ratings[i] = -1;
			}
			
			
		}
		
		//gets the current badge
		public function getCurrentBadge():int{
			return currentBadge;
		}
		
		/*
		 * Checks to see whether e-mail is a valid e-mail
		 * 
		 * @param address E-mail address
		 * @return Boolean whether e-mail is validated
		 */
		private function validateEmail(address:String):Boolean {
			var email_REGEX:RegExp = /^[0-9a-zA-Z][-._a-zA-Z0-9]*@([0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4}$/;
			
			return email_REGEX.test(address);
		}
		
		/*
		 * Stores e-mail
		 * 
		 * @param address E-mail address
		 */
		private function storeEmail(address:String):void {
			email = address;
		}
		
		/* ------ Interface/Animation Functions ------ */
		
		private function endsession_dwn(e:TouchEvent):void {
			button_endsession.gotoAndStop("down");
		}
		
		private function endsession_up(e:TouchEvent):void {
			button_endsession.gotoAndStop("up");
		}
		
		private function toscreen_dwn(e:TouchEvent):void {
			button_toscreen..gotoAndStop("down");
		}
		
		private function toscreen_up(e:TouchEvent):void {
			button_toscreen..gotoAndStop("up");
		}
		
		private function email_dwn(e:TouchEvent):void {
			button_email.gotoAndStop("down");
		}
		
		private function email_up(e:TouchEvent):void {
			button_email.gotoAndStop("up");
			
			if (email == '') { //if no e-mail entered yet
				shadeOn();
				addChild(cont_exitEmail); //put exit_email above shade
				addChild(window_email); //put window_email above shade
				addChild(cont_okemail); //put button_okemail above all else
				Tweener.addTween(cont_shader, { y: cont_shader.y + 300, time: 1 } );				
				Tweener.addTween(this, { y: this.y - 300, time: 1 } );				
				Tweener.addTween(button_okemail, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(window_email, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(window_email, { height: window_email.height + 100, width: window_email.width + 100, delay: 0.5, time: 1, transition: "easeOutElastic" } );
				dispatchEvent(new Event("shiftUp", true)); //move background up
				
				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { y: cont_blocker_fullscreen.y + 300, time: 1 } );
				Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
			} else { //e-mail already entered
				
			}
		}
		
		private function exitEmail(e:TouchEvent):void {
			removeChild(cont_exitEmail); //put exit_email above shade
			Tweener.addTween(cont_shader, { y: cont_shader.y - 300, time: 1 } );				
			Tweener.addTween(this, { y: this.y + 300, time: 1 } );				
			Tweener.addTween(button_okemail, { alpha: 0, time: 1 } );
			Tweener.addTween(window_email, { alpha: 0, time: 1 } );
			Tweener.addTween(window_email, { height: window_email.height - 100, width: window_email.width - 100, time: 1, transition: "easeOutElastic" } );
			dispatchEvent(new Event("shiftDown", true)); //move background down
			shadeOff();
			
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { y: cont_blocker_fullscreen.y - 300, time: 1 } );
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}
		
		private function star1_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
		}
		
		private function star1_up(e:TouchEvent):void {
			button_star1.gotoAndStop("up");
			
			setRating(1);
			getNext();
		}
		
		private function star2_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
		}
		
		private function star2_up(e:TouchEvent):void {
			button_star1.gotoAndStop("up");
			button_star2.gotoAndStop("up");
			
			setRating(2);
			getNext();
		}
		
		private function star3_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
		}
		
		private function star3_up(e:TouchEvent):void {
			button_star1.gotoAndStop("up");
			button_star2.gotoAndStop("up");
			button_star3.gotoAndStop("up");
			
			setRating(3);
			getNext();
		}
		
		private function star4_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
			button_star4.gotoAndStop("down");
		}
		
		private function star4_up(e:TouchEvent):void {
			button_star1.gotoAndStop("up");
			button_star2.gotoAndStop("up");
			button_star3.gotoAndStop("up");
			button_star4.gotoAndStop("up");
			
			setRating(4);
			getNext();
		}
		
		public function shadeOn():void {
			addChild(cont_shader);
			Tweener.addTween(shader, { alpha: 1, time: 1 } );
		}
		
		public function shadeOff():void {
			//trace("call off shader");
			Tweener.addTween(shader, { alpha: 0, time: 1, onComplete: function() { removeChild(cont_shader) } } );
		}
		
		public function blockerOn():void {
			//trace("blocker ON");
			addChild(cont_blocker_fullscreen);
			setChildIndex(cont_blocker_fullscreen, numChildren - 1);
			cont_blocker_fullscreen.visible = true;
		}
		
		public function blockerOff():void {
			//trace("blocker OFF");
			removeChild(cont_blocker_fullscreen);
			cont_blocker_fullscreen.visible = false;
		}
		
/*		private function randomRange(minNum:Number, maxNum:Number):Number{
			return (Math.floor(Math.random()*(maxNum-minNum + 1)) + minNum);
		}*/

	}
	
}
