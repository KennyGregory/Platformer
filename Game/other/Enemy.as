﻿package  other{
	
	import org.flixel.*;
	import other.Bullet;
	
	public class Enemy extends FlxSprite
	{
		[Embed(source="../assets/Enemy.png")] private var ImgEnemy:Class;

		protected var _bullets:FlxGroup;
		protected var maxRateOfFire:Number = .60;
		protected var rateOfFire:Number = -1;
		protected var _aim:uint;		

		private var _move_speed:int = 400;  
		private var _jump:Number = 0;
		private var jumpPadding:int = 20;
		private var _max_health:int = 10;
		private var _hurt_counter:Number = 0;
		private var _attack_counter:Number = 0;

		//to check whether the enemy is bouncable or not when bomb explode
		public var bounced:Boolean = false;

		// player reference
		private var _player:FlxSprite;   
		
        public function Enemy(X:Number, Y:Number, ThePlayer:FlxSprite, Bullets:FlxGroup):void
        {
            super(X, Y);
            loadGraphic(ImgEnemy, true, true, 16, 16);
			
			_player = ThePlayer;
            
            maxVelocity.x = 25;
            maxVelocity.y = 200;
			
			health = 2;
            acceleration.y = 420;            
            drag.x = 300;
            width = 8;
            height = 14;
            offset.x = 4;
            offset.y = 2;
            
            addAnimation("normal", [0, 1, 2, 3], 10);
            addAnimation("jump", [2]);
            addAnimation("attack", [4,5,6],10);
            addAnimation("stopped", [0]);
            addAnimation("hurt", [2,7],10);
            addAnimation("dead", [7, 7, 7], 5);

			_bullets = Bullets;
		
        }			
		
		override public function update():void
        {
				
			// enemy object x,y location rounded
			var pt:FlxPoint = new FlxPoint(Math.floor(x),Math.floor(y));
			// player object x,y location rounded
			var playerPt:FlxPoint = new FlxPoint(Math.floor(_player.x),Math.floor(_player.y));
			
			// jump if below player
			if(pt.y > _player.y) { 
				if(facing == LEFT) { 
					if((playerPt.x + jumpPadding) > pt.x) {
						jump();
					}
		
				}
				else if(facing == RIGHT) {
					if((playerPt.x - jumpPadding) < pt.x) {
						jump();
					}			
				}
			}
			// reset jump
			if(this.velocity.y == 0) { 
				_jump = 0;
			}

			setBounce();
            // alive
            if(!alive)
            {
				this.kill();
                if (finished)
                    exists = false;
                else
                    super.update();
                return;
            }
            
			// hurt
            if (_hurt_counter > 0)
            {
                _hurt_counter -= FlxG.elapsed*3;
            }		
			
			// standing below player
			if(_player.x == pt.x) {
				play("stopped");
			}			
			// walk left
			else if(_player.x < x) {
				facing = LEFT;
				velocity.x -= _move_speed * FlxG.elapsed;
			}
			// walk right
			else
            {
                facing = RIGHT;
                velocity.x += _move_speed * FlxG.elapsed;                
            }

			
			// enemy shoot
			_aim = facing;
			if(pt.y <= (playerPt.y + 25 /* padding */) && pt.y >= (playerPt.y - 25 /* padding */))  {
//				trace("firing");
				rateOfFire -= FlxG.elapsed;
				if(rateOfFire <= 0) {
					(_bullets.recycle(Bullet) as Bullet).shoot(new FlxPoint(pt.x+2,pt.y+3),_aim);

					rateOfFire = maxRateOfFire;
				}
			}
			else {
				rateOfFire = -1;
			}
			// end


			if (_hurt_counter > 0)
            {
                play("hurt");
            }
            else            
            {
                if (_attack_counter > 0)
                {
                    play("attack");
                }
                else
                {
                    if (velocity.y != 0)
                    {
                        play("jump");
                    }
                    else
                    {
                        if (velocity.x == 0)
                        {
                            play("stopped");
                        }
                        else
                        {
                           play("normal");
                        }
                    }
                }
            }
            
            super.update();
            
        }

		public function jump():void {
//			trace("Jumping!");
			if(velocity.y == 0) {
				if(_jump >= 0) {
					_jump += FlxG.elapsed;
					if(_jump > 0.25) {
						_jump = -1;
					}
				}
				else {
					_jump = -1;
				}
				if(_jump > 0) {
					if(_jump < 0.065) {
						velocity.y = -180;
						this.play("jump");
					}
					else {
						acceleration.y = 50;
					}
				}
				else {
					velocity.y = 1200;
				}
			}
		}
		
		
		override public function hurt(Damage:Number):void
        {
            _hurt_counter = 1;
            return super.hurt(Damage);
        } 

		public function setBounce():void {
			
			if(isTouching(FLOOR))
			{
				if (bounced)
				{
					bounced = false;
					return;
				}
			}

		}

	}
	
}
