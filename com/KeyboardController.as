﻿package com  {
	import flash.text.*;
	import flash.events.Event;
	import gl.events.TouchEvent;
	import id.core.TouchComponent;
	import flash.display.MovieClip;
	import id.core.TouchSprite;
	import caurina.transitions.Tweener;

	
	public class KeyboardController extends TouchComponent{
		public var emailInputTxt:TextField;
		public var keyboard:SoftKeyboard;
		public var touchName:TouchSprite;
		public var touchTitle:TouchSprite;
		//private var n:NameInput;
		//private var t:TitleInput;
		private var format:TextFormat;
		
		public var english:Boolean = true;
		public var transition:Boolean = false; //animation is occurring
		
		public function KeyboardController(){
			format = new TextFormat();
			emailInputTxt = new TextField();
			keyboard = new SoftKeyboard(emailInputTxt);
			addChild(keyboard);
			
			commitUI();
			layoutUI();
		}
		
		override protected function commitUI():void{
			format.font = "Arial";
			format.align = TextFieldAutoSize.CENTER;
			format.color = 0x666666;
			format.size = 20;
			format.bold = true;
			
			emailInputTxt.type = TextFieldType.INPUT; 
			emailInputTxt.width = 365; 
			emailInputTxt.height = 30;
			emailInputTxt.border = false;
			emailInputTxt.background = false;
			emailInputTxt.defaultTextFormat = format;
		}
		
		override protected function layoutUI():void{
			//x = 0;
			//y = 0;
			keyboard.scaleX = keyboard.scaleY = 0.7;
			emailInputTxt.x = 515;
			emailInputTxt.y = 75;
			addChild(emailInputTxt);
			
			//keyboard.y = touchName.y + touchName.height + 100;
			//keyboard.alpha = 0;
			
		}
		
		/*
		 * Checks to see whether e-mail is a valid e-mail
		 * 
		 * @param address E-mail address
		 * @return Boolean whether e-mail is validated
		 */
		public function validateEmail(address:String):Boolean {
			var email_REGEX:RegExp = /^[0-9a-zA-Z][-._a-zA-Z0-9]*@([0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4}$/;
			
			return email_REGEX.test(address);
		}
		
		public function emailText():String{
			return emailInputTxt.text;
		}
		
		public function clearEmail():void {
			emailInputTxt.text = '';
		}
	}	
}
