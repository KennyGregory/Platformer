﻿package core {

	import org.flixel.*		
	import org.flixel.plugin.photonstorm.*;
	import other.Player;
	import other.Bullet;
	import other.Enemy;
	import other.Hybrid;
	import other.ExplosionParticle;
	import org.flixel.system.FlxTile;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

		


	public class State extends FlxState {



		// Core References
		private var sky:FlxTilemap;
		public static var map:FlxTilemap;
		public static var player:Player;
		private var bgmusic:FlxSound;
		
		public var _bullets: FlxGroup;
		public var _enemyBullets:FlxGroup;
		public var _grpEnemies:FlxGroup;
		public var _grpHybrids:FlxGroup;
		public var _grpHearts:FlxGroup;
		public var _grpLifes:FlxGroup;		
		public var lifesIconOffset:int = 3;

		private var sprite:FlxSprite;
		private var collisionTriggered:Boolean = false;
		
		//grenade
		public var group_grenades:FlxGroup = new FlxGroup();
		public var group_explosions:FlxGroup = new FlxGroup();

		private var healthBar:FlxSprite;
		
		/****///jets
		private var jets:FlxEmitter;
	

		// Embedded
		[Embed(source = '../assets/player.png')] private var playerPNG:Class; // for the player lifes

		[Embed(source = '../map/mapCSV_Level1_Map.csv', mimeType = "application/octet-stream")] public var mapCSV:Class;
		[Embed(source = '../map/mapCSV_Level1_Sky.csv', mimeType = "application/octet-stream")] public var skyCSV:Class;
		[Embed(source = '../map/backdrop.png')] public var skyTilesPNG:Class;
		[Embed(source = '../assets/tiles.png')] public var mapTilesPNG:Class;

		[Embed(source="../assets/elevator.png")] private var ImgElevator:Class;
		// Music
		[Embed(source = '../assets/backgroundmusic_track1.mp3')] private var musicTrack1:Class;
		
		// Heart / Testing
		[Embed(source = '../assets/heart.png')] private var heartClass:Class;
		


		override public function create():void {			

			// sky
			sky = new FlxTilemap();	
			sky.loadMap(new skyCSV, skyTilesPNG, 192, 300, 0, 0, 1, 1);
			sky.setTileProperties(1, FlxObject.NONE);

			// map
			map = new FlxTilemap();
			map.loadMap(new mapCSV, mapTilesPNG, 16, 16, 0, 0, 1, 31);


			_bullets = new FlxGroup();
			jets = new FlxEmitter(0,0,0.01);
			_enemyBullets = new FlxGroup();			
			_grpHybrids = new FlxGroup();
			_grpHearts = new FlxGroup();
			_grpLifes = new FlxGroup();

			// player
			player = new Player(48,48,_bullets,jets);
			
            _grpEnemies = new FlxGroup();

/******************************			ELEVATOR CODE */
			var path:FlxPath;
			var destination:FlxPoint;
			
			//Create the elevator and put it on a up and down path
			sprite = new FlxSprite(435,80,ImgElevator);
			sprite.immovable = true;
			destination = sprite.getMidpoint();
			destination.y += 112;
			path = new FlxPath([sprite.getMidpoint(),destination]);
			sprite.followPath(path,40,FlxObject.PATH_YOYO);

/*******************************/			


			// Need to move the map to its own Class - Kenny
			
			map.setTileProperties(40, FlxObject.UP, null, null, 4);

			// set tile where we can climb up its layers. open DAME and hover over the tiles to find their index value.. 

			map.setTileProperties(58, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(59, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(60, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(61, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(62, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(77, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(78, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(79, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(80, FlxObject.NONE, waterCollision, null, 1);
			map.setTileProperties(81, FlxObject.NONE, waterCollision, null, 1);


			// camera
			FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);

			trace("map w,h: " + map.width + "," + map.height);

//			FlxG.camera.zoom = 2;	
			
			// add
			add(sky);
			add(map);
			add(sprite);
			add(player);
			add(_grpEnemies);
			add(_grpHybrids);
			add(_bullets);	
			add(jets);
			add(_enemyBullets);
			add(group_grenades);
			add(group_explosions);

			for(var i:int = 0; i < Math.random() * 10; i++) { 
				var heart:FlxSprite = new FlxSprite(Math.random()*map.width,Math.random()*map.height,heartClass);
				heart.scale = new FlxPoint(.5,.5);
				_grpHearts.add(heart);
			}

			add(_grpHearts);


			/*****************health bar**********/
			var frame:FlxSprite = new FlxSprite((FlxG.stage.stageWidth - 75),13);
			frame.makeGraphic(54,10,0xFFFFFFFF);
			frame.scrollFactor.x = 0;
			frame.scrollFactor.y = 0;
			
			var inside:FlxSprite = new FlxSprite((FlxG.stage.stageWidth - 74),14);
			inside.makeGraphic(52,8,0xFFFF0000);
			inside.scrollFactor.x = 0;
			inside.scrollFactor.y = 0;
			
			healthBar = new FlxSprite((FlxG.stage.stageWidth - 73),15);
			healthBar.makeGraphic(50,6,0xFFFFF000);
			healthBar.scrollFactor.x = 0;
			healthBar.scrollFactor.y = 0;

			
			add(frame);
			add(inside);
			add(healthBar);
			/********************************/


			///////////////////////////////////////////////////////////////////////////
			// Lifes HUD

			// add them in reverse so we can remove them from right to left. we pull them from _grpLifes by getFirstAlive
			for(var l:int = player.lifes; l > 0; l--) { 
				var lifeIcon:FlxSprite = new FlxSprite((16 * l) + lifesIconOffset,10);
				lifeIcon.loadGraphic(playerPNG, false, false, 16,18,false);
				lifeIcon.x += 5; // make an adjustment to the whole row x

				// make life icons follow camera movement and hold position
				lifeIcon.scrollFactor.x = 0;
				lifeIcon.scrollFactor.y = 0;
				_grpLifes.add(lifeIcon);
			}

			add(_grpLifes);

			//////////////////////////////////////////////////////////////////////////


			// fixme: camera shouldn't need offset with the stage to be in the correct position.
//			FlxG.camera.y -= 75;
			
			bgmusic = new FlxSound();
			bgmusic.loadEmbedded(musicTrack1,true,false);
			bgmusic.volume = .5;
			bgmusic.play(true);
			FlxG.music = bgmusic;

	
			// Just for now add some enemies. 
			for(var enemycnt:int = 0; enemycnt < 5; enemycnt++) { 
				trace("Added enemy to level");
	            _grpEnemies.add(new Enemy(Math.floor(Math.random()*map.width), Math.floor(Math.random()*map.height) , player, _enemyBullets));		
			}
			for(var hybridcnt:int = 0; hybridcnt < 5; hybridcnt++) { 
				trace("Added hybrid to level");
				_grpHybrids.add(new Hybrid(Math.floor(Math.random()*map.width), Math.floor(Math.random()*map.height)));
			}


		}
	

		override public function update():void { 

			if(!player.alive) return;
		
			if(player.lifes < _grpLifes.length && _grpLifes.length != 0) {
				_grpLifes.remove(_grpLifes.getFirstAlive(),true);
				trace("Removed life.");
			}
			else if(_grpLifes.length == 0) {
				// no lifes remaining. handle what happens when the player runs out of lifes here.
				trace("Handle what happens when the player runs out of lifes here!");
			}

			super.update();
//			trace(FlxG.camera.bounds.x);

			// player general collisions
			FlxG.collide(player, map);
			FlxG.collide(player, sprite);

			// collide with map solid tiles
			FlxG.collide(_grpEnemies,map);
			FlxG.collide(_grpHybrids,map);

			// grenade and hearts collide with map. this allows heart underwater feature w/ alpha			
			FlxG.collide(group_grenades,map);
			FlxG.collide(_grpHearts,map);

			// collide with all map tiles
			FlxG.overlap(_grpEnemies,map,enemyMapCollision);

			// bullets hit enemy type
			FlxG.overlap(_bullets,_grpEnemies,bulletHitEnemy);
			FlxG.overlap(_bullets,_grpHybrids,bulletHitEnemy);

			// bullets touched player
			FlxG.overlap(_enemyBullets,player,enemyBulletHitPlayer);

			// bullets touched map
			FlxG.overlap(_bullets,map,bulletTouchedMap);
			FlxG.overlap(_enemyBullets,map,bulletTouchedMap);

			// heart & player collision
			FlxG.overlap(player,_grpHearts,playerTouchedHeart);		

			if(!player.alive) { 
//				var deathEmitter:FlxEmitter = createEmitter();
//				deathEmitter.at(player);
			}
			FlxG.overlap(player,_grpEnemies,playerTouchedEnemy);
			FlxG.overlap(player,_grpHybrids,playerTouchedEnemy);
//			trace("player health /2 : " + (player.health/2));
			if(player.health > 0)
				healthBar.makeGraphic(((player.health/2)),6,0xFFFFF000);

			// check to see if player is underwater
			switch(map.getTile(Math.floor(player.x)/16,Math.floor(player.y)/16)) { 

				// id of underwater tiles
				case 58: 
				case 59:
				case 60:
				case 61:
				case 62:

				case 77: 
				case 78:
				case 79:
				case 80:
				case 81:

					player.underwater = true; 		
				 	player.acceleration.y = 0;
					player.velocity.y = 35;
					break;

				// other tiles
				default: 
					if(!player.underwater) return;
					else { 
						player.underwater = false;
						player.breath = 100;
						player.alpha = 1;
						player.acceleration.y = 400;
					}
					break;		
			}		


		}

		private function enemyMapCollision(e:Enemy, m:FlxTilemap):void {
			
		}

		private function playerTouchedHeart(p:Player, heart:FlxSprite):void {
			heart.flicker(3);
			heart.kill();
			player.health += 50;
			if(player.health > 100) player.health = 100;
		}


		private function bulletTouchedMap(b:Bullet, m:FlxTilemap):void {

			var tile:uint = m.getTile(b.x/16,b.y/16);


//			trace("bullet over tile: " + tile);

			switch(tile) {
				// solid tiles on the map that the bullet will collide with.
				case 63:
				case 64:
				case 65:
				case 66:
				case 67:
				case 68:
				case 69:
				case 70:
				case 71:
	
				case 31:
				
				case 49:
				case 48:
				case 47:
				case 46:
				case 45:
				case 44:
	
				case 34: 
				case 33: 
				case 32:
					b.kill();
					break;
			}
		}
		
		private function playerTouchedEnemy(p:*, e:*):void {


			if(collisionTriggered) {
				collisionTriggered = false;
				return;
			}
			else {

				collisionTriggered = true;			
				player.flicker(0.15);
				player.hurt(5);
				//if(player.health <= 0) {
					//player.kill();
				//}
//				trace("\tplayer health: " + player.health);


				// player knockback on collision
//				trace(" player collided with: " + e);
				if(player.x < e.x) player.velocity.x = -100;
				else if(player.x > e.x) player.velocity.x = 100;
				if(player.x == e.x) {
					var rand:int = Math.random()*2 + 1;
					switch(rand) {
						case 1:
							player.velocity.x = -100;
							break;
						case 2:
							player.velocity.x = 100;
							break;
					}
				}
			}		
		}
		
        private function bulletHitEnemy(colStar:FlxSprite, colEnemy:FlxSprite):void
        {
            colStar.kill();
            colEnemy.hurt(1);
			// spawn 3 new enemies in duration of every 800ms
			if(colEnemy.health == 0) { 
/*
				var newEnemyTimer:Timer = new Timer(800, 1);
				newEnemyTimer.addEventListener(TimerEvent.TIMER,enemyTimerEvent,false,0,true);
				newEnemyTimer.start();
*/
			}
			if(player.health == 0) player.respawn(null,null);
        }


        private function enemyBulletHitPlayer(colStar:FlxSprite, colPlayer:FlxSprite):void
        {
            player.hurt(2);
			player.flicker(.25);
        }


		private function enemyTimerEvent(e:TimerEvent):void {
            _grpEnemies.add(new Enemy(Math.floor(Math.random()*map.width), Math.floor(Math.random()*map.height) , player, _enemyBullets));			
			if((e.target as Timer).currentCount == 3) {
//				trace("Removing enemyTimerEvent");
				e.target.removeEventListener(TimerEvent.TIMER,enemyTimerEvent);
			}
			else {	
//				trace("enemyTimerEvent currentCount does not equal total of (3)");
			}
			
		}

		// Recycling, like in Collapse Tutorial
		public function addExplosionParticle(x:int, y:int, c:Number):void
		{
			
			var respawn:ExplosionParticle = (group_explosions.getFirstDead() as ExplosionParticle);
			if (group_explosions.members.length < 50 || respawn)
			{
				if (!respawn)
				{
					respawn = new ExplosionParticle();
					group_explosions.add(respawn);
				}
				respawn.spawn(x, y, c);
			}
		}

		private function waterCollision(t:*, o:*):void {
			var passedType:String = getQualifiedClassName(o);
			if(passedType == "other::Player") { 
//				trace("Player is under water");
				player.underwater = true;			
				player.alpha = 0.3;				
				player.useBreath();
			}
			else if(passedType == "other::Enemy") { 
				var e:Enemy = o as Enemy;
				e.underwater = true;
				e.alpha = 0.3;
			}
			else
				o.alpha = 0.3;
		}

	}//class
}//package
