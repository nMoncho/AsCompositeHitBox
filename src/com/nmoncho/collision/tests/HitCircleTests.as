package com.nmoncho.collision.tests {
	import net.flashpunk.Entity;
	import com.nmoncho.collision.HitCircle;
	import asunit.framework.TestCase;

	/**
	 * @author developer
	 */
	public class HitCircleTests extends TestCase 
	{
		public static const RANDOM_TESTS:int = 10000;	
		
		public function HitCircleTests(testMethod:String = null) {
			super(testMethod);
		}
		
		public function testPointInsideHitCircle_Random():void {
			var circle0_0_10_10:HitCircle = new HitCircle(10);
			var circle5_5_10_10:HitCircle = new HitCircle(10, "hitcircle", 5, 5);
			var circle_5__5_10_10:HitCircle = new HitCircle(10, "hitcircle", -5, -5);
			
			testPointInsideHitCircle_RandomCheck(circle0_0_10_10);
			testPointInsideHitCircle_RandomCheck(circle5_5_10_10);
			testPointInsideHitCircle_RandomCheck(circle_5__5_10_10);
		}
		
		private function testPointInsideHitCircle_RandomCheck(hb:HitCircle):void {
			var i:int;
			var x:Number, y:Number, r:Number, theta:Number;
			for (i = 0; i < RANDOM_TESTS; i++) {
				r = Math.sqrt(Math.random() * hb.radius);
				theta = Math.random() * 2 * Math.PI;
				x = r * Math.cos(theta) + hb.x;
				y = r * Math.sin(theta) + hb.y;
				assertTrue("(" + x +", "+ y + ") was not inside of " + hb, hb.isPointInside(x, y));
			}
		}
		
		public function testPointInsideHitCircle_NoOrigin():void {
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
		}
		
		public function testPointInsideHitCircle_WithPositiveOrigin():void {
			var circle10_10_10_10:HitCircle = new HitCircle(10, "hit_circle", 10, 10);
			assertTrue(circle10_10_10_10.isPointInside(5, 5));
			assertTrue(circle10_10_10_10.isPointInside(10, 0));
			assertTrue(circle10_10_10_10.isPointInside(0, 10));
			
			assertFalse(circle10_10_10_10.isPointInside(-1, 0));
			assertFalse(circle10_10_10_10.isPointInside(20, 20));
		}
		
		public function testPointInsideHitCircle_WithNegativeOrigin():void {
			var circle10_10_10_10:HitCircle = new HitCircle(10, "hit_circle", -10, -10);
			assertTrue(circle10_10_10_10.isPointInside(-5, -5));
			assertTrue(circle10_10_10_10.isPointInside(-10, 0));
			assertTrue(circle10_10_10_10.isPointInside(0, -10));
			
			assertFalse(circle10_10_10_10.isPointInside(0, 0));
			assertFalse(circle10_10_10_10.isPointInside(20, 20));
		}
	
		public function testHitCircleSymmetry():void {
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
		
		public function testSetForEntity():void {
			var entity:Entity = new Entity();
			entity.width = 128;
			entity.height = 256;
			entity.originX = 64;
			entity.originY = -32;
			
			var fittingHitCircle:HitCircle = new HitCircle().setForEntity(entity);
			assertEquals(fittingHitCircle.owner, entity);
			assertTrue(fittingHitCircle.collides(entity));
			
			var notFittingHitBox:HitCircle = new HitCircle(512, "foobar", -16, 8);
			notFittingHitBox.setForEntity(entity, false);
			
			assertEquals(notFittingHitBox.owner, entity);
		}
	}
}
