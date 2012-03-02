package com {
	import flash.display.Stage;
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import flash.events.Event;
	import id.core.TouchComponent;
	import id.element.BitmapLoader;
	import flash.display.DisplayObject;
	import id.core.TouchSprite;
	import caurina.transitions.Tweener;
	import flash.events.GestureEvent;
	import flash.geom.Point;
		
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
		private var viewing:Boolean = false;  //Whether or not the image is currently zoomed in
		private var stageWidth:Number = 1920;
		private var stageHeight:Number = 1080;
		
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
			//blobContainerEnabled = true;
			addEventListener(TouchEvent.TOUCH_UP, touchHandler, false, 0, true);
			addChild(photo);
			
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
			var pw = photo.width + viewPadding * 2;
			var ph = photo.height + viewPadding * 2;
			var heightLongest:Boolean = false;
			
			//Find the longest side of this thumbnail
			if(ph >= pw){
				heightLongest = true;
			}
			
			if(heightLongest){
				photo.scaleX = photo.scaleY = stage.stageHeight/ph;
			}
			else{
				photo.scaleX = photo.scaleY = stage.stageWidth/pw;
				//Correct the image if it is still too tall for the photo frame
				if(photo.scaleY * ph > stage.stageHeight){
					photo.scaleX = photo.scaleY = stage.stageHeight/ph;
				}
			}
			var nextX = (stage.stageWidth/2) - ((photo.width * photo.scaleX)/2);
			var nextY = (stage.stageHeight/2) - ((photo.height * photo.scaleY)/2);
			var localPoint:Point = globalToLocal(new Point(nextX,nextY));
			photo.x = localPoint.x;
			photo.y = localPoint.y;
		}
		
		public function resetPhoto(){
			photo.x = savedX;
			photo.y = savedY;
			photo.scaleX = photo.scaleY = savedScale;
		}
		
		private function touchHandler(e:TouchEvent):void{
			if(!viewing){
				setupViewingPhoto();
				viewing = true;
			}
			else{
				resetPhoto();
				viewing = false;
			}
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
