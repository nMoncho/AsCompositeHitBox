package com.nmoncho.collision.tests 
{
	import net.flashpunk.Entity;
	import asunit.framework.TestCase;
	import com.nmoncho.collision.HitBox;
	
	/**
	 * ...
	 * @author nMoncho
	 */
	public class HitBoxTests extends TestCase 
	{
		public static const RANDOM_TESTS:int = 10000;
		
		public function HitBoxTests(testMethod:String = null) {
			super(testMethod);
		}
		
		public function testPointInsideHitBox_Random():void {
			var box0_0_10_10:HitBox = new HitBox(10, 10);
			var box5_5_10_10:HitBox = new HitBox(10, 10, "hitbox", 5, 5);
			var box_5__5_10_10:HitBox = new HitBox(10, 10, "hitbox", -5, -5);
			
			testPointInsideHitBox_RandomCheck(box0_0_10_10);
			testPointInsideHitBox_RandomCheck(box5_5_10_10);
			testPointInsideHitBox_RandomCheck(box_5__5_10_10);
		}
		
		private function testPointInsideHitBox_RandomCheck(hb:HitBox):void {
			var i:int;
			var x:Number, y:Number;
			for (i = 0; i < RANDOM_TESTS; i++) {
				x = Math.random() * hb.width + hb.left;
				y = Math.random() * hb.height + hb.top;
				assertTrue(hb.isPointInside(x, y));
			}
		}
		
		public function testPointInsideHitBox_NoOrigin():void {
			var box0_0_10_10:HitBox = new HitBox(10, 10);
			assertTrue(box0_0_10_10.isPointInside(5, 5));
			assertTrue(box0_0_10_10.isPointInside(10, 10));
			assertTrue(box0_0_10_10.isPointInside(0, 0));
			assertFalse(box0_0_10_10.isPointInside(11, 11));
			assertFalse(box0_0_10_10.isPointInside(5, 11));
			assertFalse(box0_0_10_10.isPointInside(11, 5));
		}
		
		public function testPointInsideHitBox_WithPositiveOrigin():void {
			var box5_5_10_10:HitBox = new HitBox(10, 10, "hitbox", 5, 5);
			assertTrue(box5_5_10_10.isPointInside(5, 5));
			assertTrue(box5_5_10_10.isPointInside(10, 10));
			assertTrue(box5_5_10_10.isPointInside(15, 15));
			assertFalse(box5_5_10_10.isPointInside(16, 16));
			assertFalse(box5_5_10_10.isPointInside(5, 16));
			assertFalse(box5_5_10_10.isPointInside(16, 5));
		}
		
		public function testPointInsideHitBox_WithNegativeOrigin():void {
			var box5_5_10_10:HitBox = new HitBox(10, 10, "hitbox", -5, -5);
			assertTrue(box5_5_10_10.isPointInside(0, 0));
			assertTrue(box5_5_10_10.isPointInside(-5, -5));
			assertTrue(box5_5_10_10.isPointInside(5, 5));
			assertFalse(box5_5_10_10.isPointInside(10, 10));
			assertFalse(box5_5_10_10.isPointInside(-10, -10));
			assertFalse(box5_5_10_10.isPointInside(5, 16));
			assertFalse(box5_5_10_10.isPointInside(16, 5));
		}
		
		public function testHitBoxSymmetry():void {
			var hitboxes:Array = createHierachicalHitBox().children;
			var hb1:HitBox;
			while (hitboxes.length > 1) {
				hb1 = HitBox(hitboxes.shift());
				for each (var hb2:HitBox in hitboxes) {
					testSymmetry(hb1, hb2);
				}
			}
		}
		
		private function testSymmetry(hb1:HitBox, hb2:HitBox):void {
			assertEquals(hb1.collides(hb2) != null, hb2.collides(hb1) != null);	
		}
		
		public function testHitBoxSameClassCollision():void {
			var hierachical:HitBox = createHierachicalHitBox();
			var center:HitBox = HitBox(hierachical.getBoundingByName("center"));
			trace("-> " + center.x);
			hierachical.removeChild(center);
			trace("-> " + center.x);
			var cornerHitBoxes:Array = hierachical.children;
			// All Collides
			cornerHitBoxes.forEach(function(val:HitBox, idx:int, a:Array):void {
				assertTrue(val + " don't collides with " + center, center.collides(val));
			});
			// Nothing collides
			cornerHitBoxes.forEach(function(val:HitBox, idx:int, arr:Array):void {
				for (var i:int = idx + 1; i < arr.length; i++) {
					assertFalse(val + " collided with " + arr[i], val.collides(arr[i]));	
				}
			});
		}
		
		public function testHierachicalHitBox():void {
			var box0_0_10_10:HitBox = new HitBox(10, 10, "hb1");
			var box5_5_10_10:HitBox = new HitBox(10, 10, "hb2", -5, -5);
			var hb:HitBox = HitBox.createHierachicalHitBox([box0_0_10_10, box5_5_10_10]);
			assertTrue(hb.children.indexOf(box0_0_10_10) < hb.children.indexOf(box5_5_10_10));
		}
		
		public function testSetForEntity():void {
			var entity:Entity = new Entity();
			entity.width = 128;
			entity.height = 256;
			entity.originX = 64;
			entity.originY = -32;
			
			var fittingHitBox:HitBox = new HitBox().setForEntity(entity);
			assertEquals(fittingHitBox.owner, entity);
			assertEquals(fittingHitBox.width, entity.width);
			assertEquals(fittingHitBox.height, entity.height);
			assertEquals(fittingHitBox.originX, entity.originX);
			assertEquals(fittingHitBox.originY, entity.originY);
			
			var notFittingHitBox:HitBox = new HitBox();
			notFittingHitBox.width = 512;
			notFittingHitBox.height = 1024;
			notFittingHitBox.setOrigin(-16, 8);
			notFittingHitBox.setForEntity(entity, false);
			
			assertEquals(notFittingHitBox.owner, entity);
			assertFalse(notFittingHitBox.width === entity.width);
			assertFalse(notFittingHitBox.height === entity.height);
			assertFalse(notFittingHitBox.originX === entity.originX);
			assertFalse(notFittingHitBox.originY === entity.originY);
		}
		
		private function createHierachicalHitBox():HitBox {
			var center:HitBox = new HitBox(20, 20, "center", 8, 8);
			var upperLeft:HitBox = new HitBox(15, 15, "upperLeft");
			var upperRight:HitBox = new HitBox(15, 15, "upperRight", 20, 0);
			var downLeft:HitBox = new HitBox(15, 15, "downLeft", 0, 20);
			var downRight:HitBox = new HitBox(15, 15, "downRight", 20, 20);
			
			return HitBox.createHierachicalHitBox([center, upperLeft, upperRight, downLeft, downRight], false);
		}
		
		public function testCreateHierachicalHitBox():void {
			var hHB:HitBox = createHierachicalHitBox();
			var hb:HitBox = new HitBox(10, 10);
			// test simple and symmetric
			assertTrue(hHB.collides(hb));
			assertTrue(hb.collides(hHB));
			
			testHierachicalHitBox_collidesChildren(hHB);
			// move and re test.
			hHB.setOrigin(200, 200);
			// random move and re test.
			testHierachicalHitBox_collidesChildren(hHB);
			for (var i:int = 0; i < RANDOM_TESTS; i++) {
				hHB.setOrigin(Math.random() * 400 - 200, Math.random() * 400 - 200);
				testHierachicalHitBox_collidesChildren(hHB);
			}
		}
		
		private function testHierachicalHitBox_collidesChildren(hierachicalHB:HitBox) : void {
			for each (var hb:HitBox in hierachicalHB.children) {
				assertTrue(hierachicalHB.collides(hb));
			}
		}
	}

}