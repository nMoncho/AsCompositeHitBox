package com.nmoncho.collision.debug {
	import net.flashpunk.World;
	import net.flashpunk.graphics.Text;
	import com.nmoncho.collision.BoundingArea;
	/**
	 * @author developer
	 */
	public class CollisionInfo {
		
		public var ba:BoundingArea;
		public var isColliding:Boolean = false;
		public var text:Text;
		
		public function CollisionInfo(ba:BoundingArea, world:World) {
			this.ba = ba;
			this.text = new Text(ba.name, ba.x, ba.y - 10);
			text.size = 10;
			world.addGraphic(text);	
		}
		
		public function update(collides:Boolean):void {
			this.isColliding = collides;
			text.x = x;
			text.y = y - 15;
		}
		
		private function get x():Number {
			return ba.owner ? ba.owner.x : ba.x; 
		}
		
		private function get y():Number {
			return ba.owner ? ba.owner.y : ba.y; 
		}
	}
}
