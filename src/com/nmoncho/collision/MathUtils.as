package com.nmoncho.collision {
	/**
	 * @author developer
	 */
	public class MathUtils {

		/**
		 * Calculates the squared value of a number.
		 * @param val number to be squared.
		 * @return computed square.
		 */
		public static function sq(val:Number):Number {
			return val * val;
		}
		
		public static function length(x0:Number, y0:Number, x1:Number, y1:Number):Number {
			return Math.sqrt(sq(x1 - x0) + sq(y1 - y0));
		}
	}
}
