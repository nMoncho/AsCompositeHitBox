package com.nmoncho.collision.tests 
{
	import asunit.framework.TestSuite;
	
	/**
	 * ...
	 * @author nMoncho
	 */
	public class TestFoo extends TestSuite 
	{
		
		public function TestFoo() {
			addTest(new HitBoxTests("testPointInsideHitBox_NoOrigin"));
			addTest(new HitBoxTests("testPointInsideHitBox_WithPositiveOrigin"));
			addTest(new HitBoxTests("testPointInsideHitBox_WithNegativeOrigin"));
			addTest(new HitBoxTests("testHitBoxSymmetry"));
			addTest(new HitBoxTests("testHitBoxSameClassCollision"));
			addTest(new HitBoxTests("testHierachicalHitBox"));
			addTest(new HitBoxTests("testSetForEntity"));
			addTest(new HitBoxTests("testPointInsideHitBox_Random"));
			addTest(new HitBoxTests("testCreateHierachicalHitBox"));
			
			addTest(new HitCircleTests("testPointInsideHitCircle_Random"));
			addTest(new HitCircleTests("testPointInsideHitCircle_NoOrigin"));
			addTest(new HitCircleTests("testPointInsideHitCircle_WithPositiveOrigin"));
			addTest(new HitCircleTests("testPointInsideHitCircle_WithNegativeOrigin"));
			addTest(new HitCircleTests("testHitCircleSymmetry"));
			addTest(new HitCircleTests("testSetForEntity"));
			
			addTest(new BoundingAreaTests("testAddChild"));
			addTest(new BoundingAreaTests("testRemoveChild"));
			addTest(new BoundingAreaTests("testRemoveChildByName"));
			addTest(new BoundingAreaTests("testGetBoundingByName"));
		}

	}

}