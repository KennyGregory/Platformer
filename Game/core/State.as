﻿package core {

	import org.flixel.*		
	import org.flixel.plugin.photonstorm.*;
	import other.Player;
	import other.Bullet;
	import other.Enemy;
	import other.ExplosionParticle;
	import org.flixel.system.FlxTile;
	import flash.utils.Timer;
	import flash.events.TimerEvent;



	public class State extends FlxState {

		// Core References
		private var sky:FlxTilemap;
		public static var map:FlxTilemap;
		public var player:Player;
		private var bgmusic:FlxSound;
		
		private var _bullets: FlxGroup;
		private var _enemyBullets:FlxGroup;
		public var _grpEnemies:FlxGroup;
		protected var _grpHearts:FlxGroup;
		private var sprite:FlxSprite;
		private var collisionTriggered:Boolean = false;
		
		//grenade
		public var group_grenades:FlxGroup = new FlxGroup();
		public var group_explosions:FlxGroup = new FlxGroup();

		private var healthBar:FlxSprite;
		
		/****///jets
		private var jets:FlxEmitter;
	

		// Embedded
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
			_grpHearts = new FlxGroup();

			// player
			player = new Player(48,48,_bullets,jets);
			
            _grpEnemies = new FlxGroup();
            _grpEnemies.add(new Enemy(100, 100, player, _enemyBullets));			
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
			// set tile where we can climb up its layers. open DAME and hover over the tiles to find their index value.. 
			map.setTileProperties(40, FlxObject.UP, null, null, 4);


			// camera
			FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
//			FlxG.camera.zoom = 2;	
			
			// add
			add(sky);
			add(map);
			add(sprite);
			add(player);
			add(_grpEnemies);
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
			var frame:FlxSprite = new FlxSprite((FlxG.stage.stageWidth - 100),50);
			frame.makeGraphic(54,10,0xFFFFFFFF);
			frame.scrollFactor.x = 0;
			
			var inside:FlxSprite = new FlxSprite((FlxG.stage.stageWidth - 99),51);
			inside.makeGraphic(52,8,0xFFFF0000);
			inside.scrollFactor.x = 0;
			
			healthBar = new FlxSprite((FlxG.stage.stageWidth - 98),52);
			healthBar.makeGraphic(50,6,0xFFFFF000);
			healthBar.scrollFactor.x = 0;

			
			add(frame);
			add(inside);
			add(healthBar);
			/********************************/


			// fixme: camera shouldn't need offset with the stage to be in the correct position.
			FlxG.camera.y -= 75;
			
			bgmusic = new FlxSound();
			bgmusic.loadEmbedded(musicTrack1,true,false);
			bgmusic.volume = .5;
			bgmusic.play(true);
			FlxG.music = bgmusic;

	
			// Just for now add some enemies. 
			for(var enemycnt:int = 0; enemycnt < 5; enemycnt++) { 
	            _grpEnemies.add(new Enemy(Math.floor(Math.random()*map.width), Math.floor(Math.random()*map.height) , player, _enemyBullets));		
			}

		}
	

		override public function update():void { 

			if(!player.alive) return;


			super.update();
//			trace(FlxG.camera.bounds.x);

			FlxG.collide(player, map);
			FlxG.collide(player, sprite);
			// collide with map solid tiles
			FlxG.collide(_grpEnemies,map);
			
			FlxG.collide(group_grenades,map);
			// collide with all map tiles
			FlxG.overlap(_grpEnemies,map,enemyMapCollision);

			FlxG.overlap(_bullets,_grpEnemies,bulletHitEnemy);
			FlxG.overlap(_enemyBullets,player,enemyBulletHitPlayer);
			FlxG.overlap(_bullets,map,bulletTouchedMap);
			FlxG.overlap(_enemyBullets,map,bulletTouchedMap);

			// heart & player collision
			FlxG.overlap(player,_grpHearts,playerTouchedHeart);		

			if(!player.alive) { 
//				var deathEmitter:FlxEmitter = createEmitter();
//				deathEmitter.at(player);
			}
			FlxG.overlap(player,_grpEnemies,playerTouchedEnemy);
//			trace("player health /2 : " + (player.health/2));
			if(player.health > 0)
				healthBar.makeGraphic(((player.health/2)),6,0xFFFFF000);


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
				if(player.health <= 0) {
					player.kill();
				}
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


	}//class
}//package
