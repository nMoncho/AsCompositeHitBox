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
		
		override internal function collidesClass(target:BoundingArea, x:Number, y:Number): BoundingArea {
			var collides:BoundingArea;
			if (target is HitCircle) {
				collides = collidesClazz(HitCircle(target), x, y);				
			}
			return collides;
		}
		
		private function collidesClazz(target:HitCircle, x:Number, y:Number): BoundingArea {
			return MathUtils.sq(target.x - x) + MathUtils.sq(target.y - y) <= MathUtils.sq(radius + target.radius) ? 
				this : 
				null;
			/*return MathUtils.length(x, y, target.x, target.y) < (this.radius + target.radius) ?
				this :
				null;*/
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
	}
}