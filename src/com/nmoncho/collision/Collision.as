package com.nmoncho.collision 
{
	import net.flashpunk.Entity;
	/**
	 * Collision object, representing a collision (d'uh) whether the objects really collides.
	 * Regretfully AS3 doesn't provide generics to implement different classes based on the
	 * same parent class.
	 * @author nMoncho
	 */
	public class Collision 
	{
		/**
		 * Defines if the involving objects really collides.
		 */
		public var collides:Boolean;
		
		/**
		 * Object that issued the query (although it can be a bounding area child).
		 * For example: player.collides(hitbox), then this would be player.
		 */
		public var querier:Object;
		
		/**
		 * Object that collides with querier.
		 * For example: player.collides(hitbox), then this would be hitbox.
		 */
		public var collider:Object;
		
		/**
		 * Collision constructor.
		 * @param	collides whether the objects involed collide or not.
		 * @param	querier the object that is checking the collision.
		 * @param	collider the object that collides with the querier.
		 */
		public function Collision(collides:Boolean, querier:Object, collider:Object) {
			this.collides = collides;
			this.collider = collider;
			this.querier = querier;
		}
		
		/**
		 * Gets Querier's Owner (entity) if the querier is a Bounding Area.
		 * @return owner if querier is Bouding Area, undefined otherwise.
		 */
		public function get querierOwner():Entity {
			return getOwner(querier);
		}
		
		/**
		 * Gets Collider's Owner (entity) if the querier is a Bounding Area.
		 * @return owner if collider is Bouding Area, undefined otherwise.
		 */
		public function get colliderOwner():Entity {
			return getOwner(collider);
		}
		
		/**
		 * Helper function to get owner based on parameter.
		 * @param	obj object to get owner from.
		 * @return owner if obj is Bouding Area, undefined otherwise.
		 */
		private function getOwner(obj:Object):Entity {
			return (obj is BoundingArea) ? BoundingArea(obj).owner : undefined;
		}
	}

}