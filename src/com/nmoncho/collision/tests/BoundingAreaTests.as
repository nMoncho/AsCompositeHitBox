package com.nmoncho.collision.tests {
	import com.nmoncho.collision.BoundingArea;
	import net.flashpunk.Entity;
	import com.nmoncho.collision.HitBox;
	import asunit.framework.TestCase;
	
	/**
	 * @author developer
	 */
	public class BoundingAreaTests extends TestCase 
	{
		public static const RANDOM_TESTS:int = 10000;	
		
		public function BoundingAreaTests(testMethod:String = null) {
			super(testMethod);
		}
		
		private function createHierachicalHitBox():HitBox {
			var entity:Entity = new Entity();
			var parent:HitBox = new HitBox(10, 10, "parent", 30, 20, entity);
			var child01:HitBox = new HitBox(5, 10, "child_01", 5, 5);
			var child02:HitBox = new HitBox(20, 5, "child_02", 30, 10);
			var child03:HitBox = new HitBox(20, 5, "child_03", 30, 10);
			
			parent.addChild(child01).addChild(child02).addChild(child03);
			return parent;
		}
		
		public function testAddChild() : void {
			var entity:Entity = new Entity();
			var parent:HitBox = new HitBox(10, 10, "parent", 30, 20, entity);
			var child01:HitBox = new HitBox(5, 10, "child_01", 5, 5);
			var child02:HitBox = new HitBox(20, 5, "child_02", 30, 10);
			var child03:HitBox = new HitBox(20, 5, "child_03", 30, 10);
			var child04:HitBox = new HitBox(32, 22, "child_01", 4, 1);
			
			parent.addChild(child01);
			checkParenthood(parent, child01);
			parent.addChild(child02);
			checkParenthood(parent, child02);
			checkParenthood(parent, child01);
			parent.addChild(child03);
			checkParenthood(parent, child03);
			checkParenthood(parent, child02);
			checkParenthood(parent, child01);
			assertThrows(Error, function():void {
				parent.addChild(child04);	
			});
		}
		
		public function testRemoveChild() : void {
			var entity:Entity = new Entity();
			var parent:HitBox = new HitBox(10, 10, "parent", 30, 20, entity);
			var child01:HitBox = new HitBox(5, 10, "child_01", 5, 5);
			var child02:HitBox = new HitBox(20, 5, "child_02", 30, 10);
			var child03:HitBox = new HitBox(20, 5, "child_03", 30, 10);
			
			parent.addChild(child01);
			parent.addChild(child02);
			parent.addChild(child03);
			checkParenthood(parent, child03);
			checkParenthood(parent, child02);
			checkParenthood(parent, child01);
			
			assertEquals(child01, parent.removeChild(child01));
			checkUnParenthood(parent, child01);
			checkParenthood(parent, child03);
			checkParenthood(parent, child02);
			assertEquals(child02, parent.removeChild(child02));
			checkUnParenthood(parent, child02);
			checkParenthood(parent, child03);
			assertEquals(child03, parent.removeChild(child03));
			checkUnParenthood(parent, child03);
		}
		
		public function testRemoveChildByName() : void {
			var entity:Entity = new Entity();
			var parent:HitBox = new HitBox(10, 10, "parent", 30, 20, entity);
			var child01:HitBox = new HitBox(5, 10, "child_01", 5, 5);
			var child02:HitBox = new HitBox(20, 5, "child_02", 30, 10);
			var child03:HitBox = new HitBox(20, 5, "child_03", 30, 10);
			
			parent.addChild(child01);
			parent.addChild(child02);
			parent.addChild(child03);
			checkParenthood(parent, child03);
			checkParenthood(parent, child02);
			checkParenthood(parent, child01);

			assertEquals(child01, parent.removeChildByName("child_01"));
			checkUnParenthood(parent, child01);
			checkParenthood(parent, child03);
			checkParenthood(parent, child02);
			assertEquals(child02, parent.removeChildByName("child_02"));
			checkUnParenthood(parent, child02);
			checkParenthood(parent, child03);
			assertEquals(child03, parent.removeChildByName("child_03"));
			checkUnParenthood(parent, child03);
		}
		
		private function checkParenthood(parent:BoundingArea, child:BoundingArea) : void {
			assertTrue(child.parent == parent);
			assertTrue(child.owner == parent.owner);
			assertTrue(parent.children.indexOf(child) >= 0);
			assertTrue(parent.getBoundingByName(child.name) == child);
		}
		
		private function checkUnParenthood(parent:BoundingArea, child:BoundingArea) : void {
			assertTrue(child + " is child of " + parent, child.parent != parent);
			assertTrue(child + " has parent's owner " + parent.owner, child.owner != parent.owner);
			assertTrue(child + " is child (in-array) of " + parent, parent.children.indexOf(child) < 0);
			assertTrue(child + " is child (in-name) of " + parent, parent.getBoundingByName(child.name) != child);
		}
		
		public function testGetBoundingByName() : void {
			var entity:Entity = new Entity();
			var parent:HitBox = new HitBox(10, 10, "parent", 30, 20, entity);
			var child01:HitBox = new HitBox(5, 10, "child_01", 5, 5);
			var child02:HitBox = new HitBox(20, 5, "child_02", 30, 10);
			var child03:HitBox = new HitBox(20, 5, "child_03", 30, 10);
			
			parent.addChild(child01).addChild(child02).addChild(child03);
			assertEquals(parent.getBoundingByName("child_01"), child01);
			assertEquals(parent.getBoundingByName("child_02"), child02);
			assertEquals(parent.getBoundingByName("child_03"), child03);
			assertNull(parent.getBoundingByName("child_04"));
		}
	}
}
