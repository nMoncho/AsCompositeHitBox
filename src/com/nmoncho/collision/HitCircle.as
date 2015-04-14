package com.nmoncho.collision {
	import net.flashpunk.Entity;
	import com.nmoncho.collision.BoundingArea;

	/**
	 * @author developer
	 */
	public class HitCircle extends BoundingArea {
		
		public var radius:Number;
		
		public function HitCircle(radius:Number = 0, name:String = "hit_circle", originX:Number = 0, originY:Number = 0, owner:Entity = null):void {
			super(name, originX, originY, owner);
			this.radius = radius;
		}
		
		override public function isPointInside(x : Number, y : Number) : Boolean {
			return MathUtils.sq(x - this.x) + MathUtils.sq(y - this.y) <= MathUtils.sq(radius); 
		}
		
		override internal function collidesClass(target:BoundingArea, x:Number, y:Number) : Boolean {
			var hitCircle:HitCircle = HitCircle(target);
			return MathUtils.sq(hitCircle.x - x) + MathUtils.sq(hitCircle.y - y) <= MathUtils.sq(radius + hitCircle.radius);
		}
		
		public static function createHierachicalHitCircle(children:Array, asRelative:Boolean = true, name:String = "parent_hit_circle"):HitCircle {
			var parentHC:HitCircle = new HitCircle();
			var ba:BoundingArea;
			var minX:Number = Number.MAX_VALUE, minY:Number = Number.MAX_VALUE, 
				maxX:Number = Number.MIN_VALUE, maxY:Number = Number.MIN_VALUE;
			parentHC.name = name;
			for each (ba in children) {
				if (asRelative) {
					parentHC.addChild(ba, asRelative);
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
			
			parentHC.originX = minX + (maxX - minX) / 2;
			parentHC.originY = minY + (maxY - minY) / 2;
			parentHC.radius = MathUtils.length(minX, minY, maxX, maxY) / 2;
			// TODO unify child adding
			if (!asRelative) {
				for each (ba in children) {
					parentHC.addChild(ba, asRelative);
				}
			}
			
			return parentHC;
		}
		
		/**
		 * Sets this hitcircle for an Entity.
		 * @param entity entity to set from.
		 * @param useEntityValues [optional] use entity's width, height... to fit the hitcircle.
		 * @return this instance.
		 */
		public function setForEntity(entity:Entity, useEntityValues:Boolean = true) : HitCircle {
			owner = entity;
			if (useEntityValues) {
				originX = -entity.width / 2;
				originY = -entity.height / 2;
				radius = MathUtils.length(0, 0, entity.width / 2, entity.height / 2);
			}
			return this;
		}

		/**
		 * The leftmost position.
		 */
		override public function get left():Number { return x - radius; }
		
		/**
		 * The rightmost position.
		 */
		override public function get right():Number { return x +radius; }
		
		/**
		 * The topmost position.
		 */
		override public function get top():Number { return y - radius; }
		
		/**
		 * The bottommost position.
		 */
		override public function get bottom():Number { return y + radius; }
		
		public function toString():String {
			return "HitCircle(" + name + "){r: " + radius + ", x: " + x + ", y: " + y + "}";
		}
	}
}
