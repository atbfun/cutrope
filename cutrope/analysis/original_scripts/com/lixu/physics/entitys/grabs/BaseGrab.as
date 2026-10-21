package com.lixu.physics.entitys.grabs
{
   import Flave.Particle;
   import Flave.World;
   import com.lixu.physics.LXWorld;
   import com.lixu.physics.entitys.Rope;
   import com.lixu.physics.entitys.Spider;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class BaseGrab extends Particle
   {
      
      public var rope:Rope;
      
      public var spider:Spider;
      
      public var backSp:Sprite;
      
      internal var pt:Point = new Point();
      
      public function BaseGrab(_x:Number, _y:Number, world:World, spider:Boolean = false)
      {
         super(_x,_y);
         this.world = world;
         this.setImg();
         this.backSp.x = _x;
         this.backSp.y = _y;
         this.removeEventListener("mouseDown",click);
         this.collide = 0;
         var lxWord:LXWorld = world as LXWorld;
         lxWord.hockContiner.backGround.addChild(this.backSp);
         lxWord.hockContiner.hockGround.addChild(this);
         if(spider)
         {
            this.createSpider();
         }
      }
      
      protected function setImg() : void
      {
      }
      
      protected function createRope(hock:Particle, candy:Particle, length:Number = -1) : void
      {
         this.rope = new Rope(hock,this.world as LXWorld,length,this.spider);
      }
      
      override public function step() : void
      {
         super.step();
         this.pt.x = this.X;
         this.pt.y = this.Y;
         this.pt = this.world.localToGlobal(this.pt);
         var _wo:LXWorld = this.world as LXWorld;
         if(this.spider != null && this.rope != null && this.spider.currentState == Spider.WAIT_STATE && this.pt.x > 0 && this.pt.x < _wo.worldWidth && this.pt.y > 0 && this.pt.y < _wo.worldHeight)
         {
            this.spiderMove();
         }
      }
      
      protected function createSpider() : void
      {
         this.spider = new Spider(this.X,this.Y);
         this.world.addChild(this.spider);
         this.world.parts.push(this.spider);
         this.spider.init();
         this.spider.world = this.world;
      }
      
      protected function spiderMove() : void
      {
         if(this.spider == null)
         {
            return;
         }
         this.spider.toMove(this.rope.constraints);
      }
      
      public function removeConstraint(world:LXWorld, num:int = -1, iscut:Boolean = true) : void
      {
         if(this.rope)
         {
            this.rope.removeConstraint(world,num);
         }
         if(Boolean(this.spider) && Boolean(this.spider.currentState != Spider.WIN_STATE) && iscut == true)
         {
            this.spider.lost();
            this.spider = null;
         }
      }
   }
}

