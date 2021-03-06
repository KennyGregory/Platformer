﻿/*
	Parent of: Game.as

	Memory Inspection: 	May,20 2012 (pass)

*/

package core {

	import com.demonsters.debugger.MonsterDebugger;

	import org.flixel.system.FlxPreloader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import core.Game;
	import core.CoreEvent;

	[SWF(width="550", height="400", backgroundColor="#000000")]




///////////////////////////////////////////////////////// [ CLASS ] ////////////////////////////////////////////////////////////////////////////



		
	public class DocumentClass extends Sprite {

		private var preloader:FlxPreloader;
		private var preloaderEnabled:Boolean = true;	// Change to false to disable Preloader. 	<-- Hiren




///////////////////////////////////////////////////////// [ CONSTRUCTOR ] ////////////////////////////////////////////////////////////////////////////




		public function DocumentClass() {
			if(stage) initialize();
			else addEventListener(Event.ADDED_TO_STAGE, initialize);
		}




///////////////////////////////////////////////////////// [ METHODS ] ////////////////////////////////////////////////////////////////////////////




/* --------------------------- */// Initialize


		private function initialize(e:Event = null):void {
			trace("[ + ] Document Class: Initialized");

			if(hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, initialize);


			/* --------------------------- */// Monster Debugger : 3rd Party Debugger
	

			MonsterDebugger.initialize(this,"127.0.0.1",null);


			/* --------------------------- */// Preload			


			if(preloaderEnabled) { 
				// FlxPreloader dispatches this event when it is complete with preload process. We listen for it here and handle it here also.
				stage.addEventListener(CoreEvent.PRELOADED,loadFinished,false,0,true);
				preloader = new FlxPreloader();
				stage.addChild(preloader);			
			}
			else {
				newGame();
			}
		}
				
		private function loadFinished(e:Event):void { 
			trace("[ % ] Assets Loaded!");
			stage.removeEventListener(CoreEvent.PRELOADED,loadFinished);
			newGame();
		}


/* --------------------------- */// New Game


		
		public function newGame():void { 
			var game:Game = new Game;
			addChild(game);		
		}


/* --------------------------- */// Destroy Preloader

		public function destroyPreloader():void {
			if(preloaderEnabled) {
				preloader.destroy();
				preloader = null;
			}
		}


	}//class
}//package
