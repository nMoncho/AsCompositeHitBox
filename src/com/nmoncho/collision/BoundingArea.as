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
			if (!asRelative) { // I think I should use this.x instead of this.originX (to handle multiple levels)
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
		 * Removes child from this Hierachical Bounding Area
		 * @param child child to be removed.
		 * @return child removed. (Can be used for checking removal)
		 */
		public function removeChild(child:BoundingArea) : BoundingArea {
			var childRemoved:BoundingArea;
			var idx:int = children.indexOf(child);
			if (idx >= 0) { // I think I should use this.x instead of this.originX (to handle multiple levels)
				childRemoved = children.splice(idx, 1)[0];
				childRemoved.originX = originX - childRemoved.originX;
				childRemoved.originY = originY - childRemoved.originY;	
				childRemoved.parent = null;
				childRemoved.owner = null;
				removeChildName(childRemoved);
			}
			return childRemoved;
		}
		
		/**
		 * Removes the child name for fast look up.
		 * @param child child to be removed.
		 */
		private function removeChildName(child:BoundingArea):void {
			if (parent) {
				parent.removeChildName(child);
			} else if (childrenName) {
				delete childrenName[child.name];
			}
		}
		
		/**
		 * Removes child from this Hierachical Bounding Area by its name.
		 * @param childName child's name to remove.
		 * @return child removed.
		 */
		public function removeChildByName(childName:String) : BoundingArea {
			return removeChild(getBoundingByName(childName));
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
		 * Override this method to handle same BoundingArea class collisions.
		 * Remember to cast to proper class (sorry don't have generics).
		 * @param target object to test collision.
		 * @param x virtual x coordinate of THIS bounding area. In case you want an offset. (ie: x + 10)
		 * @param y virtual y coordinate of THIS bounding area.
		 */
		internal function collidesClass(target:BoundingArea, x:Number, y:Number) : Boolean {
			return false;
		}

		/**
		 * Tests if the <b>target</b> collides with the bounding area with the specified <b>name</b>.
		 * If the name doesn't exist will not test. Also, doesn't check on children.
		 * @param name name of the bounding area to test against.
		 * @param target object to test collision.
		 * @param x virtual x coordinate of THIS bounding area. In case you want an offset. (ie: x + 10)
		 * @param y virtual y coordinate of THIS bounding area.
		 * @return returns a collision object if collided.
		 */
		public function collidesWithName(name:String, target:Object, x:Number = NaN, y:Number = NaN) : Collision {
			var boundingArea:BoundingArea = getBoundingByName(name);
			return boundingArea != null ? boundingArea.collides(target, x, y, false) : null;
		}

		/**
		 * Checks if the <b>target</b> collides with this bounding area.
		 * @param target object to check against.
		 * @param x virtual x coordinate of THIS bounding area. In case you want an offset. (ie: x + 10)
		 * @param y virtual y coordinate of THIS bounding area.
		 * @return returns a collision object if collided, null otherwise. 
		 */
		public function collides(target:Object, x:Number = NaN, y:Number = NaN, checkChildren:Boolean = true) : Collision {
			var collided:Boolean;
			var collision:Collision;
			var hierachicalTest:Boolean = !isLeaf;
			// TODO check on all impl that uses virtual coords
			x = isNaN(x) ? this.x : x;
			y = isNaN(y) ? this.y : y;
			if (target is String && validEntityTypeCollisionCheck(String(target))) { // do a by type collision check
				collision = collidesType(String(target), x, y);
				collided =  collision && collision.collides;
				target = collision.collider;
			} else if (target is Entity) {
				target = HitBox.createHitBoxForEntity(Entity(target)); // TODO reuse tempHitBox on game loop recursion (cache between deltas)
				collided = collidesBoundingArea(HitBox(target), x, y);
			} else if (target is BoundingArea) {
				collided = collidesBoundingArea(BoundingArea(target), x, y);
				hierachicalTest = !this.isLeaf || !BoundingArea(target).isLeaf;
			} else if (target is Point) {
				collided = isPointInside(Point(target).x, Point(target).y);
			} else {
				throw new Error("Not supported target type");
			}
			
			if (collided && checkChildren && hierachicalTest) { // check on children
				var childrenA:Array = isLeaf ? [this] : children, // TODO not taking into account if B is not BA.
					childrenB:Array = target is BoundingArea  && !BoundingArea(target).isLeaf ? BoundingArea(target).children : [target];
				collision = collidesChildren(childrenA, childrenB);
			} else if (collided && (!checkChildren || !hierachicalTest)) {
				collision = new Collision(collided, this, target);
			}

			return collision;
		}
		
		/**
		 * Checks collision with family type.
		 * @param	type name of type to check against.
		 * @param x virtual x coordinate of THIS bounding area. In case you want an offset. (ie: x + 10)
		 * @param y virtual y coordinate of THIS bounding area.
		 * @return collision object, maybe undefined if don't collided.
		 */
		private function collidesType(type:String, x:Number, y:Number) : Collision {
			var entities:Array = [];
			var tempHitBox:HitBox;
			var collision:Collision;
			
			FP.world.getType(type, entities);
			for each (var entity:Entity in entities) {
				tempHitBox = HitBox.createHitBoxForEntity(entity, tempHitBox);
				if (collidesBoundingArea(tempHitBox, x, y)) {
					collision =  new Collision(true, this, tempHitBox);
					// TODO ERROR not checking on this children
					break;	
				}
			}
			
			return collision;
		}
		
		private function collidesChildren(childrenA:Array, childrenB:Array) : Collision {
			// TODO do a better version of this, doing a line sweep
			var collision:Collision;
			for each (var ba:BoundingArea in childrenA) { // O(n ^ 2) : BAAAAAAAADDDDDD!!!
				for each (var bb:BoundingArea in childrenB) {
					collision = ba.collides(bb);
					if (collision) {
						return collision;
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

		internal function collidesBoundingArea(target:BoundingArea, x:Number, y:Number) : Boolean {
			var collides:Boolean;
			if (this._class == target._class) {
				collides = collidesClass(target, x, y);
			} else if (isCircleBoxCollision(target)) {
				collides = circleBoxCollisionCheck(target, x, y);
			} else {
				throw new Error("Collision mix not supported " + this._class + " / " + target._class);
			}
			return collides;
		}

		private function isCircleBoxCollision(target:BoundingArea) : Boolean {
			return (this is HitCircle && target is HitBox) || (this is HitBox && target is HitCircle);
		}
		
		private function circleBoxCollisionCheck(target:BoundingArea, x:Number, y:Number) : Boolean {
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
				return false;
			} else if (distX <= box.halfWidth || distY <= box.halfHeight) {
				return true;
			} else {
				cornerDistanceSq = MathUtils.sq(distX - box.halfWidth) + MathUtils.sq(distY - box.halfHeight);
				return cornerDistanceSq <= MathUtils.sq(circle.radius);
			}
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
		 * Sets the Entity's hitbox properties.
		 * @param	width		Width of the hitbox.
		 * @param	height		Height of the hitbox.
		 * @param	originX		X origin of the hitbox.
		 * @param	originY		Y origin of the hitbox.
		 */
		public function setHitbox(width:int = 0, height:int = 0, originX:int = 0, originY:int = 0):void {
			this.originX = originX;
			this.originY = originY;
			this.width = width;
			this.height = height;
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
		 * Half the Entity's width.
		 */
		public function get halfWidth():Number { throw new Error("Unsupported Operation"); }

		/**
		 * Half the Entity's height.
		 */
		public function get halfHeight():Number { throw new Error("Unsupported Operation"); }
		
		/**
		 * The center x position of the Entity's hitbox.
		 */
		public function get centerX():Number { throw new Error("Unsupported Operation"); }
		
		/**
		 * The center y position of the Entity's hitbox.
		 */
		public function get centerY():Number { throw new Error("Unsupported Operation"); }
		
		/**
		 * Width of the Entity's hitbox.
		 */
		public function get width():int { throw new Error("Unsupported Operation"); }
		
		public function set width(val:int):void { throw new Error("Unsupported Operation"); }
		
		/**
		 * Height of the Entity's hitbox.
		 */
		public function get height():int { throw new Error("Unsupported Operation"); }
		
		public function set height(val:int):void { throw new Error("Unsupported Operation"); }

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
