package com.lixu.physics.entitys.grabs
{
   import Flave.Particle;
   import Flave.World;
   import com.lixu.assets.ImgHockAuto;
   import com.lixu.assets.ImgHockAutoBack;
   import com.lixu.help.SoundController;
   import com.lixu.physics.LXWorld;
   import flash.display.Sprite;
   
   public class AutoGrab extends BaseGrab
   {
      
      public var haveRope:Boolean = false;
      
      public var ropeRadius:Number = 100;
      
      public function AutoGrab(_x:Number, _y:Number, world:World, spider:Boolean = false, radius:Number = 100)
      {
         this.ropeRadius = radius;
         this.mouseEnabled = false;
         super(_x,_y,world,spider);
      }
      
      override protected function setImg() : void
      {
         var px:Number = NaN;
         var py:Number = NaN;
         var ppx:Number = NaN;
         var ppy:Number = NaN;
         var lpx:Number = NaN;
         var lpy:Number = NaN;
         var cx:Number = NaN;
         var cy:Number = NaN;
         this.backSp = new ImgHockAutoBack();
         this.backSp.mouseEnabled = false;
         var sp:Sprite = new ImgHockAuto();
         sp.mouseEnabled = false;
         var step:Number = 3 / this.ropeRadius;
         sp.graphics.lineStyle(2,6323105);
         sp.graphics.moveTo(Math.cos(0) * this.ropeRadius,Math.sin(0) * this.ropeRadius);
         for(var angle:Number = step; angle < 2 * 3.14; angle += step)
         {
            px = Math.cos(angle) * this.ropeRadius;
            py = Math.sin(angle) * this.ropeRadius;
            ppx = Math.cos(angle - step) * this.ropeRadius;
            ppy = Math.sin(angle - step) * this.ropeRadius;
            lpx = Math.cos(angle + step) * this.ropeRadius;
            lpy = Math.sin(angle + step) * this.ropeRadius;
            cx = px * 2 - (ppx + lpx) / 2;
            cy = py * 2 - (ppy + lpy) / 2;
            sp.graphics.moveTo(ppx,ppy);
            sp.graphics.curveTo(cx,cy,lpx,lpy);
            angle += 2 * step;
         }
         this.setSprite(sp,false);
      }
      
      override public function step() : void
      {
         super.step();
         var candy:Particle = (this.world as LXWorld).candy;
         if(candy == null)
         {
            return;
         }
         var dx:* = candy.X - this.X;
         var dy:* = candy.Y - this.Y;
         var dst:* = Math.sqrt(dx * dx + dy * dy);
         if(dst < this.ropeRadius + 18 && this.haveRope == false)
         {
            this.createRope(this,candy,this.ropeRadius + 20);
            SoundController.getInstance().rope_get();
            this.spiderMove();
            this.sprite.graphics.clear();
            this.haveRope = true;
         }
      }
   }
}

