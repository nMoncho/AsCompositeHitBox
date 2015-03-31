package com.nmoncho.collision.tests {
	import com.nmoncho.collision.HitCircle;
	import asunit.framework.TestCase;

	/**
	 * @author developer
	 */
	public class HitCircleTests extends TestCase {
		
		public function HitCircleTests(testMethod:String = null) {
			super(testMethod);
		}
		
		public function TestPointInsideHitCircle():void {
			var circle0_0_10_10:HitCircle = new HitCircle(10);
			assertTrue(circle0_0_10_10.isPointInside(5, 5));
			assertTrue(circle0_0_10_10.isPointInside(10, 0));
			assertTrue(circle0_0_10_10.isPointInside(-10, 0));
			assertTrue(circle0_0_10_10.isPointInside(0, 10));
			assertTrue(circle0_0_10_10.isPointInside(0, -10));
			
			assertFalse(circle0_0_10_10.isPointInside(10, -10));
			assertFalse(circle0_0_10_10.isPointInside(10, 10));
			assertFalse(circle0_0_10_10.isPointInside(-10, -10));
			assertFalse(circle0_0_10_10.isPointInside(-11, 0));
			
			var circle10_10_10_10:HitCircle = new HitCircle(10, "hit_circle", 10, 10);
			assertTrue(circle10_10_10_10.isPointInside(5, 5));
			assertTrue(circle10_10_10_10.isPointInside(10, 0));
			assertTrue(circle10_10_10_10.isPointInside(0, 10));
			
			assertFalse(circle10_10_10_10.isPointInside(-1, 0));
			assertFalse(circle10_10_10_10.isPointInside(20, 20));
		}
		
		public function TestHitCircleSymmetry():void {
			var circle0_0_10:HitCircle = new HitCircle(10);
			var circle0_0_20:HitCircle = new HitCircle(20);
			var circle10_15_15:HitCircle = new HitCircle(10);
			circle10_15_15.setOrigin(15, 15);
			
			assertNotNull(circle0_0_10.collides(circle0_0_20));
			assertNotNull(circle0_0_20.collides(circle0_0_10));
			
			assertNotNull(circle0_0_20.collides(circle10_15_15));
			assertNotNull(circle10_15_15.collides(circle0_0_20));
			
			assertNull(circle0_0_10.collides(circle10_15_15));
			assertNull(circle10_15_15.collides(circle0_0_10));
		}
	}
}
