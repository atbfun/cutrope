package com.lixu.help
{
   import flash.media.Sound;
   import flash.media.SoundChannel;
   
   public class SoundController
   {
      
      private static var instance:SoundController;
      
      private var Menu_music:Class = SoundController_Menu_music;
      
      private var _menu_music:Sound = new this.Menu_music();
      
      private var _menu_musicChannel:SoundChannel;
      
      private var menu_musicPlayed:Boolean = false;
      
      private var Bubble_break:Class = SoundController_Bubble_break;
      
      private var _bubble_break:Sound = new this.Bubble_break();
      
      private var _bubble_breakChannel:SoundChannel;
      
      private var ButtonA:Class = SoundController_ButtonA;
      
      private var _button:Sound = new this.ButtonA();
      
      private var _buttonChannel:SoundChannel;
      
      private var Bubble:Class = SoundController_Bubble;
      
      private var _bubble:Sound = new this.Bubble();
      
      private var _bubbleChannel:SoundChannel;
      
      private var Candy_break:Class = SoundController_Candy_break;
      
      private var _Candy_break:Sound = new this.Candy_break();
      
      private var _Candy_breakChannel:SoundChannel;
      
      private var Electric:Class = SoundController_Electric;
      
      private var _electric:Sound = new this.Electric();
      
      private var _electricChannel:SoundChannel;
      
      private var Gravity_off:Class = SoundController_Gravity_off;
      
      private var _gravity_off:Sound = new this.Gravity_off();
      
      private var _gravity_offChannel:SoundChannel;
      
      private var Gravity_on:Class = SoundController_Gravity_on;
      
      private var _gravity_on:Sound = new this.Gravity_on();
      
      private var _gravity_onChannel:SoundChannel;
      
      private var Monster_chewing:Class = SoundController_Monster_chewing;
      
      private var _monster_chewing:Sound = new this.Monster_chewing();
      
      private var _monster_chewingChannel:SoundChannel;
      
      private var Monster_close:Class = SoundController_Monster_close;
      
      private var _monster_close:Sound = new this.Monster_close();
      
      private var _monster_closeChannel:SoundChannel;
      
      private var Monster_open:Class = SoundController_Monster_open;
      
      private var _monster_open:Sound = new this.Monster_open();
      
      private var _monster_openChannel:SoundChannel;
      
      private var Monster_sad:Class = SoundController_Monster_sad;
      
      private var _monster_sad:Sound = new this.Monster_sad();
      
      private var _monster_sadChannel:SoundChannel;
      
      private var Pump_1:Class = SoundController_Pump_1;
      
      private var _pump_1:Sound = new this.Pump_1();
      
      private var _pump_1Channel:SoundChannel;
      
      private var Pump_2:Class = SoundController_Pump_2;
      
      private var _pump_2:Sound = new this.Pump_2();
      
      private var _pump_2Channel:SoundChannel;
      
      private var Pump_3:Class = SoundController_Pump_3;
      
      private var _pump_3:Sound = new this.Pump_3();
      
      private var _pump_3Channel:SoundChannel;
      
      private var Pump_4:Class = SoundController_Pump_4;
      
      private var _pump_4:Sound = new this.Pump_4();
      
      private var _pump_4Channel:SoundChannel;
      
      private var Rope_bleak_1:Class = SoundController_Rope_bleak_1;
      
      private var _rope_bleak_1:Sound = new this.Rope_bleak_1();
      
      private var _rope_bleak_1Channel:SoundChannel;
      
      private var Rope_bleak_2:Class = SoundController_Rope_bleak_2;
      
      private var _rope_bleak_2:Sound = new this.Rope_bleak_2();
      
      private var _rope_bleak_2Channel:SoundChannel;
      
      private var Rope_bleak_3:Class = SoundController_Rope_bleak_3;
      
      private var _rope_bleak_3:Sound = new this.Rope_bleak_3();
      
      private var _rope_bleak_3Channel:SoundChannel;
      
      private var Rope_bleak_4:Class = SoundController_Rope_bleak_4;
      
      private var _rope_bleak_4:Sound = new this.Rope_bleak_4();
      
      private var _rope_bleak_4Channel:SoundChannel;
      
      private var Rope_get:Class = SoundController_Rope_get;
      
      private var _rope_get:Sound = new this.Rope_get();
      
      private var _rope_getChannel:SoundChannel;
      
      private var Scrape:Class = SoundController_Scrape;
      
      private var _scrape:Sound = new this.Scrape();
      
      private var _scrapeChannel:SoundChannel;
      
      private var Spider_activate:Class = SoundController_Spider_activate;
      
      private var _spider_activate:Sound = new this.Spider_activate();
      
      private var _spider_activateChannel:SoundChannel;
      
      private var Spider_fall:Class = SoundController_Spider_fall;
      
      private var _spider_fall:Sound = new this.Spider_fall();
      
      private var _spider_fallChannel:SoundChannel;
      
      private var Spider_win:Class = SoundController_Spider_win;
      
      private var _spider_win:Sound = new this.Spider_win();
      
      private var _spider_winChannel:SoundChannel;
      
      private var Star_1:Class = SoundController_Star_1;
      
      private var _star_1:Sound = new this.Star_1();
      
      private var _star_1Channel:SoundChannel;
      
      private var Star_2:Class = SoundController_Star_2;
      
      private var _star_2:Sound = new this.Star_2();
      
      private var _star_2Channel:SoundChannel;
      
      private var Star_3:Class = SoundController_Star_3;
      
      private var _star_3:Sound = new this.Star_3();
      
      private var _star_3Channel:SoundChannel;
      
      private var Teleport:Class = SoundController_Teleport;
      
      private var _teleport:Sound = new this.Teleport();
      
      private var _teleportChannel:SoundChannel;
      
      private var Wheel:Class = SoundController_Wheel;
      
      private var _wheel:Sound = new this.Wheel();
      
      private var _wheelChannel:SoundChannel;
      
      private var Win:Class = SoundController_Win;
      
      private var _win:Sound = new this.Win();
      
      private var _winChannel:SoundChannel;
      
      private var Game_music:Class = SoundController_Game_music;
      
      private var _game_music:Sound = new this.Game_music();
      
      private var _game_musicChannel:SoundChannel;
      
      private var gameMusicPlayed:Boolean = false;
      
      private var position:Number = 0;
      
      public function SoundController(pvt:PrivateClass)
      {
         super();
      }
      
      public static function getInstance() : SoundController
      {
         if(SoundController.instance == null)
         {
            SoundController.instance = new SoundController(new PrivateClass());
         }
         return SoundController.instance;
      }
      
      public function game_music() : void
      {
         if(this.gameMusicPlayed == false)
         {
            this._game_musicChannel = this._game_music.play(0,int.MAX_VALUE);
         }
         this.gameMusicPlayed = true;
         this.menu_musicStop();
      }
      
      public function game_musicStop() : void
      {
         if(this._game_musicChannel)
         {
            this._game_musicChannel.stop();
         }
         this.gameMusicPlayed = false;
      }
      
      public function game_mucisPause() : void
      {
         if(this._game_musicChannel)
         {
            this.position = this._game_musicChannel.position;
            this._game_musicChannel.stop();
         }
         this.gameMusicPlayed = false;
      }
      
      public function game_musicRestart() : void
      {
         this.game_musicStop();
         this._game_musicChannel = this._game_music.play(this.position,int.MAX_VALUE);
         this.gameMusicPlayed = true;
         this.menu_musicStop();
      }
      
      public function menu_music() : void
      {
         if(this.menu_musicPlayed == true)
         {
            return;
         }
         this._menu_musicChannel = this._menu_music.play(0,10000);
         this.menu_musicPlayed = true;
         this.game_musicStop();
      }
      
      public function menu_musicStop() : void
      {
         if(this._menu_musicChannel)
         {
            this._menu_musicChannel.stop();
         }
         this.menu_musicPlayed = false;
      }
      
      public function button() : void
      {
         this._buttonChannel = this._button.play();
      }
      
      public function bubble_break() : void
      {
         this._bubble_breakChannel = this._bubble_break.play(0);
      }
      
      public function bubble() : void
      {
         this._bubbleChannel = this._bubble.play();
      }
      
      public function candy_break() : void
      {
         this._Candy_breakChannel = this._Candy_break.play();
      }
      
      public function electric() : void
      {
         this._electricChannel = this._electric.play();
      }
      
      public function gravity_off() : void
      {
         this._gravity_offChannel = this._gravity_off.play();
      }
      
      public function gravity_on() : void
      {
         this._gravity_onChannel = this._gravity_on.play();
      }
      
      public function monster_chewing() : void
      {
         this._monster_chewingChannel = this._monster_chewing.play();
      }
      
      public function monster_close() : void
      {
         this._monster_closeChannel = this._monster_close.play();
      }
      
      public function monster_open() : void
      {
         this._monster_openChannel = this._monster_open.play();
      }
      
      public function monster_sad() : void
      {
         this._monster_sadChannel = this._monster_sad.play();
      }
      
      public function pump() : void
      {
         var r:Number = Math.random();
         if(r < 0.25)
         {
            this._pump_1Channel = this._pump_1.play();
         }
         else if(r < 0.5)
         {
            this._pump_2Channel = this._pump_2.play();
         }
         else if(r < 0.75)
         {
            this._pump_3Channel = this._pump_3.play();
         }
         else if(r < 1)
         {
            this._pump_4Channel = this._pump_4.play();
         }
      }
      
      public function rope_bleak_1() : void
      {
         this._rope_bleak_1Channel = this._rope_bleak_1.play();
      }
      
      public function rope_bleak_2() : void
      {
         this._rope_bleak_2Channel = this._rope_bleak_2.play();
      }
      
      public function rope_bleak_3() : void
      {
         this._rope_bleak_3Channel = this._rope_bleak_3.play();
      }
      
      public function rope_bleak_4() : void
      {
         this._rope_bleak_4Channel = this._rope_bleak_4.play();
      }
      
      public function rope_get() : void
      {
         this._rope_getChannel = this._rope_get.play();
      }
      
      public function scrape() : void
      {
         this._scrapeChannel = this._scrape.play();
      }
      
      public function spider_activate() : void
      {
         this._spider_activateChannel = this._spider_activate.play();
      }
      
      public function spider_fall() : void
      {
         this._spider_fallChannel = this._spider_fall.play();
      }
      
      public function spider_win() : void
      {
         this._spider_winChannel = this._spider_win.play();
      }
      
      public function star(num:uint) : void
      {
         switch(num)
         {
            case 1:
               this._star_1Channel = this._star_1.play();
               break;
            case 2:
               this._star_2Channel = this._star_2.play();
               break;
            case 3:
               this._star_3Channel = this._star_3.play();
         }
      }
      
      public function teleport() : void
      {
         this._teleportChannel = this._teleport.play();
      }
      
      public function wheel() : void
      {
         this._wheelChannel = this._wheel.play();
      }
      
      public function win() : void
      {
         this._winChannel = this._win.play();
      }
   }
}

class PrivateClass
{
   
   public function PrivateClass()
   {
      super();
   }
}
