﻿package com {
	import flash.display.Stage;
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import flash.events.Event;
	import id.core.TouchComponent;
	import id.element.BitmapLoader;
	import flash.display.DisplayObject;
	import id.core.TouchSprite;
	import caurina.transitions.Tweener;
		
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
		
		public function Photo(idValue:int){
			_id = idValue;
			blobContainerEnabled = true;
			
			addEventListener(GestureEvent.GESTURE_DRAG_1, dragHandler);
			
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
			createUI();
			commitUI();
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
			photo.blobContainerEnabled = false;
			addChild(photo);
			
		}
		
		override protected function commitUI():void{
			photo.url = iUrl;
			
		}
		
		override protected function layoutUI():void{
			var pw = photo.width;
			var ph = photo.height;
			var heightLongest:Boolean = false;
			
			//Find the longest side of this thumbnail
			if(ph >= pw){
				heightLongest = true;
			}
			
			if(heightLongest){
				photo.scaleX = photo.scaleY = 831/ph;
			}
			else{
				photo.scaleX = photo.scaleY = 1201/pw;
			}
		}
		
		private function dragHandler(e:GestureEvent):void{
			x += e.dx;
            y += e.dy;
		}

		
		
	}
}
