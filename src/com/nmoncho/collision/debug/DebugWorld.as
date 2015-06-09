package com.nmoncho.collision.debug {
	import net.flashpunk.CollisionConsole;
	import com.nmoncho.collision.HitBox;
	import com.nmoncho.collision.HitCircle;
	import net.flashpunk.FP;
	import net.flashpunk.World;

	/**
	 * @author developer
	 */
	public class DebugWorld extends World {
		
		public var player:Player = new Player(false);
		public var npc1:Player = new Player(true, new HitBox(48, 32, "body", 0, 0));
		public var worldHitBox:HitBox = new HitBox(100, 100, "world_hit_box", 100, 100);
		public var compoundHB1:HitBox = new HitBox(20, 20, "compound_hb_1", 300, 100);
		public var compoundHB2:HitBox = new HitBox(20, 20, "compound_hb_2", 350, 150);
		public var compositeHB:HitBox = HitBox.createHierachicalHitBox([compoundHB1, compoundHB2], false);
		
		public var compoundHB3:HitBox = new HitBox(20, 20, "compound_hb_1", 500, 300);
		public var compoundHB4:HitBox = new HitBox(30, 20, "compound_hb_2", 550, 350);
		public var compositeHC:HitCircle = HitCircle.createHierachicalHitCircle([compoundHB3, compoundHB4], false);
		
		public var center:HitBox = new HitBox(20, 20, "center", 8, 8);
		public var upperLeft:HitBox = new HitBox(15, 15, "upperLeft");
		public var upperRight:HitBox = new HitBox(15, 15, "upperRight", 20, 0);
		public var downLeft:HitBox = new HitBox(15, 15, "downLeft", 0, 20);
		public var downRight:HitBox = new HitBox(15, 15, "downRight", 20, 20);
		
		public var hHB:HitBox = HitBox.createHierachicalHitBox([center, upperLeft, upperRight, downLeft, downRight], false);
		
		public var circle_01:HitCircle = new HitCircle(20, "top", 200, 400);
		public var circle_02:HitCircle = new HitCircle(20, "left", 180, 440);
		public var circle_03:HitCircle = new HitCircle(20, "right", 222, 440);
		public var hHC:HitCircle = HitCircle.createHierachicalHitCircle([circle_01, circle_02, circle_03], false);
		
		public function DebugWorld() {
			
		}
		
		override public function begin():void {
			add(player);
			add(npc1);
			player.x = FP.width / 2;
			player.y = FP.height / 2;
			npc1.x = npc1.y = 300;
			CollisionConsole.enable({"drawChildren": true});
			CollisionConsole.instance.addDebuggableBoundingArea(compositeHB, worldHitBox, compositeHC, hHB, hHC);
			hHB.setOrigin(210, 210);
		}
		
	}

}
