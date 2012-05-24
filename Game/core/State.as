﻿/*
	Parent of: 
			
			Hybrid.as
			Grenade.as
			ExplosionParticle.as
			Enemy.as
			Bullet.as
			Player.as
*/

package core {

	// assets
	import core.Assets;

	import org.flixel.*		
	import org.flixel.plugin.photonstorm.*;
	import other.Player;
	import other.Bullet;
	import other.Enemy;
	import other.Hybrid;
	import other.ExplosionParticle;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;




///////////////////////////////////////////////////////// [ CLASS ] ////////////////////////////////////////////////////////////////////////////




	public class State extends FlxState {


		private var sky:FlxTilemap;
		public static var map:FlxTilemap;
		public static var player:Player;
		private var bgmusic:FlxSound;
		
		public static var playerBullets: FlxGroup;
		public static var enemyBullets:FlxGroup;
		private var max_playerBullets_inQueue:int = 5;
		private var max_enemyBullets_inQueue:int = 10;



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

		private var jets:FlxEmitter;

		//healthbar
		private var healthbar:FlxBar;
	

/* --------------------------- */// Create State


		override public function create():void {			



			/* --------------------------- */// Sky

	
			sky = new FlxTilemap();	
			sky.loadMap(new Assets.skyCSV, Assets.skyTilesPNG, 192, 300, 0, 0, 1, 1);
			sky.setTileProperties(1, FlxObject.NONE);


			/* --------------------------- */// Map


			map = new FlxTilemap();
			map.loadMap(new Assets.mapCSV, Assets.mapTilesPNG, 16, 16, 0, 0, 1, 31);


			/* --------------------------- */// Groups


			playerBullets = new FlxGroup();
			enemyBullets = new FlxGroup();			
			_grpHybrids = new FlxGroup();
			_grpHearts = new FlxGroup();
			_grpLifes = new FlxGroup();
            _grpEnemies = new FlxGroup();

			/* --------------------------- */// Jet Emitter


			jets = new FlxEmitter(0,0,0.01);


			/* --------------------------- */// Player


			player = new Player(48,48,playerBullets,jets);


			/* --------------------------- */// Elevator


			var path:FlxPath;
			var destination:FlxPoint;

			sprite = new FlxSprite(435,80,Assets.ImgElevator);
			sprite.immovable = true;
			destination = sprite.getMidpoint();
			destination.y += 112;
			path = new FlxPath([sprite.getMidpoint(),destination]);
			sprite.followPath(path,40,FlxObject.PATH_YOYO);


			/* --------------------------- */// Assign Specific Tile Properties


			// Tip: Load map in DAME and hover over tiles to find the index # that represents them!
			map.setTileProperties(40, FlxObject.UP, null, null, 4); // walk through but able to jump up to the next level on these tiles

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
			
			/* --------------------------- */// make a slippery tile 
			map.setTileProperties(31, FlxObject.ANY, slippery, null, 1);


			/* --------------------------- */// Camera


			FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
			//FlxG.camera.zoom = 1.5;	
			

			/* --------------------------- */// Heart PowerUp Generation


			for(var i:int = 0; i < Math.random() * 10; i++) { 
				var heart:FlxSprite = new FlxSprite(Math.random()*map.width,Math.random()*map.height,Assets.heartClass);
				heart.scale = new FlxPoint(.5,.5);
				_grpHearts.add(heart);
			}

			add(_grpHearts);


			/* --------------------------- */// Health Bar Creation

			
			healthbar = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT);
			healthbar.scrollFactor.x = 0;
			healthbar.scrollFactor.y = 0;
			healthbar.createImageBar(null, Assets.healthbarPNG, 0x88000000);
			
			add(healthbar);
			FlxG.watch(healthbar, "percent");



			/* --------------------------- */// Lifes HUD


			// add them in reverse so we can remove them from right to left. we pull them from _grpLifes by getFirstAlive
			for(var l:int = player.lifes; l > 0; l--) { 
				var lifeIcon:FlxSprite = new FlxSprite((16 * l) + lifesIconOffset,10);
				lifeIcon.loadGraphic(Assets.playerPNG, false, false, 16,18,false);
				lifeIcon.x += 5; // make an adjustment to the whole row x

				// make life icons follow camera movement and hold position
				lifeIcon.scrollFactor.x = 0;
				lifeIcon.scrollFactor.y = 0;
				_grpLifes.add(lifeIcon);
			}

			add(_grpLifes);


			/* --------------------------- */// Music

			
			bgmusic = new FlxSound();
			bgmusic.loadEmbedded(Assets.musicTrack1,true,false);
			bgmusic.volume = .5;
			bgmusic.play(true);
			FlxG.music = bgmusic;


			/* --------------------------- */// Generic Enemy Generation


			for(var enemycnt:int = 0; enemycnt < 10; enemycnt++) { 
	            _grpEnemies.add(new Enemy(Math.floor(Math.random()*map.width), Math.floor(Math.random()*map.height) , player));		
			}
			for(var hybridcnt:int = 0; hybridcnt < 7; hybridcnt++) { 
				_grpHybrids.add(new Hybrid(Math.floor(Math.random()*map.width), Math.floor(Math.random()*map.height)));
			}


			/* --------------------------- */// Add Objects


			// add
			add(sky);
			add(map);
			add(sprite);
			add(player);
			add(_grpEnemies);
			add(_grpHybrids);
			add(playerBullets);	
			add(jets);
			add(enemyBullets);
			add(group_grenades);
			add(group_explosions);

			
			/* ---------------------------- */// CleanUp ( Don't clean up to much at the same time or we'll get freezing )

			var cleanUpTimer:Timer = new Timer(5000, 0);
			cleanUpTimer.addEventListener(TimerEvent.TIMER,cleanUp);
			cleanUpTimer.start();

			// Destroy Preloader
			var main:DocumentClass = FlxG.stage.getChildAt(0) as DocumentClass;
			main.destroyPreloader();
		}
	



/* --------------------------- */// Update


		override public function update():void { 




			/* --------------------------- */// Health Bar

			if(player.health > 0)
			{
				healthbar.percent = player.health;
			}


			/* --------------------------- *///	Death & Lifes


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


			/* --------------------------- */// Collisions


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
			FlxG.overlap(_grpEnemies,map,null);

			// Bullets hit enemy type
			FlxG.overlap(playerBullets,_grpEnemies,bulletHitEnemy);
			FlxG.overlap(playerBullets,_grpHybrids,bulletHitEnemy);

			// Bullets touched player
			FlxG.overlap(enemyBullets,player,enemyBulletHitPlayer);

			// Bullets touched map
			FlxG.overlap(playerBullets,map,bulletTouchedMap);
			FlxG.overlap(enemyBullets,map,bulletTouchedMap);

			// heart & player collision
			FlxG.overlap(player,_grpHearts,playerTouchedHeart);		

			FlxG.overlap(player,_grpEnemies,playerTouchedEnemy);
			FlxG.overlap(player,_grpHybrids,playerTouchedEnemy);



			/* --------------------------- */// Get Tile at Player x,y 


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





/* --------------------------- */// Player Touched Heart PowerUp


		private function playerTouchedHeart(p:Player, heart:FlxSprite):void {
			heart.flicker(3);
			heart.kill();
			player.health += 50;
			if(player.health > 100) player.health = 100;
		}


/* --------------------------- */// Bullet & Map Collisions


		private function bulletTouchedMap(b:Bullet, m:FlxTilemap):void {

			var tile:uint = m.getTile(b.x/16,b.y/16);

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

		
/* --------------------------- */// Player Touched Enemy


		private function playerTouchedEnemy(p:*, e:*):void {


			if(collisionTriggered) {
				collisionTriggered = false;
				return;
			}
			else {

				collisionTriggered = true;			
				player.flicker(0.15);
				player.hurt(5);
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

		
/* --------------------------- */// Player Bullet hit Enemy


        private function bulletHitEnemy(colStar:FlxSprite, colEnemy:FlxSprite):void
        {
            colStar.kill();
            colEnemy.hurt(1);

        }


/* --------------------------- */// Enemy Bullet hit Player


        private function enemyBulletHitPlayer(colStar:FlxSprite, colPlayer:FlxSprite):void
        {
            player.hurt(2);
			player.flicker(.25);

			if(player.health == 0) player.respawn(null,null);
        }


/* --------------------------- */// Add Explosion Particle


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


/* --------------------------- */// Water Collision


		private function waterCollision(t:*, o:*):void {
			var passedType:String = getQualifiedClassName(o);
			if(passedType == "other::Player") { 
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

/* --------------------------- */// Makes player sleep when on particular tile

		private function slippery(t:*, o:*):void {
			var passedType:String = getQualifiedClassName(o);
			if(passedType == "other::Player") { 
				//trace("Player is on tile31");
				player.x += 0.5;
			}			
		}


///////////////////////////////////////////////////////// [ CLEAN ] ////////////////////////////////////////////////////////////////////////////




/* --------------------------- */// CleanUp


		private function cleanUp(e:TimerEvent):void { 
			playerBullet_cleanUp();
			enemyBullet_cleanUp();
		}

		// just an idea before i loose it we can assign a value FlxG.elapsed to each object that dies and after its been dead so long remove it add all FlxGroups to another array and loop through that array searching for any dead objects that's timed out!


		private function playerBullet_cleanUp():void { 
			// if theres more player bullets in FlxGroup than allowed
			//trace("playerBullets.length: " + playerBullets.length);
			if(playerBullets.length > max_playerBullets_inQueue) {
				for(var diff:int = 0; diff < playerBullets.length - max_playerBullets_inQueue; diff++) {
					var deadBullet:Bullet = playerBullets.getFirstDead() as Bullet;
					if(deadBullet != null) {
						playerBullets.remove(deadBullet,true);
						deadBullet = null;
					}
					else 
						continue;
				}
			}
		}
		private function enemyBullet_cleanUp():void { 
			// if theres more enemy bullets in FlxGroup than allowed
			//trace("enemy.length: " + enemyBullets.length);
			if(enemyBullets.length > max_enemyBullets_inQueue) {
				for(var diff:int = 0; diff < enemyBullets.length - max_enemyBullets_inQueue; diff++) {
					var deadBullet:Bullet = enemyBullets.getFirstDead() as Bullet;
					if(deadBullet != null) { 	
						enemyBullets.remove(deadBullet,false);
						deadBullet = null;
					}
					else 
						continue;
				}
			}
		}





	}//class
}//package
