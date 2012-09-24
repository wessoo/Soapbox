package com
{
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import flash.events.Event;
	import flash.net.*;
	import id.core.TouchComponent;
	import flash.display.Shape;
	import flash.display.Graphics;
	//import flash.display.Stage;
	import id.core.TouchSprite;
	import flash.text.engine.EastAsianJustifier; 


	import caurina.transitions.Tweener;
	import flash.utils.Dictionary;

	public class Ranking extends TouchComponent
	{
		private var ranks:Array;
		private var list:Array;
		private var displayed:Array;
		private var dict:Dictionary;


		private var totalAmount:int = 40;
		private var vheight:Number = 849;
		private var vy:Number = -446;
		private var correctV:Number = 25;
		private var bottomCorrection = 19;
		
		//Flick variables
		private var friction:Number = 0.955;
        private var dy:Number = 0;
		
		//Variables used for bounce effect
		private var resist:Number = .15;
		private var maximumStretch:Number = 60;
		
		private var tweening:Boolean = false;
		
		//Variables to set off bounce back animation when trying to scroll past the end of the list
		private var bounceTop:Boolean = false;
		private var bounceBottom:Boolean = false;

		private var hpadding:Number;//= 396.2 + 66.48;
		private var vpadding:Number;//= 399.7 + 19.8;

		private var scrollS:Shape;
		private var cont_scroll:TouchSprite;



		public function Ranking()
		{
			blobContainerEnabled = true;
			ranks = new Array();
			list = new Array();
			displayed = new Array();
			scrollS = new Shape();
			cont_scroll = new TouchSprite();
			dict = new Dictionary();

			//Language presets
			txt_top40.txt_header_esp.alpha = txt_top40.txt_body_esp.alpha = 0;
			
			setupDict();
			getInitialRankings();
		}
		
		private function setupDict():void{
			for(var i:int = 0; i < 120; ++i){
				var ext:String = ImageParser.settings.Content.Source[i].ext;
				dict[ext] = i + 1;
			}
		}

		override protected function createUI():void
		{
			for (var i:int = 0; i < ranks.length; ++i)
			{
				var rp:RankPhoto = new RankPhoto(i,ranks[i]);
				list.push(rp);
			}

			for (var j:int = 0; j < 12; ++j)
			{
				addChildAt(list[j], getChildIndex(graphic_headfoot));
				displayed.push(list[j]);
			}

		}

		override protected function commitUI():void
		{

			hpadding = ((1920 - (list[0].width * 4))/5) + list[0].width;
			vpadding = ((vheight - list[0].height * 2)/3) + list[0].height;

			list[0].x = (-1920/2) + hpadding - (list[0].width/2);
			list[0].y = vy + vpadding - (list[0].height/2) - correctV;

			for (var i:int = 1; i < 4; ++i)
			{
				list[i].x = list[i - 1].x + hpadding;
				list[i].y = list[i - 1].y;
			}

			list[4].x = list[0].x;
			list[4].y = list[0].y + vpadding;

			for (var j:int = 5; j < 8; ++j)
			{
				if (j != 0)
				{
					list[j].x = list[j - 1].x + hpadding;
					list[j].y = list[j - 1].y;
				}
			}
			
			list[8].x = list[4].x;
			list[8].y = list[4].y + vpadding;
			
			for (var k:int = 9; k < 12; ++k)
			{
				if (k != 0)
				{
					list[k].x = list[k - 1].x + hpadding;
					list[k].y = list[k - 1].y;
				}
			}

			scrollS.graphics.beginFill(0xFFFFFF);
			scrollS.graphics.drawRect(-1925/2, vy, 1920, vheight);
			scrollS.graphics.endFill();
			scrollS.alpha = 0;

			cont_scroll.addChild(scrollS);
			addChildAt(cont_scroll, getChildIndex(displayed[11]) + 1)

			cont_scroll.addEventListener(GestureEvent.GESTURE_DRAG , dragHandler, false, 0, true);
			cont_scroll.addEventListener(TouchEvent.TOUCH_UP , touchUpHandler, false, 0, true);
			cont_scroll.addEventListener(TouchEvent.TOUCH_DOWN , touchDownHandler, false, 0, true);
			cont_scroll.addEventListener(GestureEvent.GESTURE_FLICK, flickHandler, false, 0, true);


			cont_scroll.blobContainerEnabled = true;

		}

		override protected function layoutUI():void
		{
			//spacing = 66.48
			trace("layout that wasn't working");
		}
		
		override protected function updateUI():void{
			hpadding = ((1920 - (list[0].width * 4))/5) + list[0].width;
			vpadding = ((vheight - list[0].height * 2)/3) + list[0].height;

			list[0].x = (-1920/2) + hpadding - (list[0].width/2);
			list[0].y = vy + vpadding - (list[0].height/2) - correctV;

			for (var i:int = 1; i < 4; ++i)
			{
				list[i].x = list[i - 1].x + hpadding;
				list[i].y = list[i - 1].y;
			}

			list[4].x = list[0].x;
			list[4].y = list[0].y + vpadding;

			for (var j:int = 5; j < 8; ++j)
			{
				if (j != 0)
				{
					list[j].x = list[j - 1].x + hpadding;
					list[j].y = list[j - 1].y;
				}
			}
			
			list[8].x = list[4].x;
			list[8].y = list[4].y + vpadding;
			
			for (var k:int = 9; k < 12; ++k)
			{
				if (k != 0)
				{
					list[k].x = list[k - 1].x + hpadding;
					list[k].y = list[k - 1].y;
				}
			}
			removeChild(cont_scroll);
			addChildAt(cont_scroll, getChildIndex(displayed[11]) + 1)
		}
		
		public function reOrder():void{
			for each(var item:RankPhoto in displayed){
				removeChild(item);
			}
			displayed.splice(0, displayed.length);
			for (var j:int = 0; j < 12; ++j)
			{
				addChildAt(list[j], getChildIndex(graphic_headfoot));
				displayed.push(list[j]);
			}
			updateUI();
		}

		/* ------------------------------------------- */
		/* ------------ Logical Functions ------------ */
		/* ------------------------------------------- */
		//Get ranks from database
		private function getInitialRankings():void
		{
			var uR:URLRequest = new URLRequest("http://dev-mopa.bpoc.org/js-api/vote");
            var uV:URLVariables = new URLVariables();
			
			var now:Date = new Date();
            uV.date = now.toString();
                        
            uR.data = uV;
			
			var uL:URLLoader = new URLLoader(uR);
			
			uL.dataFormat = URLLoaderDataFormat.TEXT;
			
			uL.addEventListener(Event.COMPLETE, loaderCompleteHandler);
                        
			function loaderCompleteHandler(e:Event):void{
  				var output:XML = XML(uL.data);
				//trace("Data: " + output.item[0].filename);
				
				for (var i:int = 0; i < 40; ++i)
				{
					var ext:String = output.item[i].filename;
					ranks.push(dict[ext]);
				}
				
				
				//var returned:Array = data.split(",");
				//for each(var extension:String in returned){
					//ranks.push(dict[extension]);
				//}
				createUI();
				commitUI();
			}
		}
		
		public function updateRatings():void{
			ranks.splice(0, ranks.length);
			for each(var item:RankPhoto in displayed){
				removeChild(item);
			}
			
			for each(var listed:RankPhoto in list){
				listed.Dispose();
			}
			list.splice(0, list.length);
			displayed.splice(0, displayed.length);
			
			var uR:URLRequest = new URLRequest("http://dev-mopa.bpoc.org/js-api/vote");
            var uV:URLVariables = new URLVariables();
			
			var now:Date = new Date();
            uV.date = now.toString();
                        
            uR.data = uV;
			
			var uL:URLLoader = new URLLoader(uR);
			uL.dataFormat = URLLoaderDataFormat.TEXT;
			uL.addEventListener(Event.COMPLETE, loaderCompleteHandler);
                        
			function loaderCompleteHandler(e:Event):void{
				var output:XML = XML(uL.data);
				//trace("Data: " + output.item[0].filename);
				
				for (var i:int = 0; i < 40; ++i)
				{
					var ext:String = output.item[i].filename;
					ranks.push(dict[ext]);
				}
				createUI();
				updateUI();
			}
		}

		public function changeLang(lang:int):void {
			if(lang == 1) { //to Spanish
				//english off
				Tweener.addTween(txt_top40.txt_header, {alpha: 0, time: 0.5});
				Tweener.addTween(txt_top40.txt_body, {alpha: 0, time: 0.5});
				//spanish on
				Tweener.addTween(txt_top40.txt_header_esp, {alpha: 1, time: 0.5});
				Tweener.addTween(txt_top40.txt_body_esp, {alpha: 1, time: 0.5});
			} else { //to English
				//english on
				Tweener.addTween(txt_top40.txt_header, {alpha: 1, time: 0.5});
				Tweener.addTween(txt_top40.txt_body, {alpha: 1, time: 0.5});
				//spanish off
				Tweener.addTween(txt_top40.txt_header_esp, {alpha: 0, time: 0.5});
				Tweener.addTween(txt_top40.txt_body_esp, {alpha: 0, time: 0.5});
			}
		}


		/* ------------------------------------------- */
		/* ------ Interface/Animation Functions ------ */
		/* ------------------------------------------- */
		private function dragHandler(e:GestureEvent):void
		{
			var paddingH1:Number = ((vheight - list[0].height * 2)/3) + list[0].height/2;
			if (! tweening)
			{
				var lastT1 = displayed[displayed.length - 1];
				if ((lastT1.id != (totalAmount - 1)) && (displayed[0].id != 0))
				{
					for each (var i in displayed)
					{
						i.y +=  e.dy;
					}
				}
				else
				{
					if (displayed[0].id == 0)
					{
						bounceTop = false;
						if ((displayed[0].y <= vy + paddingH1 - correctV && (displayed[0].y + e.dy) <= vy + paddingH1 - correctV) || e.dy < 0)
						{
							for each (var j in displayed)
							{
								j.y +=  e.dy;
							}
						}else if(displayed[0].y <= vy + paddingH1 + maximumStretch)
						{
							for each (var l in displayed)
							{
								l.y += (e.dy * resist);
							}
						}
						if(displayed[0].y >= vy + paddingH1 - correctV){
							bounceTop = true;
						}
					}
					else
					{
						bounceBottom = false;
						if ((lastT1.y >= (vy + vheight - paddingH1 + correctV +  bottomCorrection) && (lastT1.y + e.dy) >= (vy + vheight - paddingH1 + correctV +  bottomCorrection)) || e.dy > 0)
						{
							for each (var k in displayed)
							{
								k.y +=  e.dy;
							}
							bounceBottom = false;
						}
						else if(lastT1.y >= vy + vheight - paddingH1 + correctV +  bottomCorrection - maximumStretch){
							for each (var m in displayed)
							{
								m.y += (e.dy * resist);
							}
						}
						
						if(lastT1.y <= vy + vheight - paddingH1 + correctV +  bottomCorrection){
							bounceBottom = true;
							trace("bottom");
						}
					}
				}

				if ((displayed[0].y) < vy - displayed[0].height/2 + 10)
				{
					removeChild(displayed[0]);
					removeChild(displayed[1]);
					removeChild(displayed[2]);
					removeChild(displayed[3]);
					displayed.splice(0,4);
				}

				if (lastT1.y > vy + vheight + paddingH1) //- 20)
				{
					removeChild(displayed[displayed.length - 1]);
					removeChild(displayed[displayed.length - 2]);
					removeChild(displayed[displayed.length - 3]);
					removeChild(displayed[displayed.length - 4]);
					displayed.splice(displayed.length - 4, 4);
				}

				if ((displayed[0].y >= vy + displayed[0].height/2) && (displayed[0].id > 0) && (e.dy > 0))
				{
					addChildAt(list[displayed[0].id - 4], getChildIndex(cont_scroll) - 1);
					addChildAt(list[displayed[0].id - 3], getChildIndex(cont_scroll) - 1);
					addChildAt(list[displayed[0].id - 2], getChildIndex(cont_scroll) - 1);
					addChildAt(list[displayed[0].id - 1], getChildIndex(cont_scroll) - 1);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					updateTop();
				}

				if ((lastT1.y <= vy + vheight - displayed[displayed.length -1].height/2) && (lastT1.id + 1 < totalAmount) && (e.dy < 0))
				{
					addChildAt(list[lastT1.id + 1], getChildIndex(cont_scroll) - 1);
					addChildAt(list[lastT1.id + 2], getChildIndex(cont_scroll) - 1);
					addChildAt(list[lastT1.id + 3], getChildIndex(cont_scroll) - 1);
					addChildAt(list[lastT1.id + 4], getChildIndex(cont_scroll) - 1);
					displayed.push(list[lastT1.id + 1]);
					displayed.push(list[lastT1.id + 2]);
					displayed.push(list[lastT1.id + 3]);
					displayed.push(list[lastT1.id + 4]);
					updateBottom();
				}
			}
		}
		
		private function touchUpHandler(e:TouchEvent):void{
			var paddingH1:Number = ((vheight - list[0].height * 2)/3) + list[0].height/2;
			if(bounceTop){
				tweening = true;
				var correction:Number = (-displayed[0].y) - (-(vy + paddingH1 - correctV))
				for each (var i in displayed){
					Tweener.addTween(i, {y: i.y + correction, time: .5, onComplete: function(){tweening = false;}});
				}
				bounceTop = false;
			}
			
			if(bounceBottom){
				tweening = true;
				var lastT1 = displayed[displayed.length - 1];
				var correction2:Number = vy + vheight - paddingH1 + correctV +  bottomCorrection - lastT1.y;
				for each (var j in displayed){
					Tweener.addTween(j, {y: j.y + correction2, time: .5, onComplete: function(){tweening = false;}});
				}
				bounceBottom = false;
			}
		}
		
		private function touchDownHandler(e:TouchEvent):void{
			dy = 0;
		}

		private function updateTop():void
		{
			var nextID:RankPhoto = displayed[4];
			var nextID2:RankPhoto = displayed[5];
			var nextID3:RankPhoto = displayed[6];
			var nextID4:RankPhoto = displayed[7];

			displayed[0].x = nextID.x;
			displayed[0].y = nextID.y - vpadding;

			displayed[1].x = nextID2.x;
			displayed[1].y = nextID2.y - vpadding;

			displayed[2].x = nextID3.x;
			displayed[2].y = nextID3.y - vpadding;

			displayed[3].x = nextID4.x;
			displayed[3].y = nextID4.y - vpadding;
		}

		private function updateBottom():void
		{
			var prevID:RankPhoto = displayed[displayed.length - 8];
			var prevID2:RankPhoto = displayed[displayed.length - 7];
			var prevID3:RankPhoto = displayed[displayed.length - 6];
			var prevID4:RankPhoto = displayed[displayed.length - 5];

			displayed[displayed.length - 4].x = prevID.x;
			displayed[displayed.length - 4].y = prevID.y + vpadding;

			displayed[displayed.length - 3].x = prevID2.x;
			displayed[displayed.length - 3].y = prevID2.y + vpadding;

			displayed[displayed.length - 2].x = prevID3.x;
			displayed[displayed.length - 2].y = prevID3.y + vpadding;

			displayed[displayed.length - 1].x = prevID4.x;
			displayed[displayed.length - 1].y = prevID4.y + vpadding;
		}
		
		private function flickHandler(e:GestureEvent):void{
			dy = e.velocityY
            addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler(e:Event):void {
            if (Math.abs(dy) <= 1) {
                dy = 0;
                removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
            }
			
			var paddingH1:Number = ((vheight - list[0].height * 2)/3) + list[0].height/2;
			if (! tweening)
			{
				var lastT1 = displayed[displayed.length - 1];
				if ((lastT1.id != (totalAmount - 1)) && (displayed[0].id != 0))
				{
					for each (var i in displayed)
					{
						i.y +=  dy;
					}
				}
				else
				{
					if (displayed[0].id == 0)
					{
						bounceTop = false;
						if ((displayed[0].y <= vy + paddingH1 - correctV && (displayed[0].y + dy) <= vy + paddingH1 - correctV) || dy < 0)
						{
							for each (var j in displayed)
							{
								j.y +=  dy;
							}
						}
						else{
							dy = 0;
						}
					}
					else
					{
						bounceBottom = false;
						if ((lastT1.y >= (vy + vheight - paddingH1 + correctV +  bottomCorrection) && (lastT1.y + dy) >= (vy + vheight - paddingH1 + correctV +  bottomCorrection)) || dy > 0)
						{
							for each (var k in displayed)
							{
								k.y +=  dy;
							}
							bounceBottom = false;
						}
						else{
							dy = 0;
						}
					}
				}

				if ((displayed[0].y) < vy - displayed[0].height/2 + 10)
				{
					removeChild(displayed[0]);
					removeChild(displayed[1]);
					removeChild(displayed[2]);
					removeChild(displayed[3]);
					displayed.splice(0,4);
				}

				if (lastT1.y > vy + vheight + paddingH1) //- 20)
				{
					removeChild(displayed[displayed.length - 1]);
					removeChild(displayed[displayed.length - 2]);
					removeChild(displayed[displayed.length - 3]);
					removeChild(displayed[displayed.length - 4]);
					displayed.splice(displayed.length - 4, 4);
				}

				if ((displayed[0].y >= vy + displayed[0].height/2) && (displayed[0].id > 0) && (dy > 0))
				{
					addChildAt(list[displayed[0].id - 4], getChildIndex(cont_scroll) - 1);
					addChildAt(list[displayed[0].id - 3], getChildIndex(cont_scroll) - 1);
					addChildAt(list[displayed[0].id - 2], getChildIndex(cont_scroll) - 1);
					addChildAt(list[displayed[0].id - 1], getChildIndex(cont_scroll) - 1);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					displayed.splice(0,0, list[displayed[0].id - 1]);
					updateTop();
				}

				if ((lastT1.y <= vy + vheight - displayed[displayed.length -1].height/2) && (lastT1.id + 1 < totalAmount) && (dy < 0))
				{
					addChildAt(list[lastT1.id + 1], getChildIndex(cont_scroll) - 1);
					addChildAt(list[lastT1.id + 2], getChildIndex(cont_scroll) - 1);
					addChildAt(list[lastT1.id + 3], getChildIndex(cont_scroll) - 1);
					addChildAt(list[lastT1.id + 4], getChildIndex(cont_scroll) - 1);
					displayed.push(list[lastT1.id + 1]);
					displayed.push(list[lastT1.id + 2]);
					displayed.push(list[lastT1.id + 3]);
					displayed.push(list[lastT1.id + 4]);
					updateBottom();
				}
			}
			
			dy *= friction;
        }
		
		
		
	}
}