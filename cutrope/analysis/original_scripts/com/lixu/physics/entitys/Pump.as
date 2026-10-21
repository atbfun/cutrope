package com.lixu.physics.entitys
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Expo;
   import com.lixu.assets.ImgPumpPopA;
   import com.lixu.assets.ImgPumpPopB;
   import com.lixu.assets.ImgPumpPopC;
   import com.lixu.assets.MoviePump;
   import com.lixu.help.SoundController;
   import com.lixu.physics.LXWorld;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class pump extends Sprite
   {
      
      private var movPump:MoviePump;
      
      private var rectArea:Sprite;
      
      private var hitSp:Sprite;
      
      private var world:LXWorld;
      
      public function pump(world:LXWorld)
      {
         super();
         this.movPump = new MoviePump();
         this.addChild(this.movPump);
         this.world = world;
         this.rectArea = new Sprite();
         this.addChild(this.rectArea);
         this.rectArea.graphics.beginFill(16711680,0);
         this.rectArea.graphics.drawRect(-40,-300,80,300);
         this.rectArea.graphics.endFill();
         this.rectArea.mouseEnabled = false;
         this.mouseEnabled = false;
         this.movPump.mouseEnabled = false;
         this.hitSp = new Sprite();
         this.hitSp.graphics.beginFill(16711680,0);
         this.hitSp.graphics.drawCircle(0,0,30);
         this.hitSp.graphics.endFill();
         this.addChild(this.hitSp);
         this.hitSp.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown,false,0,true);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.removeStage);
      }
      
      private function mouseDown(evt:Event) : void
      {
         var ro:Number = NaN;
         var tx:Number = NaN;
         var ty:Number = NaN;
         var popRdm:Number = NaN;
         var pop:Sprite = null;
         var dy:Number = NaN;
         var dx:Number = NaN;
         this.movPump.gotoAndPlay(2);
         SoundController.getInstance().pump();
         for(var i:int = 0; i < 5; i++)
         {
            ro = -20 * Math.random() - 170;
            tx = Math.sin(ro * Math.PI / 180) * 200;
            ty = Math.cos(ro * Math.PI / 180) * 200;
            popRdm = Math.random();
            if(popRdm < 0.3)
            {
               pop = new ImgPumpPopA();
            }
            else if(popRdm < 0.6)
            {
               pop = new ImgPumpPopB();
            }
            else
            {
               pop = new ImgPumpPopC();
            }
            this.addChildAt(pop,0);
            pop.alpha = 2;
            TweenLite.to(pop,1 + Math.random(),{
               "x":tx,
               "y":ty,
               "alpha":0,
               "ease":Expo.easeOut,
               "onComplete":this.popCom,
               "onCompleteParams":[pop]
            });
         }
         if(this.world.candy == null)
         {
            return;
         }
         var pt:Point = new Point(this.world.candy.X,this.world.candy.Y);
         pt = this.world.localToGlobal(pt);
         if(this.rectArea.hitTestPoint(pt.x,pt.y) == true)
         {
            dy = Math.sin((this.rotation + 90) * Math.PI / 180);
            dx = Math.cos((this.rotation + 90) * Math.PI / 180);
            if(this.world.candy)
            {
               this.world.candy.applyForceAt(this.world.candy.X + dx,this.world.candy.Y + dy,3);
            }
         }
      }
      
      private function popCom(pop:Sprite) : void
      {
         if(pop.parent)
         {
            pop.parent.removeChild(pop);
         }
      }
      
      private function removeStage(evt:Event) : void
      {
         this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removeStage);
         this.movPump.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
      }
   }
}

