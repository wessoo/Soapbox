package com {
	import flash.display.Shader;
	import flash.events.Event;
	import flash.display.DisplayObject;	
	import flash.display.MovieClip;
	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import id.core.TouchComponent;
	import id.core.TouchSprite;
	
	import caurina.transitions.Tweener;	

	public class RankPhoto extends TouchComponent {
		private var photo:Photo;
		private var _id:int;
		private var _photoID:int;

		public function RankPhoto(inputID:int, photoID:int) {
			_id = inputID;
			_photoID = photoID;
			txt_rank.text = (inputID + 1).toString();
			//Photo object
			/*photo = new Photo();			
			photo.x = photo_slot.x - photo_slot.width/2;
			photo.y = photo_slot.y - photo_slot.height/2;
			addChildAt(photo, getChildIndex(effect_insetbg) + 1);*/
		}
		
		override public function get id():int{
			return _id;
		}
		
		public function get photoID():int{
			return _photoID;
		}
		
		override protected function createUI():void {
			
		}

		/* ------------------------------------------- */
		/* ------------ Logical Functions ------------ */
		/* ------------------------------------------- */
		/*
		 * Retrieves the photo ID of a photo at a given rank
		 * 
		 * @param rank - the rank to look up
		 * @return The ID of the photo at given rank
		 */
		public function getRank(rank:int):int {
			//connect to database for rank info

			return 0;
		}

		/* ------------------------------------------- */
		/* ------ Interface/Animation Functions ------ */
		/* ------------------------------------------- */

	}
	
}