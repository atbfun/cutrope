package Flave
{
   import Flave.Util.*;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   
   public dynamic class Particle extends Sprite
   {
      
      public var world:World;
      
      public var X:Number = 0;
      
      public var Y:Number = 0;
      
      public var oldx:Number = 0;
      
      public var oldy:Number = 0;
      
      public var rad:Number = 10;
      
      public var mass:Number = 30;
      
      public var fixed:Boolean = false;
      
      public var index:int = 0;
      
      public var xfric:Number = 0.9999;
      
      public var yfric:Number = 0.9999;
      
      public var CollisionPair:Array = [];
      
      public var drag:Boolean = false;
      
      public var vx:Number = this.X;
      
      public var vy:Number = this.Y;
      
      public var lastIndex:int = 0;
      
      public var constraints:Array = new Array();
      
      public var collide:int = 7;
      
      public var drawn:Boolean = false;
      
      public var userDef:*;
      
      public var sprite:Sprite;
      
      public function Particle(_x:Number, _y:Number)
      {
         super();
         this.oldx = this.X = _x;
         this.oldy = this.Y = _y;
         this.cacheAsBitmap = true;
      }
      
      public function setSprite(s:Sprite, useCacheMode:Boolean = true) : void
      {
         if(s == null)
         {
            removeChild(this.sprite);
            this.sprite = null;
         }
         else
         {
            s.mouseEnabled = false;
            this.sprite = s;
            addChild(s);
            this.graphics.clear();
         }
         this.cacheAsBitmap = useCacheMode;
         this.drawn = false;
         this.draw();
      }
      
      public function init() : void
      {
      }
      
      public function draw() : void
      {
         var col:ColorTransform = null;
         x = this.X;
         y = this.Y;
         if(this.drawn)
         {
            return;
         }
         this.drawn = true;
         if(this.sprite != null)
         {
            return;
         }
      }
      
      public function cleanGarbage() : void
      {
         stage.removeEventListener("mouseUp",this.up);
         this.removeEventListener("mouseDown",this.click);
         this.world = null;
      }
      
      public function step() : void
      {
         var p:Point = null;
         this.CollisionPair = [];
         if(this.drag)
         {
            p = new Point(root.mouseX,root.mouseY);
            p = parent.globalToLocal(p);
            this.oldx = this.X;
            this.oldy = this.Y;
            this.X = Input.keysDown[16] ? this.toGrid(p.x + this.vx,10) : p.x + this.vx;
            this.Y = Input.keysDown[16] ? this.toGrid(p.y + this.vy,10) : p.y + this.vy;
            return;
         }
         if(this.fixed)
         {
            return;
         }
         var tx:Number = this.X;
         var ty:Number = this.Y;
         this.X += (this.X - this.oldx) * this.xfric;
         this.Y += (this.Y - this.oldy) * this.yfric;
         this.oldx = tx;
         this.oldy = ty;
      }
      
      public function click(e:*) : void
      {
         if(Input.keysDown[16])
         {
            this.fixed = !this.fixed;
            return;
         }
         this.drag = true;
         var p:Point = new Point(root.mouseX,root.mouseY);
         p = parent.globalToLocal(p);
         this.vx = this.X - p.x;
         this.vy = this.Y - p.y;
         stage.addEventListener("mouseUp",this.up,false,0,true);
      }
      
      public function up(e:*) : void
      {
         this.drag = false;
      }
      
      public function get iMass() : Number
      {
         return 1 / this.mass;
      }
      
      public function get velocity() : Vector2
      {
         var vx:Number = this.X - this.oldx;
         var vy:Number = this.Y - this.oldy;
         return new Vector2(vx,vy);
      }
      
      public function get direction() : Number
      {
         var dx:Number = this.X - this.oldx;
         var dy:Number = this.Y - this.oldy;
         return Math.atan2(dy,dx) * (180 / Math.PI);
      }
      
      public function slowDown(fx:Number = 0.5, fy:Number = 0.5) : void
      {
         var vx:Number = this.X - this.oldx;
         var vy:Number = this.Y - this.oldy;
         this.oldx = this.X - vx * fx;
         this.oldy = this.Y - vy * fy;
      }
      
      public function accelerate(vx:Number, vy:Number) : void
      {
         this.oldx += vx;
         this.oldy += vy;
      }
      
      public function applyForceAt(px:Number, py:Number, f:Number) : void
      {
         if(this.fixed)
         {
            return;
         }
         var dx:Number = this.X - px;
         var dy:Number = this.Y - py;
         var dis:Number = Math.sqrt(dx * dx + dy * dy);
         dx /= dis;
         dy /= dis;
         this.X += dx * f;
         this.Y += dy * f;
      }
      
      public function get nextConnected() : Particle
      {
         return this.constraints[this.lastIndex].p1 == this ? this.constraints[this.lastIndex].p2 : this.constraints[this.lastIndex].p1;
      }
      
      public function toGrid(vari:Number, grid:Number) : Number
      {
         return int(vari / grid) * grid;
      }
      
      public function getVec() : Vector2
      {
         return new Vector2(this.X,this.Y);
      }
      
      public function callBack() : Boolean
      {
         if(parent == null)
         {
            return false;
         }
         return true;
      }
   }
}

