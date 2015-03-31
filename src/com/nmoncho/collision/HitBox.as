package com.nmoncho.collision {
	import net.flashpunk.Entity;
	import com.nmoncho.collision.BoundingArea;

	/**
	 * @author developer
	 */
	public class HitBox extends BoundingArea {
		
		public var width:Number, height:Number;
		
		public function HitBox(width:Number = 0, height:Number = 0, name:String = "hit_box", originX:Number = 0, originY:Number = 0, owner:Entity = null):void {
			super(name, originX, originY, owner);
			this.width = width;
			this.height = height;
		}

		override public function isPointInside(x : Number, y : Number) : Boolean {
			return x >= left && x <= right 
				&& y >= top && y <= bottom;			
		}
		
		override internal function collidesClass(target:BoundingArea, x:Number, y:Number): BoundingArea {
			var collides:BoundingArea;
			if (target is HitBox) {
				collides = collidesClazz(HitBox(target), x, y);				
			}
			return collides;
		}
		
		private function collidesClazz(target:HitBox, x:Number, y:Number): BoundingArea {
			return (withinDimension(x, width, target.x, target.width) &&
				withinDimension(y, height, target.y, target.height)) ?
				this :
				null;	
		}
		
		private function withinDimension(coordA:Number, dimA:Number, coordB:Number, dimB:Number):Boolean {
			return (coordA <= coordB) ?
				(coordB - coordA) <= dimA :
				(coordA - coordB) <= dimB;
		}
		
		public static function createHierachicalHitBox(children:Array, asRelative:Boolean = true, name:String = "parent_hit_box"):HitBox {
			var parentHB:HitBox = new HitBox();
			var ba:BoundingArea;
			var minX:Number = Number.MAX_VALUE, minY:Number = Number.MAX_VALUE, 
				maxX:Number = Number.MIN_VALUE, maxY:Number = Number.MIN_VALUE;
			parentHB.name = name;
			for each (ba in children) {
				if (asRelative) {
					parentHB.addChild(ba, asRelative);
				}
				if (ba.left < minX) {
					minX = ba.left;
				} 
				if (ba.right > maxX) {
					maxX = ba.right;
				}
				if (ba.top < minY) {
					minY = ba.top;
				}
				if (ba.bottom > maxY) {
					maxY = ba.bottom;
				}
			}
			parentHB.originX = minX;
			parentHB.originY = minY;
			parentHB.width = maxX - minX;
			parentHB.height = maxY - minY;
			// TODO unify child adding
			if (!asRelative) {
				for each (ba in children) {
					parentHB.addChild(ba, asRelative);
				}
			}
			
			return parentHB;
		}
		
		public static function createTempHitBoxForEntity(entity:Entity, hitbox:HitBox = null):HitBox {
			if (hitbox) {
				hitbox.setForEntity(entity);
			} else {
				hitbox = new HitBox(entity.width, entity.height, "temp_hitbox", entity.originX, entity.originY, entity);
			}

			return hitbox;
		}
		
		/**
		 * Half the Entity's width.
		 */
		public function get halfWidth():Number { return width / 2; }
		
		/**
		 * Half the Entity's height.
		 */
		public function get halfHeight():Number { return height / 2; }
		
		/**
		 * The center x position of the hitbox.
		 */
		public function get centerX():Number { return x + width / 2; }
		
		/**
		 * The center y position of the hitbox.
		 */
		public function get centerY():Number { return y + height / 2; }

		override public function get right():Number { return x + width; }

		override public function get bottom():Number { return y + height; }
		
		public function setForEntity(entity:Entity):void {
			width = entity.width;
			height = entity.height;
			owner = entity;
			originX = entity.originX;
			originY = entity.originY;
		}
	}
}
