package com.nmoncho.collision {
	import net.flashpunk.Entity;
	import com.nmoncho.collision.BoundingArea;

	/**
	 * HitBox implementation of Bounding Area (although it should be HitSquare).
	 * The origin of the HitBox is the upper-left corner, expanding downward left.
	 * @author nMoncho
	 */
	public class HitBox extends BoundingArea {
		
		public var _width:Number, _height:Number;
		
		public function HitBox(width:Number = 0, height:Number = 0, name:String = "hit_box", originX:Number = 0, originY:Number = 0, owner:Entity = null):void {
			super(name, originX, originY, owner);
			_width = width;
			_height = height;
		}

		override public function isPointInside(x : Number, y : Number) : Boolean {
			return x >= left && x <= right 
				&& y >= top && y <= bottom;			
		}
		
		override internal function collidesClass(target:BoundingArea, x:Number, y:Number) : Boolean {
			var hitTarget:HitBox = HitBox(target);
			return withinDimension(x, width, hitTarget.x, hitTarget.width) &&
				withinDimension(y, height, hitTarget.y, hitTarget.height);
		}
		
		private function withinDimension(coordA:Number, dimA:Number, coordB:Number, dimB:Number):Boolean {
			return (coordA <= coordB) ?
				(coordB - coordA) <= dimA :
				(coordA - coordB) <= dimB;
		}
		
		/**
		 * Creates an Hierachical HitBox that fits all its children. Construction in linear time.
		 * @param children list of children.
		 * @param asRelative consider originX and originY of children as relative or absolute.
		 * @param name Parent HitBox name
		 * @return Hierachical HitBox that fits all its children.
		 */
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

		/**
		 * Creates a HitBox for an entity.
		 * @param entity entity to create the HitBox for.
		 * @param hitbox [optional] reuse a created hitbox.
		 * @return Hitbox created for entity.  
		 */
		public static function createHitBoxForEntity(entity:Entity, hitbox:HitBox = null):HitBox {
			if (hitbox) {
				hitbox.setForEntity(entity);
			} else {
				hitbox = new HitBox(entity.width, entity.height, "temp_hitbox", entity.originX, entity.originY, entity);
			}

			return hitbox;
		}
				
		override public function get width():int { return _width; }
		
		override public function set width(val:int):void { _width = val; }
		
		override public function get height():int { return _height; }
		
		override public function set height(val:int):void { _height = val; }
		
		override public function get halfWidth():Number { return width / 2; }
		
		override public function get halfHeight():Number { return height / 2; }
		
		override public function get centerX():Number { return x + width / 2; }
		
		override public function get centerY():Number { return y + height / 2; }

		override public function get right():Number { return x + width; }

		override public function get bottom():Number { return y + height; }

		/**
		 * Sets this hitbox for an Entity.
		 * @param entity entity to set from.
		 * @param useEntityValues [optional] use entity's width, height... to fit the hitbox.
		 * @return this instance.
		 */
		public function setForEntity(entity:Entity, useEntityValues:Boolean = true) : HitBox {
			owner = entity;
			if (useEntityValues) {
				width = entity.width;
				height = entity.height;
				originX = entity.originX;
				originY = entity.originY;
			}
			return this;
		}
		
		public function toString() : String {
			return "HitBox(" + name + "){w: " + width + ", h: " + height + ", x: " + x + ", y: " + y + "}";
		}
	}
}
