package com.lixu.physics.entitys.grabs
{
   import com.lixu.assets.ImgHock;
   import com.lixu.assets.ImgHockBack;
   import com.lixu.physics.LXWorld;
   
   public class Grab extends BaseGrab
   {
      
      public function Grab(_x:Number, _y:Number, world:LXWorld, spider:Boolean = false, length:Number = -1)
      {
         super(_x,_y,world,spider);
         this.createRope(this,(this.world as LXWorld).candy,length);
         this.spiderMove();
      }
      
      override protected function setImg() : void
      {
         this.backSp = new ImgHockBack();
         this.backSp.mouseEnabled = false;
         this.mouseEnabled = false;
         this.setSprite(new ImgHock(),false);
      }
   }
}

