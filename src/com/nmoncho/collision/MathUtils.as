package com.nmoncho.collision {
	
	/**
	 * Math utils not found on native Math object.
	 * @author nMoncho
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

		/**
		 * Calculates the length between two 2D points. (Pythagoras' theorem).
		 * @param	x0 x coordinate of first point.
		 * @param	y0 y coordinate of first point.
		 * @param	x1 x coordinate of second point.
		 * @param	y1 y coordinate of second point.
		 * @return length between points.
		 */
		public static function length(x0:Number, y0:Number, x1:Number, y1:Number):Number {
			return Math.sqrt(sq(x1 - x0) + sq(y1 - y0));
		}
	}
}
