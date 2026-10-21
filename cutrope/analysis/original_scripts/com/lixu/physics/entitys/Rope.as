package com.lixu.physics.entitys
{
   import Flave.Constraint;
   import Flave.Particle;
   import Flave.World;
   import com.greensock.TweenLite;
   import com.lixu.physics.LXWorld;
   import flash.geom.Point;
   
   public class Rope
   {
      
      public var constraints:Vector.<Constraint> = new Vector.<Constraint>();
      
      public var particles:Vector.<Particle> = new Vector.<Particle>();
      
      public var hock:Particle;
      
      public var constraintL:Number = 25;
      
      public var length:Number = 0;
      
      public var alpha:Number = 1;
      
      public var trueRope:Constraint;
      
      public function Rope(hock:Particle, world:LXWorld, ropeLength:Number = -1, spider:Spider = null)
      {
         super();
         this.hock = hock;
         this.createRope(hock,world,ropeLength);
      }
      
      public function createRope(pA:Particle, world:LXWorld, ropeLength:Number = -1) : void
      {
         var p2:Particle = null;
         var c:Constraint = null;
         var color:uint = 0;
         var pB:Particle = world.candy;
         var dist:Number = Point.distance(new Point(pA.X,pA.Y),new Point(pB.X,pB.Y));
         if(ropeLength == -1)
         {
            ropeLength = dist;
         }
         ropeLength += 30;
         this.length = ropeLength;
         this.trueRope = world.addConstraint(pA,pB,this.length * 1.02,0.7,false);
         this.trueRope.stiff = 0.23;
         var lengthN:int = Math.ceil(dist / this.constraintL);
         var dy:Number = (pA.Y - pB.Y) * (this.constraintL / ropeLength);
         var dx:Number = (pA.X - pB.X) * (this.constraintL / ropeLength);
         var constraintNum:Number = Math.ceil(ropeLength / this.constraintL);
         var p:Particle = pA;
         for(var i:int = 1; i < constraintNum; i++)
         {
            if(i < lengthN)
            {
               p2 = world.addParticle(pA.X - i * dx,pA.Y - i * dy,false,3,0.5);
            }
            else
            {
               p2 = world.addParticle(pB.X,pB.Y,false,3,0.5);
            }
            p2.collide = 0;
            this.particles.push(p2);
            c = world.addConstraint(p,p2,this.constraintL,0.5,false);
            p = p2;
            ropeLength -= this.constraintL;
            this.constraints.push(c);
            if(i % 2)
            {
               color = 8810027;
            }
            else
            {
               color = 5194016;
            }
            c.color = color;
         }
         c = world.addConstraint(p,pB,ropeLength,1,false);
         this.constraints.push(c);
      }
      
      public function addLength(length:Number, world:LXWorld) : void
      {
         this.length += length;
         var lc:Constraint = this.constraints.pop();
         var p1:Particle = lc.p1;
         var p2:Particle = lc.p2;
         var lastL:Number = lc.dis + length;
         world.removeConstraint(lc);
         this.createRope(p1,world,lastL);
      }
      
      public function reduceLength(length:Number, world:World) : void
      {
         var lc:Constraint = null;
         var p1:Particle = null;
         var p2:Particle = null;
         this.length -= length;
         var num:uint = this.length / this.constraintL;
         var candy:Particle = this.constraints[this.constraints.length - 1].p2;
         for(var i:* = int(this.constraints.length - num); i > 0; i--)
         {
            lc = this.constraints.pop();
            p1 = lc.p1;
            p2 = lc.p2;
            world.removeConstraint(lc);
            if(candy != p2)
            {
               world.removeParticle(p2);
            }
         }
         var lastL:Number = this.length % this.constraintL;
         var c:Constraint = world.addConstraint(this.constraints[this.constraints.length - 1].p2,candy,lastL,1,false);
         this.constraints.push(c);
      }
      
      public function removeTarget(world:LXWorld) : void
      {
         var cons:Constraint = this.constraints[this.constraints.length - 1];
         if(cons.p1 is Candy || cons.p2 is Candy)
         {
            this.constraints.pop();
            world.removeConstraint(cons);
         }
      }
      
      public function removeConstraint(world:LXWorld, num:int = -1) : *
      {
         if(this.constraints == null)
         {
            return;
         }
         world.removeConstraint(this.trueRope);
         this.trueRope = null;
         if(num == -1 || num > this.constraints.length - 1)
         {
            num = this.constraints.length - 1;
         }
         world.removeConstraint(this.constraints[num]);
         this.constraints.splice(num,1);
         TweenLite.to(this,2,{
            "alpha":0,
            "onComplete":this.removeRope,
            "onCompleteParams":[world]
         });
      }
      
      private function removeRope(world:LXWorld) : void
      {
         var i:Constraint = null;
         var j:Particle = null;
         for each(i in this.constraints)
         {
            world.removeConstraint(i);
         }
         for each(j in this.particles)
         {
            world.removeParticle(j);
         }
         this.constraints = null;
         this.particles = null;
      }
   }
}

