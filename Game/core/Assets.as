﻿package core {

	import flash.display.Sprite;
	



///////////////////////////////////////////////////////// [ CLASS ] ////////////////////////////////////////////////////////////////////////////




	public class Assets extends Sprite {


/* --------------------------- */// Weapons

	
		// bullet assets
		[Embed(source="../assets/bullet.png")] public static var ImgBullet:Class;
		[Embed(source="../assets/jump.mp3")] public static var SndHit:Class;
		[Embed(source="../assets/shoot.mp3")] public static var SndShoot:Class;
	
		// grenade
		[Embed(source = '../assets/grenade.png')] public static var img_grenade:Class;
		[Embed (source = "../assets/blip1.mp3")] public static var g_snd_blip1:Class;
		[Embed (source = "../assets/blip3.mp3")] public static var g_snd_blip2:Class;
		[Embed (source = "../assets/bounce.mp3")] public static var g_snd_bounce:Class;
		[Embed (source = "../assets/explosion2.mp3")] public static var g_snd_explosion:Class;
	
	
/* --------------------------- */// Player


		[Embed(source = '../assets/player.png')] public static var playerPNG:Class;
		[Embed(source = '../assets/playerRolling.png')] public static var playerRollingPNG:Class;
		[Embed (source = "../assets/begin_throw.mp3")] public static var snd_begin_throw:Class;
		[Embed (source = "../assets/throw.mp3")] public static var snd_throw:Class;
		[Embed (source = "../assets/charge.mp3")] public static var snd_charge:Class;
		[Embed(source = '../assets/jet.png')] public static var ImgJet:Class;
		[Embed(source = '../assets/playerJump.mp3')] public static var playerJumpSFX:Class;
		[Embed(source = '../assets/playerDeath.mp3')] public static var playerDeathSFX:Class;
	

/* --------------------------- */// Enemies

	
		// hybrid
		[Embed(source="../assets/hybridSprite.png")] public static var ImgHybridEnemy:Class;
	
		// green enemy
		[Embed(source="../assets/Enemy.png")] public static var ImgEnemy:Class;
	

/* --------------------------- */// Other

	
		// explosion
		[Embed (source = "../assets/explosion.png")] public static var img_explosion:Class;
	
		// map
		[Embed(source = '../map/mapCSV_Level1_Map.csv', mimeType = "application/octet-stream")] public static var mapCSV:Class;
		[Embed(source = '../map/mapCSV_Level1_Sky.csv', mimeType = "application/octet-stream")] public static var skyCSV:Class;
		[Embed(source = '../map/backdrop.png')] public static var skyTilesPNG:Class;
		[Embed(source = '../assets/tiles.png')] public static var mapTilesPNG:Class;
		[Embed(source="../assets/elevator.png")] public static var ImgElevator:Class;
//		[Embed(source = '../assets/backgroundmusic_track1.mp3')] public static var musicTrack1:Class;	// 8bit track
		[Embed(source = '../assets/jitorator.mp3')] public static var musicTrack1:Class;	// Ambient 
			
		// heart
		[Embed(source = '../assets/heart.png')] public static var heartClass:Class;

		// HUD
		[Embed(source = '../assets/healthbar.png')] public static var healthbarPNG:Class;		
			
		// Jump effect
		[Embed(source='../assets/run_dusty.png')] public static var tileImg:Class;
		
		//save point
		[Embed(source='../assets/tree.png')] public static var savePt:Class;



	}//class	
}//package
