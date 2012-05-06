package com
{
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import id.core.TouchComponent;
	import flash.display.Shape;
	import flash.display.Graphics;
	//import flash.display.Stage;
	import id.core.TouchSprite;
	import flash.text.engine.EastAsianJustifier;

	import caurina.transitions.Tweener;

	public class Ranking extends TouchComponent
	{
		private var ranks:Array;
		private var list:Array;
		private var displayed:Array;


		private var totalAmount:int = 40;
		private var vheight:Number = 849;
		private var vy:Number = -446;
		private var correctV:Number = 25;
		
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

			getRankings();
			createUI();
			commitUI();
		}

		override protected function createUI():void
		{
			for (var i:int = 0; i < ranks.length; ++i)
			{
				var rp:RankPhoto = new RankPhoto(i,ranks[i]);
				list.push(rp);
			}

			for (var j:int = 0; j < 8; ++j)
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

			scrollS.graphics.beginFill(0xFFFFFF);
			scrollS.graphics.drawRect(-1925/2, vy, 1920, vheight);
			scrollS.graphics.endFill();
			scrollS.alpha = 0;

			cont_scroll.addChild(scrollS);
			addChildAt(cont_scroll, getChildIndex(displayed[7]) + 1)

			cont_scroll.addEventListener(GestureEvent.GESTURE_DRAG_1 , dragHandler, false, 0, true);
			cont_scroll.addEventListener(TouchEvent.TOUCH_UP , touchUpHandler, false, 0, true);


			cont_scroll.blobContainerEnabled = true;

		}

		override protected function layoutUI():void
		{
			//spacing = 66.48
			trace("layout that wasn't working");
		}

		/* ------------------------------------------- */
		/* ------------ Logical Functions ------------ */
		/* ------------------------------------------- */
		//Get ranks from database
		private function getRankings():void
		{
			//change this when database is up
			for (var i:int = 1; i <= 40; ++i)
			{
				ranks.push(i);
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
						if ((lastT1.y >= (vy + vheight - paddingH1) && (lastT1.y + e.dy) >= (vy + vheight - paddingH1)) || e.dy > 0)
						{
							for each (var k in displayed)
							{
								k.y +=  e.dy;
							}
							bounceBottom = false;
						}
						else if(lastT1.y >= vy + vheight - paddingH1 - maximumStretch){
							for each (var m in displayed)
							{
								m.y += (e.dy * resist);
							}
						}
						
						if(lastT1.y <= vy + vheight - paddingH1){
							bounceBottom = true;
						}
					}
				}

				if ((displayed[0].y) < vy - paddingH1 + 10)
				{
					//trace(displayed[0].y + " " + (vy - paddingH1 + 10)); 
					removeChild(displayed[0]);
					removeChild(displayed[1]);
					removeChild(displayed[2]);
					removeChild(displayed[3]);
					displayed.splice(0,4);
				}

				if (lastT1.y > vy + vheight + paddingH1 + 30) //- 20)
				{
					removeChild(displayed[displayed.length - 1]);
					removeChild(displayed[displayed.length - 2]);
					removeChild(displayed[displayed.length - 3]);
					removeChild(displayed[displayed.length - 4]);
					displayed.splice(displayed.length - 4, 4);
				}

				if ((displayed[0].y >= vy + paddingH1 - 7) && (displayed[0].id > 0))
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

				if ((lastT1.y <= vy + vheight - paddingH1 - 15) && (lastT1.id + 1 < totalAmount))
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
				var correction2:Number = vy + vheight - paddingH1 - lastT1.y;
				for each (var j in displayed){
					Tweener.addTween(j, {y: j.y + correction2, time: .5, onComplete: function(){tweening = false;}});
				}
				bounceBottom = false;
			}
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
			var prevID:RankPhoto = displayed[4];
			var prevID2:RankPhoto = displayed[5];
			var prevID3:RankPhoto = displayed[6];
			var prevID4:RankPhoto = displayed[7];

			displayed[8].x = prevID.x;
			displayed[8].y = prevID.y + vpadding;

			displayed[9].x = prevID2.x;
			displayed[9].y = prevID2.y + vpadding;

			displayed[10].x = prevID3.x;
			displayed[10].y = prevID3.y + vpadding;

			displayed[11].x = prevID4.x;
			displayed[11].y = prevID4.y + vpadding;
		}
	}
}