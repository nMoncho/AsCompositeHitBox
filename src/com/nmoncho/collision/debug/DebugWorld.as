package com.nmoncho.collision.debug {
	import flash.geom.Point;
	import net.flashpunk.utils.Input;
	import com.nmoncho.collision.BoundingArea;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.HitCircle;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import net.flashpunk.FP;
	import net.flashpunk.World;

	/**
	 * @author developer
	 */
	public class DebugWorld extends World {
		
		private var debugGraphics:Sprite = new Sprite;
		private static const NOT_COLLIDES_COLOR:Number = 0x00ff00;
		private static const COLLIDES_COLOR:Number = 0xff0000;
		
		public var player:Player = new Player(false);
		public var npc1:Player = new Player(true, new HitBox(48, 32, "body", 0, 0));
		public var worldHitBox = new HitBox(100, 100, "world_hit_box", 100, 100);
		public var compoundHB1:HitBox = new HitBox(20, 20, "compound_hb_1", 300, 100);
		public var compoundHB2:HitBox = new HitBox(20, 20, "compound_hb_2", 350, 150);
		public var compositeHB:HitBox = HitBox.createHierachicalHitBox([compoundHB1, compoundHB2], false);
		
		public var compoundHB3:HitBox = new HitBox(20, 20, "compound_hb_1", 500, 300);
		public var compoundHB4:HitBox = new HitBox(30, 20, "compound_hb_2", 550, 350);
		public var compositeHC:HitCircle = HitCircle.createHierachicalHitCircle([compoundHB3, compoundHB4], false);
		
		var center:HitBox = new HitBox(20, 20, "center", 8, 8);
		var upperLeft:HitBox = new HitBox(15, 15, "upperLeft");
		var upperRight:HitBox = new HitBox(15, 15, "upperRight", 20, 0);
		var downLeft:HitBox = new HitBox(15, 15, "downLeft", 0, 20);
		var downRight:HitBox = new HitBox(15, 15, "downRight", 20, 20);
		
		var hHB:HitBox = HitBox.createHierachicalHitBox([center, upperLeft, upperRight, downLeft, downRight], false);
		
		var circle_01:HitCircle = new HitCircle(20, "top", 200, 400);
		var circle_02:HitCircle = new HitCircle(20, "left", 180, 440);
		var circle_03:HitCircle = new HitCircle(20, "right", 222, 440);
		var hHC:HitCircle = HitCircle.createHierachicalHitCircle([circle_01, circle_02, circle_03], false);
		
		private const collisionInfos:Array = [];
		
		public function DebugWorld() {
			
		}
		
		override public function begin():void {
			FP.engine.addChild(debugGraphics);
			add(player);
			add(npc1);
			player.x = FP.width / 2;
			player.y = FP.height / 2;
			npc1.x = npc1.y = 300;

			collisionInfos.push(new CollisionInfo(player.boundingArea, this));
			collisionInfos.push(new CollisionInfo(compositeHB, this));
			collisionInfos.push(new CollisionInfo(npc1.boundingArea, this));
			collisionInfos.push(new CollisionInfo(worldHitBox, this));
			collisionInfos.push(new CollisionInfo(compositeHC, this));
			collisionInfos.push(new CollisionInfo(hHB, this));
			collisionInfos.push(new CollisionInfo(hHC, this));
			hHB.setOrigin(210, 210);
		}
		
		override public function update():void {
			var i:Number, j:Number;
			super.update();
			debugGraphics.graphics.clear();
			for (i = 0; i < collisionInfos.length; i++) {
				collisionInfos[i].isColliding = false;
			}
			for (i = 0; i < collisionInfos.length; i++) {
				for (j = i + 1; j < collisionInfos.length; j++) {
					if (collisionInfos[i].isColliding) break;
					if (collisionInfos[j].isColliding) break;
					var isColliding:Boolean = BoundingArea(collisionInfos[i].ba).collides(collisionInfos[j].ba);
					collisionInfos[i].update(isColliding);
					collisionInfos[j].update(isColliding);
				}
			}
			if (Input.mouseDown) {
				for (i = 0; i < collisionInfos.length; i++) {
					if (BoundingArea(collisionInfos[i].ba).collides(new Point(Input.mouseX, Input.mouseY))) {
						collisionInfos[i].update(true);	
					}
				}					
			}
			for (i = 0; i < collisionInfos.length; i++) {
				renderBoundingArea(collisionInfos[i].ba, collisionInfos[i].isColliding);
			}
		}
		
		private function renderBoundingArea(area:BoundingArea, collides:Boolean = false):void {
			if (area is HitBox) {
				renderHitBox(HitBox(area), collides);
			} else if (area is HitCircle) {
				renderHitCircle(HitCircle(area), collides);
			}
			if (area.children) {
				for each (var ba:BoundingArea in area.children) {
					renderBoundingArea(ba);
				}
			}
		}
		
		private function renderHitBox(box:HitBox, collides:Boolean):void {
			var g:Graphics = debugGraphics.graphics,
					sx:Number = FP.screen.scaleX * FP.screen.scale,
					sy:Number = FP.screen.scaleY * FP.screen.scale;
			g.lineStyle(1, collides ? COLLIDES_COLOR : NOT_COLLIDES_COLOR);
			g.drawRect((box.x - FP.camera.x) * sx, (box.y - FP.camera.y) * sy, box.width * sx, box.height * sy);
		}
		
		private function renderHitCircle(circle:HitCircle, collides:Boolean):void {
			var g:Graphics = debugGraphics.graphics,
					sx:Number = FP.screen.scaleX * FP.screen.scale,
					sy:Number = FP.screen.scaleY * FP.screen.scale;
			g.lineStyle(1, collides ? COLLIDES_COLOR : NOT_COLLIDES_COLOR);
			g.drawCircle((circle.x - FP.camera.x) * sx, (circle.y - FP.camera.y) * sy, circle.radius * sx);
			g.drawRect(circle.x, circle.y, 2, 2);
		}
	}
	
	
}
