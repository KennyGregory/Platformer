﻿package other 
{
	import org.flixel.*;
	
	public class ExplosionParticle extends FlxSprite
	{
		[Embed (source = "../assets/explosion.png")] private var img_explosion:Class;
		
		// Time until death
		public var t:Number;
		
		// We're going to recycle these particles. As such, the constructor is minimal, and the spawn() function has all the setup
		public function ExplosionParticle() 
		{
			super();
			loadGraphic(img_explosion, false, true, 128, 256);
			offset.x = 64;
			offset.y = 128;
		}
		
		public function spawn(x:int, y:int, c:Number): void
		{
			// Reset these in case this is a recycled particle
			alive = true;
			exists = true;
			
			this.x = x;
			this.y = y;
			angle = Math.random() * 360;
			angularVelocity = Math.random() * 45 - 22.5;
			scale.x = Math.random() * 0.3 + 0.1;
			scale.y = Math.random() * 0.2 + 0.1;
			
			// Color offset value
			var cs:Number = Math.random() * 2;
			
			// RAINBOW
			color = 0xff000000 +
			0x00010000 * int((Math.sin(c + cs) + 1) * 127) +
			0x00000100 * int((Math.sin(c + cs + 2.094) + 1) * 127) +
			0x00000001 * int((Math.sin(c + cs + 4.18) + 1) * 127);
			
			
			t = Math.random() * 2;
			// Sometimes the particle will be semitransparent
			if (Math.random() < 0.4)
			{
				alpha = Math.random() * 0.4 + 0.6;
				blend = "normal";
			}
			// Other times it will be set to overlay blending
			else
			{
				alpha = 1.0;
				blend = "overlay";
			}
			// We have to offset the triangles based on the angle, so they all aim outwards (shaped like a star)
			var ox:Number = Math.sin(angle / 57.295);
			var oy:Number = -Math.cos(angle / 57.295);
			this.x += ox * 128 * scale.y;
			this.y += oy * 128 * scale.y;
		}
		
		
		override public function update():void 
		{
			alpha -= FlxG.elapsed;
			scale.y += FlxG.elapsed * 0.25;
			
			// When t reaches 0 the particle dies
			t -= FlxG.elapsed;
			if (t < 0)
			{
				kill();
			}
			super.update();
		}
		
	}

}