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
			addTest(new HitBoxTests("TestPointInsideHitBox"));
			addTest(new HitBoxTests("TestHitBoxSymmetry"));
			addTest(new HitBoxTests("TestHierachicalHitBox"));
			
			addTest(new HitCircleTests("TestPointInsideHitCircle"));
			addTest(new HitCircleTests("TestHitCircleSymmetry"));
		}

	}

}