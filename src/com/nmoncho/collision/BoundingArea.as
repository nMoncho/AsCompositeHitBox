package com.nmoncho.collision {
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import net.flashpunk.FP;
	import avmplus.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import net.flashpunk.Entity;
	/**
	 * Abstract class that defines a Bounding Area (implemented as a HitBox or a HitCircle).
	 * Allows for Hierachical Bounding Areas, my rationale is that only leafs (the hierachy is done by a tree)
	 * make a valid collision. 
	 * @author nMoncho
	 */
	public class BoundingArea {
	
		public var name:String;
		public var owner:Entity; // A Bounding area may or may not have an owner
		public var originX:Number = 0, originY:Number = 0;
		public var parent:BoundingArea;
		public var children:Array = null;
		private var childrenName:Dictionary = null;
		private var _class:Class;
		
		public function BoundingArea(name:String = "bounding_area", originX:Number = 0, originY:Number = 0, owner:Entity = null):void {
			this.name = name;
			this.owner = owner;
			this.originX = originX;
			this.originY = originY;
			this._class = Class(getDefinitionByName(getQualifiedClassName(this)));
		}
		
		/**
		 * Adds child to this bounding area (to do a hierachical bounding area)
		 * @param child bounding area to add as child
		 * @return this bounding area.  
		 */
		public function addChild(child:BoundingArea, asRelative:Boolean = true):BoundingArea {
			if (children == null) {
				children = [];
			}
			if (getBoundingByName(child.name)) {
				throw new Error("You already have a bounding area with the name " + child.name);
			}
			if (!asRelative) {
				child.originX = originX - child.originX;
				child.originY = originY - child.originY; 	
			}
			children.push(child);
			child.parent = this;
			child.owner = owner;
			addChildName(child);
			if (children.length > 1) {
				children.sort(function(a:BoundingArea, b:BoundingArea):Number {
					return (a.left == b.left) ? a.top - b.top : a.left - b.left;
				});
			}
			return this;
		}
		
		/**
		 * Add the child name for fast look up.
		 * @param child child to be added.
		 */
		private function addChildName(child:BoundingArea):void {
			if (parent) {
				parent.addChildName(child);
			} else {
				if (!childrenName) {
					childrenName = new Dictionary();
				}
				childrenName[child.name] = child;
				if (child.childrenName) { // collect all child's children and add them to top level parent
					for (var key:Object in child.childrenName) {
						if (getBoundingByName(String(key))) {
							throw new Error("You already have a bounding area with the name " + key);
						}
						childrenName[key] = child.childrenName[key];
					}
					child.childrenName = null;
				}
			}
		}
		
		/**
		 * Gets the bounding area specified by its name (looks up in children also).
		 * @param name name of the bounding area to get.
		 * @return bounding area with name, null if not exists.
		 */
		public function getBoundingByName(name:String):BoundingArea {
			if (this.name == name) {
				return this;
			}
			return parent ?
				parent.getBoundingByName(name) : 
				(childrenName ? childrenName[name] : null);
		}

		/**
		 * Tests if point is inside this bounding area (Doesn't check on children).
		 * Override this method for every area class.
		 * @param x x coord of the point to test.
		 * @param y y coord of the point to test.
		 * @return true if inside, false otherwise.
		 */
		public function isPointInside(x:Number, y:Number):Boolean {
			return false;
		}

		/**
		 * Tests if the <b>target</b> collides with the bounding area with the specified <b>name</b>.
		 * If the name doesn't exist will not test. Also, doesn't check on children.
		 * @param name name of the bounding area to test against.
		 * @param target object to test collision.
		 * @param x virtual x coordinate of THIS bounding area. In case you want an offset. (ie: x + 10)
		 * @param y virtual y coordinate of THIS bounding area.
		 * @return returns the bounding area if collided.
		 */
		public function collidesWithName(name:String, target:Object, x:Number = NaN, y:Number = NaN):Collision {
			var boundingArea:BoundingArea = getBoundingByName(name);
			return boundingArea != null ? boundingArea.collides(target, x, y, false) : null;
		}

		/**
		 * Checks if the <b>target</b> collides with this bounding area.
		 * @param target object to check against.
		 * @param x virtual x coordinate of THIS bounding area. In case you want an offset. (ie: x + 10)
		 * @param y virtual y coordinate of THIS bounding area.
		 * @return returns the bounding area that first detected a colision, null otherwise. 
		 */
		public function collides(target:Object, x:Number = NaN, y:Number = NaN, checkChildren:Boolean = true):Collision {
			var collided:BoundingArea, ba:BoundingArea, childCollided:BoundingArea;
			var tempHitBox:HitBox; // TODO reuse tempHitBox on recursion
			var entity:Entity;
			var entities:Array;
			var hierachicalTest:Boolean = !isLeaf;
			x = isNaN(x) ? this.x : x;
			y = isNaN(y) ? this.y : y;
			if (target is String && validEntityTypeCollisionCheck(String(target))) { // do a by type collision check
				collidesType(String(target));
			} else if (target is Entity) {
				tempHitBox = HitBox.createTempHitBoxForEntity(Entity(target));
				collided = collidesBoundingArea(tempHitBox, x, y);
			} else if (target is BoundingArea) {
				collided = collidesBoundingArea(BoundingArea(target), x, y);
				hierachicalTest = !this.isLeaf || !BoundingArea(target).isLeaf;
			} else if (target is Point) {
				collided = isPointInside(Point(target).x, Point(target).y) ? this : null;
			} else {
				throw new Error("Not supported target type");
			}
			
			if (collided && checkChildren && hierachicalTest) {
				var childrenA:Array = isLeaf ? [this] : children, 
					childrenB:Array = BoundingArea(target).isLeaf ? [target] : BoundingArea(target).children;
				collided = collidesChildren(childrenA, childrenB);
			}
			return collided;
		}
		
		private function collidesType(type:String):Collision {
			var entities:Array = [];
			var tempHitBox:HitBox;
			var collision:Collision;
			
			FP.world.getType(type, entities);
			for each (var entity:Entity in entities) {
				tempHitBox = HitBox.createTempHitBoxForEntity(entity, tempHitBox);
				collision = collidesBoundingArea(tempHitBox, x, y);
				if (collision) {
					break;	
				}
			}
			
			return collision;
		}
		
		private function collidesChildren(childrenA:Array, childrenB:Array):BoundingArea {
			// TODO do a better version of this, doing a line sweep
			for each (var ba:BoundingArea in childrenA) { // O(n ^ 2) : BAAAAAAAADDDDDD!!!
				for each (var bb:BoundingArea in childrenB) {
					if (ba.collides(bb)) {
						return ba;
					}
				}	
			}
			return null;
		}

		/**
		 * Checks if the entity type is valid for collision checking.
		 * @return true if valid, false otherwise.
		 */
		private function validEntityTypeCollisionCheck(target:String):Boolean {
			return FP.world && FP.world.typeFirst(target); 
		}

		internal function collidesBoundingArea(target:BoundingArea, x:Number, y:Number): BoundingArea {
			var collided:BoundingArea;
			if (this._class == target._class) {
				collided = collidesClass(target, x, y);
			} else if (isCircleBoxCollision(target)) {
				collided = circleBoxCollisionCheck(target, x, y);
			} else { // TODO check how to mix
				
			}
			return collided;
		}

		private function isCircleBoxCollision(target:BoundingArea):Boolean {
			return (this is HitCircle && target is HitBox) || (this is HitBox && target is HitCircle);
		}
		
		private function circleBoxCollisionCheck(target:BoundingArea, x:Number, y:Number):BoundingArea {
			var circle:HitCircle;
			var box:HitBox;
			var cornerDistanceSq:Number;
			var distX:Number, distY:Number;
			
			if (this is HitCircle) {
				circle = HitCircle(this);
				box = HitBox(target);
				distX = Math.abs(x - box.centerX);
				distY = Math.abs(y - box.centerY);
			} else {
				circle = HitCircle(target);
				box = HitBox(this);
				distX = Math.abs(circle.x - (x + box.width / 2));
				distY = Math.abs(circle.y - (y + box.height / 2));
			}
						
			if (distX > (box.halfWidth + circle.radius) || distY > (box.halfHeight + circle.radius)) {
				return null;
			} else if (distX <= box.halfWidth || distY <= box.halfHeight) {
				return this;
			} else {
				cornerDistanceSq = MathUtils.sq(distX - box.halfWidth) + MathUtils.sq(distY - box.halfHeight);
				return cornerDistanceSq <= MathUtils.sq(circle.radius) ? this : null;
			}
		}
		
		/**
		 * Override this method to handle same BoundingArea class collisions
		 */
		internal function collidesClass(target:BoundingArea, x:Number, y:Number): BoundingArea {
			return undefined;
		}

		/**
		 * Gets X real coordinate of the bounding area.
		 * If has entity owner, calculates based on owner.x
		 */
		public function get x():Number {
			if (owner) {
				return owner.x - originX;
			} else if (parent) {
				return parent.x - originX;
			} else {
				return originX;
			}
			//return owner ? owner.x - originX : originX;
		}

		/**
		 * Gets Y real coordinate of the bounding area.
		 * If has entity owner, calculates based on owner.y
		 */		
		public function get y():Number {
			if (owner) {
				return owner.y - originY;
			} else if (parent) {
				return parent.y - originY;
			} else {
				return originY;
			}
		}
		
		/**
		 * The leftmost position.
		 */
		public function get left():Number { return x; }
		
		/**
		 * The rightmost position.
		 */
		public function get right():Number { return x; }
		
		/**
		 * The topmost position.
		 */
		public function get top():Number { return y; }
		
		/**
		 * The bottommost position.
		 */
		public function get bottom():Number { return y; }

		/**
		 * Sets the origin coordinates of the bounding area.
		 * @param originX X coordinate of the bounding area.
		 * @param originY Y coordinate of the bounding area.
		 */		
		public function setOrigin(originX:Number, originY:Number):void {
			this.originX = originX;
			this.originY = originY;
		}

		/**
		 * Tests if this bounding area is leaf on the Hierachical bounding area.
		 * @return true if is leaf, false otherwise. 
		 */
		public function get isLeaf():Boolean {
			return children == null || children.length == 0;
		}

	}
}
