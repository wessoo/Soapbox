package com {
	import flash.display.Shader;
	import flash.events.Event;
	import flash.display.DisplayObject;	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.net.*;
	import com.refunk.events.TimelineEvent;
    import com.refunk.timeline.TimelineWatcher;
    import fl.video.*;

	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import id.core.TouchComponent;
	import id.core.TouchSprite;
	
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	
	import caurina.transitions.Tweener;	
	import flash.net.*;

	public class Rating extends TouchComponent {
		private var images:Array;     	//the array of randomized image id's
		private var emails:Array;		//the array of user emails
		private var packages:Array;		//the array of packages of images associated with the emails array
		private var ratings:Array; 		//the array of ratings of each image
		private var currentLoc:int;		//current location in the array
		private var lastRated:int;		//tells you the last image rated
		private var reachedEnd:Boolean; //tells you if you've reached the end of the array
		private var email:String;
		private var fullname:String;	//full name of person that completed Soapbox
		public var currentBadge:int;	//The badge that the user currently has
		private var photoSent:Boolean;	//whether current photo has been sent (e-mailed)
		private var photosMarked:Boolean = false;		//whether there have been any photos marked for this session
		private var package_created:Boolean = false; 	//whether any images have been packaged
		private var maillist_opt:Boolean = true;		//opting in/out of MOPA mail list. Default opt in.
		public var sendBadges:Boolean = false;			//whether to send badges, used to determine animation
		private var wantsShared = false 		//used to determine whether or not user wants to share an image with himself
		private var aboutShowing:Boolean = false;
		private var gotBadge_bool:Boolean = false;		//used to determine whether a blocker for the photo transition needs to last long
		private var request:URLRequest;
		private var variables:URLVariables;
		private var loader:URLLoader;
		private var soapbox_xml:XML;
		private var myLoader:URLLoader;
		private var now:Date; 			//used to differentiate requests of same time
		private var language:int = 0;
		private static var badge1:int = 10;		//The badges that can be attained
		private static var badge2:int = 25;
		private static var badge3:int = 45;
		private static var badge4:int = 70;
		private static var badge5:int = 95;
		private static var badge6:int = 120;
		private static var debugSpeed:int = 1; //The debugging speed for rating images (1 means normal, 2 mean 2x, etc...)
											   //Keep the debug speed a multiple of 120!!
		
		/* dyanmic interface components */
		private static var hitarea_exitEmail:ExitEmail;	//hit area outside of email box and keyboard to return to Rating screen
		private static var hitarea_es_exitKeyboard:ExitKeyboard; //hit area outside of keyboard in end session
		private static var shader:Shade;
		private static var instructions:Instructions;
		private static var blocker_fullscreen:Blocker;
		private var softKeyboard:KeyboardController;
		private var photo:Photo; 						//Photo object for rating
		private var dummyPhoto:Photo;					//Photo object used for creating transition
		private var timelineWatcher:TimelineWatcher;	//Used to watch timeline for labels
		
		/* button containers */
		private var cont_endsession:TouchSprite;
		private var cont_toscreen:TouchSprite;
		private var cont_email:TouchSprite;
		private var cont_about:TouchSprite;
		private var cont_star1:TouchSprite;
		private var cont_star2:TouchSprite;
		private var cont_star3:TouchSprite;
		private var cont_star4:TouchSprite;
		private var cont_okemail:TouchSprite;
		private var cont_exitEmail:TouchSprite;
		private var cont_es_exitKeyboard:TouchSprite;
		private var cont_shader:TouchSprite;
		private var cont_instructions:TouchSprite;
		private var cont_blocker_fullscreen:TouchSprite;
		private var cont_blocker_photo:TouchSprite;
		private var cont_removeemail:TouchSprite;
		private var cont_continue:TouchSprite;
		private var cont_endsession_modal:TouchSprite;
		private var cont_gotbadge_modal:TouchSprite;
		private var cont_es_continue:TouchSprite;
		private var cont_es_yes:TouchSprite;
		private var cont_es_no:TouchSprite;
		private var cont_es_mailbg:TouchSprite;
		private var cont_es_maillist:TouchSprite;
		private var cont_es_removeemail:TouchSprite;
		private var cont_es_okemail:TouchSprite;
		private var cont_es_esskip:TouchSprite;
		private var cont_okname:TouchSprite;
		//private var cont_namebg:TouchSprite;
		private var cont_skip:TouchSprite;
		private var cont_help:TouchSprite;
		private var cont_video1:TouchSprite;
		private var cont_video2:TouchSprite;
		private var cont_video3:TouchSprite;
		private var cont_video4:TouchSprite;
		private var cont_video5:TouchSprite;
		private var cont_video6:TouchSprite;
		//private var cont_badgeemail:TouchSprite;
		
		/* guidance cue booleans */
		private static var EMAIL_ADDED:Boolean = false;
		private static var SEND_BUBBLE_ON:Boolean = false;		//Whether send to screen button is displayed
		private static var SEND_BUBBLE_COMPLETE:Boolean = false; //Whether send to screen button is done animating
		private static var PACKAGED_COMPLETE:Boolean = false;	//Whether packaged bubble is done animating
		private static var SLOT_WIDTH:int = 1201;
		private static var SLOT_HEIGHT:int = 831;
		private static var PHOTO_LOCX:int;
		private static var PHOTO_LOCY:int;
		private static var ES_LOCY:int;
		private static var GB_LOCY:int;
		private static var DEFAULT_ES_MODALBG_Y:int;
		private static var DEFAULT_ES_MODALBG_HEIGHT:int;
		private static var DEFAULT_ES_MAILBGY:int;
		private static var DEFAULT_ES_ENDSESSIONY:int;
		private static var DEFAULT_ES_PROMPTY:int;
		private static var DEFAULT_ES_EMAILY:int;
		private static var DEFAULT_ES_INVALIDY:int;
		private static var EXPAND_HEIGHT:int = 210;					//height to expand end session window to accomodate keyboard
		private static var GB_EXPAND_HEIGHT:int = 300;					//height to expand end session window to accomodate keyboard
		private static var BUBBLE_EMAILINSTRUCT_HT:int;
		private static var BUBBLE_EMAILINSTRUCT_WD:int;
		private static var REMOVEEMAIL_SIZE:int;
		private static var SCREEN_URL:String = "http://192.168.10.101:4100/show?image=";

		public function Rating() {
			super();
			
			request = new URLRequest(SCREEN_URL);
			variables = new URLVariables();
			loader = new URLLoader();

			//Reading interface text from XML
			myLoader = new URLLoader();
			myLoader.load(new URLRequest("soapbox_interfacetext.xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);
			//End interface text from XML

			//initialize vars 
			images = new Array();
			ratings = new Array();
			emails = new Array();
			packages = new Array();
			currentLoc = -1;
			reachedEnd = false;
			currentBadge = -1;
			lastRated = -1;
			email = '';
			
			cont_endsession = new TouchSprite();
			cont_toscreen = new TouchSprite();
			cont_email = new TouchSprite();
			cont_about = new TouchSprite();
			cont_star1 = new TouchSprite();
			cont_star2 = new TouchSprite();
			cont_star3 = new TouchSprite();
			cont_star4 = new TouchSprite();
			cont_okemail = new TouchSprite();
			cont_removeemail = new TouchSprite();
			cont_continue = new TouchSprite();
			cont_endsession_modal = new TouchSprite();
			cont_gotbadge_modal = new TouchSprite();
			cont_es_continue = new TouchSprite();
			cont_es_no = new TouchSprite();
			cont_es_yes = new TouchSprite();
			cont_es_maillist = new TouchSprite();
			cont_es_removeemail = new TouchSprite();
			cont_es_mailbg = new TouchSprite();
			cont_es_okemail = new TouchSprite();
			cont_es_esskip = new TouchSprite();
			cont_okname = new TouchSprite();
			//cont_namebg = new TouchSprite();
			cont_skip = new TouchSprite();
			cont_help = new TouchSprite();
			cont_video1 = new TouchSprite();
			cont_video2 = new TouchSprite();
			cont_video3 = new TouchSprite();
			cont_video4 = new TouchSprite();
			cont_video5 = new TouchSprite();
			cont_video6 = new TouchSprite();

			cont_endsession.addChild(button_endsession);
			addChild(cont_endsession);
			cont_toscreen.addChild(button_toscreen);
			addChild(cont_toscreen);
			cont_email.addChild(button_email);
			addChild(cont_email);
			cont_about.addChild(button_about);
			addChild(cont_about);
			cont_star1.addChild(button_star1);
			addChild(cont_star1);
			cont_star2.addChild(button_star2);
			addChild(cont_star2);
			cont_star3.addChild(button_star3);
			addChild(cont_star3);
			cont_star4.addChild(button_star4);
			addChild(cont_star4);
			cont_okemail.addChild(button_okemail);
			addChild(cont_okemail);
			cont_removeemail.addChild(button_removeemail); //no addChild() because invisible first
			cont_gotbadge_modal.addChild(window_gotbadge); //invisible at first
			//addChild(cont_gotbadge_modal);
			cont_continue.addChild(window_gotbadge.button_continue);
			cont_gotbadge_modal.addChild(cont_continue);
			cont_endsession_modal.addChild(window_endsession);
			cont_es_continue.addChild(window_endsession.button_continue);
			cont_endsession_modal.addChild(cont_es_continue);
			cont_es_no.addChild(window_endsession.button_no);
			cont_endsession_modal.addChild(cont_es_no);
			cont_es_yes.addChild(window_endsession.button_yes);
			cont_endsession_modal.addChild(cont_es_yes);
			cont_es_maillist.addChild(window_endsession.button_maillist);
			cont_endsession_modal.addChild(cont_es_maillist);
			cont_es_removeemail.addChild(window_endsession.button_removeemail);
			//cont_endsession_modal.addChild(cont_es_removeemail);
			cont_es_mailbg.addChild(window_endsession.window_emailbg);
			cont_endsession_modal.addChild(cont_es_mailbg);
			cont_es_okemail.addChild(window_endsession.button_okemail);
			cont_endsession_modal.addChild(cont_es_okemail);
			cont_es_esskip.addChild(window_endsession.button_esskip);
			cont_endsession_modal.addChild(cont_es_esskip);
			cont_help.addChild(button_help);
			addChild(cont_help);
			cont_video1.addChild(video1);
			cont_video2.addChild(video2);
			cont_video3.addChild(video3);
			cont_video4.addChild(video4);
			cont_video5.addChild(video5);
			cont_video6.addChild(video6);
			cont_okname.addChild(window_gotbadge.button_okname);
			//cont_gotbadge_modal.addChild(cont_okname);
			//cont_namebg.addChild(window_gotbadge.window_name);
			//cont_gotbadge_modal.addChild(cont_namebg);
			cont_skip.addChild(window_gotbadge.button_skip);
			
			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_about.addEventListener(TouchEvent.TOUCH_DOWN, about_dwn, false, 0, true);
			cont_about.addEventListener(TouchEvent.TOUCH_UP, about_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			cont_okemail.addEventListener(TouchEvent.TOUCH_DOWN, okemail_dwn, false, 0, true);
			cont_okemail.addEventListener(TouchEvent.TOUCH_UP, okemail_up, false, 0, true);
			cont_removeemail.addEventListener(TouchEvent.TOUCH_DOWN, removeemail_dwn, false, 0, true);
			cont_removeemail.addEventListener(TouchEvent.TOUCH_UP, removeemail_up, false, 0, true);
			cont_continue.addEventListener(TouchEvent.TOUCH_DOWN, continue_dwn, false, 0, true);
			cont_continue.addEventListener(TouchEvent.TOUCH_UP, continue_up, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_UP, es_no_up, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_UP, es_yes_up, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_UP, es_maillist_up, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_UP, es_removeemail_up, false, 0, true);
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_DOWN, es_email_dwn, false, 0, true);
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_UP, es_email_up, false, 0, true);
			cont_es_okemail.addEventListener(TouchEvent.TOUCH_DOWN, es_okemail_dwn, false, 0, true);
			cont_es_okemail.addEventListener(TouchEvent.TOUCH_UP, es_okemail_up, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_DOWN, es_esskip_dwn, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_UP, es_esskip_up, false, 0, true);
			cont_okname.addEventListener(TouchEvent.TOUCH_DOWN, okname_dwn, false, 0, true);
			cont_okname.addEventListener(TouchEvent.TOUCH_UP, okname_up, false, 0, true);
			//cont_namebg.addEventListener(TouchEvent.TOUCH_DOWN, namebg_dwn, false, 0, true);
			//cont_namebg.addEventListener(TouchEvent.TOUCH_UP, namebg_up, false, 0, true);
			cont_skip.addEventListener(TouchEvent.TOUCH_DOWN, skip_dwn, false, 0, true);
			cont_skip.addEventListener(TouchEvent.TOUCH_UP, skip_up, false, 0, true);
			cont_help.addEventListener(TouchEvent.TOUCH_DOWN, help_dwn, false, 0, true);
			cont_help.addEventListener(TouchEvent.TOUCH_UP, help_up, false, 0, true);
			cont_video1.addEventListener(TouchEvent.TOUCH_DOWN, video1_dwn, false, 0, true);
			cont_video1.addEventListener(TouchEvent.TOUCH_UP, video1_up, false, 0, true);
			cont_video2.addEventListener(TouchEvent.TOUCH_DOWN, video2_dwn, false, 0, true);
			cont_video2.addEventListener(TouchEvent.TOUCH_UP, video2_up, false, 0, true);
			cont_video3.addEventListener(TouchEvent.TOUCH_DOWN, video3_dwn, false, 0, true);
			cont_video3.addEventListener(TouchEvent.TOUCH_UP, video3_up, false, 0, true);
			cont_video4.addEventListener(TouchEvent.TOUCH_DOWN, video4_dwn, false, 0, true);
			cont_video4.addEventListener(TouchEvent.TOUCH_UP, video4_up, false, 0, true);
			cont_video5.addEventListener(TouchEvent.TOUCH_DOWN, video5_dwn, false, 0, true);
			cont_video5.addEventListener(TouchEvent.TOUCH_UP, video5_up, false, 0, true);
			cont_video6.addEventListener(TouchEvent.TOUCH_DOWN, video6_dwn, false, 0, true);
			cont_video6.addEventListener(TouchEvent.TOUCH_UP, video6_up, false, 0, true);

			addEventListener("deactivate_enterphoto", deactivate_enterphoto);
			addEventListener("activate_exitphoto", activate_exitphoto);
			
			//timeline watcher for bubbles
			timelineWatcher = new TimelineWatcher(bubble_toscreen);
            timelineWatcher.addEventListener(TimelineEvent.LABEL_REACHED, screen_bubble_done);
            timelineWatcher = new TimelineWatcher(bubble_packaged);
			timelineWatcher.addEventListener(TimelineEvent.LABEL_REACHED, packaged_done);

			//email window
			button_okemail.alpha = 0;
			window_email.text_invalidemail.alpha = 0;
			window_email.alpha = 0;
			window_email.scaleX = window_email.scaleY = 0.8;
			
			//email instructions
			BUBBLE_EMAILINSTRUCT_HT = bubble_emailinstruct.height;
			BUBBLE_EMAILINSTRUCT_WD = bubble_emailinstruct.width;
			bubble_emailinstruct.alpha = 0;
			bubble_emailinstruct.scaleX = bubble_emailinstruct.scaleY = 0.8;

			//packaged bubble
			bubble_packaged.alpha = 0;
			bubble_packaged.scaleX = bubble_packaged.scaleY = 0.8;
			
			//send to screen bubble
			bubble_toscreen.alpha = 0;
			bubble_toscreen.scaleX = bubble_toscreen.scaleY = 0.8;
			
			//email remove button
			REMOVEEMAIL_SIZE = button_removeemail.width;
			button_removeemail.alpha = 0;
			button_removeemail.scaleX = button_removeemail.scaleY = 0.8;
			
			//exit email blocker
			hitarea_exitEmail = new ExitEmail();
			cont_exitEmail = new TouchSprite();
			cont_exitEmail.x = -1920 / 2;
			cont_exitEmail.y = -1080 / 2;
			cont_exitEmail.addChild(hitarea_exitEmail);
			cont_exitEmail.addEventListener(TouchEvent.TOUCH_UP, exitEmail_up);
			
			//exit end session keyboard
			hitarea_es_exitKeyboard = new ExitKeyboard();
			cont_es_exitKeyboard = new TouchSprite();
			cont_es_exitKeyboard.addChild(hitarea_es_exitKeyboard);
			cont_es_exitKeyboard.addEventListener(TouchEvent.TOUCH_UP, es_exitKeyboard_up);

			//shader
			shader = new Shade();
			cont_shader = new TouchSprite();
			cont_shader.addChild(shader);
			shader.alpha = 0;

			//instructions
			instructions = new Instructions();
			cont_instructions = new TouchSprite();
			cont_instructions.addChild(instructions);
			cont_instructions.alpha = 0;
			addChild(cont_instructions);
			cont_instructions.addEventListener(TouchEvent.TOUCH_UP, instructions_up, false, 0, true);
			
			//blocker
			blocker_fullscreen = new Blocker();
			cont_blocker_fullscreen = new TouchSprite();
			cont_blocker_fullscreen.addChild(blocker_fullscreen);

			//photo blocker
			cont_blocker_photo = new TouchSprite();
			cont_blocker_photo.addChild(blocker_photo);
			
			//keyboard
			softKeyboard = new KeyboardController();
			softKeyboard.x = -20;
			softKeyboard.y = 570;
			softKeyboard.alpha = 0;
			softKeyboard.keyboard.width = 100;
			softKeyboard.keyboard.height = 100;
			addChild(softKeyboard);
			
			//got badge modal window setup
			window_gotbadge.x = 0;
			window_gotbadge.y = -120;
			cont_gotbadge_modal.alpha = 0;
			cont_gotbadge_modal.scaleX = cont_gotbadge_modal.scaleY = 0.8;

			//end session modal setup
			cont_endsession_modal.alpha = 0;
			cont_endsession_modal.scaleX = cont_endsession_modal.scaleY = 0.8;

			//class event listeners
			addEventListener(TouchEvent.TOUCH_DOWN, anyTouch); //registering any touch on the screen
			addEventListener("okemail", okemail);
			addEventListener("screen_bubble_done", screen_bubble_done);
			
			//badge numbers
			txt_10.alpha = txt_25.alpha = txt_45.alpha = txt_70.alpha = txt_95.alpha = txt_120.alpha = 0;
			badge_1.grey.alpha = 1;

			//badge videos
			video1.video.addEventListener(VideoEvent.COMPLETE, video1_complete);
			video2.video.addEventListener(VideoEvent.COMPLETE, video2_complete);
			video3.video.addEventListener(VideoEvent.COMPLETE, video3_complete);
			video4.video.addEventListener(VideoEvent.COMPLETE, video4_complete);
			video5.video.addEventListener(VideoEvent.COMPLETE, video5_complete);
			video6.video.addEventListener(VideoEvent.COMPLETE, video6_complete);
			video1.video.autoRewind = video2.video.autoRewind = video3.video.autoRewind = video4.video.autoRewind = video5.video.autoRewind = video6.video.autoRewind = true;
			video1.video.fullScreenTakeOver = video2.video.fullScreenTakeOver = video3.video.fullScreenTakeOver = video4.video.fullScreenTakeOver = video5.video.fullScreenTakeOver = video6.video.fullScreenTakeOver = false;
			cont_video1.alpha = cont_video2.alpha = cont_video3.alpha = cont_video4.alpha = cont_video5.alpha = cont_video6.alpha = 0;

			//coming soon bubble COMING SOON TEMP
            bubble_comingsoon.alpha = 0;
            bubble_comingsoon.scaleX = bubble_comingsoon.scaleY = 0.8;

			//OTHER presets
			button_email.text_emailimageto.alpha = 0; //turns off email label
			email_entered.htmlText = bold('');
			graphic_fakebg.alpha = 0;
			window_about.alpha = 0;
			window_gotbadge.txt_inputname.alpha = window_gotbadge.window_name.alpha = window_gotbadge.txt_invalid.alpha = window_gotbadge.txt_name.alpha = window_gotbadge.txt_thanks.alpha = 0;
			
			//end session positioning presets
			window_gotbadge.button_continue.y = window_gotbadge.button_continue.y - 120;
			ES_LOCY = window_endsession.y;		//used to normalize positioning when nesting containers that are offset from origin
			GB_LOCY = window_gotbadge.y;
			DEFAULT_ES_MODALBG_Y = window_endsession.window_modal.y;
			DEFAULT_ES_MODALBG_HEIGHT = window_endsession.window_modal.height;
			DEFAULT_ES_MAILBGY = window_endsession.window_emailbg.y;
			DEFAULT_ES_ENDSESSIONY = window_endsession.txt_endsession.y;
			DEFAULT_ES_PROMPTY = window_endsession.txt_prompt.y;
			DEFAULT_ES_EMAILY = window_endsession.txt_email.y;
			DEFAULT_ES_INVALIDY = window_endsession.txt_invalid.y;
			window_endsession.txt_invalid.alpha = 0;
			window_endsession.button_maillist.y = window_endsession.button_maillist.y + ES_LOCY;
			window_endsession.button_removeemail.y = window_endsession.button_removeemail.y + ES_LOCY;
			window_endsession.button_continue.y = window_endsession.button_continue.y + ES_LOCY;
			window_endsession.window_emailbg.y = window_endsession.window_emailbg.y + ES_LOCY;
			window_endsession.button_okemail.y = window_endsession.button_okemail.y + ES_LOCY;
			window_endsession.button_esskip.y = window_endsession.button_esskip.y + ES_LOCY;
			window_endsession.txt_email.y = window_endsession.txt_email.y + ES_LOCY;
			//window_gotbadge.window_name.y = window_gotbadge.window_name.y + GB_LOCY;
			window_gotbadge.button_okname.y = window_gotbadge.button_okname.y + GB_LOCY;
			window_gotbadge.button_skip.y = window_gotbadge.button_skip.y + GB_LOCY;
			window_gotbadge.txt_name.y = window_gotbadge.txt_name.y + GB_LOCY;
			cont_endsession_modal.addChild(window_endsession.txt_email);
			cont_es_okemail.alpha = 0;
			cont_endsession_modal.removeChild(cont_es_okemail); //defaults end session's OK to off

			//initialize arrays
			for(var i:int = 1; i <= 120; ++i){
				images.push(i);
				ratings.push(-1);
			}
			shuffle();
			
			//Photo object
			photo = new Photo(getNext());			
			photo.x = photo_slot.x - photo_slot.width/2;
			photo.y = photo_slot.y - photo_slot.height/2;
			addChildAt(photo, getChildIndex(effect_insetbg) + 1);
			PHOTO_LOCX = photo.x;
			PHOTO_LOCY = photo.y;			

			//dummy Photo object
			dummyPhoto = new Photo(photo.id);
			dummyPhoto.x = photo.x;
			dummyPhoto.y = photo.y;
			addChildAt(dummyPhoto, getChildIndex(photo) + 1);
			
			setMetadata(photo.title, photo.artist, photo.bio, photo.date, photo.process, photo.credit, photo.copyright);

			//Language presets
			btxt_help_esp.alpha = 0;
			txt_nextbadge_esp.alpha = txt_togo_esp.alpha = txt_badgesearned_esp.alpha = txt_low_esp.alpha = txt_high_esp.alpha = txt_enterrating_esp.alpha = txt_aboutsb_esp.alpha = 0;
			button_endsession.btxt_es_esp.alpha = button_endsession.btxt_esbi_esp.alpha = button_toscreen.btxt_screen_esp.alpha = button_email.text_emailimage_esp.alpha = button_email.text_emailimageto_esp.alpha = 0;
			window_about.txt_body_esp.alpha = 0;
			bubble_emailinstruct.txt_body_esp.alpha = 0;
			instructions.txt_instructions_esp.alpha = 0;
			//End language presets
			
		}
		
		override protected function createUI():void {
			
		}
		
		
		override public function Dispose():void {
			
		}
		
		/* ------------------------------------------- */
		/* ------------ Logical Functions ------------ */
		/* ------------------------------------------- */
		
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
			currentLoc = currentLoc + debugSpeed;
			
			if(currentLoc >= (images.length -1)){
				reachedEnd = true;
				currentLoc = 119;  //used to be --
			}
			
			return images[currentLoc];
		}
		
		/* 
		 * Sets the rating for the current image
		 * 
		 * @param r Rating of current image
		 * @return Boolean Returns whether rating was successful or not
		 */
		public function setRating(r:int):Boolean{
			if(currentLoc == -1){
				return false;
			}else{
				ratings[currentLoc] = r;
				lastRated = currentLoc;
				sendToDatabase(photo.ext, r);
				text_remaining_ratings.htmlText = bold((int(text_remaining_ratings.text) - 1).toString());
				badgeCheck();
				return true;
			}
		}

		private function processXML(e:Event):void {
			soapbox_xml = new XML(e.target.data);
			//trace(soapbox_xml.Content.English.thanks);
		}
		
		private function sendToDatabase(ext:String, rating:int):void{
			//var uR:URLRequest = new URLRequest("http://localhost/soapbox.php");
			var uR:URLRequest = new URLRequest("http://dev-mopa.bpoc.org/js-api/vote");
            var uV:URLVariables = new URLVariables();
			uR.method = URLRequestMethod.POST;
			
			trace("UID: " + Main.uID + ", EXT: " + ext);
			uV.uid = Main.uID;
			//trace(uV.uid);
			uV.nid = ext;
			//trace(uV.nid)
			uV.vote_value = rating * 25;
			//trace(uV.vote_value);
			if(wantsShared){
				uV.email_link = 1;
			}
			else{
				uV.email_link = 0;
			}
			var now:Date = new Date();
            uV.date = now.toString();
                        
            uR.data = uV;
			
			var uL:URLLoader = new URLLoader(uR);
			wantsShared = false;
		}

		public function changeLang(lang:int):void {
			if(lang == 1) { //to Spanish
				language = 1;
				//english off
				Tweener.addTween(btxt_help, {alpha: 0, time: 1});
				Tweener.addTween(txt_nextbadge, {alpha: 0, time: 1});
				Tweener.addTween(txt_togo, {alpha: 0, time: 1});
				Tweener.addTween(txt_badgesearned, {alpha: 0, time: 1});
				Tweener.addTween(txt_low, {alpha: 0, time: 1});
				Tweener.addTween(txt_high, {alpha: 0, time: 1});
				Tweener.addTween(txt_enterrating, {alpha: 0, time: 1});
				Tweener.addTween(txt_aboutsb, {alpha: 0, time: 1});
				Tweener.addTween(button_endsession.btxt_es, {alpha: 0, time: 1});
				Tweener.addTween(button_endsession.btxt_esbi, {alpha: 0, time: 1});
				Tweener.addTween(button_toscreen.btxt_screen, {alpha: 0, time: 1});
				Tweener.addTween(button_email.text_emailimage, {alpha: 0, time: 1});
				Tweener.addTween(button_email.text_emailimageto, {alpha: 0, time: 1});
				Tweener.addTween(window_about.txt_body, {alpha: 0, time: 1});
				bubble_emailinstruct.txt_body.alpha = 0;
				instructions.txt_instructions.alpha = 0;
				window_gotbadge.txt_continuerating.htmlText = bold(soapbox_xml.Content.Spanish.continuer);
				//spanish on
				Tweener.addTween(btxt_help_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_nextbadge_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_togo_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_badgesearned_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_low_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_high_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_enterrating_esp, {alpha: 1, time: 1});
				Tweener.addTween(txt_aboutsb_esp, {alpha: 1, time: 1});
				Tweener.addTween(button_endsession.btxt_es_esp, {alpha: 1, time: 1});
				Tweener.addTween(button_endsession.btxt_esbi_esp, {alpha: 1, time: 1});
				Tweener.addTween(button_toscreen.btxt_screen_esp, {alpha: 1, time: 1});
				Tweener.addTween(window_about.txt_body_esp, {alpha: 1, time: 1});
				bubble_emailinstruct.txt_body_esp.alpha = 1;
				if(email == '') { Tweener.addTween(button_email.text_emailimage_esp, {alpha: 1, time: 1}); } 
				else { Tweener.addTween(button_email.text_emailimageto_esp, {alpha: 1, time: 1}); }
				instructions.txt_instructions_esp.alpha = 1;

				//to Spanish
				window_gotbadge.txt_thanks.htmlText = bold(soapbox_xml.Content.Spanish.thanks);
				window_gotbadge.txt_invalid.htmlText = bold(soapbox_xml.Content.Spanish.invalidname);
				window_email.txt_prompt.y = -144.65;
				window_email.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.likeimage);
				window_email.text_invalidemail.htmlText = bold(soapbox_xml.Content.Spanish.invalidemail);
				window_endsession.txt_endsession.htmlText = bold(soapbox_xml.Content.Spanish.es);
				window_endsession.button_maillist.txt_prompt.y = -25.45;
				window_endsession.button_maillist.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.mopamail);
				window_endsession.txt_invalid.htmlText = bold(soapbox_xml.Content.Spanish.invalidemail);
				window_endsession.txt_continue.htmlText = bold(soapbox_xml.Content.Spanish.cont);
				window_endsession.button_esskip.txt_es.htmlText = bold(soapbox_xml.Content.Spanish.es2);
				window_endsession.button_esskip.txt_wosending.htmlText = bold(soapbox_xml.Content.Spanish.wosend);
				window_endsession.button_yes.txt_yes.htmlText = bold(soapbox_xml.Content.Spanish.yes);
				window_endsession.button_yes.txt_yeslong.txt_yes.htmlText = bold(soapbox_xml.Content.Spanish.yescma);
				window_endsession.button_yes.txt_yeslong.txt_sendbadges.htmlText = bold(soapbox_xml.Content.Spanish.sendbadges);
				window_endsession.button_no.txt_no.htmlText = bold(soapbox_xml.Content.Spanish.no);
				window_endsession.button_no.txt_nolong.txt_no.htmlText = bold(soapbox_xml.Content.Spanish.nocma);
				window_endsession.button_no.txt_nolong.txt_dontsend.htmlText = bold(soapbox_xml.Content.Spanish.dontsend);
			} else { //to English
				language = 0;
				//english on
				Tweener.addTween(btxt_help, {alpha: 1, time: 1});
				Tweener.addTween(txt_nextbadge, {alpha: 1, time: 1});
				Tweener.addTween(txt_togo, {alpha: 1, time: 1});
				Tweener.addTween(txt_badgesearned, {alpha: 1, time: 1});
				Tweener.addTween(txt_low, {alpha: 1, time: 1});
				Tweener.addTween(txt_high, {alpha: 1, time: 1});
				Tweener.addTween(txt_enterrating, {alpha: 1, time: 1});
				Tweener.addTween(txt_aboutsb, {alpha: 1, time: 1});
				Tweener.addTween(button_endsession.btxt_es, {alpha: 1, time: 1});
				Tweener.addTween(button_endsession.btxt_esbi, {alpha: 1, time: 1});
				Tweener.addTween(button_toscreen.btxt_screen, {alpha: 1, time: 1});
				Tweener.addTween(window_about.txt_body, {alpha: 1, time: 1});
				bubble_emailinstruct.txt_body.alpha = 1;
				if(email == '') { Tweener.addTween(button_email.text_emailimage, {alpha: 1, time: 1}); } 
				else { Tweener.addTween(button_email.text_emailimageto, {alpha: 1, time: 1}); }
				instructions.txt_instructions.alpha = 1;
				window_gotbadge.txt_continuerating.htmlText = bold(soapbox_xml.Content.English.continuer);
				//spanish off
				Tweener.addTween(btxt_help_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_nextbadge_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_togo_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_badgesearned_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_low_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_high_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_enterrating_esp, {alpha: 0, time: 1});
				Tweener.addTween(txt_aboutsb_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_endsession.btxt_es_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_endsession.btxt_esbi_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_toscreen.btxt_screen_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_email.text_emailimage_esp, {alpha: 0, time: 1});
				Tweener.addTween(button_email.text_emailimageto_esp, {alpha: 0, time: 1});
				Tweener.addTween(window_about.txt_body_esp, {alpha: 0, time: 1});
				bubble_emailinstruct.txt_body_esp.alpha = 0;
				instructions.txt_instructions_esp.alpha = 0;

				//to English
				window_gotbadge.txt_thanks.htmlText = bold(soapbox_xml.Content.English.thanks);
				window_gotbadge.txt_invalid.htmlText = bold(soapbox_xml.Content.English.invalidname);
				window_email.txt_prompt.y = -134.65;
				window_email.txt_prompt.htmlText = bold(soapbox_xml.Content.English.likeimage);
				window_email.text_invalidemail.htmlText = bold(soapbox_xml.Content.English.invalidemail);
				window_endsession.txt_endsession.htmlText = bold(soapbox_xml.Content.English.es);
				window_endsession.button_maillist.txt_prompt.y = -12.45;
				window_endsession.button_maillist.txt_prompt.htmlText = bold(soapbox_xml.Content.English.mopamail);
				window_endsession.txt_invalid.htmlText = bold(soapbox_xml.Content.English.invalidemail);
				window_endsession.txt_continue.htmlText = bold(soapbox_xml.Content.English.continuer);
				window_endsession.button_esskip.txt_es.htmlText = bold(soapbox_xml.Content.English.es2);
				window_endsession.button_esskip.txt_wosending.htmlText = bold(soapbox_xml.Content.English.wosend);
				window_endsession.button_yes.txt_yes.htmlText = bold(soapbox_xml.Content.English.yes);
				window_endsession.button_yes.txt_yeslong.txt_yes.htmlText = bold(soapbox_xml.Content.English.yescma);
				window_endsession.button_yes.txt_yeslong.txt_sendbadges.htmlText = bold(soapbox_xml.Content.English.sendbadges);
				window_endsession.button_no.txt_no.htmlText = bold(soapbox_xml.Content.English.no);
				window_endsession.button_no.txt_nolong.txt_no.htmlText = bold(soapbox_xml.Content.English.nocma);
				window_endsession.button_no.txt_nolong.txt_dontsend.htmlText = bold(soapbox_xml.Content.English.dontsend);
			}
		}
		
		//checks, based on the current location if you have gotten a badge or not
		public function badgeCheck():Boolean{
			switch(currentLoc + 1){
			//switch(120){ //TESTING AT 120
				case badge1:
					currentBadge = 1;
					text_remaining_ratings.htmlText = bold((badge2 - badge1).toString());
					gotBadge(1);
					return true;
				case badge2:
					currentBadge = 2;
					text_remaining_ratings.htmlText = bold((badge3 - badge2).toString());
					gotBadge(2);
					return true;
				case badge3:
					currentBadge = 3;
					text_remaining_ratings.htmlText = bold((badge4 - badge3).toString());
					gotBadge(3);
					return true;
				case badge4:
					currentBadge = 4;
					text_remaining_ratings.htmlText = bold((badge5 - badge4).toString());
					gotBadge(4);
					return true;
				case badge5:
					currentBadge = 5;
					text_remaining_ratings.htmlText = bold((badge6 - badge5).toString());
					gotBadge(5);
					return true;
				case badge6:
					currentBadge = 6;
					text_remaining_ratings.htmlText = bold("0");
					gotBadge(6);
					return true;
				default:
					return false;
			}
		}
		
		public function logicalReset():void {
			//Randomize images
			shuffle();
			
			//LOGICAL
			currentLoc = -1;
			reachedEnd = false;
			currentBadge = -1;
			lastRated = -1;
			photoSent = false;
			maillist_opt = false;
			email = '';
			fullname = '';
			sendBadges = false;
			aboutShowing = false;
			package_created = false;
			emails.splice();
			packages.splice();
			wantsShared= false;

			//VISUAL
			//text
			email_entered.htmlText = bold('');
			txt_email.text = '';
			text_remaining_ratings.htmlText = bold("10");
			window_endsession.txt_email.text = '';
			window_endsession.button_maillist.gotoAndStop("check");
			window_about.alpha = 0;
			
			//share button
			button_email.alpha = 1;
			if(language == 0) {
				button_email.text_emailimage.alpha = 1;
				button_email.text_emailimageto.alpha = 0;
			} else {
				button_email.text_emailimage_esp.alpha = 1;
				button_email.text_emailimageto_esp.alpha = 0;
			}
			button_removeemail.alpha = 0;
			button_removeemail.scaleX = button_removeemail.scaleY = 0.8;
			
			//photo
			photo.id = getNext();
			dummyPhoto.id = photo.id;

			//bubbles
			bubble_packaged.scaleX = bubble_packaged.scaleY = 0.8;
			bubble_toscreen.scaleX = bubble_toscreen.scaleY = 0.8;
			bubble_emailinstruct.scaleX = bubble_emailinstruct.scaleY = 0.8;
			window_email.scaleX = window_email.scaleY = 0.8;
			bubble_packaged.alpha = 0;
			bubble_toscreen.alpha = 0;
			bubble_emailinstruct.alpha = 0;
			window_email.alpha = 0;

			cont_shader.y = 0; //shader
			cont_instructions.alpha = 0;//instructional
			setMetadata(photo.title, photo.artist, photo.bio, photo.date, photo.process, photo.credit, photo.copyright); //metadata

			//got badge window
			if(cont_gotbadge_modal.contains(cont_okname)) {
				cont_gotbadge_modal.removeChild(cont_okname);
			}
			if(cont_gotbadge_modal.contains(cont_skip)) {
				cont_gotbadge_modal.removeChild(cont_skip);
			}
			window_gotbadge.graphic_continuebg.alpha = window_gotbadge.graphic_prompt.alpha = 1;
			window_gotbadge.txt_inputname.alpha = window_gotbadge.window_name.alpha = window_gotbadge.txt_invalid.alpha = window_gotbadge.txt_name.alpha = window_gotbadge.txt_thanks.alpha = 0;
			window_gotbadge.txt_name.alpha = 0;
			cont_gotbadge_modal.addChild(cont_continue);
			window_gotbadge.window_modal.height = 692.9;
			window_gotbadge.window_modal.y = 70;
			window_gotbadge.txt_continuerating.visible = true;

			//badges
			txt_10.alpha = txt_25.alpha = txt_45.alpha = txt_70.alpha = txt_95.alpha = txt_120.alpha = 0;
			badge_1.grey.alpha = 1;
			badge_2.grey.alpha = badge_3.grey.alpha = badge_3.grey.alpha = badge_4.grey.alpha = badge_5.grey.alpha = badge_6.grey.alpha = 0;
			badge_1.color.alpha = badge_2.color.alpha = badge_3.color.alpha = badge_3.color.alpha = badge_4.color.alpha = badge_5.color.alpha = badge_6.color.alpha = 0;

			//videos
			video1.video.stop();
			video2.video.stop();
			video3.video.stop();
			video4.video.stop();
			video5.video.stop();
			video6.video.stop();
			video1.graphic_videoblack.alpha = video2.graphic_videoblack.alpha = video3.graphic_videoblack.alpha = video4.graphic_videoblack.alpha = video5.graphic_videoblack.alpha = video6.graphic_videoblack.alpha = 1
			video1.graphic_play.alpha = video2.graphic_play.alpha = video3.graphic_play.alpha = video4.graphic_play.alpha = video5.graphic_play.alpha = video6.graphic_play.alpha = 1;

			//OTHER presets
			button_email.text_emailimageto.alpha = 0; //turns off email label
			email_entered.htmlText = bold('');
			graphic_fakebg.alpha = 0;
			window_about.alpha = 0;
		}

		/*
		 * Resets the session. Returns currentLoc to -1, clears the ratings array.
		 */
		public function resetSession():void {
			dispatchEvent(new Event("reset_animate", true));

			Tweener.addTween(this, { delay: 4, onComplete: logicalReset});
			graphic_fakebg.alpha = 0;

			//Tweener.addTween(cont_endsession_modal, { height: cont_endsession_modal.height - 20, width: cont_endsession_modal.width - 50, alpha: 0, time: 1, onComplete: function() {
			Tweener.addTween(cont_endsession_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
				removeChild(cont_endsession_modal);
				shadeOff();
			} });

			Tweener.addTween(this, {delay: 2, onComplete: function() { dispatchEvent(new Event("endSession", true)); }});

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
		}

		public function timeoutReset():void {
			//dispatchEvent(new Event("reset_animate", true));//RETURN HERE
			
			//VISUAL
			graphic_fakebg.alpha = 0;
			
			//shader
			if(shader.alpha == 1)
				shadeOff();
			
			//instructional
			if(cont_instructions.alpha == 1)
				Tweener.addTween(cont_instructions, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_instructions); }});

			//end session
			if(contains(cont_endsession_modal)) {
				//Tweener.addTween(cont_endsession_modal, { height: cont_endsession_modal.height - 20, width: cont_endsession_modal.width - 50, alpha: 0, time: 1, onComplete: function() {
				Tweener.addTween(cont_endsession_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
					removeChild(cont_endsession_modal);
				} });
			}

			//got badge modal
			if(contains(cont_gotbadge_modal)) {
				Tweener.addTween(cont_gotbadge_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
					removeChild(cont_gotbadge_modal);
				} });

				if(contains(cont_video1)) {
					Tweener.addTween(cont_video1, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video1); }});
					video1.graphic_videoblack.alpha = video1.graphic_play.alpha = 1;
					video1.video.stop();
				} else if (contains(cont_video2)) {
					Tweener.addTween(cont_video2, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video2); }});
					video2.graphic_videoblack.alpha = video2.graphic_play.alpha = 1;
					video2.video.stop();
				} else if (contains(cont_video3)) {
					Tweener.addTween(cont_video3, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video3); }});
					video3.graphic_videoblack.alpha = video3.graphic_play.alpha = 1;
					video3.video.stop();
				} else if (contains(cont_video4)) {
					Tweener.addTween(cont_video4, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video4); }});
					video4.graphic_videoblack.alpha = video4.graphic_play.alpha = 1;
					video4.video.stop();
				} else if (contains(cont_video5)) {
					Tweener.addTween(cont_video5, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video5); }});
					video5.graphic_videoblack.alpha = video5.graphic_play.alpha = 1;
					video5.video.stop();
				} else if (contains(cont_video6)) {
					Tweener.addTween(cont_video6, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video6); }});
					video6.graphic_videoblack.alpha = video6.graphic_play.alpha = 1;
					video6.video.stop();
				}	
			}

			//in e-mail keyboard mode
			if(window_email.alpha == 1) {
				//removeChild(cont_exitEmail);
				exitEmail();
			}

			//keyboard visible
			if(softKeyboard.alpha == 1) {
				Tweener.addTween(softKeyboard, { alpha: 0, time: 1 } );
			}

			//viewing photo
			if(dummyPhoto.viewing || photo.viewing) {
				dummyPhoto.exitViewing();
				photo.exitViewing();
			}
			
			Tweener.addTween(this, {delay: 1, onComplete: function() { dispatchEvent(new Event("endSession", true)); }});
			Tweener.addTween(this, { delay: 4, onComplete: logicalReset});
			
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
		}
		
		//gets the current badge
		public function getCurrentBadge():int{
			return currentBadge;
		}
		
		/*
		 * Stores e-mail
		 * 
		 * @param address E-mail address
		 */
		private function storeEmail(address:String):void {
			email = address;
			emails.push(address);
			//trace("Stored: " + address);
		}
		
		/*
		 * Calculates how far to position the X to remove email based on the email
		 * string length.
		 * 
		 * @param which - Refers to which e-mail text field to return a postion for. 1: By "Share" button. 2: In End Session modal. 
		 */
		private function getXpos(which:int):int {
			//return (email_entered.x + email_entered.width/2) - (8.2 * email.length) + 15;
			//trace(email_entered.htmlTextWidth);
			var xpos:int;

			if(which == 1) {
				xpos = button_email.x - email_entered.textWidth/2 - 25;
			} else if (which == 2) {
				xpos =  window_endsession.window_emailbg.x - window_endsession.txt_email.textWidth/2 - 25;
			}

			return xpos;
		}

		/* ------------------------------------------- */
		/* ------ Interface/Animation Functions ------ */
		/* ------------------------------------------- */
		private function anyTouch(e:TouchEvent):void {
			if (EMAIL_ADDED) {
				EMAIL_ADDED = false;
				Tweener.addTween(bubble_emailinstruct, { alpha: 0, time: 1 } );
				//Tweener.addTween(bubble_emailinstruct, { height: bubble_emailinstruct.height - 30, width: bubble_emailinstruct.width - 50, time: 1 } );
				Tweener.addTween(bubble_emailinstruct, { scaleX: 0.8, scaleY: 0.8, time: 1 } );
			}
			
			if (SEND_BUBBLE_COMPLETE) {				
				SEND_BUBBLE_COMPLETE = false;
				Tweener.addTween(bubble_toscreen, { alpha: 0, time: 1 } );
				//Tweener.addTween(bubble_toscreen, { height: bubble_toscreen.height - 50, width: bubble_toscreen.width - 50, time: 1, onComplete: function () {
				Tweener.addTween(bubble_toscreen, { scaleX: 0.8, scaleY: 0.8, time: 1, onComplete: function () {
					//SEND_BUBBLE_ON = false;
					
					cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
					cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
					bubble_toscreen.gotoAndStop(1);
				} } );
			}

			if (PACKAGED_COMPLETE) {
				PACKAGED_COMPLETE = false;

				Tweener.addTween(bubble_packaged, { alpha: 0, time: 1 } );
				//Tweener.addTween(bubble_packaged, { height: bubble_packaged.height - 50, width: bubble_packaged.width - 50, time: 1, onComplete: function () {
				Tweener.addTween(bubble_packaged, { scaleX: 0.8, scaleY: 0.8, time: 1, onComplete: function () {
					bubble_packaged.gotoAndStop("stop");
				} } );
			}

			//COMING SOON TEMP
			/*if(bubble_comingsoon.alpha == 1) {
				Tweener.addTween(bubble_comingsoon, { alpha: 0, time: 1 } );
				Tweener.addTween(bubble_comingsoon, { scaleX: 0.8, scaleY: 0.8, time: 1 } );
			}*/
		}
		
		public function showInstructions():void {
			addChild(cont_instructions);
			Tweener.addTween(cont_instructions, {alpha: 1, time: 1 } );

			//COLLECT DATA
		}

		private function instructions_up(e:TouchEvent):void {
			Tweener.addTween(cont_instructions, {alpha: 0, time: 0.5, onComplete: function () {
				removeChild(cont_instructions);
			}});

			//COLLECT DATA

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 0.5, onComplete: blockerOff } );
		}

		private function endsession_dwn(e:TouchEvent):void {
			button_endsession.gotoAndStop("down");

			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_help.removeEventListener(TouchEvent.TOUCH_DOWN, help_dwn);
			cont_help.removeEventListener(TouchEvent.TOUCH_UP, help_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function endsession_up(e:TouchEvent):void {
			button_endsession.gotoAndStop("up");
			shadeOn();

			layoutESwindow();
			cont_endsession_modal.alpha = 0;
			addChild(cont_endsession_modal);
			Tweener.addTween(cont_endsession_modal, { alpha: 1, time: 1, delay: 0.5});
			//Tweener.addTween(cont_endsession_modal, { height: cont_endsession_modal.height + 20, width: cont_endsession_modal.width + 50, time: 1, delay: 0.5, transition: "easeOutElastic"});
			Tweener.addTween(cont_endsession_modal, { scaleX: 1, scaleY: 1, time: 1, delay: 0.5, transition: "easeOutElastic"});

			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_help.addEventListener(TouchEvent.TOUCH_DOWN, help_dwn, false, 0, true);
			cont_help.addEventListener(TouchEvent.TOUCH_UP, help_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			dispatchEvent(new Event("activateLang", true));
			if(currentBadge != 6)
				photo_blockerOff();

			blockerOn();
			if(currentBadge != 6)
				Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}
		
		private function toscreen_dwn(e:TouchEvent):void {
			button_toscreen.gotoAndStop("down");

			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function toscreen_up(e:TouchEvent):void {
			button_toscreen.gotoAndStop("up");
			
			//COLLECT DATA

			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);

			//HTTP Request
			try {
                //loader.load(request);
                now = new Date();
           		request.url = SCREEN_URL + photo.ext + "&time=" + now.minutes + now.seconds;
           		loader.load(request);
                trace(request.url);
            } catch (error:Error) {
                trace("Unable to load requested document.");
            }

			Tweener.addTween(bubble_toscreen, { alpha: 1, time: 1 } );
			//Tweener.addTween(bubble_toscreen, { height: bubble_toscreen.height + 50, width: bubble_toscreen.width + 50, 
			Tweener.addTween(bubble_toscreen, { scaleX: 1, scaleY: 1, 
				time: 1, transition: "easeOutElastic", onComplete: function() { 
					//bubble_toscreen.gotoAndPlay("play");						
				} } );
			bubble_toscreen.gotoAndPlay("play");

			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			dispatchEvent(new Event("activateLang", true));
			photo_blockerOff();
		}
		
		private function email_dwn(e:TouchEvent):void {
			button_email.gotoAndStop("down");

			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_help.removeEventListener(TouchEvent.TOUCH_DOWN, help_dwn);
			cont_help.removeEventListener(TouchEvent.TOUCH_UP, help_up);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function email_up(e:TouchEvent):void {
			button_email.gotoAndStop("up");
			
			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_help.addEventListener(TouchEvent.TOUCH_DOWN, help_dwn, false, 0, true);
			cont_help.addEventListener(TouchEvent.TOUCH_UP, help_up, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			dispatchEvent(new Event("activateLang", true));
			photo_blockerOff();

			if (email == '') { //if no e-mail entered yet
				//COMING SOON TEMP
				/*bubble_comingsoon.x = 719.7;
				bubble_comingsoon.y = 436.85;
				Tweener.addTween(bubble_comingsoon, { alpha: 1, time: 1 } );
				Tweener.addTween(bubble_comingsoon, { scaleX: 1, scaleY: 1, time: 1, transition: "easeOutElastic" } );

				Tweener.addTween(bubble_comingsoon, { alpha: 0, time: 1, delay: 4 } );
				Tweener.addTween(bubble_comingsoon, { scaleX: 0.8, scaleY: 0.8, time: 1, delay: 4 } );*/
				
				shadeOn();
				addChild(cont_exitEmail); //put exit_email above shade
				addChild(window_email); //put window_email above shade
				addChild(softKeyboard); //put window_email above shade
				addChild(cont_okemail); //put button_okemail above all else
				Tweener.addTween(cont_shader, { y: cont_shader.y + 300, time: 1 } );				
				Tweener.addTween(this, { y: this.y - 300, time: 1 } );				
				Tweener.addTween(button_okemail, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(window_email, { alpha: 1, delay: 0.5, time: 1 } );
				Tweener.addTween(window_email, { scaleX: 1, scaleY: 1, delay: 0.5, time: 1, transition: "easeOutElastic" } );
				Tweener.addTween(softKeyboard, { alpha: 1, delay: 0.5, time: 1 } );
				addChild(txt_email);
				txt_email.text = '';
				softKeyboard.x = -140;
				softKeyboard.y = 565;
				softKeyboard.setInputTF(txt_email);
				softKeyboard.toDefault();
				
				dispatchEvent(new Event("shiftUp", true)); //move background up
				
				//timedBlocker(1.5);
				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { y: cont_blocker_fullscreen.y + 300, time: 1 } );
				Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
			} else if (!photoSent) { //e-mail already entered
				//COLLECT DATA

				/* code for sending e-mail */
				if(!package_created) {
					storeEmail(email);
					//trace("Added empty array to packages for new email");
					packages.push(new Array());
					package_created = true;
				}
				
				wantsShared = true;				
				//trace("Packaged " + photo.ext + " with email: " + emails[emails.length - 1]);
				photosMarked = true;
				packages[emails.length - 1].push(photo.ext);
				photoSent = true;
				button_email.alpha = 0.5;
				Tweener.addTween(bubble_packaged, { alpha: 1, time: 1 } );
				Tweener.addTween(bubble_packaged, { scaleX: 1, scaleY: 1, time: 1 } );
				bubble_packaged.gotoAndPlay("play");
				
				cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
				cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			}
		}
		
		private function reactivateEmailButton():void {
			photoSent = false;
			button_email.alpha = 1;
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
		}

		private function about_dwn(e:TouchEvent):void {
			button_about.gotoAndStop("down");
		}

		private function about_up(e:TouchEvent):void {
			button_about.gotoAndStop("up");

			if(!aboutShowing) {
				Tweener.addTween(window_about, {alpha: 1, time: 1});
				aboutShowing = true;
			} else {
				Tweener.addTween(window_about, {alpha: 0, time: 1});
				aboutShowing = false;
			}
		}

		private function exitEmail_up(e:TouchEvent):void {
			exitEmail();
		}

		private function exitEmail():void {
			removeChild(cont_exitEmail); //put exit_email above shade
			softKeyboard.clearEmail();
			Tweener.addTween(cont_shader, { y: cont_shader.y - 300, time: 1 } );				
			Tweener.addTween(this, { y: this.y + 300, time: 1 } );				
			Tweener.addTween(button_okemail, { alpha: 0, time: 1 } );
			Tweener.addTween(window_email, { alpha: 0, time: 1 } );
			//Tweener.addTween(window_email, { height: window_email.height - 100, width: window_email.width - 100, time: 1, transition: "easeOutElastic" } );
			Tweener.addTween(window_email, { scaleX: 0.8, scaleY: 0.8, time: 1, transition: "easeOutElastic" } );
			Tweener.addTween(softKeyboard, { alpha: 0, time: 1 } );
			Tweener.addTween(softKeyboard, { height: softKeyboard.height - 100, width: softKeyboard.width - 100, time: 1, transition: "easeOutElastic" } );
			dispatchEvent(new Event("shiftDown", true)); //move background down
			shadeOff();
			
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { y: cont_blocker_fullscreen.y - 300, time: 1 } );
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}

		private function okemail_dwn(e:TouchEvent):void {
			button_okemail.gotoAndStop("down");
		}
		
		private function okemail_up(e:TouchEvent):void {
			button_okemail.gotoAndStop("up");
			okemail(e);
		}
		
		private function okemail(e:Event):void {
			if ( !softKeyboard.validateEmail(softKeyboard.emailText()) ) { //e-mail invalid
				Tweener.addTween( window_email.text_invalidemail, { alpha: 1, time: 0.5 } );
				Tweener.addTween( window_email.text_invalidemail, { alpha: 0, delay: 2, time: 0.5 } );
			} else { //e-mail valid				
				//COLLECT DATA

				email = softKeyboard.emailText();
				email_entered.htmlText = bold(softKeyboard.emailText());
				email_entered.alpha = 0;
				softKeyboard.clearEmail();
				exitEmail();
				
				//crossfade action brahhhhhh
				if(language == 0) {
					Tweener.addTween(button_email.text_emailimage, { alpha: 0, delay: 1, time: 1 } );
					Tweener.addTween(button_email.text_emailimageto, { alpha: 1, delay: 1, time: 1 } );
				} else {
					Tweener.addTween(button_email.text_emailimage_esp, { alpha: 0, delay: 1, time: 1 } );
					Tweener.addTween(button_email.text_emailimageto_esp, { alpha: 1, delay: 1, time: 1 } );
				}
				Tweener.addTween(email_entered, { alpha: 1, delay: 1, time: 1 } );
				Tweener.addTween(bubble_emailinstruct, { alpha: 1, delay: 1, time: 1 } );
				//Tweener.addTween(bubble_emailinstruct, { height: BUBBLE_EMAILINSTRUCT_HT, width: BUBBLE_EMAILINSTRUCT_WD, delay: 1, time: 1, transition: "easeOutElastic" } );
				Tweener.addTween(bubble_emailinstruct, { scaleX: 1, scaleY: 1, delay: 1, time: 1, transition: "easeOutElastic" } );
				addChild(cont_removeemail);
				button_removeemail.x = getXpos(1);
				Tweener.addTween(button_removeemail, { alpha: 1, delay: 1, time: 1 } );
				//Tweener.addTween(button_removeemail, { height: REMOVEEMAIL_SIZE, width: REMOVEEMAIL_SIZE, delay: 1, time: 1, transition: "easeOutElastic" } );
				Tweener.addTween(button_removeemail, { scaleX: 1, scaleY: 1, delay: 1, time: 1, transition: "easeOutElastic" } );
				EMAIL_ADDED = true; //bubble is on
			}
		}
		
		private function removeemail_dwn(e:TouchEvent):void {
			button_removeemail.gotoAndStop("down");
		}
		
		private function removeemail_up(e:TouchEvent):void {
			button_removeemail.gotoAndStop("up");
			if(language == 0) {
				Tweener.addTween(button_email.text_emailimage, { alpha: 1, time: 1 } );
				Tweener.addTween(button_email.text_emailimageto, { alpha: 0, time: 1 } );
			} else {
				Tweener.addTween(button_email.text_emailimage_esp, { alpha: 1, time: 1 } );
				Tweener.addTween(button_email.text_emailimageto_esp, { alpha: 0, time: 1 } );
			}
			Tweener.addTween(button_removeemail, { alpha: 0, time: 1 } );
			//Tweener.addTween(button_removeemail, { height: button_removeemail.height - 20, width: button_removeemail.width - 20, time: 1 } );
			Tweener.addTween(button_removeemail, { scaleX: 0.8, scaleY: 0.8, time: 1 } );
			Tweener.addTween(email_entered, { alpha: 0, time: 1 } );
			Tweener.addTween(button_email, { alpha: 1, time: 1 } )

			photoSent = false;
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			email = '';
			
			softKeyboard.clearEmail();
		}

		private function continue_dwn(e:TouchEvent):void {
			window_gotbadge.button_continue.gotoAndStop("down");

			cont_video1.removeEventListener(TouchEvent.TOUCH_DOWN, video1_dwn);
			cont_video1.removeEventListener(TouchEvent.TOUCH_UP, video1_up);
			cont_video2.removeEventListener(TouchEvent.TOUCH_DOWN, video2_dwn);
			cont_video2.removeEventListener(TouchEvent.TOUCH_UP, video2_up);
			cont_video3.removeEventListener(TouchEvent.TOUCH_DOWN, video3_dwn);
			cont_video3.removeEventListener(TouchEvent.TOUCH_UP, video3_up);
			cont_video4.removeEventListener(TouchEvent.TOUCH_DOWN, video4_dwn);
			cont_video4.removeEventListener(TouchEvent.TOUCH_UP, video4_up);
			cont_video5.removeEventListener(TouchEvent.TOUCH_DOWN, video5_dwn);
			cont_video5.removeEventListener(TouchEvent.TOUCH_UP, video5_up);
			cont_video6.removeEventListener(TouchEvent.TOUCH_DOWN, video6_dwn);
			cont_video6.removeEventListener(TouchEvent.TOUCH_UP, video6_up);
		}

		private function continue_up(e:TouchEvent):void {
			window_gotbadge.button_continue.gotoAndStop("up");
			
			//COLLECT DATA
			

			gotBadge_bool = false;

			cont_video1.addEventListener(TouchEvent.TOUCH_DOWN, video1_dwn, false, 0, true);
			cont_video1.addEventListener(TouchEvent.TOUCH_UP, video1_up, false, 0, true);
			cont_video2.addEventListener(TouchEvent.TOUCH_DOWN, video2_dwn, false, 0, true);
			cont_video2.addEventListener(TouchEvent.TOUCH_UP, video2_up, false, 0, true);
			cont_video3.addEventListener(TouchEvent.TOUCH_DOWN, video3_dwn, false, 0, true);
			cont_video3.addEventListener(TouchEvent.TOUCH_UP, video3_up, false, 0, true);
			cont_video4.addEventListener(TouchEvent.TOUCH_DOWN, video4_dwn, false, 0, true);
			cont_video4.addEventListener(TouchEvent.TOUCH_UP, video4_up, false, 0, true);
			cont_video5.addEventListener(TouchEvent.TOUCH_DOWN, video5_dwn, false, 0, true);
			cont_video5.addEventListener(TouchEvent.TOUCH_UP, video5_up, false, 0, true);
			cont_video6.addEventListener(TouchEvent.TOUCH_DOWN, video6_dwn, false, 0, true);
			cont_video6.addEventListener(TouchEvent.TOUCH_UP, video6_up, false, 0, true);

			//Tweener.addTween(cont_gotbadge_modal, { heiokght: cont_gotbadge_modal.height - 100, width: cont_gotbadge_modal.width - 100, alpha: 0, time: 1, onComplete: function() {
			Tweener.addTween(cont_gotbadge_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
				removeChild(cont_gotbadge_modal);
				shadeOff();
			} });

			if(currentBadge == 1) {
				Tweener.addTween(badge_1.color, { alpha: 1, time: 1, delay: 2 });
				Tweener.addTween(badge1_glow, { delay: 2, onComplete: function() { badge1_glow.gotoAndPlay("play"); } } );
				Tweener.addTween(badge_2.grey, { alpha: 1, time: 2, delay: 2.5 });
				Tweener.addTween(txt_10, { alpha: 1, time: 1, delay: 2 });
				Tweener.addTween(cont_video1, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video1); }});
				if(video1.video.playing) {
					Tweener.addTween(video1.graphic_videoblack, {alpha: 1, time: 1});
					Tweener.addTween(video1.graphic_play, {alpha: 1, time: 1});
					video1.video.stop();
				}
			} else if(currentBadge == 2) {
				Tweener.addTween(badge_2.color, { alpha: 1, time: 1, delay: 2});
				Tweener.addTween(badge2_glow, { delay: 2, onComplete: function() { badge2_glow.gotoAndPlay("play"); } } );
				Tweener.addTween(badge_3.grey, { alpha: 1, time: 2, delay: 2.5 });
				Tweener.addTween(txt_25, { alpha: 1, time: 1, delay: 2 });
				Tweener.addTween(cont_video2, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video2); }});
				if(video2.video.playing) {
					Tweener.addTween(video2.graphic_videoblack, {alpha: 1, time: 1});
					Tweener.addTween(video2.graphic_play, {alpha: 1, time: 1});
					video2.video.stop();
				}
			} else if(currentBadge == 3) {
				Tweener.addTween(badge_3.color, { alpha: 1, time: 1, delay: 2});
				Tweener.addTween(badge3_glow, { delay: 2, onComplete: function() { badge3_glow.gotoAndPlay("play"); } } );
				Tweener.addTween(badge_4.grey, { alpha: 1, time: 2, delay: 2.5 });
				Tweener.addTween(txt_45, { alpha: 1, time: 1, delay: 2 });
				Tweener.addTween(cont_video3, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video3); }});
				if(video3.video.playing) {
					Tweener.addTween(video3.graphic_videoblack, {alpha: 1, time: 1});
					Tweener.addTween(video3.graphic_play, {alpha: 1, time: 1});
					video3.video.stop();
				}
			} else if(currentBadge == 4) {
				Tweener.addTween(badge_4.color, { alpha: 1, time: 1, delay: 2});
				Tweener.addTween(badge4_glow, { delay: 2, onComplete: function() { badge4_glow.gotoAndPlay("play"); } } );
				Tweener.addTween(badge_5.grey, { alpha: 1, time: 2, delay: 2.5 });
				Tweener.addTween(txt_70, { alpha: 1, time: 1, delay: 2 });
				Tweener.addTween(cont_video4, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video4); }});
				if(video4.video.playing) {
					Tweener.addTween(video4.graphic_videoblack, {alpha: 1, time: 1});
					Tweener.addTween(video4.graphic_play, {alpha: 1, time: 1});
					video4.video.stop();
				}
			} else if(currentBadge == 5) {
				Tweener.addTween(badge_5.color, { alpha: 1, time: 1, delay: 2});
				Tweener.addTween(badge5_glow, { delay: 2, onComplete: function() { badge5_glow.gotoAndPlay("play"); } } );
				Tweener.addTween(txt_95, { alpha: 1, time: 1, delay: 2 });
				Tweener.addTween(cont_video5, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video5); }});
				if(video5.video.playing) {
					Tweener.addTween(video5.graphic_videoblack, {alpha: 1, time: 1});
					Tweener.addTween(video5.graphic_play, {alpha: 1, time: 1});
					video5.video.stop();
				}
			} /*else if(currentBadge == 6) {
				Tweener.addTween(badge_2.color, { alpha: 1, time: 1, delay: 2});
				Tweener.addTween(badge2_glow, { delay: 1, onComplete: function() { badge2_glow.gotoAndPlay("play"); } } );
			}*/

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
		}

		private function es_continue_dwn(e:TouchEvent):void {
			window_endsession.button_continue.gotoAndStop("down");

			cont_es_no.removeEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn);
			cont_es_no.removeEventListener(TouchEvent.TOUCH_UP, es_no_up);
			cont_es_yes.removeEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn);
			cont_es_yes.removeEventListener(TouchEvent.TOUCH_UP, es_yes_up);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_UP, es_maillist_up);
			cont_es_removeemail.removeEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn);
			cont_es_removeemail.removeEventListener(TouchEvent.TOUCH_UP, es_removeemail_up);
			cont_es_mailbg.removeEventListener(TouchEvent.TOUCH_DOWN, es_email_dwn);
			cont_es_mailbg.removeEventListener(TouchEvent.TOUCH_UP, es_email_up);
			cont_es_esskip.removeEventListener(TouchEvent.TOUCH_DOWN, es_esskip_dwn);
			cont_es_esskip.removeEventListener(TouchEvent.TOUCH_UP, es_esskip_up);
		}

		private function es_continue_up(e:TouchEvent):void {
			window_endsession.button_continue.gotoAndStop("up");

			//Tweener.addTween(cont_endsession_modal, { height: cont_endsession_modal.height - 20, width: cont_endsession_modal.width - 50, alpha: 0, time: 1, onComplete: function() {
			Tweener.addTween(cont_endsession_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
				removeChild(cont_endsession_modal);
				shadeOff();
			} });

			cont_es_no.addEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_UP, es_no_up, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_UP, es_yes_up, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_UP, es_maillist_up, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_UP, es_removeemail_up, false, 0, true);
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_DOWN, es_email_dwn, false, 0, true);
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_UP, es_email_up, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_DOWN, es_esskip_dwn, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_UP, es_esskip_up, false, 0, true);

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
		}

		private function es_no_dwn(e:TouchEvent):void {
			window_endsession.button_no.gotoAndStop("down");

			cont_es_continue.removeEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn);
			cont_es_continue.removeEventListener(TouchEvent.TOUCH_UP, es_continue_up);
			cont_es_yes.removeEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn);
			cont_es_yes.removeEventListener(TouchEvent.TOUCH_UP, es_yes_up);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_UP, es_maillist_up);
			cont_es_removeemail.removeEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn);
			cont_es_removeemail.removeEventListener(TouchEvent.TOUCH_UP, es_removeemail_up);
		}

		private function es_no_up(e:TouchEvent):void {
			window_endsession.button_no.gotoAndStop("up");

			if (currentBadge == -1) { //no badges, so 'no' means don't end session, continue rating
				//Tweener.addTween(cont_endsession_modal, { height: cont_endsession_modal.height - 20, width: cont_endsession_modal.width - 50, alpha: 0, time: 1, onComplete: function() {
				Tweener.addTween(cont_endsession_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
					removeChild(cont_endsession_modal);
					shadeOff();
				} });

				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { delay: 2, onComplete: blockerOff } );
			} else { //earned badges, so 'no' means end session without sending badges
				resetSession();
			}

			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_UP, es_yes_up, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_UP, es_maillist_up, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_UP, es_removeemail_up, false, 0, true);
		}

		private function es_yes_dwn(e:TouchEvent):void {
			window_endsession.button_yes.gotoAndStop("down");

			cont_es_continue.removeEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn);
			cont_es_continue.removeEventListener(TouchEvent.TOUCH_UP, es_continue_up);
			cont_es_no.removeEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn);
			cont_es_no.removeEventListener(TouchEvent.TOUCH_UP, es_no_up);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_UP, es_maillist_up);
			cont_es_removeemail.removeEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn);
			cont_es_removeemail.removeEventListener(TouchEvent.TOUCH_UP, es_removeemail_up);
		}

		private function es_yes_up(e:TouchEvent):void {
			window_endsession.button_yes.gotoAndStop("up");

			if (currentBadge == -1) { //no badges, so 'yes' means just end session

			} else { //earned badges, so 'yes' means send badges and then end session
				//call some function that send request
				sendBadges = true;
			}
			sendUserData();

			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_UP, es_no_up, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_UP, es_maillist_up, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_DOWN, es_removeemail_dwn, false, 0, true);
			cont_es_removeemail.addEventListener(TouchEvent.TOUCH_UP, es_removeemail_up, false, 0, true);
			
			resetSession();
		}

		private function es_maillist_dwn(e:TouchEvent):void {

		}

		private function es_maillist_up(e:TouchEvent):void {
			if (maillist_opt) {
				window_endsession.button_maillist.gotoAndStop("uncheck");
				maillist_opt = false;
			} else {
				window_endsession.button_maillist.gotoAndStop("check");
				maillist_opt = true;
			}
		}

		private function es_removeemail_dwn(e:TouchEvent):void {
			window_endsession.button_removeemail.gotoAndStop("down");

			cont_es_continue.removeEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn);
			cont_es_continue.removeEventListener(TouchEvent.TOUCH_UP, es_continue_up);
			cont_es_no.removeEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn);
			cont_es_no.removeEventListener(TouchEvent.TOUCH_UP, es_no_up);
			cont_es_yes.removeEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn);
			cont_es_yes.removeEventListener(TouchEvent.TOUCH_UP, es_yes_up);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn);
			cont_es_maillist.removeEventListener(TouchEvent.TOUCH_UP, es_maillist_up);
		}

		private function es_removeemail_up(e:TouchEvent):void {
			window_endsession.button_removeemail.gotoAndStop("up");
			cont_endsession_modal.addChild(cont_es_mailbg);
			cont_endsession_modal.addChild(window_endsession.txt_email); 

			//end session layout animate
			//XML
			if(language == 0) {
				Tweener.addTween(window_endsession.txt_email, {alpha: 0, time: 0.5, onComplete: function() { window_endsession.txt_email.htmlText = bold(soapbox_xml.Content.English.enteremail); } });
				Tweener.addTween(window_endsession.txt_prompt, {alpha: 0, time: 0.5, onComplete: function() { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.English.wouldsend);} });				
			} else {
				Tweener.addTween(window_endsession.txt_email, {alpha: 0, time: 0.5, onComplete: function() { window_endsession.txt_email.htmlText = bold(soapbox_xml.Content.Spanish.enteremail); } });
				Tweener.addTween(window_endsession.txt_prompt, {alpha: 0, time: 0.5, onComplete: function() { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.wouldsend);} });				
			}
			Tweener.addTween(window_endsession.txt_email, {alpha: 1, time: 0.5, delay: 0.5});
			Tweener.addTween(window_endsession.txt_prompt, {alpha: 1, time: 0.5, delay: 0.5});

			Tweener.addTween(cont_es_removeemail, {alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_removeemail); } });
			Tweener.addTween(cont_es_yes, {alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_yes); } });
			Tweener.addTween(cont_es_no, {alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_no); } });
			cont_es_esskip.alpha = 0;
			cont_endsession_modal.addChild(cont_es_esskip);
			Tweener.addTween(cont_es_esskip, {alpha: 1, time: 1});
			Tweener.addTween(cont_es_mailbg, {alpha: 1, time: 1});
			Tweener.addTween(cont_es_maillist, {alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_maillist); } });
			
			//share button animate
			button_removeemail.gotoAndStop("up");
			if(language == 0) {
				Tweener.addTween(button_email.text_emailimage, { alpha: 1, time: 1 } );
				Tweener.addTween(button_email.text_emailimageto, { alpha: 0, time: 1 } );
			} else {
				Tweener.addTween(button_email.text_emailimage_esp, { alpha: 1, time: 1 } );
				Tweener.addTween(button_email.text_emailimageto_esp, { alpha: 0, time: 1 } );
			}
			Tweener.addTween(button_removeemail, { alpha: 0, time: 1 } );
			//Tweener.addTween(button_removeemail, { height: button_removeemail.height - 20, width: button_removeemail.width - 20, time: 1 } );
			Tweener.addTween(button_removeemail, { scaleX: 0.8, scaleY: 0.8, time: 1 } );
			Tweener.addTween(email_entered, { alpha: 0, time: 1 } );
			Tweener.addTween(button_email, { alpha: 1, time: 1 } )
			photoSent = false;
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			email = '';

			window_endsession.button_maillist.gotoAndStop("check");
			maillist_opt = true;

			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_DOWN, es_no_dwn, false, 0, true);
			cont_es_no.addEventListener(TouchEvent.TOUCH_UP, es_no_up, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_DOWN, es_yes_dwn, false, 0, true);
			cont_es_yes.addEventListener(TouchEvent.TOUCH_UP, es_yes_up, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_DOWN, es_maillist_dwn, false, 0, true);
			cont_es_maillist.addEventListener(TouchEvent.TOUCH_UP, es_maillist_up, false, 0, true);

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1, onComplete: blockerOff } );
		}

		private function es_okemail_dwn(e:TouchEvent):void {
			window_endsession.button_okemail.gotoAndStop("down");
		}

		private function es_okemail_up(e:TouchEvent):void {
			window_endsession.button_okemail.gotoAndStop("up");

			if ( !softKeyboard.validateEmail(softKeyboard.emailText()) ) { //e-mail invalid
				Tweener.addTween(window_endsession.txt_invalid, { alpha: 1, time: 0.5 } );
				Tweener.addTween(window_endsession.txt_invalid, { alpha: 0, delay: 2, time: 0.5 } );
			} else { //e-mail valid				
				cont_es_mailbg.addEventListener(TouchEvent.TOUCH_UP, es_email_up, false, 0, true);
				email_entered.htmlText = bold(softKeyboard.emailText());
				email_entered.alpha = 0;
				//softKeyboard.clearEmail();
				email = softKeyboard.emailText();
				trace("session ended");
				removeChild(cont_es_exitKeyboard);

				//end session window animate
				Tweener.addTween(window_endsession.window_modal, { height: 395, y: -197.5, time: 1});
				Tweener.addTween(window_endsession.window_emailbg, { y: 51, time: 1});
				Tweener.addTween(window_endsession.txt_endsession, { y: -375, time: 1});
				Tweener.addTween(window_endsession.txt_prompt, { y: -335, time: 1});
				Tweener.addTween(window_endsession.txt_email, { y: 34, time: 1});
				//Tweener.addTween(window_endsession.txt_invalid, { y: -219, time: 1});
				//NOTE: coordinates get distorted somehow, so just hardcoded
				
				//layout buttons
				Tweener.addTween(cont_es_mailbg, { alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_mailbg); } } );
				cont_endsession_modal.addChild(cont_es_maillist);
				Tweener.addTween(cont_es_maillist, {alpha: 1, time: 1} );
				window_endsession.button_removeemail.x = getXpos(2);
				cont_endsession_modal.addChild(cont_es_removeemail);
				cont_es_removeemail.alpha = 0;
				Tweener.addTween(cont_es_removeemail, {alpha: 1, time: 0.5, delay: 1} );
				cont_endsession_modal.addChild(cont_es_yes);
				Tweener.addTween(cont_es_yes, {alpha: 1, time: 1});
				cont_endsession_modal.addChild(cont_es_no);				
				Tweener.addTween(cont_es_no, {alpha: 1, time: 1});
				cont_endsession_modal.addChild(cont_es_esskip);	
				Tweener.addTween(cont_es_esskip, {alpha: 1, time: 1});

				//reactivate end session skip + continue
				cont_endsession_modal.removeChild(cont_es_esskip);
				Tweener.addTween(cont_es_continue, {alpha: 1, time: 1} );

				//ok button disappear
				Tweener.addTween(cont_es_okemail, { alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_okemail); } } );

				//hide keyboard
				Tweener.addTween(softKeyboard, {alpha: 0, time: 1, onComplete: function() { 
					softKeyboard.y = 0;
					softKeyboard.x = 590;
				}} );

				//share button animate
				if(language == 0) {
					Tweener.addTween(button_email.text_emailimage, { alpha: 0, delay: 1, time: 1 } );
					Tweener.addTween(button_email.text_emailimageto, { alpha: 1, delay: 1, time: 1 } );
				} else {
					Tweener.addTween(button_email.text_emailimage_esp, { alpha: 0, delay: 1, time: 1 } );
					Tweener.addTween(button_email.text_emailimageto_esp, { alpha: 1, delay: 1, time: 1 } );
				}
				Tweener.addTween(email_entered, { alpha: 1, delay: 1, time: 1 } );
				addChildAt(cont_removeemail, getChildIndex(cont_shader) - 1);

				button_removeemail.x = getXpos(1);
				Tweener.addTween(button_removeemail, { alpha: 1, delay: 1, time: 1 } );
				Tweener.addTween(button_removeemail, { scaleX: 1, scaleY: 1, delay: 1, time: 1, transition: "easeOutElastic" } );
				EMAIL_ADDED = true; //bubble is on

				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
			}
		}

		private function es_esskip_dwn(e:TouchEvent):void {
			window_endsession.button_esskip.gotoAndStop("down");

			cont_es_continue.removeEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn);
			cont_es_continue.removeEventListener(TouchEvent.TOUCH_UP, es_continue_up);
			cont_es_mailbg.removeEventListener(TouchEvent.TOUCH_DOWN, es_email_dwn);
			cont_es_mailbg.removeEventListener(TouchEvent.TOUCH_UP, es_email_up);
		}

		private function es_esskip_up(e:TouchEvent):void {
			window_endsession.button_esskip.gotoAndStop("up");

			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_DOWN, es_email_dwn, false, 0, true);
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_UP, es_email_up, false, 0, true);

			resetSession();
		}
		
		private function es_email_dwn(e:TouchEvent):void {
			cont_es_continue.removeEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn);
			cont_es_continue.removeEventListener(TouchEvent.TOUCH_UP, es_continue_up);
			cont_es_esskip.removeEventListener(TouchEvent.TOUCH_DOWN, es_esskip_dwn);
			cont_es_esskip.removeEventListener(TouchEvent.TOUCH_UP, es_esskip_up);
		}

		private function es_email_up(e:TouchEvent):void {
			//COMING SOON TEMP
			/*addChild(bubble_comingsoon);
			bubble_comingsoon.x = 150;
			bubble_comingsoon.y = 150;

			Tweener.addTween(bubble_comingsoon, { alpha: 1, time: 1 } );
			Tweener.addTween(bubble_comingsoon, { scaleX: 1, scaleY: 1, time: 1, transition: "easeOutElastic" } );

			Tweener.addTween(bubble_comingsoon, { alpha: 0, time: 1, delay: 4 } );
			Tweener.addTween(bubble_comingsoon, { scaleX: 0.8, scaleY: 0.8, time: 1, delay: 4 } );

			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_DOWN, es_esskip_dwn, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_UP, es_esskip_up, false, 0, true);*/
			
			var target_height:int = window_endsession.window_modal.height + EXPAND_HEIGHT;
			var target_ypos:int = window_endsession.window_modal.y - (target_height - window_endsession.window_modal.height)/2;
			
			addChild(cont_es_exitKeyboard);
			window_endsession.txt_email.text = '';

			/*trace("modal height: " + window_endsession.window_modal.height);
			trace("modal y: " + window_endsession.window_modal.y);
			trace("emailbg y: " + window_endsession.window_emailbg.y);
			trace("end session y: " + window_endsession.txt_endsession.y);
			trace("prompt y: " + window_endsession.txt_prompt.y);
			trace("email text y: " + window_endsession.txt_email.y);
			trace("invalid text y: " + window_endsession.txt_invalid.y);*/

			//shift things up to make room for keyboard
			Tweener.addTween(window_endsession.window_modal, { height: target_height, y: target_ypos, time: 1});
			Tweener.addTween(window_endsession.window_emailbg, { y: window_endsession.window_emailbg.y - EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_endsession.txt_endsession, { y: window_endsession.txt_endsession.y - EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_endsession.txt_prompt, { y: window_endsession.txt_prompt.y - EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_endsession.txt_email, { y: window_endsession.txt_email.y - EXPAND_HEIGHT, time: 1});
			//Tweener.addTween(window_endsession.txt_invalid, { y: window_endsession.txt_invalid.y - EXPAND_HEIGHT, time: 1});

			//deactivate end session
			Tweener.addTween(cont_es_esskip, {alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_esskip); }} );
			Tweener.addTween(cont_es_continue, {alpha: 0.3, time: 1} );

			//ok button appears
			cont_endsession_modal.addChild(cont_es_okemail);
			Tweener.addTween(cont_es_okemail, { alpha: 1, time: 1 , delay: 0.5} );

			//show keyboard
			softKeyboard.alpha = 0;
			softKeyboard.y = -120;
			softKeyboard.x = -297;
			softKeyboard.setInputTF(window_endsession.txt_email);
			Tweener.addTween(softKeyboard, {alpha: 1, time: 1, delay: 0.5} );
			softKeyboard.toDefault();
			addChild(softKeyboard);

			cont_es_mailbg.removeEventListener(TouchEvent.TOUCH_UP, es_email_up);

			cont_es_continue.addEventListener(TouchEvent.TOUCH_DOWN, es_continue_dwn, false, 0, true);
			cont_es_continue.addEventListener(TouchEvent.TOUCH_UP, es_continue_up, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_DOWN, es_esskip_dwn, false, 0, true);
			cont_es_esskip.addEventListener(TouchEvent.TOUCH_UP, es_esskip_up, false, 0, true);

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}

		private function es_exitKeyboard_up(e:TouchEvent):void {
			removeChild(cont_es_exitKeyboard);
			
			cont_es_mailbg.addEventListener(TouchEvent.TOUCH_UP, es_email_up, false, 0, true);
			window_endsession.txt_email.htmlText = bold('enter e-mail here');

			//shift down to hide keyboard
			Tweener.addTween(window_endsession.window_modal, { height: 395, y: -197.5, time: 1});
			Tweener.addTween(window_endsession.window_emailbg, { y: 51, time: 1});
			Tweener.addTween(window_endsession.txt_endsession, { y: -375, time: 1});
			Tweener.addTween(window_endsession.txt_prompt, { y: -335, time: 1});
			Tweener.addTween(window_endsession.txt_email, { y: 34, time: 1});
			//Tweener.addTween(window_endsession.txt_invalid, { y: -219, time: 1});
			//NOTE: coordinates get distorted somehow, so just hardcoded

			//reactivate end session
			cont_endsession_modal.addChild(cont_es_esskip);
			Tweener.addTween(cont_es_esskip, {alpha: 1, time: 1} );
			Tweener.addTween(cont_es_continue, {alpha: 1, time: 1} );

			//ok button disappears
			Tweener.addTween(cont_es_okemail, { alpha: 0, time: 1, onComplete: function() { cont_endsession_modal.removeChild(cont_es_okemail); }} );
			//cont_endsession_modal.removeChild(cont_es_okemail);

			//hide keyboard
			Tweener.addTween(softKeyboard, {alpha: 0, time: 1, onComplete: function() { 
				softKeyboard.y = 0;
				softKeyboard.x = 590;
			}} );

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}

		private function okname_dwn(e:TouchEvent):void {
			window_gotbadge.button_okname.gotoAndStop("down");
		}
		
		private function okname_up(e:TouchEvent):void {
			window_gotbadge.button_okname.gotoAndStop("up");

			if(!contains(cont_video6)) { //ok for name
				if ( !softKeyboard.validateName(softKeyboard.emailText()) ) { //name invalid
					Tweener.addTween( window_gotbadge.txt_invalid, { alpha: 1, time: 0.5 } );
					Tweener.addTween( window_gotbadge.txt_invalid, { alpha: 0, delay: 2, time: 0.5 } );
					trace("invalid");
				} else { //name valid
					window_gotbadge.txt_inputname.text = softKeyboard.emailText() + ",";
					fullname = softKeyboard.emailText();
					//sendName();
					
					var target_height:int = window_gotbadge.window_modal.height - 225;
					var target_ypos:int = window_gotbadge.window_modal.y - (target_height - window_gotbadge.window_modal.height)/2;
		
					//fade out
					Tweener.addTween(window_gotbadge.window_modal, { height: target_height, y: target_ypos, time: 1});
					Tweener.addTween(window_gotbadge.window_name, { alpha: 0, time: 1});
					Tweener.addTween(window_gotbadge.txt_name, { alpha: 0, time: 1});
					Tweener.addTween(window_gotbadge.graphic_prompt, { alpha: 0, time: 1});
					Tweener.addTween(cont_skip, { alpha: 0, time: 1, onComplete: function() { cont_gotbadge_modal.removeChild(cont_skip); }});
					Tweener.addTween(window_gotbadge.graphic_continuebg , { alpha: 0, time: 0.5});
		
					//hide keyboard
					Tweener.addTween(softKeyboard, {alpha: 0, time: 1, onComplete: function() { 
						softKeyboard.y = 0;
						softKeyboard.x = 590;
					}} );
		
					//fade in
					//Tweener.addTween(window_gotbadge.txt_inputname, { alpha: 1, time: 1});
					Tweener.addTween(window_gotbadge.txt_inputname, { alpha: 1, time: 1, delay: 0.5});
					Tweener.addTween(window_gotbadge.txt_thanks, { alpha: 1, time: 1, delay: 1.5});
					addChild(cont_video6);
					Tweener.addTween(cont_video6, {alpha: 1, time: 1, delay: 2});
					Tweener.addTween(cont_video6, {delay: 2.5, onComplete: function() { video6_up(e); }});
		
					blockerOn();
					Tweener.addTween(cont_blocker_fullscreen, { delay: 3, onComplete: blockerOff } );
				}
			} else if (contains(cont_video6)) { //ok for video
				Tweener.addTween(cont_gotbadge_modal, { scaleX: 0.8, scaleY: 0.8, alpha: 0, time: 1, onComplete: function() {
					removeChild(cont_gotbadge_modal);
				} });

				Tweener.addTween(badge_6.color, { alpha: 1, time: 1, delay: 1.5});
				Tweener.addTween(badge6_glow, { delay: 1, onComplete: function() { badge6_glow.gotoAndPlay("play"); } } );
				Tweener.addTween(txt_120, { alpha: 1, time: 1, delay: 1.5 });
				Tweener.addTween(cont_video6, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video6); }});
				if(video6.video.playing) {
					Tweener.addTween(video6.graphic_videoblack, {alpha: 1, time: 1});
					Tweener.addTween(video6.graphic_play, {alpha: 1, time: 1});
					video6.video.stop();
				}

				Tweener.addTween(cont_gotbadge_modal, { delay: 1.5, onComplete: function() { endsession_up(e); } });

				blockerOn();
				Tweener.addTween(cont_blocker_fullscreen, { delay: 2.5, onComplete: blockerOff } );
			}
		}
		
		private function sendUserData():void{
			var uR:URLRequest = new URLRequest("http://dev-mopa.bpoc.org/js-api/vote");
            var uV:URLVariables = new URLVariables();
			uR.method = URLRequestMethod.POST;
			
			if(fullname != ""){
				uV.credits_name = fullname;
			}
			if(maillist_opt){
				uV.optin = "1";
			}
			else{
				uV.optin = "0";
			}
			
			if(email != ""){
				uV.email_address = email;
			}
			
			uV.uid = Main.uID;
			
			var now:Date = new Date();
            uV.date = now.toString();
                        
            uR.data = uV;
			
			var uL:URLLoader = new URLLoader(uR);
		}

		private function skip_dwn(e:TouchEvent):void {
			window_gotbadge.button_skip.gotoAndStop("down");
		}
		
		private function skip_up(e:TouchEvent):void {
			window_gotbadge.button_skip.gotoAndStop("up");

			window_gotbadge.txt_inputname.text = "";

			var target_height:int = window_gotbadge.window_modal.height - 240;
			var target_ypos:int = window_gotbadge.window_modal.y - (target_height - window_gotbadge.window_modal.height)/2;

			//fade out
			Tweener.addTween(window_gotbadge.window_modal, { height: target_height, y: target_ypos, time: 1});
			Tweener.addTween(window_gotbadge.window_name, { alpha: 0, time: 1});
			Tweener.addTween(window_gotbadge.txt_name, { alpha: 0, time: 1});
			Tweener.addTween(window_gotbadge.graphic_prompt, { alpha: 0, time: 1});
			Tweener.addTween(cont_skip, { alpha: 0, time: 1, onComplete: function() { cont_gotbadge_modal.removeChild(cont_skip); }});
			Tweener.addTween(window_gotbadge.graphic_continuebg , { alpha: 0, time: 0.5});

			//hide keyboard
			Tweener.addTween(softKeyboard, {alpha: 0, time: 1, onComplete: function() { 
				softKeyboard.y = 0;
				softKeyboard.x = 590;
			}} );

			//fade in
			Tweener.addTween(window_gotbadge.txt_thanks, { alpha: 1, time: 1, delay: 0.5});
			addChild(cont_video6);
			Tweener.addTween(cont_video6, {alpha: 1, time: 1, delay: 1});
			Tweener.addTween(cont_video6, {delay: 1.5, onComplete: function() { video6_up(e); }});

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 3, onComplete: blockerOff } );
		}


		private function namebg_dwn(e:TouchEvent):void {
		}
		
		private function namebg_up(e:TouchEvent):void {
			var target_height:int = window_gotbadge.window_modal.height + GB_EXPAND_HEIGHT;
			var target_ypos:int = window_gotbadge.window_modal.y - (target_height - window_gotbadge.window_modal.height)/2;
			
			addChild(cont_es_exitKeyboard); //NEED TO ADD EXIT KEYBOARD? RETURN HERE
			window_gotbadge.txt_name.text = '';

			trace("modal height: " + window_gotbadge.window_modal.height);
			trace("modal y: " + window_gotbadge.window_modal.y);
			trace("win name y: " + window_gotbadge.window_name.y);
			trace("name y: " + window_gotbadge.txt_name.y);
			trace("bellows y: " + window_gotbadge.graphic_bellows.y);
			trace("congrats y: " + window_gotbadge.txt_congrats.y);
			trace("120prompt y: " + window_gotbadge.txt_120prompt.y);

			//shift things up to make room for keyboard
			Tweener.addTween(window_gotbadge.window_modal, { height: target_height, y: target_ypos, time: 1});
			Tweener.addTween(window_gotbadge.window_name, { y: window_gotbadge.window_name.y - GB_EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_gotbadge.txt_name, { y: window_gotbadge.txt_name.y - GB_EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_gotbadge.graphic_bellows, { y: window_gotbadge.graphic_bellows.y - GB_EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_gotbadge.txt_congrats, { y: window_gotbadge.txt_congrats.y - GB_EXPAND_HEIGHT, time: 1});
			Tweener.addTween(window_gotbadge.txt_120prompt, { y: window_gotbadge.txt_120prompt.y - GB_EXPAND_HEIGHT, time: 1});

			//remove videos
			Tweener.addTween(cont_video6, {alpha: 0, time: 1, onComplete: function() { removeChild(cont_video6); }});

			//ok button appears
			cont_gotbadge_modal.addChild(cont_okname);
			cont_okname.alpha = 0;
			Tweener.addTween(cont_okname, { alpha: 1, time: 1 , delay: 0.5} );

			//show keyboard
			softKeyboard.alpha = 0;
			softKeyboard.y = -120;
			softKeyboard.x = -297;
			softKeyboard.setInputTF(window_gotbadge.txt_name);
			Tweener.addTween(softKeyboard, {alpha: 1, time: 1, delay: 0.5} );
			softKeyboard.toDefault();
			addChild(softKeyboard);

			//cont_namebg.removeEventListener(TouchEvent.TOUCH_UP, namebg_up);
			
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}

		private function help_dwn(e:TouchEvent):void {
			button_help.gotoAndStop("down");

			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function help_up(e:TouchEvent):void {
			button_help.gotoAndStop("up");

			showInstructions();

			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			dispatchEvent(new Event("activateLang", true));	
		}

		private function video1_dwn(e:TouchEvent):void {
		}
		
		private function video1_up(e:TouchEvent):void {
			//if(video1.video.playheadTime == 0) {
				Tweener.addTween(video1.graphic_videoblack, {alpha: 0, time: 1});
				Tweener.addTween(video1.graphic_play, {alpha: 0, time: 1});
			//}

			if(contains(cont_gotbadge_modal)) {
				if(!video1.video.playing) {
					video1.video.play();
					Tweener.addTween(video1.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video1.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				} else {
					video1.video.pause();
					Tweener.addTween(video1.graphic_play, {alpha: 1, time: 1});
					Tweener.addTween(video1.graphic_videoblack, {alpha: 0.5, time: 1});
					dispatchEvent(new Event("resume_timeout", true));
				}
			}
		}

		private function video1_complete(e:VideoEvent):void {
			//COLLECT DATA

			video1.video.stop();
			Tweener.addTween(video1.graphic_videoblack, {alpha: 1, time: 1});
			Tweener.addTween(video1.graphic_play, {alpha: 1, time: 1});
			dispatchEvent(new Event("resume_timeout", true));
		}

		private function video2_dwn(e:TouchEvent):void {
		}
		
		private function video2_up(e:TouchEvent):void {
			//if(video1.video.playheadTime == 0) {
				Tweener.addTween(video2.graphic_videoblack, {alpha: 0, time: 1});
				Tweener.addTween(video2.graphic_play, {alpha: 0, time: 1});
			//}

			if(contains(cont_gotbadge_modal)) {
				if(!video2.video.playing) {
					video2.video.play();
					Tweener.addTween(video2.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video2.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				} else {
					video2.video.pause();
					Tweener.addTween(video2.graphic_play, {alpha: 1, time: 1});
					Tweener.addTween(video2.graphic_videoblack, {alpha: 0.5, time: 1});
					dispatchEvent(new Event("resume_timeout", true));
				}
			}
		}

		private function video2_complete(e:VideoEvent):void {
			//COLLECT DATA

			video2.video.stop();
			Tweener.addTween(video2.graphic_videoblack, {alpha: 1, time: 1});
			Tweener.addTween(video2.graphic_play, {alpha: 1, time: 1});
			dispatchEvent(new Event("resume_timeout", true));
		}

		private function video3_dwn(e:TouchEvent):void {
		}
		
		private function video3_up(e:TouchEvent):void {
			//if(video1.video.playheadTime == 0) {
				Tweener.addTween(video3.graphic_videoblack, {alpha: 0, time: 1});
				Tweener.addTween(video3.graphic_play, {alpha: 0, time: 1});
			//}

			if(contains(cont_gotbadge_modal)) {
				if(!video3.video.playing) {
					video3.video.play();
					Tweener.addTween(video3.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video3.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				} else {
					video3.video.pause();
					Tweener.addTween(video3.graphic_play, {alpha: 1, time: 1});
					Tweener.addTween(video3.graphic_videoblack, {alpha: 0.5, time: 1});
					dispatchEvent(new Event("resume_timeout", true));
				}
			}
		}

		private function video3_complete(e:VideoEvent):void {
			//COLLECT DATA

			video3.video.stop();
			Tweener.addTween(video3.graphic_videoblack, {alpha: 1, time: 1});
			Tweener.addTween(video3.graphic_play, {alpha: 1, time: 1});
			dispatchEvent(new Event("resume_timeout", true));
		}

		private function video4_dwn(e:TouchEvent):void {
		}
		
		private function video4_up(e:TouchEvent):void {
			//if(video1.video.playheadTime == 0) {
				Tweener.addTween(video4.graphic_videoblack, {alpha: 0, time: 1});
				Tweener.addTween(video4.graphic_play, {alpha: 0, time: 1});
			//}

			if(contains(cont_gotbadge_modal)) {
				if(!video4.video.playing) {
					video4.video.play();
					Tweener.addTween(video4.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video4.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				} else {
					video4.video.pause();
					Tweener.addTween(video4.graphic_play, {alpha: 1, time: 1});
					Tweener.addTween(video4.graphic_videoblack, {alpha: 0.5, time: 1});
					dispatchEvent(new Event("resume_timeout", true));
				}
			}
		}

		private function video4_complete(e:VideoEvent):void {
			//COLLECT DATA

			video4.video.stop();
			Tweener.addTween(video4.graphic_videoblack, {alpha: 1, time: 1});
			Tweener.addTween(video4.graphic_play, {alpha: 1, time: 1});
			dispatchEvent(new Event("resume_timeout", true));
		}

		private function video5_dwn(e:TouchEvent):void {
		}
		
		private function video5_up(e:TouchEvent):void {
			//if(video1.video.playheadTime == 0) {
				Tweener.addTween(video5.graphic_videoblack, {alpha: 0, time: 1});
				Tweener.addTween(video5.graphic_play, {alpha: 0, time: 1});
			//}

			if(contains(cont_gotbadge_modal)) {
				if(!video5.video.playing) {
					video5.video.play();
					Tweener.addTween(video5.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video5.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				} else {
					video5.video.pause();
					Tweener.addTween(video5.graphic_play, {alpha: 1, time: 1});
					Tweener.addTween(video5.graphic_videoblack, {alpha: 0.5, time: 1});
					dispatchEvent(new Event("resume_timeout", true));
				}
			}
		}

		private function video5_complete(e:VideoEvent):void {
			//COLLECT DATA

			video5.video.stop();
			Tweener.addTween(video5.graphic_videoblack, {alpha: 1, time: 1});
			Tweener.addTween(video5.graphic_play, {alpha: 1, time: 1});
			dispatchEvent(new Event("resume_timeout", true));
		}

		private function video6_dwn(e:TouchEvent):void {
		}
		
		private function video6_up(e:TouchEvent):void {
			//if(video1.video.playheadTime == 0) {
				Tweener.addTween(video6.graphic_videoblack, {alpha: 0, time: 1});
				Tweener.addTween(video6.graphic_play, {alpha: 0, time: 1});
			//}

			if(contains(cont_gotbadge_modal)) {
				if(!video6.video.playing) {
					video6.video.play();
					Tweener.addTween(video6.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video6.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				} else {
					video6.video.pause();
					Tweener.addTween(video6.graphic_play, {alpha: 1, time: 1});
					Tweener.addTween(video6.graphic_videoblack, {alpha: 0.5, time: 1});
					dispatchEvent(new Event("resume_timeout", true));
				}
			}
		}

		private function video6_complete(e:VideoEvent):void {
			//COLLECT DATA

			video6.video.stop();
			Tweener.addTween(video6.graphic_videoblack, {alpha: 1, time: 1});
			Tweener.addTween(video6.graphic_play, {alpha: 1, time: 1});
			dispatchEvent(new Event("resume_timeout", true));
		}

		private function star1_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");

			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function star1_up(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star1.effect_starglow.gotoAndPlay("on");
			setRating(1);
			animateSwitch();

			Tweener.addTween(this, {delay: 2.4, onComplete: function() { 
				cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
				cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
				dispatchEvent(new Event("activateLang", true));
			}});			
			
			if (photoSent)
				reactivateEmailButton();
		}
		
		private function star2_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");

			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function star2_up(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star1.effect_starglow.gotoAndPlay("on");
			button_star2.effect_starglow.gotoAndPlay("on");
			
			setRating(2);
			animateSwitch();

			Tweener.addTween(this, {delay: 2.4, onComplete: function() {
				cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
				cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
				dispatchEvent(new Event("activateLang", true));
			}});

			if (photoSent)
				reactivateEmailButton();
		}
		
		private function star3_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");

			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function star3_up(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
			button_star1.effect_starglow.gotoAndPlay("on");
			button_star2.effect_starglow.gotoAndPlay("on");
			button_star3.effect_starglow.gotoAndPlay("on");
			
			setRating(3);
			animateSwitch();
			
			Tweener.addTween(this, {delay: 2.4, onComplete: function() {
				cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
				cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
				dispatchEvent(new Event("activateLang", true));
			}});

			if (photoSent)
				reactivateEmailButton();
		}
		
		private function star4_dwn(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
			button_star4.gotoAndStop("down");

			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			dispatchEvent(new Event("deactivateLang", true));
			photo_blockerOn();
		}
		
		private function star4_up(e:TouchEvent):void {
			button_star1.gotoAndStop("down");
			button_star2.gotoAndStop("down");
			button_star3.gotoAndStop("down");
			button_star4.gotoAndStop("down");
			button_star1.effect_starglow.gotoAndPlay("on");
			button_star2.effect_starglow.gotoAndPlay("on");
			button_star3.effect_starglow.gotoAndPlay("on");
			button_star4.effect_starglow.gotoAndPlay("on");
			
			setRating(4);
			animateSwitch();

			Tweener.addTween(this, {delay: 2.4, onComplete: function() {
				cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
				cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
				cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
				cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
				dispatchEvent(new Event("activateLang", true));
			}});
			
			if (photoSent)
				reactivateEmailButton();
		}

		private function deactivate_enterphoto(e:Event):void {
			cont_endsession.removeEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn);
			cont_endsession.removeEventListener(TouchEvent.TOUCH_UP, endsession_up);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn);
			cont_toscreen.removeEventListener(TouchEvent.TOUCH_UP, toscreen_up);
			cont_email.removeEventListener(TouchEvent.TOUCH_DOWN, email_dwn);
			cont_email.removeEventListener(TouchEvent.TOUCH_UP, email_up);
			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);
			dispatchEvent(new Event("deactivateLang", true));
		}

		private function activate_exitphoto(e:Event):void {
			cont_endsession.addEventListener(TouchEvent.TOUCH_DOWN, endsession_dwn, false, 0, true);
			cont_endsession.addEventListener(TouchEvent.TOUCH_UP, endsession_up, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_DOWN, toscreen_dwn, false, 0, true);
			cont_toscreen.addEventListener(TouchEvent.TOUCH_UP, toscreen_up, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_DOWN, email_dwn, false, 0, true);
			cont_email.addEventListener(TouchEvent.TOUCH_UP, email_up, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
			cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
			cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
			cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
			cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			dispatchEvent(new Event("activateLang", true));
		}
		
		private function setMetadata(iTitle, iArtist, iBio, iDate, iProcess, iCredit, iCopyright):void{
			var newline:String = "<br>";
			var oldTH:Number = text_metadata.textHeight;
			var	oldWH:Number = window_metadata.height;
			
			/*var ss:StyleSheet = new StyleSheet();
			var myItalic:Object = {fontFamily:"Calibri Italic", letterSpacing:0, fontSize:16, color:"#CCCCCC"};
			ss.setStyle(".myItalic", myItalic);
			text_metadata.styleSheet = ss;
			text_metadata.embedFonts = true;*/
			
			text_metadata.autoSize = TextFieldAutoSize.LEFT;
			text_metadata.htmlText = bold(iArtist) + newline + iBio + newline + newline + italic(iTitle) +
								     newline + iDate + newline + iProcess + newline + newline + iCredit +
									 newline + iCopyright;
			text_metadata.wordWrap = true;
			text_metadata.multiline = true;
			
			text_metadata.height += (text_metadata.textHeight - oldTH);
			
			//var next_height:int = text_metadata.textHeight + 14 * 2;
			//var next_y:int = window_metadata.y + (oldWH - next_y) / 2;
			
			text_metadata.y = window_metadata.y - text_metadata.height / 2;
			
			Tweener.addTween(window_metadata, { time: 1, height: text_metadata.textHeight + 14 * 2, y: window_metadata.y + (oldWH - window_metadata.height) / 2 } );
			Tweener.addTween(text_metadata, { time: 1, alpha: 1} );
		}
		
		private function bold(input:String):String{
			return "<B>" + input + "</B>";
		}

		private function italic(input:String):String{
			return "<I>" + input + "</I>";
		}
		
		private function animateSwitch():void {
			Tweener.addTween(button_star1, { time: 1.3, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			Tweener.addTween(button_star2, { time: 1.3, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			Tweener.addTween(button_star3, { time: 1.3, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0 } );
			Tweener.addTween(button_star4, { time: 1.3, delay: 1, width: 10, height: 10, rotation: 90, alpha: 0, onComplete: function() {
				button_star1.rotation = button_star2.rotation = button_star3.rotation = button_star4.rotation = 0;
				button_star1.alpha = button_star2.alpha = button_star3.alpha = button_star4.alpha = 1;
				button_star1.width = button_star2.width = button_star3.width = button_star4.width = 81.8;
				button_star1.height = button_star2.height = button_star3.height = button_star4.height = 77.8;
				
				button_star1.gotoAndStop("up");
				button_star2.gotoAndStop("up");
				button_star3.gotoAndStop("up");
				button_star4.gotoAndStop("up");
				
				button_star1.effect_starglow.gotoAndStop("off");
				button_star2.effect_starglow.gotoAndStop("off");
				button_star3.effect_starglow.gotoAndStop("off");
				button_star4.effect_starglow.gotoAndStop("off");
			}} );

			//reactivate stars
			Tweener.addTween(this, {delay: 2.4, onComplete: function() {
				cont_star1.addEventListener(TouchEvent.TOUCH_DOWN, star1_dwn, false, 0, true);
				cont_star1.addEventListener(TouchEvent.TOUCH_UP, star1_up, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_DOWN, star2_dwn, false, 0, true);
				cont_star2.addEventListener(TouchEvent.TOUCH_UP, star2_up, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_DOWN, star3_dwn, false, 0, true);
				cont_star3.addEventListener(TouchEvent.TOUCH_UP, star3_up, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_DOWN, star4_dwn, false, 0, true);
				cont_star4.addEventListener(TouchEvent.TOUCH_UP, star4_up, false, 0, true);
			}});

			cont_star1.removeEventListener(TouchEvent.TOUCH_DOWN, star1_dwn);
			cont_star1.removeEventListener(TouchEvent.TOUCH_UP, star1_up);
			cont_star2.removeEventListener(TouchEvent.TOUCH_DOWN, star2_dwn);
			cont_star2.removeEventListener(TouchEvent.TOUCH_UP, star2_up);
			cont_star3.removeEventListener(TouchEvent.TOUCH_DOWN, star3_dwn);
			cont_star3.removeEventListener(TouchEvent.TOUCH_UP, star3_up);
			cont_star4.removeEventListener(TouchEvent.TOUCH_DOWN, star4_dwn);
			cont_star4.removeEventListener(TouchEvent.TOUCH_UP, star4_up);

			if(!reachedEnd){
				addChildAt(photo, getChildIndex(effect_insetbg) + 1);
				addChildAt(dummyPhoto, getChildIndex(photo) + 1);
				photo.x += SLOT_WIDTH + 30;
				photo.id = getNext();
	
				//fade out metadata
				Tweener.addTween(text_metadata, { delay: 0.7, time: 1, alpha: 0, onComplete: function() { 
					setMetadata(photo.title, photo.artist, photo.bio, photo.date, photo.process, photo.credit, photo.copyright); 
				}} );
				
				//photo transitions
				Tweener.addTween(dummyPhoto, { delay: 0.7, x: PHOTO_LOCX - SLOT_WIDTH - 30, time: 1.7, transition: "easeInOutQuart" } );
				Tweener.addTween(photo, { x: PHOTO_LOCX, delay: 0.7, time: 1.7, transition: "easeInOutQuart", onComplete: function() {
					removeChild(dummyPhoto);
					dummyPhoto.id = photo.id;
					dummyPhoto.x = photo_slot.x - photo_slot.width / 2;
					dummyPhoto.y = photo_slot.y - photo_slot.height / 2;				
				} } );
	
				if(!gotBadge_bool) {
					photo_blockerOn();
					Tweener.addTween(cont_blocker_photo, { delay: 2.4, onComplete: photo_blockerOff } );
				}
			}
		}

		/*
		 * Prepares layout for end session modal window
		 *
		 */
		private function layoutESwindow():void {			
			window_endsession.txt_continue.visible = false;
			window_endsession.graphic_continuebg.visible = false;
			window_endsession.txt_invalid.visible = false;
			//window_endsession.button_removeemail.visible = false;

			cont_es_mailbg.alpha = 1;
			cont_es_yes.alpha = 1;
			cont_es_no.alpha = 1;
			cont_es_removeemail.alpha = 1;
			cont_es_esskip.alpha = 1;
			cont_es_maillist.alpha = 1;
			window_endsession.txt_email.visible = true;
			cont_endsession_modal.addChild(cont_es_yes);
			cont_endsession_modal.addChild(cont_es_no);
			cont_endsession_modal.addChild(cont_es_continue);
			cont_endsession_modal.addChild(cont_es_esskip);
			cont_endsession_modal.addChild(cont_es_maillist);
			cont_endsession_modal.addChild(cont_es_mailbg);
			cont_endsession_modal.addChild(cont_es_removeemail);

			//if(false) { //testing
			if(currentBadge == -1 && !package_created) { //if no badges earned AND no images marked
				window_endsession.window_modal.height = 240;
				window_endsession.window_modal.y = -(window_endsession.window_modal.height/2);

				window_endsession.txt_endsession.y = -220;
				window_endsession.txt_prompt.y = -180;
				//XML
				if(language == 0) {	window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.English.sure); }
				else { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.sure); }
				
				window_endsession.button_yes.visible = true;
				window_endsession.button_yes.y = -90 + ES_LOCY;
				window_endsession.button_yes.x = -70;
				window_endsession.button_yes.txt_yes.visible = true;
				window_endsession.button_yes.txt_yeslong.visible = false;

				window_endsession.button_no.visible = true;
				window_endsession.button_no.y = -90 + ES_LOCY;
				window_endsession.button_no.x = 70;
				window_endsession.button_no.txt_no.visible = true;
				window_endsession.button_no.txt_nolong.visible = false;

				window_endsession.txt_email.visible = false;
				cont_endsession_modal.removeChild(cont_es_continue);
				cont_endsession_modal.removeChild(cont_es_esskip);
				cont_endsession_modal.removeChild(cont_es_mailbg);
				cont_endsession_modal.removeChild(cont_es_maillist);
				cont_endsession_modal.removeChild(cont_es_removeemail);
			} else { //either badge earned OR image marked
				//determine text prompt
				if(currentBadge != -1 && !package_created) { //got badge, no images marked
					if(language == 0) { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.English.sendbadgesonly); } 
					else { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.wouldsend); }
				} else if (currentBadge == -1 && package_created) { //images marked, no badges
					if(language == 0) { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.English.sendimages); } 
					else { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.wouldsend); }
				} else if (currentBadge != -1 && package_created) { //got badge, images marked
					if(language == 0) { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.English.sendbadim); } 
					else { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.wouldsend); }
				}

				//email format
				if(email != '') { //email entered
					//XML
					//if(language == 0) { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.English.wouldsend); } 
					//else { window_endsession.txt_prompt.htmlText = bold(soapbox_xml.Content.Spanish.wouldsend); }
					window_endsession.txt_email.htmlText = bold(email);

					window_endsession.button_removeemail.alpha = 1;
					window_endsession.button_removeemail.x = getXpos(2);

					cont_endsession_modal.removeChild(cont_es_mailbg);
					cont_endsession_modal.removeChild(cont_es_esskip);
				} else { //email not entered
					//XML
					if(language == 0) { window_endsession.txt_email.htmlText = bold(soapbox_xml.Content.English.enteremail); } 
					else { window_endsession.txt_email.htmlText = bold(soapbox_xml.Content.Spanish.enteremail); }
					
					cont_endsession_modal.addChild(cont_es_mailbg);
					cont_endsession_modal.removeChild(cont_es_maillist);
					cont_endsession_modal.removeChild(cont_es_yes);
					cont_endsession_modal.removeChild(cont_es_no);
					cont_endsession_modal.removeChild(cont_es_removeemail);
					cont_endsession_modal.addChild(window_endsession.txt_email); //in order to keep e-mail above white bg
				}

				window_endsession.window_modal.height = 395;
				window_endsession.window_modal.y = -(window_endsession.window_modal.height/2);

				window_endsession.txt_endsession.y = -375;
				window_endsession.txt_prompt.y = -335;
				
				window_endsession.button_yes.visible = true;
				window_endsession.button_yes.y = -110 + ES_LOCY;
				window_endsession.button_yes.txt_yes.visible = false;
				window_endsession.button_yes.txt_yeslong.visible = true;

				window_endsession.button_no.visible = true;
				window_endsession.button_no.y = -110 + ES_LOCY;
				window_endsession.button_no.txt_no.visible = false;
				window_endsession.button_no.txt_nolong.visible = true;
				
				window_endsession.txt_email.visible = true;
				window_endsession.txt_invalid.visible = true;

				window_endsession.txt_continue.visible = window_endsession.graphic_continuebg.visible = true;
				window_endsession.button_continue.visible = true;

				if(currentBadge == 6) {
					if(cont_endsession_modal.contains(cont_es_continue)) {
						cont_endsession_modal.removeChild(cont_es_continue);
					}
					window_endsession.graphic_continuebg.visible = false;
					window_endsession.txt_continue.visible = false;
				}
			}
		}

		private function gotBadge(badgeNum:int):void {
			//trace("badge " + badgeNum + " achieved!");
			shadeOn();
			addChild(cont_gotbadge_modal);
			gotBadge_bool = true;

			//COLLECT DATA

			if(currentBadge == 1) {
				if(language == 0) {	window_gotbadge.graphic_prompt.gotoAndStop("badge1"); } 
				else { window_gotbadge.graphic_prompt.gotoAndStop("badge1_esp"); }
				addChild(cont_video1);
				Tweener.addTween(cont_video1, {alpha: 1, time: 1, delay: 0.5});
				Tweener.addTween(cont_video1, {delay: 1.5, onComplete: function() { 
					video1.video.play();
					Tweener.addTween(video1.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video1.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				}});
			} else if(currentBadge == 2) {
				if(language == 0) {	window_gotbadge.graphic_prompt.gotoAndStop("badge2"); } 
				else { window_gotbadge.graphic_prompt.gotoAndStop("badge2_esp"); }
				addChild(cont_video2);
				Tweener.addTween(cont_video2, {alpha: 1, time: 1, delay: 0.5});
				Tweener.addTween(cont_video2, {delay: 1.5, onComplete: function() { 
					video2.video.play();
					Tweener.addTween(video2.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video2.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				}});
			} else if(currentBadge == 3) {
				if(language == 0) {	window_gotbadge.graphic_prompt.gotoAndStop("badge3"); } 
				else { window_gotbadge.graphic_prompt.gotoAndStop("badge3_esp"); }
				addChild(cont_video3);
				Tweener.addTween(cont_video3, {alpha: 1, time: 1, delay: 0.5});
				Tweener.addTween(cont_video3, {delay: 1.5, onComplete: function() { 
					video3.video.play();
					Tweener.addTween(video3.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video3.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				}});
			} else if(currentBadge == 4) {
				if(language == 0) {	window_gotbadge.graphic_prompt.gotoAndStop("badge4"); } 
				else { window_gotbadge.graphic_prompt.gotoAndStop("badge4_esp"); }
				addChild(cont_video4);
				Tweener.addTween(cont_video4, {alpha: 1, time: 1, delay: 0.5});
				Tweener.addTween(cont_video4, {delay: 1.5, onComplete: function() { 
					video4.video.play();
					Tweener.addTween(video4.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video4.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				}});
			} else if(currentBadge == 5) {
				if(language == 0) {	window_gotbadge.graphic_prompt.gotoAndStop("badge5"); } 
				else { window_gotbadge.graphic_prompt.gotoAndStop("badge5_esp"); }
				addChild(cont_video5);
				Tweener.addTween(cont_video5, {alpha: 1, time: 1, delay: 0.5});
				Tweener.addTween(cont_video5, {delay: 1.5, onComplete: function() { 
					video5.video.play();
					Tweener.addTween(video5.graphic_play, {alpha: 0, time: 1});
					Tweener.addTween(video5.graphic_videoblack, {alpha: 0, time: 1});
					dispatchEvent(new Event("suspend_timeout", true));
				}});
			} else if(currentBadge == 6) {
				if(language == 0) {	window_gotbadge.graphic_prompt.gotoAndStop("badge6"); } 
				else { window_gotbadge.graphic_prompt.gotoAndStop("badge6_esp"); }
				
				//layout
				window_gotbadge.graphic_continuebg.alpha = 1;
				window_gotbadge.window_modal.height = 820;
				window_gotbadge.window_modal.y = 7;
				window_gotbadge.txt_name.alpha = window_gotbadge.window_name.alpha = 1;
				window_gotbadge.txt_name.text = '';
				cont_gotbadge_modal.addChild(window_gotbadge.txt_name); //in order to keep e-mail above white bg
				cont_gotbadge_modal.removeChild(cont_continue);
				window_gotbadge.txt_continuerating.visible = false;

				//show keyboard
				softKeyboard.alpha = 0;
				softKeyboard.y = -120;
				softKeyboard.x = -297;
				softKeyboard.setInputTF(window_gotbadge.txt_name);
				Tweener.addTween(softKeyboard, {alpha: 1, time: 1, delay: 0.7} );
				softKeyboard.toDefault();
				addChild(softKeyboard);

				//ok + skip button appears
				cont_gotbadge_modal.addChild(cont_okname);
				cont_okname.alpha = 0;
				Tweener.addTween(cont_okname, { alpha: 1, time: 1 , delay: 0.5} );
				cont_gotbadge_modal.addChild(cont_skip);
				cont_skip.alpha = 0;
				Tweener.addTween(cont_skip, { alpha: 1, time: 1 , delay: 0.5} );
			}

			window_gotbadge.x = 0;
			window_gotbadge.y = -120;
			cont_gotbadge_modal.alpha = 0;

			Tweener.addTween(cont_gotbadge_modal, { alpha: 1, time: 1, delay: 0.5 } );
			Tweener.addTween(cont_gotbadge_modal, { scaleX: 1, scaleY: 1, time: 1, delay: 0.5, transition: "easeOutElastic" });

			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: 1.5, onComplete: blockerOff } );
		}

		private function screen_bubble_done(e:TimelineEvent):void {
			if (e.currentLabel === "done") {
				//trace("screen bubble complete");
				SEND_BUBBLE_COMPLETE = true;
			}
		}

		private function packaged_done(e:TimelineEvent):void {
			if (e.currentLabel === "done") {
				//trace("screen bubble complete");
				PACKAGED_COMPLETE = true;
			}
		}
		
		public function shadeOn():void {
			addChild(cont_shader);
			Tweener.addTween(shader, { alpha: 1, time: 1 } );
		}
		
		public function shadeOff():void {
			//trace("call off shader");
			Tweener.addTween(shader, { alpha: 0, time: 1, onComplete: function() { removeChild(cont_shader) } } );
		}
		
		public function timedBlocker(duration:int):void {
			blockerOn();
			Tweener.addTween(cont_blocker_fullscreen, { delay: duration, onComplete: blockerOff } );
		}
		
		public function blockerOn():void {
			//trace("blocker ON");
			addChild(cont_blocker_fullscreen);
			setChildIndex(cont_blocker_fullscreen, numChildren - 1);
			cont_blocker_fullscreen.visible = true;
		}
		
		public function blockerOff():void {
			//trace("blocker OFF");
			removeChild(cont_blocker_fullscreen);
			cont_blocker_fullscreen.visible = false;
		}

		public function photo_blockerOn():void {
			//trace("blocker ON");
			addChild(cont_blocker_photo);
			/*setChildIndex(cont_blocker_photo, numChildren - 1);
			cont_blocker_fullscreen.visible = true;*/
		}
		
		public function photo_blockerOff():void {
			//trace("blocker OFF");
			removeChild(cont_blocker_photo);
			//cont_blocker_photo.visible = false;
		}
	}
	
}
