package com.lixu.physics.entitys
{
   import com.lixu.assets.MovieBubblePop;
   import com.lixu.help.SoundController;
   import com.lixu.physics.LXWorld;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol899")]
   public class Bubble extends MovieClip
   {
      
      public static const NormalState:String = "normal";
      
      public static const FlyState:String = "fly";
      
      public static const bombState:String = "bomb";
      
      public var world:LXWorld;
      
      public var currentState:String;
      
      public var a:Number = 4;
      
      public function Bubble(world:LXWorld)
      {
         addFrameScript(0,this.frame1,42,this.frame43);
         super();
         this.world = world;
         this.currentState = NormalState;
         this.mouseEnabled = false;
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.md);
      }
      
      private function md(evt:MouseEvent) : void
      {
         if(this.currentState == FlyState)
         {
            this.currentState = bombState;
            this.removeEventListener(MouseEvent.MOUSE_DOWN,this.md);
         }
      }
      
      public function step() : void
      {
         var candy:Candy = this.world.candy;
         if(candy == null)
         {
            if(this.currentState == FlyState)
            {
               this.currentState = bombState;
               this.bomb();
               return;
            }
            return;
         }
         var dx:Number = this.x - candy.X;
         var dy:Number = this.y - candy.Y;
         var dis:Number = Math.sqrt(dx * dx + dy * dy);
         if(this.currentState == NormalState && Boolean(candy))
         {
            if(dis < candy.rad + 20)
            {
               if(candy.hasBubble != false)
               {
                  this.bomb();
                  return;
               }
               this.currentState = FlyState;
               candy.hasBubble = true;
               this.play();
               this.mouseEnabled = true;
            }
         }
         else if(this.currentState == FlyState)
         {
            this.x = candy.X;
            this.y = candy.Y;
            candy.oldx += (candy.X - candy.oldx) / 20;
            candy.oldy += (candy.Y - candy.oldy) / 20;
            candy.applyForceAt(candy.X,candy.Y + 20,0.25);
         }
         else if(this.currentState == bombState)
         {
            candy.hasBubble = false;
            this.bomb();
         }
      }
      
      private function bomb() : void
      {
         SoundController.getInstance().bubble_break();
         var sp:MovieBubblePop = new MovieBubblePop();
         sp.x = this.x;
         sp.y = this.y;
         this.parent.addChild(sp);
         this.parent.removeChild(this);
         this.world.bubbles.splice(this.world.bubbles.indexOf(this),1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame43() : *
      {
         gotoAndPlay(4);
      }
   }
}

