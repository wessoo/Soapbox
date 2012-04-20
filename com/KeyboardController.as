package com  {
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
			format.font = "Calibri";
			format.align = TextFieldAutoSize.CENTER;
			format.color = 0x666666;
			format.size = 20;
			format.bold = true;
		}
		
		override protected function layoutUI():void{
			keyboard.scaleX = keyboard.scaleY = 0.85;
		}

		/* Sets input text field to a new text field
		 *
		 */
		public function setInputTF(newInput:TextField):void {
			keyboard.input = newInput;
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

		public function validateName(address:String):Boolean {
			//var name_REGEX:RegExp = /^[A-Z]'?[- a-zA-Z]( [a-zA-Z])*$/;
			//var name_REGEX:RegExp = /^[A-Z]'?[- a-zA-Z]( [a-zA-Z])*$/;

			//return name_REGEX.test(address);
			return (address != '');
		}
		
		public function toDefault():void {
			keyboard.toDefault();
		}

		public function emailText():String{
			return keyboard.inputTxt.text;
		}
		
		public function clearEmail():void {
			keyboard.inputTxt.text = '';
		}
	}	
}
