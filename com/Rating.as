package com {
	
	public class Rating {
			private var badge1:int = 10;	//The badges that can be attained
			private var badge2:int = 25;
			private var badge3:int = 45;
			private var badge4:int = 70;
			private var badge5:int = 95;
			private var badge6:int = 120;
			
			private var images:Array;		//the array of randomized image id's
			private var ratings:Array; 		//the array of ratings of each image
			private var currentLoc:int;		//current location in the array
			private var lastRated:int;		//tells you the last image rated
			private var reachedEnd:Boolean;	//tells you if you've reached the end of the array
			private var currentBadge:int;	//The badge that the user currently has
			
		
		//Constructor
		public function Rating() {
			//initialize vars 
			images = new Array();
			ratings = new Array();
			currentLoc = -1;
			reachedEnd = false;
			currentBadge = -1;
			lastRated = -1;
			
			//initialize arrays
			for(var i:int = 1; i <= 120; ++i){
				images.push(i);
				ratings.push(-1);
			}
			shuffle();
			
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
		
/*		public function randomRange(minNum:Number, maxNum:Number):Number{
			return (Math.floor(Math.random()*(maxNum-minNum + 1)) + minNum);
		}*/

	}
	
}
