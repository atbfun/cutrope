package com.lixu.physics.entitys
{
   import Flave.Particle;
   import com.lixu.assets.CandyPieceA;
   import com.lixu.assets.CandyPieceB;
   import com.lixu.assets.CandyPieceC;
   import com.lixu.assets.CandyPieceD;
   import com.lixu.assets.CandyPieceE;
   import com.lixu.assets.MovieCandy;
   import com.lixu.help.SoundController;
   import com.lixu.physics.LXWorld;
   import com.lixu.physics.entitys.grabs.BaseGrab;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class Candy extends Particle
   {
      
      public static const Event_Break:String = "break";
      
      public var ropes:Vector.<Rope> = new Vector.<Rope>();
      
      public var isBreak:Boolean = false;
      
      public var hasBubble:Boolean = false;
      
      public function Candy(_x:Number, _y:Number)
      {
         var i:Sprite = null;
         super(_x,_y);
         this.mouseEnabled = false;
         var movie:MovieCandy = new MovieCandy();
         movie.scaleX = movie.scaleY = 0.7;
         movie.mouseEnabled = false;
         for each(i in movie)
         {
            i.mouseEnabled = false;
         }
         this.setSprite(movie,false);
      }
      
      public function breakCandy(e:Event = null) : void
      {
         this.isBreak = true;
         if(this.world == null)
         {
            return;
         }
         this.dispatchEvent(new Event(Event_Break,true));
         SoundController.getInstance().candy_break();
         this.removeRope();
         var pA:CandyPieceA = new CandyPieceA();
         var pB:CandyPieceB = new CandyPieceB();
         var pC:CandyPieceC = new CandyPieceC();
         var pD:CandyPieceD = new CandyPieceD();
         var pE:CandyPieceE = new CandyPieceE();
         pA.x = pB.x = pC.x = pD.x = pE.x = this.X;
         pA.y = pB.y = pC.y = pD.y = pE.y = this.Y;
         this.world.addChild(pA);
         this.world.addChild(pB);
         this.world.addChild(pC);
         this.world.addChild(pD);
         this.world.addChild(pE);
         (this.world as LXWorld).candy = null;
         this.world.removeParticle(this);
      }
      
      public function removeRope() : void
      {
         var i:BaseGrab = null;
         var lxWorld:LXWorld = this.world as LXWorld;
         if(lxWorld == null)
         {
            return;
         }
         for each(i in lxWorld.grabs)
         {
            i.removeConstraint(lxWorld);
         }
      }
      
      public function beEat() : void
      {
         this.isBreak = true;
         this.removeRope();
         (this.world as LXWorld).candy = null;
         this.world.removeParticle(this);
      }
   }
}

