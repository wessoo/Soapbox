package com {
	import flash.display.Shader;
	import flash.events.Event;
	import flash.display.DisplayObject;	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import com.refunk.events.TimelineEvent;
    import com.refunk.timeline.TimelineWatcher;
	
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
		private var currentBadge:int;	//The badge that the user currently has
		private var photoSent:Boolean;	//whether current photo has been sent (e-mailed)
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
		private var softKeyboard:KeyboardController;
		private var photo:Photo; 						//Photo object for rating
		private var dummyPhoto:Photo;					//Photo object used for creating transition
		private var timelineWatcher:TimelineWatcher;	//Used to watch timeline for labels
		
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
		private var cont_removeemail:TouchSprite;
		
		/* guidance cue booleans */
		public static var EMAIL_ADDED:Boolean = false;
		public static var SEND_BUBBLE_ON:Boolean = false;		//Whether send to screen button is displayed
		public static var SEND_BUBBLE_COMPLETE:Boolean = false; //Whether send to screen button is done animating
		public static var SLOT_WIDTH:int = 1201;
		public static var SLOT_HEIGHT:int = 831;
		
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
			cont_removeemail = new TouchSprite();
			
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
			cont_removeemail.addChild(button_removeemail);
			
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
			cont_okemail.addEventListener(TouchEvent.TOUCH_DOWN, okemail_dwn, false, 0, true);
			cont_okemail.addEventListener(TouchEvent.TOUCH_UP, okemail_up, false, 0, true);
			cont_removeemail.addEventListener(TouchEvent.TOUCH_DOWN, removeemail_dwn, false, 0, true);
			cont_removeemail.addEventListener(TouchEvent.TOUCH_UP, removeemail_up, false, 0, true);
			
			//timeline watcher for sending button
			timelineWatcher = new TimelineWatcher(bubble_toscreen);
            timelineWatcher.addEventListener(TimelineEvent.LABEL_REACHED, screen_bubble_done);
			
			//email window
			button_okemail.alpha = 0;
			window_email.text_invalidemail.alpha = 0;
			window_email.alpha = 0;
			window_email.height -= 100;
			window_email.width -= 100;
			
			//email instructions
			bubble_emailinstruct.alpha = 0;
			bubble_emailinstruct.height -= 50;
			bubble_emailinstruct.width -= 50;
			
			//send to screen bubble
			bubble_toscreen.alpha = 0;
			bubble_toscreen.height -= 50;
			bubble_toscreen.width -= 50;
			
			//email remove button
			button_removeemail.alpha = 0;
			button_removeemail.width -= 20;
			button_removeemail.height -= 20;			
			
			//exit email blocker
			hitarea_exitEmail = new ExitEmail();
			cont_exitEmail = new TouchSprite();
			cont_exitEmail.addChild(hitarea_exitEmail);
			cont_exitEmail.x = -1920 / 2;
			cont_exitEmail.y = -1080 / 2;
			cont_exitEmail.addEventListener(TouchEvent.TOUCH_UP, exitEmailUp);
			
			//shader
			shader = new Shade();
			cont_shader = new TouchSprite();
			cont_shader.addChild(shader);
			shader.alpha = 0;
			
			//blocker
			blocker_fullscreen = new Blocker();
			cont_blocker_fullscreen = new TouchSprite();
			cont_blocker_fullscreen.addChild(blocker_fullscreen);
			
			//keyboard
			softKeyboard = new KeyboardController();
			softKeyboard.x = 0;
			softKeyboard.y = 590;
			softKeyboard.alpha = 0;
			softKeyboard.width -= 100;
			softKeyboard.height -= 100;
			addChild(softKeyboard);
			
			//class event listeners
			addEventListener(TouchEvent.TOUCH_DOWN, anyTouch); //registering any touch on the screen
			addEventListener("okemail", okemail);
			addEventListener("screen_bubble_done", screen_bubble_done);
			
			//other presets
			button_email.text_emailimageto.alpha = 0; //turns off label
			email_entered.text = '';
			
			//initialize arrays
			for(var i:int = 1; i <= 120; ++i){
				images.push(i);
				ratings.push(-1);
			}
			shuffle();
			
			//Photo object
			photo = new Photo(getNext());			
			photo.x = photo_slot.x - photo_slot.width/2;
			photo.y = photo_slot.y - photo_slot.height/2;
			addChildAt(photo, getChildIndex(effect_insetbg) + 1);
			//photo.height = photo.height * 0.9;
			//photo.width = photo.width * 0.9;
			
			//dummy Photo object
			dummyPhoto = new Photo(photo.id);
			dummyPhoto.x = photo_slot.x - photo_slot.width/2;
			dummyPhoto.y = photo_slot.y - photo_slot.height/2;
			addChildAt(dummyPhoto, getChildIndex(photo) + 1);
			
			setMetadata(photo.title, photo.artist, photo.bio, photo.date, photo.process, photo.credit);
			
		}
		
		/*private function initialize():void{
			
		}*/
		
		override protected function createUI():void {
			
		}
		
		
		override public function Dispose():void {
			
		}
		
		/* ----------------------------------- */
		/* -------- Logical Functions -------- */
		/* ----------------------------------- */
		
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
				text_remaining_ratings.text = (int(text_remaining_ratings.text) - 1).toString();
				badgeCheck();
				return true;
			}
		}
		
		//checks, based on the current location if you have gotten a badge or not
		public function badgeCheck():Boolean{
			switch(currentLoc + 1){
				case badge1:
					currentBadge = 1;
					text_remaining_ratings.text = (badge2 - badge1).toString();
					return true;
				case badge2:
					currentBadge = 2;
					text_remaining_ratings.text = (badge3 - badge2).toString();
					return true;
				case badge3:
					currentBadge = 3;
					text_remaining_ratings.text = (badge4 - badge3).toString();
					return true;
				case badge4:
					currentBadge = 4;
					text_remaining_ratings.text = (badge5 - badge4).toString();
					return true;
				case badge5:
					currentBadge = 5;
					text_remaining_ratings.text = (badge6 - badge5).toString();
					return true;
				case badge6:
					currentBadge = 6;
					text_remaining_ratings.text = "0";
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
		 * Stores e-mail
		 * 
		 * @param address E-mail address
		 */
		private function storeEmail(address:String):void {
			email = address;
		}
		
		/*
		 * Calculates how far to position the X to remove email based on the email
		 * string length.
		 */
		private function getXpos():int {
			return (email_entered.x + email_entered.width/2) - (8 * email.length) + 15;
		}
		
		/* ------------------------------------------- */
		/* ------ Interface/Animation Functions ------ */
		/* ------------------------------------------- */
		private function anyTouch(e:TouchEvent):void {
			if (EMAIL_ADDED) {
				EMAIL_ADDED = false;
				Tweener.addTween(bubble_emailinstruct, { alpha: 0, time: 1 } );
				Tweener.addTween(bubble_emailinstruct, { height: bubble_emailinstruct.height - 50, width: bubble_emailinstruct.width - 50, time: 1 } );
			}
			
			if (SEND_BUBBLE_COMPLETE) {				
				SEND_BUBBLE_COMPLETE = false;
				Tweener.addTween(bubble_toscreen, { alpha: 0, time: 1 } );
				Tweener.addTween(bubble_toscreen, { height: bubble_toscreen.height - 50, width: bubble_toscreen.width - 50, time: 1, onComplete: function () {
					//SEND_BUBBLE_ON = false;
					
					cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
					cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
					bubble_toscreen.gotoAndStop(1);
				} } );
			}
		}
		
		private function endsession_dwn(e:TouchEvent):void {
			button_endsession.gotoAndStop("down");
		}
		
		private function endsession_up(e:TouchEvent):void {
			button_endsession.gotoAndStop("up");
		}
		
		private function toscreen_dwn(e:TouchEvent):void {
			button_toscreen.gotoAndStop("down");
		}
		
		private function toscreen_up(e:TouchEvent):void {
			button_toscreen.gotoAndStop("up");
			
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			
			Tweener.addTween(bubble_toscreen, { alpha: 1, time: 1 } );
			Tweener.addTween(bubble_toscreen, { height: bubble_toscreen.height + 50, width: bubble_toscreen.width + 50, 
				time: 1, transition: "easeOutElastic", onComplete: function() { 
					//bubble_toscreen.gotoAndPlay("play");						
				} } );
			bubble_toscreen.gotoAndPlay("play");
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
				addChild(softKeyboard); //put window_email above shade
				addChild(cont_okemail); //put button_okemail above all else
				Tweener.addTween(cont_shader, { y: cont_shader.y + 300, time: 1 } );				
				Tweener.addTween(this, { y: this.y - 300, time: 1 } );				
				Tweener.addTween(button_okemail, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(window_email, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(window_email, { height: window_email.height + 100, width: window_email.width + 100, delay: 0.5, time: 1, transition: "easeOutElastic" } );
				Tweener.addTween(softKeyboard, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(softKeyboard, { height: softKeyboard.height + 100, width: softKeyboard.width + 100, delay: 0.5, time: 1, transition: "easeOutElastic" } );
				dispatchEvent(new Event("shiftUp", true)); //move background up
				
				//timedBlocker(1.5);
				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { y: cont_blocker_fullscreen.y + 300, time: 1 } );
				Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
			} else if (!photoSent) { //e-mail already entered
				/* code for sending e-mail */
				
				photoSent = true;
				button_email.alpha = 0.5;
				cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
				cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			}
		}
		
		private function reactivateEmailButton():void {
			photoSent = false;
			button_email.alpha = 1;
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
		}
		
		private function exitEmailUp(e:TouchEvent):void {
			exitEmail();
		}
		
		private function okemail_dwn(e:TouchEvent):void {
			button_okemail.gotoAndStop("down");
		}
		
		private function okemail_up(e:TouchEvent):void {
			button_okemail.gotoAndStop("up");
			okemail(e);
		}
		
		private function okemail(e:Event):void {
			if ( !softKeyboard.validateEmail(softKeyboard.emailText()) ) { //e-mail invalid
				Tweener.addTween( window_email.text_invalidemail, { alpha: 1, time: 0.5 } );
				Tweener.addTween( window_email.text_invalidemail, { alpha: 0, delay: 2, time: 0.5 } );
			} else { //e-mail valid				
				email = softKeyboard.emailText();
				email_entered.text = softKeyboard.emailText();
				email_entered.alpha = 0;
				softKeyboard.clearEmail();
				exitEmail();
				
				trace(softKeyboard.emailText());
				trace(email);
				trace(email_entered.text);
				
				//crossfade action brahhhhhh
				Tweener.addTween(button_email.text_emailimage, { alpha: 0, delay: 1, time: 1 } );
				Tweener.addTween(button_email.text_emailimageto, { alpha: 1, delay: 1, time: 1 } );
				Tweener.addTween(email_entered, { alpha: 1, delay: 1, time: 1 } );
				Tweener.addTween(bubble_emailinstruct, { alpha: 1, delay: 1, time: 1 } );
				Tweener.addTween(bubble_emailinstruct, { height: bubble_emailinstruct.height + 50, width: bubble_emailinstruct.width + 50, delay: 1, time: 1, transition: "easeOutElastic" } );
				addChild(cont_removeemail);
				button_removeemail.x = getXpos();
				Tweener.addTween(button_removeemail, { alpha: 1, delay: 1, time: 1 } );
				Tweener.addTween(button_removeemail, { height: button_removeemail.height + 20, width: button_removeemail.width + 20, delay: 1, time: 1, transition: "easeOutElastic" } );
				EMAIL_ADDED = true; //bubble is on
			}
		}
		
		private function exitEmail():void {
			removeChild(cont_exitEmail); //put exit_email above shade
			Tweener.addTween(cont_shader, { y: cont_shader.y - 300, time: 1 } );				
			Tweener.addTween(this, { y: this.y + 300, time: 1 } );				
			Tweener.addTween(button_okemail, { alpha: 0, time: 1 } );
			Tweener.addTween(window_email, { alpha: 0, time: 1 } );
			Tweener.addTween(window_email, { height: window_email.height - 100, width: window_email.width - 100, time: 1, transition: "easeOutElastic" } );
			Tweener.addTween(softKeyboard, { alpha: 0, time: 1 } );
			Tweener.addTween(softKeyboard, { height: softKeyboard.height - 100, width: softKeyboard.width - 100, time: 1, transition: "easeOutElastic" } );
			dispatchEvent(new Event("shiftDown", true)); //move background down
			shadeOff();
			
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { y: cont_blocker_fullscreen.y - 300, time: 1 } );
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}
		
		private function removeemail_dwn(e:TouchEvent):void {
			button_removeemail.gotoAndStop("down");
		}
		
		private function removeemail_up(e:TouchEvent):void {
			button_removeemail.gotoAndStop("up");
			Tweener.addTween(button_email.text_emailimage, { alpha: 1, time: 1 } );
			Tweener.addTween(button_email.text_emailimageto, { alpha: 0, time: 1 } );
			Tweener.addTween(button_removeemail, { alpha: 0, time: 1 } );
			Tweener.addTween(button_removeemail, { height: button_removeemail.height - 20, width: button_removeemail.width - 20, time: 1 } );
			Tweener.addTween(email_entered, { alpha: 0, time: 1 } );
			
			email = '';
			softKeyboard.clearEmail();
		}
		
		private function setMetadata(iTitle, iArtist, iBio, iDate, iProcess, iCredit):void{
			var newline:String = "\n";
			var oldTH:Number = text_metadata.textHeight;
			var	oldWH:Number = window_metadata.height;
			text_metadata.text = iArtist + newline + iBio + newline + newline + iTitle +
								 newline + iDate + newline + newline + iProcess + newline + iCredit;
			text_metadata.wordWrap = true;
		
			text_metadata.height += (text_metadata.textHeight - oldTH);
			//window_metadata.height = text_metadata.textHeight + 14 * 2;
			//window_metadata.y += (oldWH - window_metadata.height) / 2;
			text_metadata.y = window_metadata.y - text_metadata.height / 2;
			
			Tweener.addTween(window_metadata, { time: 1, height: text_metadata.textHeight + 14 * 2, y: window_metadata.y + (oldWH - window_metadata.height) / 2 } );
			Tweener.addTween(text_metadata, { time: 1, alpha: 1} );
		}
		
		private function animateSwitch():void {
			addChildAt(photo, getChildIndex(effect_insetbg) + 1);
			addChildAt(dummyPhoto, getChildIndex(photo) + 1);
			photo.x += SLOT_WIDTH + 30;
			
			//fade out metadata
			Tweener.addTween(text_metadata, { delay: 1, time: 1, alpha: 0, onComplete: function() { 
				setMetadata(photo.title, photo.artist, photo.bio, photo.date, photo.process, photo.credit); 
			}} );
			
			Tweener.addTween(button_star1, { time: 1, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			Tweener.addTween(button_star2, { time: 1, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			Tweener.addTween(button_star3, { time: 1, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			Tweener.addTween(button_star4, { time: 1, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			
			Tweener.addTween(dummyPhoto, { delay: 1, x: dummyPhoto.x - SLOT_WIDTH - 30, time: 1.7 } );
			Tweener.addTween(photo, { x: photo.x - SLOT_WIDTH - 30, delay: 1, time: 1.7, onComplete: function() {
				removeChild(dummyPhoto);
				dummyPhoto.id = photo.id;
				dummyPhoto.x = photo_slot.x - photo_slot.width / 2;
				dummyPhoto.y = photo_slot.y - photo_slot.height / 2;
				
				button_star1.rotation = button_star2.rotation = button_star3.rotation = button_star4.rotation = 0;
				button_star1.alpha = button_star2.alpha = button_star3.alpha = button_star4.alpha = 1;
				button_star1.width = button_star2.width = button_star3.width = button_star4.width = 81.8;
				button_star1.height = button_star2.height = button_star3.height = button_star4.height = 77.8;
				
				/*button_star1.rotation = 0;
				button_star1.alpha = 1;
				button_star1.width = 200;
				button_star1.height = 200;*/
				
				button_star1.gotoAndStop("up");
				button_star2.gotoAndStop("up");
				button_star3.gotoAndStop("up");
				button_star4.gotoAndStop("up");
				
				button_star1.effect_starglow.gotoAndStop("off");
				button_star2.effect_starglow.gotoAndStop("off");
				button_star3.effect_starglow.gotoAndStop("off");
				button_star4.effect_starglow.gotoAndStop("off");
				
				
			} } );
			
			timedBlocker(2.7);
			/*blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2.2, onComplete: blockerOff } );*/
			photo.id = getNext();
		}
		
		private function star1_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
		}
		
		private function star1_up(e:TouchEvent):void {
			button_star1.effect_starglow.gotoAndPlay("on");
			animateSwitch();
			setRating(1);
			
			if (photoSent)
				reactivateEmailButton();
		}
		
		private function star2_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
		}
		
		private function star2_up(e:TouchEvent):void {
			button_star1.effect_starglow.gotoAndPlay("on");
			button_star2.effect_starglow.gotoAndPlay("on");
			
			setRating(2);
			animateSwitch();

			if (photoSent)
				reactivateEmailButton();
		}
		
		private function star3_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
		}
		
		private function star3_up(e:TouchEvent):void {
			button_star1.effect_starglow.gotoAndPlay("on");
			button_star2.effect_starglow.gotoAndPlay("on");
			button_star3.effect_starglow.gotoAndPlay("on");
			
			setRating(3);
			animateSwitch();

			if (photoSent)
				reactivateEmailButton();
		}
		
		private function star4_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
			button_star4.gotoAndStop("down");
		}
		
		private function star4_up(e:TouchEvent):void {
			button_star1.effect_starglow.gotoAndPlay("on");
			button_star2.effect_starglow.gotoAndPlay("on");
			button_star3.effect_starglow.gotoAndPlay("on");
			button_star4.effect_starglow.gotoAndPlay("on");
			
			setRating(4);
			animateSwitch();
			
			if (photoSent)
				reactivateEmailButton();
		}
		
		private function screen_bubble_done(e:TimelineEvent):void {
			if (e.currentLabel === "done") {
				trace("screen bubble complete");
				SEND_BUBBLE_COMPLETE = true;
			}
		}
		
		public function shadeOn():void {
			addChild(cont_shader);
			Tweener.addTween(shader, { alpha: 1, time: 1 } );
		}
		
		public function shadeOff():void {
			//trace("call off shader");
			Tweener.addTween(shader, { alpha: 0, time: 1, onComplete: function() { removeChild(cont_shader) } } );
		}
		
		public function timedBlocker(duration:int):void {
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: duration, onComplete: blockerOff } );
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
		
		/*private function randomRange(minNum:Number, maxNum:Number):Number{
			return (Math.floor(Math.random()*(maxNum-minNum + 1)) + minNum);
		}*/

	}
	
}
