package com.nmoncho.collision.tests 
{
	import avmplus.getQualifiedClassName;
	import net.flashpunk.Entity;
	import com.nmoncho.collision.HitCircle;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.BoundingArea;
	import asunit.framework.TestCase;
	import net.flashpunk.CollisionConsole;
	import net.flashpunk.FP;
	/**
	 * ...
	 * @author ...
	 */
	public class ConsoleTests extends TestCase
	{
		public static const RANDOM_TESTS:int = 10000;	
		private static const SCREEN_WIDTH:int = 800, SCREEN_HEIGHT:int = 600;
		
		private var fooAcc:Function;
		private var baAcc:Function;
		
		public function ConsoleTests(testMethod:String = null) {
			super(testMethod);
		}
		
		override protected function setUp():void {
			super.setUp();
			FP.camera.x = 0;
			FP.camera.y = 0;
			FP.width = SCREEN_WIDTH;
			FP.height = SCREEN_HEIGHT;
			ConsoleProxy.resetConsole(); // Clean console for every test.
			
			fooAcc = CollisionConsole.createPropertyAccessor("foo");
			baAcc = CollisionConsole.createPropertyAccessor("boundingArea");
		}
		
		public function testAddDebuggableBoundingArea():void {
			var inst:ConsoleProxy = ConsoleProxy.getInstance();
			assertTrue(inst.getDebuggableBoundingAreas().length == 0);
			inst.addDebuggableBoundingArea(new BoundingArea, new HitBox, new HitCircle);
			assertTrue(inst.getDebuggableBoundingAreas().length == 3);
		}
		
		public function testRemoveDebuggableBoundingArea():void {
			var inst:ConsoleProxy = ConsoleProxy.getInstance();
			var ba:BoundingArea = new BoundingArea();
			var hb:HitBox = new HitBox();
			var hc:HitCircle = new HitCircle();
			assertTrue(inst.getDebuggableBoundingAreas().length == 0);
			inst.addDebuggableBoundingArea(ba, hb, hc);
			assertTrue(inst.getDebuggableBoundingAreas().length == 3);
			inst.removeDebuggableBoundingArea(ba);
			assertTrue(inst.getDebuggableBoundingAreas().length == 2);
			inst.removeDebuggableBoundingArea(hb, hc);
			assertTrue(inst.getDebuggableBoundingAreas().length == 0);
		}
		
		public function testCreatePropertyAccessor():void {
			const testEntity:TestEntity = new TestEntity();
			assertEquals(testEntity.foo, fooAcc.call(null, testEntity));
			assertEquals(testEntity.boundingArea, baAcc.call(null, testEntity));
		}
		
		public function testCreatePropertyAccessor_Undefined():void {
			const entity:Entity = new Entity();
			assertNull(fooAcc.call(null, entity));
			assertNull(baAcc.call(null, entity));
		}
		
		public function testGetOptions():void {
			var options:Object = CollisionConsole.instance.options; // will check on default options
			assertNotNull(options[CollisionConsole.RENDERERS_OPTION]);
			assertNotNull(options[CollisionConsole.ACCESSORS_OPTION]);
			assertNotNull(options[CollisionConsole.DRAW_CHILDREN_OPTION]);
		}
		
		public function testSetOptions():void {
			const renderProp:String = CollisionConsole.RENDERERS_OPTION,
				accessorProp:String = CollisionConsole.ACCESSORS_OPTION,
				drawChildrenProp:String = CollisionConsole.DRAW_CHILDREN_OPTION,
				hitboxClassName:String = getQualifiedClassName(HitBox);
			var options:Object = {"renderers": {"com.nmoncho.collision::HitBox": function():void{}},
				"accessors": ["foo"],
				"drawChildren": true};
			CollisionConsole.instance.options = options;
			var consoleOptions:Object = CollisionConsole.instance.options;
			assertEquals(options[accessorProp].length + 1, consoleOptions[accessorProp].length); // +1 'cause of default accessor
			assertEquals(options[drawChildrenProp], consoleOptions[drawChildrenProp]);
			assertEquals(options[renderProp][hitboxClassName], consoleOptions[renderProp][hitboxClassName]);
		}
	}
	
}

import net.flashpunk.CollisionConsole;

class ConsoleProxy extends CollisionConsole { // What an ugly proxy class
	
	public static function getInstance():ConsoleProxy {
		if (_instance == null) {
			_instance = new ConsoleProxy();
		}
		
		return _instance as ConsoleProxy;
	}
	
	public static function resetConsole():void {
		_instance = null;		
	}
	
	public function getDebuggableBoundingAreas():Array {
		return ConsoleProxy(_instance).debuggableBoundingAreas;
	}
}