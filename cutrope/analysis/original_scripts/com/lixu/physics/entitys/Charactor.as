package com.lixu.physics.entitys
{
   import com.lixu.assets.Chair;
   import com.lixu.help.SoundController;
   import com.lixu.physics.LXWorld;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol759")]
   public class Charactor extends MovieClip
   {
      
      public var a:Number;
      
      public var b:Number;
      
      public var c:Number;
      
      public var d:Number;
      
      public var wait_State:String = "wait";
      
      public var eat_state:String = "eat";
      
      public var preEat_state:String = "preEat";
      
      public var lost_State:String = "lost";
      
      public var bye_state:String = "bye";
      
      public var eatLost_state:String = "eatlost";
      
      public var currentState:String = "wait";
      
      private var world:LXWorld;
      
      public function Charactor(world:LXWorld)
      {
         addFrameScript(54,this.frame55,95,this.frame96,123,this.frame124,159,this.frame160,215,this.frame216,291,this.frame292,337,this.frame338,410,this.frame411);
         super();
         var chair:Chair = new Chair();
         chair.mouseEnabled = false;
         this.mouseEnabled = false;
         chair.gotoAndStop(Document.menuNum);
         this.addChildAt(chair,0);
         this.world = world;
         this.world.addEventListener(Candy.Event_Break,this.candyBreak);
         this.addEventListener(Event.ENTER_FRAME,this.onframe);
      }
      
      private function onframe(evt:Event) : void
      {
         var candy:Candy = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dis:Number = NaN;
         if(this.world.candy)
         {
            candy = this.world.candy;
            dx = this.x - candy.X;
            dy = this.y - candy.Y;
            dis = Math.sqrt(dx * dx + dy * dy);
            switch(this.currentState)
            {
               case this.wait_State:
                  this.updateWaitState();
                  break;
               case this.eat_state:
                  this.updateEatState();
                  break;
               case this.preEat_state:
                  this.updatePreEatState();
                  break;
               case this.lost_State:
                  this.updateLostState();
                  break;
               case this.bye_state:
                  this.updateByeState();
                  break;
               case this.eatLost_state:
                  this.updateEatLostState();
            }
         }
      }
      
      private function updateWaitState() : void
      {
         var candy:Candy = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dis:Number = NaN;
         if(this.world.candy)
         {
            if(this.world.candy.fixed == true)
            {
               return;
            }
            candy = this.world.candy;
            dx = this.x - candy.X;
            dy = this.y + 20 - candy.Y;
            dis = Math.sqrt(dx * dx + dy * dy);
            if(dis < 100)
            {
               this.gotoAndPlay("preEat");
               this.currentState = this.preEat_state;
               SoundController.getInstance().monster_open();
            }
         }
      }
      
      private function updateEatState() : void
      {
      }
      
      private function updatePreEatState() : void
      {
         var candy:Candy = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dis:Number = NaN;
         if(this.world.candy)
         {
            candy = this.world.candy;
            dx = this.x - candy.X;
            dy = this.y + 20 - candy.Y;
            dis = Math.sqrt(dx * dx + dy * dy);
            if(dis < 40)
            {
               this.gotoAndPlay("preEatting");
               this.currentState = this.eat_state;
               this.world.candy.beEat();
               SoundController.getInstance().monster_chewing();
               this.world.dispatchEvent(new Event(LXWorld.WIN));
            }
            else if(dis > 100)
            {
               this.gotoAndPlay("eatLost");
               this.currentState = this.wait_State;
               SoundController.getInstance().monster_close();
            }
         }
         else
         {
            this.gotoAndPlay("lost");
            this.currentState = this.eatLost_state;
         }
      }
      
      private function updateLostState() : void
      {
      }
      
      private function updateByeState() : void
      {
      }
      
      private function updateEatLostState() : void
      {
      }
      
      private function candyBreak(evt:Event) : void
      {
         this.currentState = this.lost_State;
         SoundController.getInstance().monster_sad();
         this.gotoAndPlay("lost");
         this.world.dispatchEvent(new Event(LXWorld.LOST));
      }
      
      public function eatStar() : void
      {
         if(this.currentState == this.wait_State)
         {
            this.gotoAndPlay("eatStar");
         }
      }
      
      internal function frame55() : *
      {
         this.a = Math.random();
         if(this.a < 0.8)
         {
            this.gotoAndPlay("wait");
         }
         else if(this.a < 0.9)
         {
            this.gotoAndPlay("wait3");
         }
         else if(this.a < 1)
         {
            this.gotoAndPlay("wait4");
         }
      }
      
      internal function frame96() : *
      {
         stop();
      }
      
      internal function frame124() : *
      {
         stop();
      }
      
      internal function frame160() : *
      {
         gotoAndPlay("eating");
      }
      
      internal function frame216() : *
      {
         this.b = Math.random();
         if(this.b < 0.8)
         {
            this.gotoAndPlay("wait");
         }
         else if(this.b < 0.9)
         {
            this.gotoAndPlay("wait3");
         }
         else if(this.b < 1)
         {
            this.gotoAndPlay("wait4");
         }
      }
      
      internal function frame292() : *
      {
         this.c = Math.random();
         if(this.c < 0.8)
         {
            this.gotoAndPlay("wait");
         }
         else if(this.c < 0.9)
         {
            this.gotoAndPlay("wait3");
         }
         else if(this.c < 1)
         {
            this.gotoAndPlay("wait4");
         }
      }
      
      internal function frame338() : *
      {
         this.d = Math.random();
         if(this.d < 0.8)
         {
            this.gotoAndPlay("wait");
         }
         else if(this.d < 0.9)
         {
            this.gotoAndPlay("wait3");
         }
         else if(this.d < 1)
         {
            this.gotoAndPlay("wait4");
         }
      }
      
      internal function frame411() : *
      {
         this.gotoAndPlay("wait");
      }
   }
}

