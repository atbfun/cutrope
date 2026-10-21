package com.lixu.physics.entitys
{
   import Flave.Constraint;
   import Flave.Particle;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import com.lixu.assets.ImgSpikesA;
   import com.lixu.assets.ImgSpikesB;
   import com.lixu.assets.ImgSpikesC;
   import com.lixu.assets.ImgSpikesD;
   import com.lixu.physics.LXWorld;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class Spikes extends Sprite
   {
      
      private var length:uint = 1;
      
      private var bgSp:Sprite;
      
      private var phyA:Particle;
      
      private var phyB:Particle;
      
      private var cons:Constraint;
      
      private var moveSpeed:Number;
      
      private var path:Array;
      
      private var tween:TweenMax;
      
      private var rotateSpeed:Number = 0;
      
      private var world:LXWorld;
      
      internal var pt:Point = new Point();
      
      public function Spikes(world:LXWorld, _X:Number, _Y:Number, length:uint = 1, angle:Number = 90, moveSpeed:Number = -1, path:Array = null, rotateSpeed:Number = 0)
      {
         super();
         this.world = world;
         this.rotateSpeed = rotateSpeed;
         this.x = _X;
         this.y = _Y;
         this.rotation = angle;
         this.moveSpeed = moveSpeed;
         this.path = path;
         switch(length)
         {
            case 1:
               this.bgSp = new ImgSpikesA();
               break;
            case 2:
               this.bgSp = new ImgSpikesB();
               break;
            case 3:
               this.bgSp = new ImgSpikesC();
               break;
            case 4:
               this.bgSp = new ImgSpikesD();
         }
         this.addChild(this.bgSp);
         this.mouseEnabled = false;
         this.phyA = world.addParticle(100,100,true,1,1);
         this.phyB = world.addParticle(500,100,true,1,1);
         this.cons = world.addConstraint(this.phyA,this.phyB);
         this.addEventListener(Event.ENTER_FRAME,this.onframe);
         this.addEventListener(Event.ADDED_TO_STAGE,this.onstage);
      }
      
      private function onstage(e:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.onstage);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.removeStage);
         if(this.path)
         {
            this.tween = new TweenMax(this,this.moveSpeed / 10,{
               "x":this.x + this.path[0],
               "y":this.y + this.path[1],
               "yoyo":true,
               "repeat":-1,
               "ease":Linear.easeNone
            });
         }
      }
      
      private function removeStage(e:Event) : void
      {
         if(this.tween)
         {
            this.tween.kill();
         }
      }
      
      private function onframe(evt:Event) : void
      {
         this.pt.x = -this.bgSp.width / 2;
         this.pt.y = 0;
         var tpA:Point = this.localToGlobal(this.pt);
         tpA = this.world.globalToLocal(tpA);
         this.phyA.X = tpA.x;
         this.phyA.Y = tpA.y;
         this.pt.x = this.bgSp.width / 2;
         this.pt.y = 0;
         var tpB:Point = this.localToGlobal(this.pt);
         tpB = this.world.globalToLocal(tpB);
         this.phyB.X = tpB.x;
         this.phyB.Y = tpB.y;
         this.rotation += this.rotateSpeed;
      }
      
      public function createPhysic() : void
      {
      }
   }
}

