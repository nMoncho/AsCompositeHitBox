package com.nmoncho.collision.tests {
	import com.nmoncho.collision.HitCircle;
	import com.nmoncho.collision.HitBox;
	import asunit.framework.TestCase;

	import com.nmoncho.collision.CollidableEntity;

	/**
	 * @author developer
	 */
	public class CollidableEntityTests extends TestCase {
		
		public static const RANDOM_TESTS:int = 10000;	
		
		public function CollidableEntityTests(testMethod:String = null) {
			super(testMethod);
		}
		
		private function testProxiedFuntionEquality(bEntity:CollidableEntity):void {
			assertEquals(bEntity.boundingArea.width, bEntity.widthCE);
			assertEquals(bEntity.boundingArea.height, bEntity.heightCE);
			assertEquals(bEntity.boundingArea.originX, bEntity.originXCE);
			assertEquals(bEntity.boundingArea.originY, bEntity.originYCE);
		}
		
		public function testConstructor_NoBoundingArea():void {
			var bEntity:CollidableEntity = new CollidableEntity(100, 100);
			assertTrue("Entity has no bounding area", bEntity.boundingArea != null);
			assertTrue("Entity has bounding area but isn't a HitBox", bEntity.boundingArea is HitBox);
			assertEquals(bEntity.boundingArea.width, 0);
			assertEquals(bEntity.boundingArea.height, 0);
			testProxiedFuntionEquality(bEntity);
		}
		
		public function testConstructor_WithHitBox():void {
			var bEntity:CollidableEntity = new CollidableEntity(100, 100, new HitBox(32, 16, "hitbox", 64, -128));
			assertTrue("Entity has no bounding area", bEntity.boundingArea != null);
			assertTrue("Entity has bounding area but isn't a HitBox", bEntity.boundingArea is HitBox);
			assertEquals(bEntity.boundingArea.width, 32);
			assertEquals(bEntity.boundingArea.height, 16);
			assertEquals(bEntity.boundingArea.originX, 64);
			assertEquals(bEntity.boundingArea.originY, -128);
			testProxiedFuntionEquality(bEntity);
		}
		
		public function testConstructor_WithHitCircle():void {
			var bEntity:CollidableEntity = new CollidableEntity(100, 100, new HitCircle(32, "hitcircle", 64, -128));
			assertTrue("Entity has no bounding area", bEntity.boundingArea != null);
			assertTrue("Entity has bounding area but isn't a HitCircle", bEntity.boundingArea is HitCircle);
			assertEquals(HitCircle(bEntity.boundingArea).radius, 32);
			assertEquals(bEntity.boundingArea.originX, 64);
			assertEquals(bEntity.boundingArea.originY, -128);
		}
		
		public function testConstructor_WithHitCircleLiteral():void {
			var bEntity:CollidableEntity = new CollidableEntity(100, 100, {radius: 32, name: "hitcircle", originX: 64, originY: -128});
			assertTrue("Entity has no bounding area", bEntity.boundingArea != null);
			assertTrue("Entity has bounding area but isn't a HitCircle", bEntity.boundingArea is HitCircle);
			assertEquals(HitCircle(bEntity.boundingArea).radius, 32);
			assertEquals(bEntity.boundingArea.originX, 64);
			assertEquals(bEntity.boundingArea.originY, -128);
			assertEquals(bEntity.boundingArea.name, "hitcircle");
		}
		
		public function testConstructor_WithHitBoxLiteral():void {
			var bEntity:CollidableEntity = new CollidableEntity(100, 100, {width: 32, height: 16, name: "hitbox", originX: 64, originY: -128});
			assertTrue("Entity has no bounding area", bEntity.boundingArea != null);
			assertTrue("Entity has bounding area but isn't a HitBox", bEntity.boundingArea is HitBox);
			assertEquals(bEntity.boundingArea.width, 32);
			assertEquals(bEntity.boundingArea.height, 16);
			assertEquals(bEntity.boundingArea.originX, 64);
			assertEquals(bEntity.boundingArea.originY, -128);
			assertEquals(bEntity.boundingArea.name, "hitbox");
			testProxiedFuntionEquality(bEntity);
		}
	}
}
