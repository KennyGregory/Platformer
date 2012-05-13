﻿package other 
{
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import core.State;

	public class Grenade extends FlxSprite
	{
		[Embed(source = '../assets/grenade.png')] private var img_grenade:Class;
		
		[Embed (source = "../assets/blip1.mp3")] private var snd_blip1:Class;
		[Embed (source = "../assets/blip3.mp3")] private var snd_blip2:Class;
		[Embed (source = "../assets/bounce.mp3")] private var snd_bounce:Class;
		[Embed (source = "../assets/explosion2.mp3")] private var snd_explosion:Class;
		
		public const GRAVITY:Number = 200;
		public const EXPLODE_TIME:Number = 3.0;
		public const TICK_INTERVAL:Number = 0.75;
		public const FLASH_DURATION:Number = 0.1;
		public const BOUNCE:Number = 0.6;
		
		public const BLAST_RADIUS:Number = 80;
		public const BLAST_FORCE:Number = 3.0;
		public const HORIZ_BOOST:Number = 1.75; // Makes things fly faster horizontally
		public const BLAST_DAMAGE:Number = 0.75;
		
		public var timer:Number = 0;
		public var jumpVelocity = 50;
		
		public function Grenade(x:int, y:int, xv:Number, yv:Number) 
		{
			super(x, y);
			
			// We just play the spinning animation all the time.
			loadGraphic(img_grenade, true, false, 16, 16);
			addAnimation("spinning", [0, 1, 2, 3, 4, 5, 6, 7], Math.random() * 15, true);
			play("spinning");
			
			timer = EXPLODE_TIME;
			
			velocity.x = xv;
			velocity.y = yv;			
			
			acceleration.y = GRAVITY;
			
			offset.x = 6;
			offset.y = 6;
			width = 4;
			height = 4;
		}
		
		override public function update():void 
		{
			timer -= FlxG.elapsed;
			// This basically checks if the timer is about to go past a tick interval.
			// For example, this will trigger when timer = 3.01 and FlxG.elapsed is more than 0.01
			if (timer % TICK_INTERVAL < (timer - FlxG.elapsed) % TICK_INTERVAL)
			{
				// If this is the last tick, flicker for the whole duration
				if ( timer - FlxG.elapsed < TICK_INTERVAL )
				{
					flicker(TICK_INTERVAL);
					FlxG.play(snd_blip1, 0.8);
				}
				else // Otherwise just flicker briefly
				{
					flicker(FLASH_DURATION);
					FlxG.play(snd_blip1, 0.8);
				}
			}
			
			// If we have half a second left, play the about-to-explode sound
			if (timer >= 0.5 && timer - FlxG.elapsed < 0.5) {
				FlxG.play(snd_blip2, 0.8);
			}
			
			if (timer < 0) {
				explode();
			}
			
			if(isTouching(FLOOR))
			{
				// Play the bounce sound, only if it's moving fast enough.
				if (Math.abs(velocity.y) > 10)
				{
					FlxG.play(snd_bounce, Math.abs(velocity.y / 220));
				}
				
				velocity.y = - jumpVelocity * BOUNCE;
				
				velocity.x *= 0.65;
				jumpVelocity -= 5;
				// This effectively slows down the rotation speed by increasing the time delay between
				// frames in the spinning animation
				_curAnim.delay *= 1.5;
			}
			
			if(isTouching(LEFT))
			{
				FlxG.play(snd_bounce, Math.abs(velocity.x / 220));
				velocity.x = -velocity.x * BOUNCE;
			}
			
			if(isTouching(RIGHT))
			{
				FlxG.play(snd_bounce, Math.abs(velocity.x / 220));
				velocity.x = -velocity.x * BOUNCE;				
			}			
			super.update();
		}
		
		// Helper function to figure out how much to bounce things, if at all
		public function pushTarget(o:Player, damage:Boolean) : void
		{			
			var x1:int = x + 4;
			var y1:int = y + 4;
			var x2:int = o.x + o.width / 2;
			var y2:int = o.y + o.height / 2;
			
			var ds:Number = Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2);
			if ( ds < BLAST_RADIUS * BLAST_RADIUS ) // Check if the object is even in range before doing any expensive square roots
			{
				FlxG.score += ((BLAST_RADIUS * BLAST_RADIUS) - ds) / 100; // Haha.
				
				var d:Number = Math.sqrt(ds);
				o.velocity.x += ((x2 - x1) / d * (BLAST_RADIUS - d) * BLAST_FORCE) * HORIZ_BOOST;
				o.velocity.y += (y2 - y1) / d * (BLAST_RADIUS - d) * BLAST_FORCE
				
				o.bounced = true;
				if ( damage )
				{
					o.health -= (BLAST_RADIUS - d) * BLAST_DAMAGE;
				}
			}
			
		}
		
		public function pushEnemy(o:Enemy, damage:Boolean) : void
		{			
			var x1:int = x + 4;
			var y1:int = y + 4;
			var x2:int = o.x + o.width / 2;
			var y2:int = o.y + o.height / 2;
			
			var ds:Number = Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2);
			if ( ds < BLAST_RADIUS * BLAST_RADIUS ) // Check if the object is even in range before doing any expensive square roots
			{
				FlxG.score += ((BLAST_RADIUS * BLAST_RADIUS) - ds) / 100; // Haha.
				
				var d:Number = Math.sqrt(ds);
				o.velocity.x += ((x2 - x1) / d * (BLAST_RADIUS - d) * BLAST_FORCE) * HORIZ_BOOST;
				o.velocity.y += (y2 - y1) / d * (BLAST_RADIUS - d) * BLAST_FORCE
				
				o.bounced = true;
				if ( damage )
				{
					//o.health -= (BLAST_RADIUS - d) * BLAST_DAMAGE;
					o.hurt(3);
					
				}
			}
			
		}
		
		public function explode() : void
		{
			
			FlxG.shake(0.05,0.1);
			
			FlxG.play(snd_explosion, 1.0);
			
			kill();
			
			// Choose a random color value
			var c:Number = Math.random() * 6.2818;
			// Create 30 triangle particles
			for (var i:int = 0; i < 30; i++)
			{
				(FlxG.state as core.State).addExplosionParticle(x, y, c);
			}
			
			// Bounce the player
			pushTarget( (FlxG.state as core.State).player, false );
			
			// Bounce each enemy (and damage them)
			for each( var e:Enemy in (FlxG.state as core.State)._grpEnemies.members )
			{
				pushEnemy(e, true);
			}
			
		}
	}

}