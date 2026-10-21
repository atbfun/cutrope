package com.lixu.physics.entitys
{
   import com.greensock.TweenLite;
   import com.lixu.assets.MovieStarDisappear;
   import com.lixu.assets.StarTimeMovie;
   import com.lixu.help.SoundController;
   import com.lixu.physics.LXWorld;
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol187")]
   public class Star extends MovieClip
   {
      
      public static const NormalState:String = "normal";
      
      public static const FlyState:String = "fly";
      
      public static const bombState:String = "bomb";
      
      public var world:LXWorld;
      
      public var currentState:String;
      
      public var timeOut:Number = 0;
      
      private var timeTween:TweenLite;
      
      public function Star(world:LXWorld, timeOut:Number = 0)
      {
         var startime:StarTimeMovie = null;
         super();
         this.timeOut = timeOut;
         if(this.timeOut > 0)
         {
            startime = new StarTimeMovie();
            this.addChild(startime);
            startime.stop();
            this.timeTween = TweenLite.to(startime,this.timeOut + 3,{
               "starframe":37,
               "onComplete":this.starDisppear
            });
         }
         this.mouseEnabled = false;
         this.world = world;
         this.currentState = NormalState;
      }
      
      private function starDisppear() : void
      {
         this.parent.removeChild(this);
         this.world.stars.splice(this.world.stars.indexOf(this),1);
      }
      
      public function step() : void
      {
         var sp:MovieStarDisappear = null;
         var candy:Candy = this.world.candy;
         if(candy == null)
         {
            return;
         }
         var dx:Number = this.x - candy.X;
         var dy:Number = this.y - candy.Y;
         var dis:Number = Math.sqrt(dx * dx + dy * dy);
         if(this.currentState == NormalState)
         {
            if(dis < candy.rad + 20)
            {
               this.currentState = bombState;
            }
         }
         else if(this.currentState == bombState)
         {
            ++this.world.starNum;
            if(this.timeTween)
            {
               this.timeTween.kill();
            }
            SoundController.getInstance().star(this.world.starNum);
            sp = new MovieStarDisappear();
            sp.x = this.x;
            sp.y = this.y;
            this.parent.addChild(sp);
            this.parent.removeChild(this);
            this.world.stars.splice(this.world.stars.indexOf(this),1);
         }
      }
   }
}

