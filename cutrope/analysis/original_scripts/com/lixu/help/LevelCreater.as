package com.lixu.help
{
   import com.lixu.physics.LXWorld;
   import flash.utils.getDefinitionByName;
   
   public class LevelCreater
   {
      
      private var world:LXWorld;
      
      private var xml:XML;
      
      private var xmlData:Class = LevelCreater_xmlData;
      
      private var scaleY:Number;
      
      public function LevelCreater(world:LXWorld, levelXml:XML)
      {
         super();
         this.world = world;
         this.xml = levelXml;
         this.xml = XML(new LevelClass["L" + Document.menuNum.toString() + "_" + Document.levelNum.toString()]());
         this.createLevel();
      }
      
      private function createLevel() : void
      {
         this.resoveSetting();
         this.scaleY = 576 / 480;
         this.resoveObject();
      }
      
      private function resoveSetting() : void
      {
         var setting:XMLList = null;
         var sett:XML = null;
         setting = this.xml.layer.(@name == "settings");
         for each(sett in setting)
         {
            this.world.grid.size = Number(sett.map.@gridSize);
            this.world.worldWidth = Number(sett.map.@width) * 1024 / 320;
            this.world.worldHeight = Number(sett.map.@height) * 576 / 480;
            this.world.speed = Number(sett.gameDesign.@ropePhysicsSpeed);
            this.world.special = Number(sett.gameDesign.@special);
            this.world.twoParts = sett.gameDesign.@twoParts == true ? true : false;
         }
      }
      
      private function resoveObject() : void
      {
         var objects:XMLList = null;
         var i:XML = null;
         var s:String = null;
         objects = this.xml.layer.(@name == "Objects");
         objects = objects.children();
         for each(i in objects)
         {
            s = i.name();
            switch(s)
            {
               case "candy":
                  this.world.addCandy((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY);
                  break;
               case "grab":
                  this.world.addGrab((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,i.@spider == "true" ? true : false,Number(i.@moveOffset),i.@moveVertical == "true" ? true : false,Number(i.@moveLength),Number(i.@radius) == -1 ? -1 : Number(i.@radius) * this.scaleY,Boolean(i.@wheel),Number(i.@length) * this.scaleY);
                  break;
               case "target":
                  this.world.addTarget((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY);
                  break;
               case "star":
                  this.world.addStar((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@timeout));
                  break;
               case "bubble":
                  this.world.addBubble((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY);
                  break;
               case "pump":
                  this.world.addpump((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle));
                  break;
               case "spike2":
                  this.world.addSpikes2((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,uint(i.@angle),Number(i.@size),i.@toggled == "true" ? true : false);
                  break;
               case "spike3":
                  this.world.addSpikes2((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,uint(i.@angle),Number(i.@size),i.@toggled == "true" ? true : false);
                  break;
               case "spike4":
                  this.world.addSpikes2((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,uint(i.@angle),Number(i.@size),i.@toggled == "true" ? true : false,-1,null,Number(i.@rotateSpeed) / 80);
                  break;
               case "spike1":
                  this.world.addSpikes2((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,uint(i.@angle),Number(i.@size),true,Number(i.@moveSpeed),this.resoveArray(i.@path));
                  break;
               case "tutorialText":
                  this.world.addtutorialText((Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,i.@text,i.@width * this.scaleY,Number(i.@special));
                  break;
               case "tutorial01":
                  this.world.addTutorial(1,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
                  break;
               case "tutorial04":
                  this.world.addTutorial(4,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
                  break;
               case "tutorial10":
                  this.world.addTutorial(10,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
                  break;
               case "tutorial09":
                  this.world.addTutorial(9,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
                  break;
               case "tutorial08":
                  this.world.addTutorial(8,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
                  break;
               case "tutorial06":
                  this.world.addTutorial(6,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
                  break;
               case "tutorial05":
                  this.world.addTutorial(5,(Number(i.@x) - 160) * this.scaleY + 512,Number(i.@y) * this.scaleY,Number(i.@angle),Number(i.@special));
            }
         }
      }
      
      private function resoveArray(str:String) : Array
      {
         var i:int = 0;
         var a:Array = null;
         var ay:Array = str.split(",");
         a = ay.length > 1 ? ay : null;
         if(a)
         {
            for(i = 0; i < a.length; i++)
            {
               a[i] = Number(a[i]);
            }
         }
         return a;
      }
   }
}

