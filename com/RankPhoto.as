package com {
	//import flash.display.Shader;
	//import flash.events.Event;
	//import flash.display.DisplayObject;	
	//import flash.display.MovieClip;
	
	//import gl.events.GestureEvent;
	//import gl.events.TouchEvent;
	import id.core.TouchComponent;
	import id.element.BitmapLoader;

	//import id.core.TouchSprite;
	
	//import caurina.transitions.Tweener;	

	public class RankPhoto extends TouchComponent {
		private var photo:BitmapLoader;
		private var _id:int;
		private var _photoID:int;
		
		private var iUrl:String;
		private var iArtist:String;
		private var iTitle:String;
		private var iDate:String;
		private var iCopyright:String;

		public function RankPhoto(inputID:int, photoID:int) {
			_id = inputID;
			_photoID = photoID;
			txt_rank.htmlText = bold((inputID + 1).toString());
			createUI();
			commitUI();
			
		}
		
		override public function get id():int{
			return _id;
		}
		
		public function get photoID():int{
			return _photoID;
		}
		
		override protected function createUI():void {
			iUrl = ImageParser.settings.Content.Source[_photoID - 1].url2;
			iArtist = ImageParser.settings.Content.Source[_photoID - 1].artist;
			iTitle = ImageParser.settings.Content.Source[_photoID -1].title;
			iDate = ImageParser.settings.Content.Source[_photoID - 1].date;
			iCopyright = ImageParser.settings.Content.Source[_photoID - 1].copyright;
			
			photo = new BitmapLoader();
			addChild(photo);
		}
		override protected function commitUI():void{
			photo.url = iUrl;
			photo.scaleX = 1;
			photo.scaleY = 1;
			var newline:String = "<br>";
			txt_metadata.wordWrap = true;
			txt_metadata.multiline = true;
			txt_metadata.htmlText = bold(iArtist) + newline + italic(iTitle) + newline + iDate + newline + iCopyright;
		}
		
		override protected function layoutUI():void{
			setupPhoto();
		}
		
		override public function Dispose():void{
			removeChild(photo);
			photo.Dispose();
			photo = null;
		}

		/* ------------------------------------------- */
		/* ------------ Logical Functions ------------ */
		/* ------------------------------------------- */
		private function bold(input:String):String{
			return "<B>" + input + "</B>";
		}
		
		private function italic(input:String):String{
			return "<I>" + input + "</I>";
		}
		
		private function setupPhoto():void{
			var padding = 10;
			var frameWidth = photo_slot.width;
			var frameHeight = photo_slot.height;
			var pw = photo.width + padding * 2;
			var ph = photo.height + padding * 2;
			var heightLongest:Boolean = false;
			
			//Find the longest side of this thumbnail
			if(ph >= pw){
				heightLongest = true;
			}
			
			if(heightLongest){
				photo.scaleX = photo.scaleY = frameHeight/ph;
			}
			else{
				photo.scaleX = photo.scaleY = frameWidth/pw;
				//Correct the image if it is still too tall for the photo frame
				if(photo.scaleY * ph > frameHeight){
					photo.scaleX = photo.scaleY = frameHeight/ph;
				}
			}
			
			photo.x = photo_slot.x - (photo.width*photo.scaleX/2);
			photo.y = photo_slot.y - (photo.height*photo.scaleY/2);
		}

		/* ------------------------------------------- */
		/* ------ Interface/Animation Functions ------ */
		/* ------------------------------------------- */

	}
	
}