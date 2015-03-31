package com.nmoncho.collision 
{
	/**
	 * ...
	 * @author nMoncho
	 */
	public class Collision 
	{
		public const collides:Boolean;
		public const querier:BoundingArea;
		public const collider:BoundingArea;
		
		public function Collision(collides:Boolean, collider:BoundingArea, querier:BoundingArea) {
			this.collides = collides;
			this.collider = collider;
			this.querier = querier;
		}
		
	}

}