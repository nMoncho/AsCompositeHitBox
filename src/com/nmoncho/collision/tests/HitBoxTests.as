package com.nmoncho.collision.tests 
{
	import asunit.framework.TestCase;
	import com.nmoncho.collision.HitBox;
	
	/**
	 * ...
	 * @author nMoncho
	 */
	public class HitBoxTests extends TestCase 
	{
		
		public function HitBoxTests(testMethod:String = null) {
			super(testMethod);
		}
		
		public function TestPointInsideHitBox():void {
			var box0_0_10_10:HitBox = new HitBox(10, 10);
			assertTrue(box0_0_10_10.isPointInside(5, 5));
			assertTrue(box0_0_10_10.isPointInside(10, 10));
			assertTrue(box0_0_10_10.isPointInside(0, 0));
			assertFalse(box0_0_10_10.isPointInside(11, 11));
			assertFalse(box0_0_10_10.isPointInside(5, 11));
			assertFalse(box0_0_10_10.isPointInside(11, 5));
			
			var box5_5_10_10:HitBox = new HitBox(10, 10);
			box5_5_10_10.setOrigin(5, 5);
			assertTrue(box5_5_10_10.isPointInside(5, 5));
			assertTrue(box5_5_10_10.isPointInside(10, 10));
			assertTrue(box5_5_10_10.isPointInside(15, 15));
			assertFalse(box5_5_10_10.isPointInside(16, 16));
			assertFalse(box0_0_10_10.isPointInside(5, 11));
			assertFalse(box0_0_10_10.isPointInside(11, 5));
		}
		
		public function TestHitBoxSymmetry():void {
			var box0_0_10_10:HitBox = new HitBox(10, 10);
			var box5_5_10_10:HitBox = new HitBox(10, 10);
			box5_5_10_10.setOrigin(5, 5);
			var box15_15_10_10:HitBox = new HitBox(10, 10);
			box15_15_10_10.setOrigin(15, 15);
			assertNotNull(box0_0_10_10.collides(box5_5_10_10));
			assertNotNull(box5_5_10_10.collides(box0_0_10_10));
			
			assertNotNull(box5_5_10_10.collides(box15_15_10_10));
			assertNotNull(box15_15_10_10.collides(box5_5_10_10));
			
			assertNull(box0_0_10_10.collides(box15_15_10_10));
			assertNull(box15_15_10_10.collides(box0_0_10_10));
		}
		
		public function TestHierachicalHitBox():void {
			var box0_0_10_10:HitBox = new HitBox(10, 10, "hb1");
			var box5_5_10_10:HitBox = new HitBox(10, 10, "hb2", -5, -5);
			var hb:HitBox = HitBox.createHierachicalHitBox([box0_0_10_10, box5_5_10_10]);
			assertTrue(hb.children.indexOf(box0_0_10_10) < hb.children.indexOf(box5_5_10_10));
		}
	}

}