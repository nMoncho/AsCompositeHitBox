package com.nmoncho.collision.debug {
	import com.nmoncho.collision.HitCircle;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.BoundingArea;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Input;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Entity;

	/**
	 * @author developer
	 */
	public class Player extends Entity {
		private static const VELOCITY:int = 80;
		[Embed(source = "../../../assets/swordguy.png")]
		private const SWORDGUY:Class;
		
		public var sprSwordguy:Spritemap = new Spritemap(SWORDGUY, 48, 32);
		
		public var boundingArea:BoundingArea;
		
		public var npc:Boolean;
		
		public function Player(npc:Boolean = true, boundingArea:BoundingArea = null) {
			sprSwordguy.add("stand", [0, 1, 2, 3, 4, 5], 20, true);
			sprSwordguy.add("run", [6, 7, 8, 9, 10, 11], 20, true);
			graphic = sprSwordguy;
			
			sprSwordguy.play("stand");
			
			var compoundHB1:HitBox = new HitBox(20, 20, "compound_hb_1");
			var compoundHB2:HitBox = new HitBox(20, 20, "compound_hb_2", -20, -20);
			var compositeHB:HitBox = HitBox.createHierachicalHitBox([compoundHB1, compoundHB2]);
			this.boundingArea = boundingArea != null ? boundingArea : compositeHB;
			//this.boundingArea = boundingArea != null ? boundingArea : new HitCircle(24, "hit_circle", -24, -16, this);
			this.boundingArea.owner = this;
			this.npc = npc;
			width = 48;
			height = 32;
		}

		override public function update() : void {
			var xVel:Number = 0, yVel:Number = 0;
			if (!npc) {
				if (Input.check(Key.UP)) {
				yVel = -VELOCITY;
				}
				if (Input.check(Key.DOWN)) {
					yVel = VELOCITY;
				}
				if (Input.check(Key.LEFT)) {
					xVel = -VELOCITY;
				}
				if (Input.check(Key.RIGHT)) {
					xVel = VELOCITY;
				}
			}
			if (xVel != 0 || yVel != 0) {
				sprSwordguy.flipped = (xVel < 0);
				x += xVel * FP.elapsed;
				y += yVel * FP.elapsed;
				sprSwordguy.play("run");
			} else {
				sprSwordguy.play("stand");
			}
		}
		
	}

}
