package com.nmoncho.collision.tests 
{
	import asunit.errors.AssertionFailedError;
	import asunit.framework.Test;
	import asunit.framework.TestListener;
	import asunit.framework.TestResult;
	import asunit.textui.TestRunner;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author nMoncho
	 */
	public class CHTestListener implements TestListener 
	{
		private var runner:TestRunner;
		private var stage:Stage;
		private var result:TestResult;
		private var count:Number = 0;
		
		public function CHTestListener(stage:Stage, runner:TestRunner, result:TestResult) {
			this.runner = runner;
			this.stage = stage;
			this.result =  result;
		}
		
        public function run(test:Test):void {}
        public function startTest(test:Test):void {}
        public function addFailure(test:Test, t:AssertionFailedError):void {}
        public function addError(test:Test, t:Error):void {}
        public function startTestMethod(test:Test, methodName:String):void {}
        public function endTestMethod(test:Test, methodName:String):void {}
		public function endTest(test:Test):void {
			var testFoo:TestFoo = new TestFoo;
			count++;
			if (testFoo.countTestCases() == count && result.wasSuccessful()) {
				stage.removeChild(runner);
			}
		}
	}

}