package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxSound;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Volume Settings'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				#if android
				removeVirtualPad();
				#end
                                SUtil.ActWrite("Logged in Note State");
				openSubState(new options.NotesSubState());
			case 'Controls':
				#if android
				removeVirtualPad();
				#end
                                SUtil.ActWrite("Logged in Controls State");
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				#if android
				removeVirtualPad();
				#end
                                SUtil.ActWrite("Logged in Graphics State");
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				#if android
				removeVirtualPad();
				#end
                                SUtil.ActWrite("Logged in VisualsUI State");
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.GameplaySettingsSubState());
                                SUtil.ActWrite("Logged in Gameplay State");
			case 'Adjust Delay and Combo':
                                SUtil.ActWrite("Logged in Delay and Combo State");
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
                        case 'Volume Settings':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.VolumeOptionsSubState());
                                SUtil.ActWrite("Logged in Volume State");
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end
                
    FlxG.sound.playMusic(Paths.music('title'), 1);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);

		#if android
		var tipText:FlxText = new FlxText(10, 12, 0, 'Press C to Go In Android Controls Menu', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(UP_DOWN, A_B_C);
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
                SUtil.ActWrite("Logged from Option State");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
                        SUtil.ActWrite("Logged from Options State");
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}

		#if android
		if (_virtualpad.buttonC.justPressed) {
			MusicBeatState.switchState(new android.AndroidControlsMenu());
                        SUtil.ActWrite("Logged from Android Controls State");
		}
		#end
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
