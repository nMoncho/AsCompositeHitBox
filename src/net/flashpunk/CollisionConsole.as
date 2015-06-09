package net.flashpunk {
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import flash.display.Graphics;
	import com.nmoncho.collision.HitCircle;
	import flash.utils.Dictionary;
	import com.nmoncho.collision.BoundingArea;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.CollidableEntity;
	import flash.display.Sprite;
	import net.flashpunk.FP;
	import net.flashpunk.debug.Console;

	/**
	 * @author nMoncho
	 */
	public class CollisionConsole extends Console {
		
		public static const RENDERERS_OPTION:String = "renderers", 
							ACCESSORS_OPTION:String = "accessors",
							DRAW_CHILDREN_OPTION:String = "drawChildren";
							
		private static const NOT_COLLIDES_COLOR:Number = 0x00ff00, // TODO make this colors configurables. 
							COLLIDES_COLOR:Number = 0xff0000;
		
		protected static var _instance:CollisionConsole;
		
		private var backBuffer:Sprite = new Sprite;
		/** Should render bounding area's children on screen. */
		public var drawBoundingAreaChildren:Boolean = false;
		// Entity lists.
		private var entities:Array = [];
		private var debugBoundingAreas:Array = [];
		private var boundingAreas:Array = [];
		private var accessors:Array = [];
		private const cameraHitBox:HitBox = new HitBox(0, 0, "camera_hitbox");
		private const renderers:Dictionary = new Dictionary();
		private var _enabled:Boolean = false;
		
		public function CollisionConsole() {
			accessors.push(createPropertyAccessor("boundingArea"));
			addBoundingAreaRenderer(HitBox, renderHitBox);
			addBoundingAreaRenderer(HitCircle, renderHitCircle);
		}
		
		/**
		 * Adds a bounding area to be debugged.
		 * This UGLY method (until I figure some other thing out) is intended for bounding areas that aren't
		 * attached to any entity.
		 * @param	boundingArea bounding area to debug.
		 */
		public function addDebuggableBoundingArea(...boundingAreas):void {
			for each(var ba:BoundingArea in boundingAreas) {
				debugBoundingAreas.push(ba); // Should check if already in it.
			}
		}
		
		/**
		 * Removes a bounding area debugged.
		 * This UGLY method (until I figure some other thing out) is intended for bounding areas that aren't
		 * attached to any entity.
		 * @param	boundingArea bounding area to remove from debug.
		 */
		public function removeDebuggableBoundingArea(...boundingAreas):void {
			var idx:int;
			for each(var ba:BoundingArea in boundingAreas) {
				idx = debugBoundingAreas.indexOf(ba);
				if (idx >= 0) {
					debugBoundingAreas.splice(idx, 1);
				}
			}
		}
		
		override public function update():void {
			var g:Graphics;
			super.update();
			
			// update camera's hitbox with new info.
			cameraHitBox.setHitbox(FP.width, FP.height, FP.camera.x, FP.camera.y);
			updateBoundingAreas(FP.world.count != entities.length);
			
			g = backBuffer.graphics;
			g.clear();
			renderBoundingAreas(g, boundingAreas);
			renderBoundingAreas(g, debugBoundingAreas);
		}
		
		/**
		 * Fetch bounding areas from on screen entities and objects.
		 * @param	fetchList true if should fetch entities from FP.world, false otherwise.
		 */
		private function updateBoundingAreas(fetchList:Boolean = true):void {
			var entityBA:BoundingArea = null;
			// Update the list of Entities on screen.
			if (fetchList) {
				entities.length = 0;
				FP.world.getAll(entities);
			}
			boundingAreas.length = 0;
			for each (var e:Entity in entities) {
				entityBA = null;
				if (e is CollidableEntity) {
					entityBA = CollidableEntity(e).boundingArea;
				} else { // Don't consider normal entities, as the will get render by parent class
					for each (var func:Function in accessors) {
						entityBA = func.call(null, e);
						if (entityBA) {break;}
					}
				}
				if (cameraHitBox.collides(entityBA)) { // Don't debug entities that are outside of viewport
					boundingAreas.push(entityBA);
				}
			}
		}
		
		/**
		 * Render bounding areas.
		 * Uses Console renderers.
		 */
		private function renderBoundingAreas(g:Graphics, toRender:Array):void {
			var boundingArea:BoundingArea;
			var className:String;
			var fn:Function;
			for each (boundingArea in toRender) {
				className = getQualifiedClassName(boundingArea);
				fn = renderers[className];
				fn.call(null, g, boundingArea);
				if (drawBoundingAreaChildren && boundingArea.children) {
					renderBoundingAreas(g, boundingArea.children);
				}
			}
		}

		/**
		 * Singleton instance.
		 * @return singleton instance.
		 */
		public static function get instance():CollisionConsole {
			if (!_instance) {
				_instance = new CollisionConsole;
			}
			return _instance;
		}
		
		/**
		 * Creates a public property accessor function.
		 * Use this function to create accessor, so the console can know how to retrieve your
		 * bounding areas from entities.
		 * This doesn't restrict you from defining different property names for different classes, you can have multiple accessors.
		 * @param property name of the property to look for.
		 * @return accessor function.
		 */
		public static function createPropertyAccessor(property:String):Function {
			return function(val:Entity):BoundingArea {
				return val.hasOwnProperty(property) && val[property] is BoundingArea ? 
					val[property] : null; 
			};
		}
		
		/**
		 * Enables CollisionConsole.
		 * Call this method instead of the normal FP.console.enable();
		 */
		public static function enable(options:Object = null):CollisionConsole {
			if (instance._enabled) {
				return _instance;
			}
			FP._console = instance;
			FP.engine.addChild(instance.backBuffer);
			instance.options = options;
			instance.enable();
			instance._enabled = true;
			return _instance;
		}
		
		/**
		 * Set options to the console.
		 * The options objects must be of the type:
		 * {"renderers": // renderers for BoundingAreas, must be an object where each Property is className : rendererFunction
		 *	 {"org.class.name::Foo" : fooRendererFunction,
		 *    "org.class.name::Bar" : barRendererFunction}}
		 *	"accessors": // accessors for BoundingAreas, array of either functions or strings (must resolve to public property name)
		 *	 ["boundingArea", "foo", "bar", function(e:Entity){}]};
		 * @param	options options object.
		 */
		public function set options(options:Object):void {
			var clazz:Class;
			var fn:Function;
			if (!options) return;
			for (var name:String in options) {
				switch (name) {
					case RENDERERS_OPTION: {
						for (var className:String in options[RENDERERS_OPTION]) {
							clazz = Class(getDefinitionByName(className));
							if (options[RENDERERS_OPTION][className] is Function) {
								addBoundingAreaRenderer(clazz, options[RENDERERS_OPTION][className]);
							}
						}
						break;
					}
					case ACCESSORS_OPTION: {
						for each (var accessor:Object in options[ACCESSORS_OPTION]) {
							if (accessor is Function) {
								addDebuggableAccessor(Function(accessor));
							} else if (accessor is String) {
								addDebuggableAccessor(createPropertyAccessor(String(accessor)));
							}
						}
						break;
					}
					case DRAW_CHILDREN_OPTION: {
						drawBoundingAreaChildren = Boolean(options[DRAW_CHILDREN_OPTION]);
						break;
					}
					default: trace("Unrecognized property name ", name);
				}
			}
		}
		
		/**
		 * Returns the current options object.
		 * Creates a new copy of options object every time it gets called.
		 */
		public function get options():Object {
			var options:Object = new Object();
			options[DRAW_CHILDREN_OPTION] = drawBoundingAreaChildren;
			options[ACCESSORS_OPTION] = accessors.concat(); // copy array
			options[RENDERERS_OPTION] = {};
			for (var className:String in renderers) {
			 	options[RENDERERS_OPTION][className] = renderers[className];
			}
			return options;
		}
	
	    /**
	     * Adds an accessor to be applied to FP entities list.
	     * You should provide a way to access the bounding area of your entities.
	     * The accessors are executed in order, stopping at finding the first not-null object.
	     * An accessor function should expect a single arg, the entity to be checked, and return either a BoundingArea or null.
	     * Side-effect free accessor functions please.
	     */
	    public function addDebuggableAccessor(accessor:Function):void {
			accessors.push(accessor);
	    }
	
	    /**
	     * Removes a accessor that is applied to FP entities list.
	     */
	    public function removeDebuggableAccessor(accessor:Function):void {
			var accessorIdx:int = accessors.indexOf(accessor);
			if (accessorIdx >= 0) {
				accessors.splice(accessorIdx, 1);	
			}
	    }
		
		/**
		 * Adds or overrides a BoundingArea renderer.
		 * The renderer function must be like:
		 * function(g:Graphics, boundingSubClass:BoundingAreaSubClass, collides:Boolean) {}
		 * @param	clazz type of the BoundingArea to render.
		 * @param	fn renderer function.
		 */
		public function addBoundingAreaRenderer(clazz:Class, fn:Function):void {
			var cl:String = getQualifiedClassName(clazz);
			renderers[cl] = fn;
		}
		
		/**
		 * Determines whether the console is enabled or not. 
		 */
		public function get enabled():Boolean {
			return _enabled;
		}
		
		/**
		 * Accessor function for testing purposes. 
		 */
		protected function get debuggableBoundingAreas():Array {
			return debugBoundingAreas;
		}
		
		/**
		 * Returns the sprite used to draw debug information.
		 * Intended for extension. 
		 */
		protected function get debugSprite():Sprite {
			return backBuffer;
		}
		
		private static function renderHitBox(g:Graphics, box:HitBox, collides:Boolean = false):void {
			var sx:Number = FP.screen.scaleX * FP.screen.scale,
				sy:Number = FP.screen.scaleY * FP.screen.scale;
			g.lineStyle(1, collides ? COLLIDES_COLOR : NOT_COLLIDES_COLOR);
			g.drawRect((box.x - FP.camera.x) * sx, (box.y - FP.camera.y) * sy, box.width * sx, box.height * sy);
		}
		
		private static function renderHitCircle(g:Graphics, circle:HitCircle, collides:Boolean = false):void {
			var sx:Number = FP.screen.scaleX * FP.screen.scale,
				sy:Number = FP.screen.scaleY * FP.screen.scale;
			g.lineStyle(1, collides ? COLLIDES_COLOR : NOT_COLLIDES_COLOR);
			g.drawCircle((circle.x - FP.camera.x) * sx, (circle.y - FP.camera.y) * sy, circle.radius * sx);
			g.drawRect(circle.x, circle.y, 2, 2);
		}
	}
	
}
