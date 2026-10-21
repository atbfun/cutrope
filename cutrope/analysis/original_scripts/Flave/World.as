package Flave
{
   import Flave.Util.*;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.*;
   
   public class World extends Sprite
   {
      
      public var timeStep:Number = 0.02;
      
      public var consIterations:uint = 4;
      
      public var iterations:uint = 2;
      
      public var grid:Grid;
      
      public var globalIndex:int = 0;
      
      public var interactible:Boolean = true;
      
      public var parts:Vector.<Particle> = new Vector.<Particle>();
      
      public var cons:Vector.<Constraint> = new Vector.<Constraint>();
      
      public var polys:Vector.<Polygon> = new Vector.<Polygon>();
      
      public var rays:Vector.<Ray> = new Vector.<Ray>();
      
      public var defPartSize:Number = 10;
      
      public var grav:Vector2 = new Vector2(0,0.18);
      
      public var clipBounds:Rectangle;
      
      public var drawBounds:Boolean = false;
      
      public var offset:Point;
      
      public var active:Boolean = true;
      
      public function World()
      {
         super();
         this.offset = new Point();
         this.grid = new Grid();
         this.grid.MCMov = new Sprite();
         this.grid.MCMov.mouseEnabled = false;
         addChild(this.grid.MCMov);
      }
      
      public function Step() : void
      {
         var p:Particle = null;
         var k:int = 0;
         var r:Ray = null;
         var c:Constraint = null;
         if(!this.active)
         {
            return;
         }
         this.grid.resetGrid(this.grid.subdiv);
         var i:int = 0;
         for each(p in this.parts)
         {
            p.step();
            if(!p.fixed)
            {
               p.X += this.grav.X;
               p.Y += this.grav.Y;
               this.clipParticle(p);
            }
            if(p.collide != 0)
            {
               this.grid.addParticle(p);
            }
         }
         for(k = 0; k < this.consIterations; k++)
         {
            for each(c in this.cons)
            {
               c.resolve();
            }
         }
         for each(c in this.cons)
         {
            c.rupture();
            if(c != null && c.collide != 0)
            {
               this.grid.addConstraint(c);
            }
         }
         if(Configuration.Collisions)
         {
            for(i = 0; i < this.iterations; i++)
            {
               this.grid.resolveBroadPhase();
            }
         }
         if(this.clipBounds != null)
         {
            for each(p in this.parts)
            {
               this.clipParticle(p);
            }
         }
         for each(r in this.rays)
         {
            if(r.enabled)
            {
               if(r.fixOnCaster && r.Caster != null)
               {
                  r.updateBeam(r.Caster.X,r.Caster.Y,r.OriginalDirection,r.Range);
               }
               else
               {
                  r.updateBeam(r.sx,r.sy,r.OriginalDirection,r.Range);
               }
               r.trim(this.clipBounds.x,this.clipBounds.y,this.clipBounds.width,this.clipBounds.height);
               if((r.collide & 1) == 1 || (r.collide & 2) == 2)
               {
                  this.grid.testRay(r);
               }
            }
         }
      }
      
      public function Draw() : void
      {
         var p:Particle = null;
         var c:Constraint = null;
         var r:Ray = null;
         for each(p in this.parts)
         {
            p.draw();
         }
         for each(c in this.cons)
         {
            c.draw();
         }
         for each(r in this.rays)
         {
            r.redraw();
         }
         if(this.drawBounds)
         {
         }
      }
      
      public function addParticle(_x:Number, _y:Number, fixed:Boolean = false, rad:Number = -1, mass:Number = 30) : Particle
      {
         var p:Particle = new Particle(_x + this.offset.x,_y + this.offset.y);
         p.fixed = fixed;
         p.index = this.globalIndex++;
         p.rad = rad == -1 ? this.defPartSize : rad;
         p.mass = mass;
         this.parts.push(p);
         addChild(p);
         p.init();
         p.world = this;
         return p;
      }
      
      public function addConstraint(p1:Particle, p2:Particle, dis:Number = -1, e:Number = 0.5, coll:Boolean = true) : Constraint
      {
         var c:Constraint = new Constraint(p1,p2,dis);
         c.error = e;
         c.collidable = coll;
         c.collide = coll ? 7 : 0;
         c.index = this.globalIndex++;
         this.cons.push(c);
         addChildAt(c,0);
         return c;
      }
      
      public function addPoly(spots:Array, col:uint = 0, _a:Number = 1) : Polygon
      {
         this.polys.push(new Polygon(spots,col,_a));
         this.addChildAt(this.polys[this.polys.length - 1],this.cons.length);
         this.addChildAt(this.grid.MCMov,0);
         this.polys[this.polys.length - 1].redraw();
         return this.polys[this.polys.length - 1];
      }
      
      public function addRay(sx:Number, sy:Number, dir:Number, range:Number) : Ray
      {
         var r:Ray = new Ray();
         this.addChildAt(r,0);
         r.OriginalDirection = dir;
         r.updateBeam(sx,sy,dir,range);
         r.redraw();
         this.rays.push(r);
         return r;
      }
      
      public function testRay(sx:Number, sy:Number, ex:Number, ey:Number) : Ray
      {
         var r:Ray = new Ray();
         var dx:Number = ex - sx;
         var dy:Number = ey - sy;
         r.updateBeam(sx,sy,Math.atan2(dy,dx) * (180 / Math.PI),Math.sqrt(dx * dx + dy * dy));
         this.grid.testRay(r);
         return r;
      }
      
      public function loadFromCode(input:String) : Boolean
      {
         var A:* = undefined;
         var B:* = undefined;
         var D:* = undefined;
         var Hand:String = null;
         var S:* = undefined;
         var X:Number = NaN;
         var Y:Number = NaN;
         var currentType:String = null;
         var ta:Array = null;
         var j:int = 0;
         var offset:int = 0;
         this.clearEverything();
         this.grid.MCMov = new Sprite();
         addChildAt(this.grid.MCMov,0);
         input = this.trim(input);
         input = Util.decompress(input);
         var tempS:Array = input.split("|");
         var tempA:Array = new Array();
         for(var i:int = 0; i < tempS.length; i++)
         {
            tempA[i] = tempS[i].split(",");
         }
         var obs:Object = {};
         for(i = 0; i < tempA.length; i++)
         {
            if(tempA[i][0] != undefined)
            {
               if(tempA[i][0] == "p" || tempA[i][0] == "f" || tempA[i][0] == "d" || tempA[i][0] == "o")
               {
                  currentType = tempA[i][0];
               }
               else if(tempA[i][0] == "c" || tempA[i][0] == "x")
               {
                  currentType = tempA[i][0];
               }
               else if(tempA[i][0] == "n")
               {
                  currentType = "n";
                  ta = new Array();
                  for(j = 0; j < tempA[i].length - 2; j++)
                  {
                     ta.push(obs[tempA[i][j + 2]]);
                  }
                  this.addPoly(ta,parseInt(tempA[i][1]));
               }
               if((currentType == "p" || currentType == "f" || currentType == "d" || currentType == "o") && tempA[i].length >= 3)
               {
                  offset = -1;
                  if(tempA[i][0] == currentType)
                  {
                     offset = 0;
                  }
                  X = parseFloat(tempA[i][2 + offset]);
                  Y = parseFloat(tempA[i][3 + offset]);
                  Hand = tempA[i][1 + offset];
                  obs[Hand] = this.addParticle(X,Y,currentType == "f" || currentType == "d");
                  obs[Hand].collide = currentType == "p" || currentType == "f" ? 7 : 0;
                  obs[Hand].mass = tempA[i][4 + offset] == undefined ? 30 : parseFloat(tempA[i][4 + offset]);
               }
               if((currentType == "c" || currentType == "x") && tempA[i].length > 1)
               {
                  offset = -1;
                  if(tempA[i][0] == currentType)
                  {
                     offset = 0;
                  }
                  A = tempA[i][1 + offset];
                  B = tempA[i][2 + offset];
                  this.addConstraint(obs[A],obs[B],-1,0.5,currentType == "c");
               }
            }
         }
         return true;
      }
      
      public function removeParticle(p:Particle) : Boolean
      {
         if(this.parts.indexOf(p) != -1 && p.parent != null)
         {
            p.cleanGarbage();
            p.parent.removeChild(p);
            this.parts.splice(this.parts.indexOf(p),1);
            return true;
         }
         return false;
      }
      
      public function removeConstraint(c:Constraint) : Boolean
      {
         if(this.cons.indexOf(c) != -1)
         {
            c.p1.constraints.splice(c.p1.constraints.indexOf(c),1);
            c.p2.constraints.splice(c.p2.constraints.indexOf(c),1);
            c.p1 = null;
            c.p2 = null;
            this.cons.splice(this.cons.indexOf(c),1);
            delete this.cons[this.cons.indexOf(c)];
            removeChild(c);
            if(c.sprite != null)
            {
               c.removeChild(c.bitmap);
               c.bitmap.bitmapData = null;
               c.bitmap = null;
               c.sprite = null;
            }
            return true;
         }
         return false;
      }
      
      public function removePoly(poly:Polygon) : void
      {
         if(poly == null)
         {
            return;
         }
         var n:int = this.polys.indexOf(poly);
         poly.clearGarbage();
         if(poly.parent != null)
         {
            this.removeChild(poly);
         }
         if(n != -1)
         {
            this.polys[n] = null;
            this.polys.splice(n,1);
         }
         poly = null;
      }
      
      public function removeRay(r:Ray) : void
      {
         if(r == null)
         {
            return;
         }
         var n:int = this.rays.indexOf(r);
         if(r.parent != null)
         {
            this.removeChild(r);
         }
         if(n != -1)
         {
            this.rays[n] = null;
            this.rays.splice(n,1);
         }
         r = null;
      }
      
      public function clipParticle(p:Particle) : void
      {
         var dx:Number = 0;
         var dy:Number = 0;
         if(p.X < this.clipBounds.x + p.rad)
         {
            dx = (p.X - p.oldx) * 0.7;
         }
         if(p.Y < this.clipBounds.y + p.rad)
         {
            dy = (p.Y - p.oldy) * 0.7;
            if(dx != 0)
            {
               dx *= 0.8;
            }
            else
            {
               dx = -(p.X - p.oldx) * 0.8;
            }
         }
         if(p.X > this.clipBounds.width - p.rad)
         {
            dx = (p.X - p.oldx) * 0.7;
         }
         if(p.Y > this.clipBounds.height - p.rad)
         {
            dy = (p.Y - p.oldy) * 0.7;
            if(dx != 0)
            {
               dx *= 0.8;
            }
            else
            {
               dx = -(p.X - p.oldx) * 0.8;
            }
         }
         var dpx:Number = this.clipBounds.x + p.rad;
         var dpy:Number = this.clipBounds.y + p.rad;
         p.X = p.X < dpx ? dpx : p.X;
         p.Y = p.Y < dpy ? dpy : p.Y;
         dpx = this.clipBounds.width - p.rad;
         dpy = this.clipBounds.height - p.rad;
         p.X = p.X > dpx ? dpx : p.X;
         p.Y = p.Y > dpy ? dpy : p.Y;
         if(dx != 0)
         {
            p.oldx = p.X + dx;
         }
         if(dy != 0)
         {
            p.oldy = p.Y + dy;
         }
      }
      
      public function togglePause(pause:* = null) : void
      {
         this.active = pause != null ? pause as Boolean : !this.active;
      }
      
      public function clearEverything() : void
      {
         if(this.grid.MCMov != null)
         {
            removeChild(this.grid.MCMov);
         }
         this.grid.MCMov = null;
         while(this.parts.length > 0)
         {
            this.removeParticle(this.parts[0]);
         }
         while(this.cons.length > 0)
         {
            this.removeConstraint(this.cons[0]);
         }
         while(this.polys.length > 0)
         {
            this.removePoly(this.polys[0]);
         }
         while(this.rays.length > 0)
         {
            this.removeRay(this.rays[0]);
         }
      }
      
      public function setOffset(X:Number = 0, Y:Number = 0) : void
      {
         this.offset.x = X;
         this.offset.y = Y;
      }
      
      public function trim(str:String) : String
      {
         var a:Number = NaN;
         var stripCharCodes:Object = {
            "code_9":true,
            "code_10":true,
            "code_13":true,
            "code_32":true
         };
         while(stripCharCodes["code_" + str.charCodeAt(0)] == true)
         {
            str = str.substring(1,str.length);
         }
         while(stripCharCodes["code_" + str.charCodeAt(str.length - 1)] == true)
         {
            str = str.substring(0,str.length - 1);
         }
         var strs:String = "";
         for(var i:int = 0; i < str.length; i++)
         {
            a = str.charCodeAt(i);
            if(a != 9 && a != 10 && a != 13 && a != 32)
            {
               strs += String.fromCharCode(str.charCodeAt(i));
            }
         }
         return strs;
      }
   }
}

