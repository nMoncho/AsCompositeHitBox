package com.nmoncho.collision.debug 
{
	import com.nmoncho.collision.BoundingArea;
	import com.nmoncho.collision.debug.CollisionInfo;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.HitCircle;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	/**
	 * ...
	 * @author nMoncho
	 */
	public class CollisionDebug extends Entity
	{
		private static const NOT_COLLIDES_COLOR:Number = 0x00ff00;
		private static const COLLIDES_COLOR:Number = 0xff0000;
		
		/** The key used to toggle the Console on/off. Tilde (~) by default. */
		public static var toggleKey:uint = 192;
		public static var enabled:Boolean = false;
		
		private static var debugGraphics:Sprite = new Sprite;
		private static var collisionInfos:Array = [];
		
		public function CollisionDebug() {
			FP.engine.addChild(debugGraphics);
		}
		
		public static function addBoundingArea(area:BoundingArea):void {
			collisionInfos.push(new CollisionInfo(area, FP.world));
		}
		
		override public function update():void {
			debugGraphics.graphics.clear();
			if (Input.pressed(toggleKey)) {
				enabled = !enabled;
			}
			if (enabled) {
				var i:Number, j:Number;
				for (i = 0; i < collisionInfos.length; i++) {
					collisionInfos[i].update(false);
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