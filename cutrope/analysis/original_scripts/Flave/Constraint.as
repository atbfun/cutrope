package Flave
{
   import Flave.Util.Vector2;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   
   public class Constraint extends Sprite
   {
      
      public var p1:Particle;
      
      public var p2:Particle;
      
      public var dis:Number;
      
      public var error:Number;
      
      public var collidable:Boolean = true;
      
      public var stiff:Number = 1;
      
      public var damp:Number = 1;
      
      public var index:int = 0;
      
      public var collide:int = 7;
      
      public var rupturePoint:Number = Infinity;
      
      public var diff:Number = 0;
      
      public var sprite:BitmapData;
      
      public var bitmap:Bitmap;
      
      public var userDef:*;
      
      public var color:uint = 0;
      
      private var diffAdd:Boolean = false;
      
      public function Constraint(_p1:Particle, _p2:Particle, _dis:Number = -1, collide:Boolean = true)
      {
         super();
         this.p1 = _p1;
         if(this.p1.constraints.indexOf(this) == -1)
         {
            this.p1.constraints.push(this);
         }
         this.p2 = _p2;
         if(this.p2.constraints.indexOf(this) == -1)
         {
            this.p2.constraints.push(this);
         }
         this.dis = _dis == -1 ? Math.sqrt((this.p1.X - this.p2.X) * (this.p1.X - this.p2.X) + (this.p1.Y - this.p2.Y) * (this.p1.Y - this.p2.Y)) : _dis;
         this.collidable = collide;
      }
      
      public function resolve() : void
      {
         var mw:Number = NaN;
         if((this.p1.fixed || this.p1.drag) && (this.p2.fixed || this.p2.drag))
         {
            return;
         }
         var vx:Number = this.p1.X - this.p2.X;
         var vy:Number = this.p1.Y - this.p2.Y;
         var vlen:Number = Math.sqrt(vx * vx + vy * vy);
         if(vlen < this.dis)
         {
            return;
         }
         this.diff = (this.dis - vlen) / vlen;
         if(this.diff < 0)
         {
         }
         var dx:Number = vx * this.diff * this.stiff;
         var dy:Number = vy * this.diff * this.stiff;
         mw = 1 / (this.p1.iMass + this.p2.iMass);
         if(!this.p1.fixed && !this.p1.drag)
         {
            this.p1.X += dx * (this.p1.iMass * mw) * this.stiff;
            this.p1.Y += dy * (this.p1.iMass * mw) * this.stiff;
         }
         if(!this.p2.fixed && !this.p2.drag)
         {
            this.p2.X -= dx * (this.p2.iMass * mw) * this.stiff;
            this.p2.Y -= dy * (this.p2.iMass * mw) * this.stiff;
         }
      }
      
      public function resoldve() : void
      {
         if((this.p1.fixed || this.p1.drag) && (this.p2.fixed || this.p2.drag))
         {
            return;
         }
         var dx:Number = this.p2.X - this.p1.X;
         var dy:Number = this.p2.Y - this.p1.Y;
         var dist:Number = Math.sqrt(dx * dx + dy * dy);
         var diff:Number = this.dis - dist;
         var mw:Number = 1 / (this.p1.iMass + this.p2.iMass);
         this.p1.X -= diff * dx / dist / 2;
         this.p1.Y -= diff * dy / dist / 2;
         this.p2.X += diff * dx / dist / 2;
         this.p2.Y += diff * dx / dist / 2;
      }
      
      public function applyForceAt(px:Number, py:Number, dix:Number, diy:Number, f:Number) : void
      {
         var ax:Number = NaN;
         var ay:Number = NaN;
         var bx:Number = NaN;
         var by:Number = NaN;
         var AdotB:Number = NaN;
         var len:Number = NaN;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dir:Number = NaN;
         var dis:Number = NaN;
         var pen:Number = NaN;
         var perc1:Number = NaN;
         var perc2:Number = NaN;
         if(f == 0 || this.p1.fixed && this.p2.fixed)
         {
            return;
         }
         ax = this.p1.X - this.p2.X;
         ay = this.p1.Y - this.p2.Y;
         len = Math.sqrt(ax * ax + ay * ay);
         ax /= len;
         ay /= len;
         bx = this.p1.X - px;
         by = this.p1.Y - py;
         AdotB = ax * bx + ay * by;
         AdotB = AdotB < 0 ? 0 : AdotB;
         AdotB = AdotB > len ? len : AdotB;
         px = ax * AdotB;
         py = ay * AdotB;
         dx = this.p1.X - px;
         dy = this.p1.Y - py;
         dis = Math.sqrt(dx * dx + dy * dy);
         if(dis == 0)
         {
            dx = dis = 1;
         }
         dx /= dis;
         dy /= dis;
         pen = f;
         perc2 = AdotB / this.getLen();
         perc1 = 1 - perc2;
         var ddn:Number = Math.sqrt(dix * dix + diy * diy);
         dix /= ddn;
         diy /= ddn;
         if(!this.p1.fixed)
         {
            if(this.p2.fixed)
            {
               perc1 = 1;
            }
            this.p1.X += dix * (pen * perc1);
            this.p1.Y += diy * (pen * perc1);
         }
         else
         {
            perc2 = 1;
         }
         if(!this.p2.fixed)
         {
            this.p2.X += dix * (pen * perc2);
            this.p2.Y += diy * (pen * perc2);
         }
      }
      
      public function rupture() : void
      {
         if(Math.abs(this.diff) > this.rupturePoint)
         {
            parent["removeConstraint"](this);
         }
      }
      
      public function draw() : void
      {
         var rp:Number = NaN;
         var r:Number = NaN;
         var g:Number = NaN;
         var b:Number = NaN;
         var dx:Number = NaN;
         var dy:Number = NaN;
         if(this.rupturePoint == Number.POSITIVE_INFINITY)
         {
            rp = 0;
            r = g = b = (this.collide & 2) == 2 ? 153 : 221;
         }
         else
         {
            rp = this.diff / this.rupturePoint;
            rp = rp < 0 ? -rp : rp;
            r = rp * 255;
            r = rp * 255;
            g = 0;
            b = 0;
            rp = rp < 0 ? -rp : rp;
         }
         if(this.sprite != null)
         {
            x = 0;
            y = 0;
            this.graphics.clear();
            this.bitmap.x = this.p1.X;
            this.bitmap.y = this.p1.Y;
            dx = this.p2.X - this.p1.X;
            dy = this.p2.Y - this.p1.Y;
            this.bitmap.rotation = 0;
            this.bitmap.width = Math.sqrt(dx * dx + dy * dy);
            this.bitmap.rotation = Math.atan2(dy,dx) * (180 / Math.PI);
            this.bitmap.transform.colorTransform = new ColorTransform(1,1,1,1,r >> 16 & 0xFF,r >> 8 & 0xFF,r & 0xFF);
         }
         else
         {
            x = this.p1.X;
            y = this.p1.y;
            this.graphics.clear();
            this.graphics.lineStyle(1,r << 16 | g << 8 | b,rp == 0 ? 1 : rp / 2 + (this.collidable ? 0.5 : 0.2));
            this.graphics.lineTo(this.p2.X - this.p1.X,this.p2.Y - this.p1.Y);
         }
      }
      
      public function changeSprite(b:BitmapData) : void
      {
         if(this.sprite != null)
         {
            removeChild(this.bitmap);
            this.sprite.dispose();
            this.bitmap.bitmapData = null;
            this.sprite = null;
         }
         this.sprite = b;
         this.bitmap = new Bitmap(b);
         this.bitmap.smoothing = true;
         addChild(this.bitmap);
         if(this.p1 != null && this.p2 != null)
         {
            this.draw();
         }
      }
      
      public function getNormal() : Vector2
      {
         return this.p1.getVec().minus(this.p2.getVec()).normalize().perpendicular();
      }
      
      public function getLen() : Number
      {
         return Math.sqrt((this.p1.X - this.p2.X) * (this.p1.X - this.p2.X) + (this.p1.Y - this.p2.Y) * (this.p1.Y - this.p2.Y));
      }
      
      public function getDir() : Number
      {
         var dx:Number = this.p1.X - this.p2.X;
         var dy:Number = this.p1.Y - this.p2.Y;
         return Math.atan2(dy,dx);
      }
   }
}

