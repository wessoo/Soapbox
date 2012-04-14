package com {
	import flash.display.Stage;
	//import gl.events.GestureEvent;
	import flash.display.DisplayObject;	
	import gl.events.TouchEvent;
	import flash.events.Event;
	import id.core.TouchComponent;
	import id.element.BitmapLoader;
	import id.core.TouchSprite;
	import caurina.transitions.Tweener;
	import flash.geom.Point;
	import gl.touches.Touch;
		
	public class Photo extends TouchComponent{
		//Variables this object is physically made up of
		private var photo:BitmapLoader;
		
		//Data variables
		private var iUrl:String;
		private var iExt:String;
		private var iArtist:String;
		private var iBio:String;
		private var iTitle:String;
		private var iDate:String;
		private var iProcess:String;
		private var iCredit:String;

		//Other variables
		private var _id:int;
		private var savedX:Number;
		private var savedY:Number;
		private var savedContainerX:Number;
		private var savedContainerY:Number;
		private var savedScale:Number;
		private var correctionPixels:Number = 3;  //For correcting the position of the photo
		private var frameWidth:Number = 1201;  //How large the frame is that fits the photo
		private var frameHeight:Number = 831;
		private var padding:Number = 35; //padding that should go around the images
		private var viewPadding:Number = 40;
		public var viewing:Boolean = false;  //Whether or not the image is currently zoomed in
		
		private static var black:Black;
		private var cont_black:TouchSprite;
		private var cont_blocker_fullscreen:TouchSprite;
		
		public function Photo(idValue:int){
			_id = idValue;
			blobContainerEnabled = false;
			createUI();
			commitUI();
		}
		
		//Getter for this object's id
		override public function get id():int{
			return _id;
		}
		
		//Setter for this object's id
		override public function set id(idValue:int):void{
			_id = idValue;
			//parent.setChildIndex(this, 0);
			updateUI();
		}
		
		public function get url1():String{
			return iUrl;
		}
		
		public function get ext():String{
			return iExt;
		}
		
		public function get artist():String{
			return iArtist;
		}
		
		public function get bio():String{
			return iBio;
		}
		
		public function get title():String{
			return iTitle;
		}
		
		public function get date():String{
			return iDate;
		}
		
		public function get process():String{
			return iProcess;
		}
		
		public function get credit():String{
			return iCredit;
		}
		
		override protected function createUI():void{
			//Data
			iUrl = ImageParser.settings.Content.Source[_id - 1].url1;
			iExt = ImageParser.settings.Content.Source[_id - 1].ext;
			iArtist = ImageParser.settings.Content.Source[_id - 1].artist;
			iBio  = ImageParser.settings.Content.Source[_id - 1].bio;
			iTitle = ImageParser.settings.Content.Source[_id -1].title;
			iDate = ImageParser.settings.Content.Source[_id - 1].date;
			iProcess = ImageParser.settings.Content.Source[_id - 1].process;
			iCredit = ImageParser.settings.Content.Source[_id - 1].credit;
			
			photo = new BitmapLoader();
			addChild(photo);
			
			//shader
			black = new Black();
			cont_black = new TouchSprite();
			cont_black.addChild(black);
			black.x += black.width/2;
			black.y += black.height/2;
			cont_black.alpha = 0;
			
			//blocker
			cont_blocker_fullscreen = new TouchSprite();
			
			addEventListener(TouchEvent.TOUCH_UP, touchHandler, false, 0, true);
		}
		
		override protected function commitUI():void{
			photo.url = iUrl;
			
		}
		
		override protected function layoutUI():void{
			setupPhoto();
		}
		
		override protected function updateUI():void{
			iUrl = ImageParser.settings.Content.Source[_id - 1].url1;
			iExt = ImageParser.settings.Content.Source[_id - 1].ext;
			iArtist = ImageParser.settings.Content.Source[_id - 1].artist;
			iBio  = ImageParser.settings.Content.Source[_id - 1].bio;
			iTitle = ImageParser.settings.Content.Source[_id -1].title;
			iDate = ImageParser.settings.Content.Source[_id - 1].date;
			iProcess = ImageParser.settings.Content.Source[_id - 1].process;
			iCredit = ImageParser.settings.Content.Source[_id - 1].credit;
			
			removeChild(photo);
			photo.Dispose();
			photo = new BitmapLoader();
			photo.blobContainerEnabled = false;
			photo.url = iUrl;
			addChild(photo);
			
			setupPhoto();
		}
		
		private function setupPhoto():void{
			var pw = photo.width + padding * 2;
			var ph = photo.height + padding * 2;
			var heightLongest:Boolean = false;
			
			//Find the longest side of this thumbnail
			if(ph >= pw){
				heightLongest = true;
			}
			
			if(heightLongest){
				photo.scaleX = photo.scaleY = savedScale = frameHeight/ph;
			}
			else{
				photo.scaleX = photo.scaleY = savedScale = frameWidth/pw;
				//Correct the image if it is still too tall for the photo frame
				if(savedScale * ph > frameHeight){
					photo.scaleX = photo.scaleY = savedScale = frameHeight/ph;
				}
			}
			
			photo.x = savedX = (frameWidth/2) - (photo.width*photo.scaleX/2) + correctionPixels;
			photo.y = savedY = (frameHeight/2) - (photo.height*photo.scaleY/2) + correctionPixels;
		}
		
		public function setupViewingPhoto():void{
			addChild(photo);
			//photo.alpha = 0;
			var pw = photo.width + viewPadding * 2;
			var ph = photo.height + viewPadding * 2;
			var heightLongest:Boolean = false;
			

			var nxt_xScale;
			var nxt_yScale;

			//Find the longest side of this thumbnail
			if(ph >= pw){
				heightLongest = true;
			}
			
			if(heightLongest){
				//photo.scaleX = photo.scaleY = stage.stageHeight/ph;
				nxt_xScale = stage.stageHeight/ph;
				nxt_yScale = stage.stageHeight/ph;
				Tweener.addTween(photo, {scaleX: nxt_xScale, scaleY: nxt_yScale, time: 2, delay: .5});
			}
			else{
				
				nxt_xScale = nxt_yScale = stage.stageWidth/pw;
				//Correct the image if it is still too tall for the photo frame
				if(nxt_yScale * ph > stage.stageHeight){
					nxt_xScale = nxt_yScale = stage.stageHeight/ph;
				}
				Tweener.addTween(photo, {scaleX: nxt_xScale, scaleY: nxt_yScale, time: 2, delay: .5});
			}
			var nextX = (stage.stageWidth/2) - ((photo.width * nxt_xScale)/2);
			var nextY = (stage.stageHeight/2) - ((photo.height * nxt_yScale)/2);
			var localPoint:Point = globalToLocal(new Point(nextX,nextY));
			Tweener.addTween(photo, {x: localPoint.x, y: localPoint.y, time: 2, delay: .5} );
			//Tweener.addTween(photo, {alpha: 1, time: .5, delay: .5});
		}
		
		public function resetPhoto(){
			photo.x = savedX;
			photo.y = savedY;
			photo.scaleX = photo.scaleY = savedScale;
			photo.alpha = 1;
		}
		
		public function blackOn():void {
			addChild(cont_black);
			var localPoint:Point = globalToLocal(new Point(0,0));
			cont_black.x = localPoint.x;
			cont_black.y = localPoint.y;
			Tweener.addTween(cont_black, { alpha: 1, time: 1.5 } );
		}
		
		public function blackOff():void {
			Tweener.addTween(cont_black, { alpha: 0, time: 1, delay : .5, onComplete: function() { 
							 if(contains(cont_black)){
							 	removeChild(cont_black);
							 }
							 } } );
		}
		
		public function blockerOn():void {
			removeEventListener(TouchEvent.TOUCH_UP, touchHandler);
		}
		
		public function blockerOff():void {
			addEventListener(TouchEvent.TOUCH_UP, touchHandler, false, 0, true);

		}
		
		private function touchHandler(e:TouchEvent):void{
			if(!viewing){
				parent.addChild(this);
				blackOn();
				
				setupViewingPhoto();
				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { delay: .5, onComplete: function() { blockerOff(); } } );
				viewing = true;
			}
			else{
				//Tweener.addTween(photo, {alpha: 0, time: .5, onComplete: function() { resetPhoto(); }});
				/*Tweener.addTween(photo, {x: savedX, y: savedY, scaleX: savedScale, scaleY: savedScale, time: 1.5})
				blackOff();
				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { delay: .5, onComplete: function() { blockerOff(); } } );
				viewing = false;*/
				exitViewing();
			}
		}
		
		public function exitViewing():void {
			Tweener.addTween(photo, {x: savedX, y: savedY, scaleX: savedScale, scaleY: savedScale, time: 1.5})
			blackOff();
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: .5, onComplete: function() { blockerOff(); } } );
			viewing = false;
		}

		override public function Dispose():void{
			removeChild(photo);
			photo.Dispose();
			photo = null;
			
			//Data variables
			iUrl = iExt = iArtist = iBio = iTitle = iDate = iProcess = iCredit = null;

		}
		
		
	}
}
