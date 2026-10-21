package com.lixu.physics.entitys
{
   import Flave.Constraint;
   import Flave.Particle;
   import com.lixu.assets.MovieSpider;
   import com.lixu.help.SoundController;
   
   public class Spider extends Particle
   {
      
      public static const WAIT_STATE:String = "wait";
      
      public static const RUN_STATE:String = "run";
      
      public static const LOST_STATE:String = "lost";
      
      public static const WIN_STATE:String = "win";
      
      public var cons:Vector.<Constraint>;
      
      public var constraintNum:uint = 0;
      
      public var stepLength:Number = 0.3;
      
      public var currentLength:Number = 0;
      
      public var movie:MovieSpider;
      
      public var candy:Candy;
      
      public var currentState:String = "wait";
      
      public function Spider(_X:Number, _Y:Number)
      {
         this.cons;
         super(_X,_Y);
         this.collide = 0;
         this.fixed = true;
         this.mass = 20;
         this.movie = new MovieSpider();
         this.movie.mouseEnabled = false;
         this.setSprite(this.movie,false);
         this.mouseEnabled = false;
         this.currentState = WAIT_STATE;
      }
      
      public function toMove(cons:Vector.<Constraint>) : void
      {
         this.cons = cons;
         this.movie.play();
      }
      
      override public function step() : void
      {
         var dx:Number = NaN;
         var dy:Number = NaN;
         var radians:Number = NaN;
         var tx:Number = NaN;
         var ty:Number = NaN;
         super.step();
         if(this.currentState == WAIT_STATE && this.movie.currentLabel == "run")
         {
            this.currentState = RUN_STATE;
         }
         if(this.currentState == RUN_STATE && this.constraintNum < this.cons.length)
         {
            dx = this.cons[this.constraintNum].p2.X - this.cons[this.constraintNum].p1.X;
            dy = this.cons[this.constraintNum].p2.Y - this.cons[this.constraintNum].p1.Y;
            radians = Math.atan2(dy,dx);
            this.rotation = radians * 180 / Math.PI - 90;
            tx = this.cons[this.constraintNum].p1.X + this.currentLength * Math.cos(radians);
            ty = this.cons[this.constraintNum].p1.Y + this.currentLength * Math.sin(radians);
            this.X = tx;
            this.Y = ty;
            this.currentLength += this.stepLength;
            if(this.currentLength > this.cons[this.constraintNum].dis)
            {
               ++this.constraintNum;
               this.currentLength = 0;
            }
            if(this.constraintNum >= this.cons.length)
            {
               SoundController.getInstance().spider_win();
               this.currentState = WIN_STATE;
               this.movie.gotoAndStop("win");
               this.rotation = 0;
               this.fixed = false;
               this.oldx = this.X;
               this.oldy = this.Y + 2;
               if(this.cons[this.cons.length - 1].p1 is Candy)
               {
                  this.candy = this.cons[this.cons.length - 1].p1 as Candy;
               }
               else if(this.cons[this.cons.length - 1].p2 is Candy)
               {
                  this.candy = this.cons[this.cons.length - 1].p2 as Candy;
               }
               this.candy.removeRope();
               if(this.candy)
               {
                  this.candy.collide = 0;
                  this.candy.fixed = true;
               }
            }
         }
         else if(this.currentState == WIN_STATE)
         {
            this.candy.X = this.X;
            this.candy.Y = this.Y - 50;
         }
      }
      
      public function lost() : void
      {
         if(this.currentState != RUN_STATE)
         {
            return;
         }
         this.currentState = LOST_STATE;
         this.movie.gotoAndStop("lost");
         this.rotation = 0;
         this.fixed = false;
         this.oldx = this.X;
         this.oldy = this.Y + 4;
         SoundController.getInstance().spider_fall();
      }
   }
}

