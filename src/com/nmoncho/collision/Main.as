package com.nmoncho.collision {
	import asunit.framework.TestResult;
	import com.nmoncho.collision.tests.CHTestListener;
	import asunit.textui.TestRunner;
	import com.nmoncho.collision.debug.DebugWorld;
	import com.nmoncho.collision.tests.TestFoo;
	import net.flashpunk.FP;
	import net.flashpunk.Engine;

	/**
	 * @author developer
	 */
	 [SWF(width="800", height="600")]
	public class Main extends Engine {
		
		public function Main() {
			super(800, 600, 60, false);
			//CONFIG::DEBUG {
			CONFIG::debug {
				//BoundingAreaDebugger.enableDebuggin();
				runTests();
			}
		}

		override public function init():void {
			trace("FlashPunk has started successfully!");
			var world:DebugWorld = new DebugWorld();
			FP.world = world;
		}
		
		private function runTests():void {
			var unitTests:TestRunner = new TestRunner();
			stage.addChild(unitTests);
			var testResults:TestResult = unitTests.start(TestFoo, null, TestRunner.SHOW_TRACE);
			testResults.addListener(new CHTestListener(stage, unitTests, testResults));
		}

		
	}
}
