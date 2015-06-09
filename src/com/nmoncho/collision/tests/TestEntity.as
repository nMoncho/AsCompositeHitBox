package com.nmoncho.collision.tests {
	import com.nmoncho.collision.HitCircle;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.BoundingArea;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;

	/**
	 * @author developer
	 */
	public class TestEntity extends Entity {
		
		public var foo:BoundingArea = new HitBox();
		public var boundingArea:BoundingArea = new HitCircle();
	
		public function TestEntity(x : Number = 0, y : Number = 0, graphic : Graphic = null, mask : Mask = null) {
			super(x, y, graphic, mask);
		}
	}
}
