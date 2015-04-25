package com.nmoncho.collision {
	
	import net.flashpunk.Graphic;
	import net.flashpunk.Entity;

	/**
	 * Flashpunk's Entity extension providing BoundingArea collision checks out of the box.
	 * You shouldn't use width, height, originX or originY, it's impossible to override them, for this 
	 * purposes please use the accessors.
	 * I wished that we could use Entity and CollidableEntity interchangeably, but beause of this we can't.
	 * @author nMoncho
	 */
	public class CollidableEntity extends Entity {
		
		public var boundingArea:BoundingArea;
		
		public function CollidableEntity(x:Number = 0, y:Number = 0, boundingArea:Object = null, graphic:Graphic = null) {
			super(x, y, graphic);
			if (boundingArea is BoundingArea) {
				this.boundingArea = BoundingArea(boundingArea);
			} else if (boundingArea && boundingArea.width && boundingArea.height) {
				this.boundingArea = new HitBox(boundingArea.width, boundingArea.height);
			} else if (boundingArea && boundingArea.radius) {
				this.boundingArea = new HitCircle(boundingArea.radius);
			} else {
				this.boundingArea = new HitBox();
			}
			
			if (boundingArea && !(boundingArea is BoundingArea)) {
				checkOptionalProperties(boundingArea);
			}
		}
		
		/**
		 * Checks and configures based on optional config object.
		 * @param config configuration object.
		 */
		private function checkOptionalProperties(config:Object):void {
			if (config.originX) {
				this.boundingArea.originX = config.originX; 
			}
			if (config.originY) {
				this.boundingArea.originY = config.originY; 
			}
			if (config.name) {
				this.boundingArea.name = config.name; 
			}
		}
		
		override public function collide(type:String, x:Number, y:Number):Entity {
			var collision:Collision = boundingArea.collides(type, x, y);
			return collision ? collision.colliderOwner : null;
		}
		
		override public function collideTypes(types:Object, x:Number, y:Number):Entity {
			var collision:Collision = boundingArea.collides(type, x, y);
			return collision ? collision.colliderOwner : null;
		}
		
		override public function collideWith(e:Entity, x:Number, y:Number):Entity {
			return boundingArea.collides(type, x, y) ? e : null;
		}
		
		override public function collideRect(x:Number, y:Number, rX:Number, rY:Number, rWidth:Number, rHeight:Number):Boolean {
			var hitbox:HitBox = new HitBox(rWidth, rHeight, "hit_box", rX, rY);
			return boundingArea.collides(hitbox, x, y);
		}
		
		override public function collidePoint(x:Number, y:Number, pX:Number, pY:Number):Boolean {
			return boundingArea.isPointInside(pX, pY); // TODO not taking into account virtual coords.
		}
		
		override public function collideInto(type:String, x:Number, y:Number, array:Object):void {
			throw new Error("Unsupported operation");
		}
		
		override public function collideTypesInto(types:Object, x:Number, y:Number, array:Object):void {
			throw new Error("Unsupported operation");
		}
		
		override public function setHitbox(width:int = 0, height:int = 0, originX:int = 0, originY:int = 0):void {
			boundingArea.setHitbox(width, height, originX, originY);
		}
		
		override public function setHitboxTo(o:Object):void {
			var width:Number, height:Number, originX:Number, originY:Number;
			if (o.hasOwnProperty("width")) width = Number(o.width);
			if (o.hasOwnProperty("height")) height = Number(o.height);
			if (o.hasOwnProperty("originX") && !(o is Graphic)) originX = Number(o.originX);
			else if (o.hasOwnProperty("x")) originX = Number(-o.x);
			if (o.hasOwnProperty("originY") && !(o is Graphic)) originY = Number(o.originY);
			else if (o.hasOwnProperty("y")) originY = Number(-o.y);
			
			setHitbox(o.width, o.height, -o.x, -o.y);
		}
		
		override public function setOrigin(x:int = 0, y:int = 0):void {
			boundingArea.setOrigin(x, y);
		}
		
		override public function get halfWidth():Number { return boundingArea.halfWidth; }

		override public function get halfHeight():Number { return boundingArea.halfHeight; }
		
		override public function get centerX():Number { return boundingArea.centerX; }
		
		override public function get centerY():Number { return boundingArea.centerY; }

		override public function get right():Number { return boundingArea.right; }

		override public function get bottom():Number { return boundingArea.bottom; }
		
		override public function get left():Number { return boundingArea.left; }

		override public function get top():Number { return boundingArea.top; }
		
		public function get widthCE():Number { return boundingArea.width; }
		public function set widthCE(val:Number):void { boundingArea.width = val; }
		public function get heightCE():Number { return boundingArea.height; }
		public function set heightCE(val:Number):void { boundingArea.height = val; }
		
		public function get originXCE():Number { return boundingArea.originX; }
		public function set originXCE(val:Number):void { boundingArea.originX = val; }
		public function get originYCE():Number { return boundingArea.originY; }
		public function set originYCE(val:Number):void { boundingArea.originY = val; }
	}
}
