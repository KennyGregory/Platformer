﻿package other{	import org.flixel.*;	public class Bullet extends FlxSprite	{		// -------------------------------------------------------------------- //		[Embed(source='../assets/bullet.png')] protected var bulletClass:Class;		// -------------------------------------------------------------------- //		public function Bullet(speed:Number, ...args)		{			super();			loadGraphic(bulletClass,true);			width = 6;			height = 6;			offset.x = 1;			offset.y = 1;			addAnimation("up",[0]);			addAnimation("down",[1]);			addAnimation("left",[2]);			addAnimation("right",[3]);			addAnimation("poof",[4, 5, 6, 7], 50, false);		}		// -------------------------------------------------------------------- //		override public function kill():void 		{		}		// -------------------------------------------------------------------- //	}//class}//package