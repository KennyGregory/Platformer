﻿package other {	// assets	import core.Assets;	import org.flixel.*;		import org.flixel.plugin.photonstorm.FlxControl;	import org.flixel.plugin.photonstorm.FlxControlHandler;	import flash.utils.Timer;	import flash.events.TimerEvent;	import org.flixel.system.FlxTile;	import org.flixel.FlxEmitter;	import core.State;			public class Player extends FlxSprite {				//lives		public var lifes:int;		//underwater		public var underwater:Boolean = false;		public var breath:Number = 100;		public var breathReductionRate:Number = 3;		private var breathTimer:Timer = new Timer(500,1);		//rolling		public var rolling:Boolean;		public var canJump:Boolean;				//running		public var running:Boolean;		public var speedStage:int;		//grenade		public const MAX_GRENADE_CHARGE:Number = 1.8;		public var grenade_charge:Number = 0;		public var grenade_charging:Boolean = false;		public var grenadeContactWhileRolling:Boolean = false;		public var throwing:Boolean = false;				public var keyDown_elapsed:Number = 0;				/****/		private var allowJetpack:Boolean = false;		private var _boosters:Boolean;		private var _canBoost:Boolean;		private var _boostRecharging:Boolean;		private var _fuel:int;		private var _jets:FlxEmitter;				protected var _bullets:FlxGroup;		protected var _aim:uint;						private var pngWidth:int = 16;		private var pngHeight:int = 18;				private var moveSpeed:int = 400;		private var jumpPower:int = 800;		private var maxHealth:int = 100;		private var spawnX:int = 48;		private var spawnY:int = 48;		// lower the # the faster automatic firing of the bullets repeats.		private var maxRateOfFire:Number = .15;		private var rateOfFire:Number = -1; // -1 causes rateOfFire to trigger a new assessment and revert to maxRateOfFire.		//blood emitter		private var _emitter:Object;		private var emitterContents:Array;				//jump effect		private var _jumpEffect:PlayerJumpEffect;				// sfx		private var playerDeathSound:FlxSound;		private var playerJumpSound:FlxSound;		public var charge_sound:FlxSound;				//to check whether the player is bouncable or not when bomb explode		public var bounced:Boolean = false;		// Player		public function Player(X:int, Y:int,Bullets:FlxGroup,Jets:FlxEmitter):void {			super(X,Y);					// spawn locations			spawnX = X;			spawnY = Y;						// health			health = maxHealth;				// graphic			loadGraphic(Assets.playerPNG, true, true, pngWidth, pngHeight, true);			width = 8;			height = 18;			// graphic offset			offset.x = 2;			offset.y = 0;			// animations			addAnimation("normal", [0,1,0,2],10,true);			addAnimation("jump", [2],0,false);			addAnimation("stopped", [0],0,false);			// bullet stuff			_bullets = Bullets;						/****///_jets			_jets = Jets;			// control handler			if (FlxG.getPlugin(FlxControl) == null)			{				FlxG.addPlugin(new FlxControl);			}			FlxControl.create(this, FlxControlHandler.MOVEMENT_ACCELERATES, FlxControlHandler.STOPPING_DECELERATES, 1, true, false);			FlxControl.player1.setCursorControl(false, false, true, true);			FlxControl.player1.setJumpButton("SPACE", FlxControlHandler.KEYMODE_PRESSED, 200, FlxObject.FLOOR, 250, 200);			FlxControl.player1.setMovementSpeed(400, 0, 100, 200, 400, 0);			//	downward gravity of 400px/sec			FlxControl.player1.setGravity(0, 400);			facing = RIGHT;			// jump sfx			playerJumpSound = new FlxSound();			playerJumpSound.loadEmbedded(Assets.playerJumpSFX, false, false);					playerJumpSound.volume = .3;			// jump effect			_jumpEffect = new PlayerJumpEffect();									// death sfx			playerDeathSound = new FlxSound();			playerDeathSound.loadEmbedded(Assets.playerDeathSFX, false, false);									// Set up the charging-up sound			charge_sound = new FlxSound();			charge_sound.loadEmbedded(Assets.snd_charge);			charge_sound.volume = 0.6;						/****///jetpack setup			_boostRecharging = false;			_fuel = 5000;						_jets.gravity = 0;			_jets.setXSpeed( -10, 10);						_jets.setYSpeed(-100,0);						_jets.makeParticles(Assets.ImgJet,15);						_jets.kill();						running = false;			rolling = false;			canJump = true;			lifes = 5;			emitterContents = new Array();						speedStage = 0;			}		override public function update():void {						super.update();				// revive - KEEP AT TOP OF UPDATE()			if(health <= 0) {				trace("[*] Reviving player..");								//saves the positions of player before respawning//				GameSaver.xposition = this.x -10;//				GameSaver.yposition = this.y -10; 				//				respawn(null,null);				respawn(50,50);			}			// underwater			if(underwater) {				// and rolling				if(rolling)  {					// stop rolling					rolling = false;					// re-adjust movement speed					FlxControl.player1.setMovementSpeed(400, 0, 100, 200, 400, 0);					// reload default graphic set for player.					loadGraphic(Assets.playerPNG, true, true, pngWidth, pngHeight, true);				}			}			// move left			if(FlxG.keys.LEFT) {				facing = LEFT;				velocity.x -= moveSpeed * FlxG.elapsed;				if(FlxG.keys.SPACE) { 					this.angularVelocity = -800; // sprite rotation				}			}			// move right			else if(FlxG.keys.RIGHT) { 				facing = RIGHT;				velocity.x += moveSpeed * FlxG.elapsed;				if(FlxG.keys.SPACE) { 					this.angularVelocity = 800; // sprite rotation				}			}				// aim direction			_aim = facing;						// 'r' key to respawn			if(FlxG.keys.R) {				respawn(null,null);			}						///////////////////////////////////////////////////////////			// 	Rolling			// 'down arrow' pressed - turn player into a ball			if(FlxG.keys.justPressed("DOWN")) { 				if(this.rolling) {					// unload rolling graphic					loadGraphic(Assets.playerPNG, true, true, pngWidth, pngHeight, true);					this.rolling = false; // enable/disable rolling					this.width = 12;					this.height = 18;					// restore player movement speed from rolling to default					FlxControl.player1.setMovementSpeed(400, 0, 100, 200, 400, 0);				}				else {					loadGraphic(Assets.playerRollingPNG, false, false, 16, 18, false);					this.rolling = true;					this.width = 10;					this.height = 16;				}			}			if(this.rolling) { 				// disable jumping - i added this feature as i couldn't find a way to disable keys. i think we should have a way to disable individual keys we might add this in the future. - Kenny				FlxControl.player1.disableJumpButton();				if(facing == LEFT) { 					this.angularVelocity = -2600; // sprite rotation				}				else // if facing is neither or RIGHT				{					this.angularVelocity = 2600;				}								// increase player movement speed when rolling				FlxControl.player1.setMovementSpeed(430, 0, 200, 200, 430, 0);			}			else {				// restore jump button player is no longer rolling				FlxControl.player1.setJumpButton("SPACE", FlxControlHandler.KEYMODE_PRESSED, 200, FlxObject.FLOOR, 250, 200);				if(underwater) {					this.angularVelocity = 0;					this.angle = 0;				}			}						////////////////////////////////////////////////////////////////////						// 'space' pressed			if(FlxG.keys.SPACE) { 				if(velocity.y == 0){					_jumpEffect.playAt(this.x - 12, this.y + 10);					FlxG.state.add(_jumpEffect);					playerJumpSound.play(false)				}			}						/////////////////////////////////////////////////////////			// shooting			if((FlxG.keys.S || FlxG.keys.justPressed("S")) && !rolling)			{				// rate of fire is for when holding "S" your weapon will switch to fully automatic mode. rate of fire will vary depending on powerups and weapons.				rateOfFire -= FlxG.elapsed;				if(rateOfFire <= 0) {					// to get the midle point of player					getMidpoint(_point);					// recycling is designed to help you reuse game objects without always re-allocating or "newing" them.					(_bullets.recycle(Bullet) as Bullet).shoot(_point,_aim);					// reset rate of fire. once rate of fire drops below or equals zero; a new bullet will be created at that time.					rateOfFire = maxRateOfFire;				}			}			if(FlxG.keys.justReleased("S")) { 				// we reset the rate of fire so that it will jump back into the if statement above firing when the S key is hit again and will still retain automatic firing without hiccups.				rateOfFire = -1;			}									// player not jumping			if(isTouching(FLOOR) && !rolling)			{				this.angularVelocity = 0;							this.angle = 0;							}			setBounce();			/*if(velocity.y == 0) { 				this.angularVelocity = 0;							this.angle = 0;			}*/			// player jumping			if(velocity.y != 0) {				play("jump");			}			// player not moving			else if(velocity.x == 0) { 				play("stopped");			}			// player moving			else {				play("normal");			}					/****/			_jets.y = this.y + 4;			if(facing == RIGHT) _jets.x = this.x;			else _jets.x = this.x + 5;			if (!velocity.y) {				_canBoost = false;			}			if (velocity.y && FlxG.keys.justReleased("SPACE")) {				_canBoost = true;			}			if (velocity.y > 0) {				_canBoost = true;			}			// initiate boost sequence			if(FlxG.keys.justPressed("SPACE") && !_boosters && _canBoost && !rolling && !underwater) {				if(!allowJetpack) return;				if(_boostRecharging) return; // boost still recharging				else {					// boost charge timer					var boostTimer:Timer = new Timer(1800,1);					boostTimer.addEventListener(TimerEvent.TIMER, boostRechargeTimer, false, 0, true);					boostTimer.start();				}				_boosters = true;				_boostRecharging = true;				_jets.start();			}			if(FlxG.keys.SPACE && underwater) { //				trace("Underwater....");				velocity.y = -50;				acceleration.y = -100;			}			if(!FlxG.keys.SPACE && _boosters)			{				_boosters = false;				this.angularVelocity = 0;							this.angle = 0;					_jets.kill();			}			if (_boosters && _fuel <= 0)			{				_boosters = false;				_jets.kill();			}			if(allowJetpack) { 				if(_boosters && _fuel>0)				{					velocity.y = -70;					_fuel += -10;				}				if(!_boosters && _fuel<400)				{					_fuel += 20;				}			} 			/****/						// player outside of world bounds  - update: allow player outside of top bounds but respawn any other bounds			if(this.x <= 0) {				flicker(.5);				respawn(null,null);			}			else if(x >= FlxG.worldBounds.right || y >= FlxG.worldBounds.bottom ) { 				flicker(.5);				respawn(null,null);			}						do_input();			if (throwing)			{				//play("throw2");				//if (_curFrame == 6) { 				throwing = false; 				//}			}			if(grenadeContactWhileRolling) { 				this.velocity.y += -100;				grenadeContactWhileRolling = false;				trace("Player.x: " + x);			}			/* --------------------------- *///	Speed Run/Momentum Feature						if(FlxG.keys.justPressed("LEFT") || FlxG.keys.justPressed("RIGHT")) {				keyDown_elapsed = 0;			}			else if(FlxG.keys.justReleased("LEFT") || FlxG.keys.justReleased("RIGHT")) { 				keyDown_elapsed = 0;				moveSpeed = 400;				speedStage = 0;			}			if(FlxG.keys.LEFT || FlxG.keys.RIGHT) { 				keyDown_elapsed += FlxG.elapsed;				if(this.isTouching(LEFT) || this.isTouching(RIGHT)) { 					keyDown_elapsed = 0;					moveSpeed = 400;				}							// check elapsed time				else if(keyDown_elapsed >= 1 && keyDown_elapsed < 1.5 && speedStage != 1) { 					speedStage = 1; // fast					moveSpeed = 6000;				}				else if(keyDown_elapsed >= 1.5 && keyDown_elapsed < 2 && speedStage != 2) {					speedStage = 2; // faster					moveSpeed = 8000;				}				else if(keyDown_elapsed >= 2 && keyDown_elapsed < 2.5 && speedStage != 3) { 										speedStage = 3; // fastest					moveSpeed = 10000;				}				// evaluate the elapsed time results...				if(moveSpeed > 400) running = true;				else running = false;					if(running) { 					var momentum:PlayerMomentumEffect = new PlayerMomentumEffect();					momentum.added(true); // add to FlxG.state					FlxG.state.add(momentum);					switch(speedStage) { 						case 1:							momentum.create(.15,50,1);							break;						case 2:							momentum.create(.10,50,1);							break;						case 3:							momentum.create(.15,50,2);							break;					}				}			}			/* --------------------------- *///		}		// boost recharge timer function		private function boostRechargeTimer(e:TimerEvent):void {			e.target.removeEventListener(TimerEvent.TIMER,boostRechargeTimer);			_boostRecharging = false;		}		public function do_input() : void		{			// Grenade			// If you've pressed the button and you're not releasing the grenade			if (FlxG.keys.justPressed("C") && !throwing)			{				grenade_charging = true;				throwing = false;				FlxG.play(Assets.snd_begin_throw);			}						// If you're still charging up			if (FlxG.keys.C && grenade_charging)			{				grenade_charge += FlxG.elapsed;								// Start playing the sound if we've charged a bit (0.16 is arbitrary)								if (grenade_charge > 0.16 && !charge_sound.active)				{					charge_sound.play();				}			}									// If you let go, or it finishes charging, throw			if ( (FlxG.keys.justReleased("C") || grenade_charge >= MAX_GRENADE_CHARGE) && grenade_charging)			{				throwing = true;			}						// But it doesn't actually create the object or anything until the animation has gotten to frame 2			//if (throwing && _curFrame == 2 && _curAnim.name == "throw2" && grenade_charging)			if (throwing && grenade_charging)			{				// Figure out velocities				var xv:Number;				var yv:Number = -70;				if ( facing == LEFT ) { xv = - 40; }				else { xv = 40; }				// Some weird arithmetic which is basically saying the longer you charge, the further it will go, with a tendency				// towards a higher trajectory. <- I don't understand but I'm glad you do :) Joke!				if(rolling) { 					var gRolling:Grenade = new Grenade(x+(this.width/2), y+(this.height/2), 0,0);						(FlxG.state as core.State).group_grenades.add(gRolling);							}				else {					var g:Grenade = new Grenade(x + 8, y + 5, xv * (grenade_charge + 2), yv * (grenade_charge * 1.5 + 0.5));									(FlxG.state as core.State).group_grenades.add(g);				}				// Reset stuff				grenade_charge = 0;				grenade_charging = false;				charge_sound.stop();				FlxG.play(Assets.snd_throw, 0.6);								//FlxG.score += 25; // Joke! LOL!!! ;>			}						/*if (grenade_charging ) { // If you're charging, you can't move.				acceleration.x = 0;				if (onFloor)				{					drag.x = RUN_DRAG;				}				return;			}*/					}		// get bullet spawn point		public function getBulletSpawnPosition():FlxPoint		 {			 var p: FlxPoint = new FlxPoint(x+7, y+9);			 return p;		 }				// kill		override public function kill():void {			trace("Killed player");		}		// respawn		public function respawn(tile:*, obj:*):void {			this.alive = false;			var spawnTimer:Timer = new Timer(300, 1);			spawnTimer.start();			spawnTimer.addEventListener(TimerEvent.TIMER_COMPLETE, spawnTimerFinalize);			playerDeathSound.play(false);			trace("Player respawn function");			lifes--; // take away from lifes the life icon will adjust from State.as once it notices a change.		}		// spawn timer complete		private function spawnTimerFinalize(e:TimerEvent):void {			e.target.removeEventListener(TimerEvent.TIMER_COMPLETE, spawnTimerFinalize);			this.flicker(.5);			this.reset(spawnX,spawnY);						this.alive = true;			this.health = 100;						//sets the player location based on saved location			this.x = GameSaver.xposition;			this.y = GameSaver.yposition;					}		public function setBounce():void {						if(isTouching(FLOOR))			{				if (bounced)				{					bounced = false;					return;				}			}		}		public function useBreath():void { 				if(breathTimer.hasEventListener(TimerEvent.TIMER)) { 				return;			}			else {				breathTimer.addEventListener(TimerEvent.TIMER,takeBreath,false,0,true);				breathTimer.start();			}					}				private function takeBreath(e:TimerEvent):void {			e.target.removeEventListener(TimerEvent.TIMER,takeBreath);			breath -= breathReductionRate;//			trace("Breath remaining: " + breath);			if(breath <= 0) {				breath = 0; // force breath to be 0 if empty								hurt(2);				trace("Hurt player: " + health); 			}						e.target.stop();		}				override public function hurt(Damage:Number):void		{			health = health - Damage;			    		//blood effect while getting injured            _emitter = initBloodEmitter();            _emitter.x = this.x;            _emitter.y = this.y;            _emitter.start(true, .75, 0.2);            FlxG.state.add(_emitter as FlxBasic);            				}		        /**         * init blood emitter         */        private function initBloodEmitter():FlxEmitter        {            var emitter:FlxEmitter = new FlxEmitter(160, 30, 1);            emitter.setXSpeed(-150, 150);            emitter.setYSpeed(0, 250);            emitter.bounce = .02;            //emitter.lifespan = 1;            emitter.gravity = 30;                        var redPixel:FlxParticle;            for (var i:int = 0; i < emitter.maxSize; i++)             {                redPixel = new FlxParticle();                redPixel.makeGraphic(2, 2, 0xFFFF0000);                redPixel.visible = false; //Make sure the particle doesn't show up at (0, 0)                emitter.add(redPixel);                redPixel = new FlxParticle();                redPixel.makeGraphic(1, 1, 0xFFFF0000);                redPixel.visible = false;                emitter.add(redPixel);				            }		            return emitter;        }		}//class}//package