package;
import flixel.FlxSprite;
import flixel.addons.ui.FlxClickArea;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import WaveWidget.WaveInfo;


/**
 * ...
 * @author 
 */
class SigilWidget extends FlxUIGroup
{

	public var starts:Array<Bool> = [true,false,false,false,false];
	public var ends:Array<Bool> = [true,false,false,false,false];
	
	public var startsAsRadio:Bool = false;
	public var endsAsRadio:Bool = false;
	public var allAsRadio:Bool = false;
	
	public var event:String = "sigil_change";
	public var code:String = "wave_widget";
	
	public var lockExtraEnds:Bool = true;
	
	public function new(xx:Int,yy:Int,H:Float) 
	{
		super(xx, yy);
		var X = 0;
		var Y = 0;
		for (i in 0...5){
			var sigil = makeSigil(i, H);
			sigil.ID = i;
			sigil.x = X;
			var click = new FlxUIButton(X, Y, "", toggleStart.bind(i));
			click.resize(sigil.width, sigil.height);
			click.ID = -1;
			add(click);
			add(sigil);
			click.alpha = 0;
			X += Std.int(sigil.width + 1);
		}
		X = 0;
		for (i in 0...5){
			var sigil = makeSigil(i + 5, H);
			sigil.ID = i + 5;
			if (i == 0){
				Y += Std.int(sigil.height + 1);
			}
			sigil.x = X;
			sigil.y = Y;
			var click = new FlxUIButton(X, Y, "", toggleEnd.bind(i));
			click.resize(sigil.width, sigil.height);
			click.ID = -1;
			click.alpha = 0;
			X += Std.int(sigil.width + 1);
			
			if (lockExtraEnds && i > 0){
				//don't add them!
			}else{
				add(click);
				add(sigil);
			}
		}
	}
	
	public function getFirstI():Int{
		for (i in 0...10){
			if (i < 5){
				if (starts[i]) return i;
			}else{
				if (ends[i - 5]) return i;
			}
		}
		return -1;
	}
	
	public function setValues(starts:Array<Bool>, ends:Array<Bool>){
		if (starts.length != 5 && ends.length != 5) return;
		for(i in 0...5){
			toggleStart(i, starts[i]);
		}
		for (i in 0...5){
			toggleEnd(i, ends[i]);
		}
	}
	
	public function sync(info:WaveInfo){
		for (i in 0...info.starts.length){
			toggleStart(i, info.starts[i]);
		}
		for (i in 0...info.ends.length){
			toggleEnd(i, info.ends[i]);
		}
	}
	
	private function toggleStart(i:Int, ?b:Bool){
		for (j in 0...members.length){
			var member = members[j];
			if (member.ID == i && member.ID < 5){
				var spr:FlxUISprite = cast member;
				if (b == null){
					if (allAsRadio){
						turnOff(true, true);
					}
					if (startsAsRadio){
						turnOff(true, false);
					}
					starts[i] = !starts[i];
					FlxUI.event(event, this, i, [code,"start"]);
				}else{
					starts[i] = b;
				}
				spr.alpha = starts[i] ? 1.0 : 0.25;
				return;
			}
		}
	}
	
	private function toggleEnd(i:Int, ?b:Bool){
		for (j in 0...members.length){
			var member = members[j];
			if (member.ID == i + 5){
				var spr:FlxUISprite = cast member;
				
				if (b == null){
					if (allAsRadio){
						turnOff(true, true);
					}
					if (endsAsRadio){
						turnOff(false, true);
					}
					ends[i] = !ends[i];
					FlxUI.event(event, this, i, [code,"end"]);
				}else{
					ends[i] = b;
				}
				spr.alpha = ends[i] ? 1.0 : 0.25;
			}
		}
	}
	
	private function turnOff(doStarts:Bool, doEnds:Bool){
		for (j in 0...members.length){
			var member = members[j];
			var spr:FlxUISprite = cast member;
			if (spr == null) continue;
			if (doStarts && member.ID < 5){
				starts[member.ID] = false;
				spr.alpha = 0.25;
			}
			if (doEnds && member.ID >= 5){
				ends[member.ID - 5] = false;
				spr.alpha = 0.25;
			}
		}
	}
	
	private function makeSigil(i:Int,H:Float):FlxUISprite
	{
		var spr = new FlxUISprite();
		spr.loadGraphic("*assets/gfx/_hd/editor/sigils.png", true, 48, 48);
		spr.scale.set(H / spr.graphic.bitmap.height, H / spr.graphic.bitmap.height);
		spr.updateHitbox();
		spr.antialiasing = true;
		spr.animation.frameIndex = i;
		return spr;
	}
}