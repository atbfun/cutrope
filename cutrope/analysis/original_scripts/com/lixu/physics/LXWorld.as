package com.lixu.physics
{
   import Flave.Constraint;
   import Flave.World;
   import com.lixu.assets.BubbleBg;
   import com.lixu.assets.ImgBg;
   import com.lixu.assets.tutorials.BaseTutorial;
   import com.lixu.assets.tutorials.Tutorial01;
   import com.lixu.assets.tutorials.Tutorial04;
   import com.lixu.assets.tutorials.Tutorial05;
   import com.lixu.assets.tutorials.Tutorial06;
   import com.lixu.assets.tutorials.Tutorial08;
   import com.lixu.assets.tutorials.Tutorial09;
   import com.lixu.assets.tutorials.Tutorial10;
   import com.lixu.assets.tutorials.TutorialText;
   import com.lixu.assets.tutorials.tutorialSensor;
   import com.lixu.help.SoundController;
   import com.lixu.physics.Math.LineSegment;
   import com.lixu.physics.entitys.Bubble;
   import com.lixu.physics.entitys.Candy;
   import com.lixu.physics.entitys.Charactor;
   import com.lixu.physics.entitys.HockContiner;
   import com.lixu.physics.entitys.IStep;
   import com.lixu.physics.entitys.Rope;
   import com.lixu.physics.entitys.Spikes;
   import com.lixu.physics.entitys.Star;
   import com.lixu.physics.entitys.grabs.AutoGrab;
   import com.lixu.physics.entitys.grabs.AutoMoveGrab;
   import com.lixu.physics.entitys.grabs.BaseGrab;
   import com.lixu.physics.entitys.grabs.Grab;
   import com.lixu.physics.entitys.grabs.MoveGrab;
   import com.lixu.physics.entitys.pump;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class LXWorld extends World
   {
      
      public static const STAREAT:String = "stareat";
      
      public static const WIN:String = "win";
      
      public static const LOST:String = "lost";
      
      private var _starNum:uint = 0;
      
      public var hockContiner:HockContiner = new HockContiner();
      
      public var targetContiner:Sprite = new Sprite();
      
      public var tutrilContiner:Sprite = new Sprite();
      
      public var ropes:Vector.<Rope> = new Vector.<Rope>();
      
      public var bubbles:Vector.<Bubble> = new Vector.<Bubble>();
      
      public var canStep:Vector.<IStep> = new Vector.<IStep>();
      
      public var stars:Vector.<Star> = new Vector.<Star>();
      
      public var grabs:Vector.<BaseGrab> = new Vector.<BaseGrab>();
      
      public var candy:Candy;
      
      public var char:Charactor;
      
      private var mouseSegment:LineSegment = new LineSegment();
      
      private var ropeSegment:LineSegment = new LineSegment();
      
      private var cutting:Boolean = false;
      
      public var bg:MovieClip;
      
      public var worldWidth:Number = 1000;
      
      public var worldHeight:Number = 1000;
      
      public var speed:Number = 1;
      
      public var special:Number = 1;
      
      public var twoParts:Boolean = false;
      
      public var tutorialDelay:Number = 8;
      
      public var tutorialSpecialAy:Vector.<BaseTutorial> = new Vector.<BaseTutorial>();
      
      private var vx:Number = 2;
      
      private var vy:Number = 2;
      
      public function LXWorld()
      {
         super();
         this.bg = new ImgBg();
         this.bg.gotoAndStop(Document.menuNum);
         this.addChild(this.bg);
         this.addChild(this.tutrilContiner);
         this.tutrilContiner.mouseEnabled = false;
         this.addChild(this.targetContiner);
         this.targetContiner.mouseEnabled = false;
         this.addChild(this.hockContiner);
         this.addEventListener(Event.ADDED_TO_STAGE,this.onstage);
      }
      
      private function onstage(evt:Event) : void
      {
         this.bg.height = this.worldHeight;
         this.bg.width = this.worldWidth;
         this.removeEventListener(Event.ADDED_TO_STAGE,this.onstage);
      }
      
      public function get starNum() : uint
      {
         return this._starNum;
      }
      
      public function set starNum(value:uint) : void
      {
         this._starNum = value;
         Document.starNum = value;
         this.dispatchEvent(new Event(STAREAT));
         if(this.char)
         {
            this.char.eatStar();
         }
      }
      
      public function mouseDown(evt:MouseEvent) : void
      {
         if(evt.target != this.bg)
         {
            return;
         }
         this.cutting = true;
         this.mouseSegment.pA_v.x = this.mouseX;
         this.mouseSegment.pA_v.y = this.mouseY;
         this.mouseSegment.pB_v.x = this.mouseX;
         this.mouseSegment.pB_v.y = this.mouseY;
      }
      
      public function mouseUp(evt:MouseEvent) : void
      {
         this.cutting = false;
      }
      
      public function gameStep() : void
      {
         var b:Bubble = null;
         var s:Star = null;
         var st:IStep = null;
         Step();
         for each(b in this.bubbles)
         {
            b.step();
         }
         for each(s in this.stars)
         {
            s.step();
         }
         for each(st in this.canStep)
         {
            st.step();
         }
         if(this.cutting)
         {
            this.cutRope();
         }
         if(this.candy)
         {
            if(this.candy.X < -100 || this.candy.X > this.worldWidth + 100 || this.candy.Y < -100 || this.candy.Y > this.worldHeight + 100)
            {
               this.candy.breakCandy();
            }
         }
         this.updateCamera();
      }
      
      private function updateCamera() : void
      {
         if(this.candy == null || this.char == null)
         {
            return;
         }
         var pt:Point = new Point();
         pt = this.candy.localToGlobal(pt);
         if(pt.x < Document.gameWidth / 2)
         {
            this.x += Math.min(5,(Document.gameWidth / 2 - pt.x) / 2);
         }
         else if(pt.x > Document.gameWidth / 2)
         {
            this.x += Math.max(-5,(Document.gameWidth / 2 - pt.x) / 2);
         }
         if(pt.y < Document.gameHeight / 2)
         {
            this.y += Math.min(5,(Document.gameHeight / 2 - pt.y) / 2);
         }
         else if(pt.y > Document.gameHeight / 2)
         {
            this.y += Math.max(-5,(Document.gameHeight / 2 - pt.y) / 2);
         }
         if(this.x + this.worldWidth < Document.gameWidth)
         {
            this.x = Document.gameWidth - this.worldWidth;
         }
         if(this.x > 0)
         {
            this.x = 0;
         }
         if(this.y + this.worldHeight < Document.gameHeight)
         {
            this.y = Document.gameHeight - this.worldHeight;
         }
         if(this.y > 0)
         {
            this.y = 0;
         }
      }
      
      private function cutRope() : void
      {
         var i:BaseGrab = null;
         var rope:Rope = null;
         var j:Constraint = null;
         var s:int = 0;
         this.mouseSegment.pA_v.x = this.mouseSegment.pB_v.x;
         this.mouseSegment.pA_v.y = this.mouseSegment.pB_v.y;
         this.mouseSegment.pB_v.x = this.mouseX;
         this.mouseSegment.pB_v.y = this.mouseY;
         for each(i in this.grabs)
         {
            rope = i.rope;
            if(rope != null)
            {
               for each(j in rope.constraints)
               {
                  this.ropeSegment.pA_v.x = j.p1.X;
                  this.ropeSegment.pA_v.y = j.p1.Y;
                  this.ropeSegment.pB_v.x = j.p2.X;
                  this.ropeSegment.pB_v.y = j.p2.Y;
                  if(this.ropeSegment.intersect(this.mouseSegment))
                  {
                     s = rope.constraints.indexOf(j);
                     SoundController.getInstance().rope_bleak_1();
                     i.removeConstraint(this,s);
                  }
               }
            }
         }
      }
      
      override public function Draw() : void
      {
         var color:uint = 0;
         var hock:BaseGrab = null;
         var rope:Rope = null;
         var i:int = 0;
         var xc:Number = NaN;
         var yc:Number = NaN;
         super.Draw();
         var ropeSp:Sprite = this.hockContiner.ropeGround;
         ropeSp.graphics.clear();
         var alp:Number = 1;
         for each(hock in this.grabs)
         {
            rope = hock.rope;
            if(!(rope == null || rope.constraints == null))
            {
               alp = rope.alpha;
               ropeSp.graphics.lineStyle(4,0,alp);
               ropeSp.graphics.moveTo(rope.constraints[0].p1.X,rope.constraints[0].p1.Y);
               for(i = 1; i < rope.constraints.length - 1; i++)
               {
                  color = rope.constraints[i - 1].color;
                  if(rope.constraints[i - 1].getLen() - rope.constraints[i - 1].dis > 0)
                  {
                     color = uint(Math.min(221,255 * (rope.constraints[i - 1].getLen() - rope.constraints[i - 1].dis) / 2 / rope.constraints[i - 1].dis) << 16 | color);
                  }
                  ropeSp.graphics.lineStyle(4,color,alp);
                  if(rope.constraints[i - 1].p2.constraints.length <= 1)
                  {
                     ropeSp.graphics.lineTo(rope.constraints[i - 1].p2.X,rope.constraints[i - 1].p2.Y);
                     ropeSp.graphics.moveTo(rope.constraints[i].p1.X,rope.constraints[i].p1.Y);
                  }
                  else
                  {
                     xc = (rope.constraints[i].p1.X + rope.constraints[i].p2.X) / 2;
                     yc = (rope.constraints[i].p1.Y + rope.constraints[i].p2.Y) / 2;
                     ropeSp.graphics.curveTo(rope.constraints[i].p1.X,rope.constraints[i].p1.Y,xc,yc);
                  }
               }
               if(rope.constraints.length == 1)
               {
                  i = 0;
               }
               if(i % 2)
               {
                  ropeSp.graphics.lineStyle(4,8810027,alp);
               }
               else
               {
                  ropeSp.graphics.lineStyle(4,5194016,alp);
               }
               if(rope.constraints[i].p1.constraints.length <= 1)
               {
                  ropeSp.graphics.moveTo(rope.constraints[i].p1.X,rope.constraints[i].p1.Y);
               }
               ropeSp.graphics.curveTo(rope.constraints[i].p1.X,rope.constraints[i].p1.Y,rope.constraints[i].p2.X,rope.constraints[i].p2.Y);
            }
         }
      }
      
      public function addCandy(_x:Number, _y:Number) : Candy
      {
         this.candy = new Candy(_x,_y);
         this.candy.mass = 38;
         this.candy.rad = 20;
         parts.push(this.candy);
         this.addChild(this.candy);
         this.candy.init();
         this.candy.world = this;
         return this.candy;
      }
      
      public function addTarget(_x:Number, _y:Number) : *
      {
         this.char = new Charactor(this);
         this.targetContiner.addChild(this.char);
         this.char.x = _x;
         this.char.y = _y;
      }
      
      public function addSpikes2(_x:Number, _y:Number, angle:Number, size:uint, toggled:Boolean = true, moveSpeed:Number = -1, path:Array = null, rotateSpeed:Number = 0) : void
      {
         var sp:Spikes = new Spikes(this,_x,_y,size,angle,moveSpeed,path,rotateSpeed);
         this.addChild(sp);
      }
      
      public function addGrab(_x:Number, _y:Number, spider:Boolean = false, moveOffset:Number = 0, moveVertical:Boolean = true, moveLength:Number = 0, radius:Number = -1, wheel:Boolean = false, length:Number = -1) : BaseGrab
      {
         var g:BaseGrab = null;
         if(moveLength <= 0)
         {
            if(radius == -1)
            {
               g = new Grab(_x,_y,this,spider,length);
            }
            else
            {
               g = new AutoGrab(_x,_y,this,spider,radius);
            }
         }
         else if(radius == -1)
         {
            g = new MoveGrab(_x,_y,this,spider,moveOffset,moveVertical,moveLength,radius,wheel,length);
         }
         else
         {
            g = new AutoMoveGrab(_x,_y,this,spider,moveOffset,moveVertical,moveLength,radius,wheel,length);
         }
         g.fixed = true;
         g.index = globalIndex++;
         parts.push(g);
         g.init();
         this.grabs.push(g);
         return g;
      }
      
      public function addBubble(_x:Number, _y:Number) : void
      {
         var b:Bubble = new Bubble(this);
         b.x = _x;
         b.y = _y;
         this.bubbles.push(b);
         this.addChild(b);
         var bg:BubbleBg = new BubbleBg();
         bg.x = _x;
         bg.y = _y;
         this.tutrilContiner.addChild(bg);
      }
      
      public function addStar(_x:Number, _y:Number, timeOut:Number = 0) : void
      {
         var s:Star = new Star(this,timeOut);
         s.x = _x;
         s.y = _y;
         this.stars.push(s);
         this.addChild(s);
      }
      
      public function addpump(_x:Number, _y:Number, angle:Number) : void
      {
         var p:pump = new pump(this);
         this.addChild(p);
         p.x = _x;
         p.y = _y;
         p.rotation = angle + 90;
      }
      
      public function addtutorialText(_x:int, _y:int, text:String, width:Number, special:Number) : void
      {
         var t:TutorialText = new TutorialText(_x,_y,text,width,this.tutorialDelay);
         if(special != 1)
         {
            this.tutrilContiner.addChild(t);
            t.tween();
         }
         else
         {
            this.tutorialSpecialAy.push(t);
         }
      }
      
      public function addTutorial(type:uint, _x:int, _y:int, angle:Number, special:Number) : void
      {
         var t:BaseTutorial = null;
         var se:tutorialSensor = null;
         switch(type)
         {
            case 1:
               t = new Tutorial01(_x,_y,this.tutorialDelay);
               break;
            case 4:
               t = new Tutorial04(_x,_y,this.tutorialDelay);
               break;
            case 5:
               t = new Tutorial05(_x,_y,this.tutorialDelay);
               break;
            case 6:
               t = new Tutorial06(_x,_y,this.tutorialDelay);
               break;
            case 8:
               t = new Tutorial08(_x,_y,this.tutorialDelay);
               break;
            case 9:
               t = new Tutorial09(_x,_y,this.tutorialDelay);
               break;
            case 10:
               t = new Tutorial10(_x,_y,this.tutorialDelay);
         }
         t.rotation = angle;
         if(special != 1)
         {
            t.tween();
            this.tutrilContiner.addChild(t);
         }
         else
         {
            this.tutorialSpecialAy.push(t);
            se = new tutorialSensor(this,_x,_y);
            this.canStep.push(se);
         }
      }
      
      private function removeTutorial(s:DisplayObject) : void
      {
         if(s.parent)
         {
            s.parent.removeChild(s);
         }
      }
   }
}

