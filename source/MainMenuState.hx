package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import FunkinLua;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

#if hscript
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
#end

using StringTools;
typedef MenuData = 
{
    storyP:Array<Int>,
    freeplayP:Array<Int>,
    modsP:Array<Int>,
    creditsP:Array<Int>,
    donateP:Array<Int>,
    optionsP:Array<Int>,
    storyS:Array<Float>,
    freeplayS:Array<Float>,
    modsS:Array<Float>,
    creditsS:Array<Float>,
    donateS:Array<Float>,
    optionsS:Array<Float>,
    speedWind:Array<Int>,
    visibleBG:Bool,
    centerX:Bool,
    menuBG:String
}
class MainMenuState extends MusicBeatState
{
    public var scriptArray:Array<FunkinLua> = [];
    var MainJSON:MenuData;
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
    public static var altEngineVersion:String = '2.2.1';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{

	    instance = this;

		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		MainJSON = Json.parse(Paths.getTextFromFile('UI Jsons/MainMenuData.json'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image(MainJSON.menuBG));
		bg.scrollFactor.set(0, 0.10);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image(MainJSON.menuBG));
		magenta.scrollFactor.set(0, 0.10);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		//var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			//StoryMenu
			var menuItem:FlxSprite = new FlxSprite(MainJSON.storyP[0],MainJSON.storyP[1]);
			menuItem.scale.x = MainJSON.storyS[0];
			menuItem.scale.y = MainJSON.storyS[1];
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[0]);
			menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 0;
                        // menuItem.screenCenter(X)
            if(MainJSON.centerX == true) {
                menuItem.screenCenter(X);
            }
			menuItems.add(menuItem);
            var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0,scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//freeplay
			var menuItem:FlxSprite = new FlxSprite(MainJSON.freeplayP[0],MainJSON.freeplayP[1]);
			menuItem.scale.x = MainJSON.freeplayS[0];
			menuItem.scale.y = MainJSON.freeplayS[1];
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[1]);
			menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 1;
                        // menuItem.screenCenter(X);
            if(MainJSON.centerX == true) {
                menuItem.screenCenter(X);
            }
			menuItems.add(menuItem);
            var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0,scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//mods
			var menuItem:FlxSprite = new FlxSprite(MainJSON.modsP[0],MainJSON.modsP[1]);
			menuItem.scale.x = MainJSON.modsS[0];
			menuItem.scale.y = MainJSON.modsS[1];
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[2]);
			menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 2;
                        // menuItem.screenCenter(X);
            if(MainJSON.centerX == true) {
                menuItem.screenCenter(X);
            }
			menuItems.add(menuItem);
            var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0,scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//credits
			var menuItem:FlxSprite = new FlxSprite(MainJSON.creditsP[0],MainJSON.creditsP[1]);
			menuItem.scale.x = MainJSON.creditsS[0];
			menuItem.scale.y = MainJSON.creditsS[1];
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);
			menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 3;
			if(MainJSON.centerX == true) {
                menuItem.screenCenter(X);
            }
			menuItems.add(menuItem);
                        var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0,scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//donate
			var menuItem:FlxSprite = new FlxSprite(MainJSON.donateP[0],MainJSON.donateP[1]);
			menuItem.scale.x = MainJSON.donateS[0];
			menuItem.scale.y = MainJSON.donateS[1];
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[4]);
			menuItem.animation.addByPrefix('idle', optionShit[4] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[4] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 4;
                        // menuItem.screenCenter(X);
            if(MainJSON.centerX == true) {
                menuItem.screenCenter(X);
            }
			menuItems.add(menuItem);
                        var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0,scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			//options
			var menuItem:FlxSprite = new FlxSprite(MainJSON.optionsP[0],MainJSON.optionsP[1]);
			menuItem.scale.x = MainJSON.optionsS[0];
			menuItem.scale.y = MainJSON.optionsS[1];
			
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[5]);
			menuItem.animation.addByPrefix('idle', optionShit[5] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[5] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = 5;
                        // menuItem.screenCenter(X);
            if(MainJSON.centerX == true) {
                menuItem.screenCenter(X);
            }
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0,scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

        var bgScroll = new FlxBackdrop(Paths.image('wind'), true, true, -33, -32);
		bgScroll.scrollFactor.set();
		bgScroll.screenCenter();
		bgScroll.velocity.set(MainJSON.speedWind[0] ,MainJSON.speedWind[1]);
		bgScroll.antialiasing = ClientPrefs.globalAntialiasing;
		if(MainJSON.visibleBG){
		add(bgScroll);
     	}
     	
		FlxG.camera.follow(camFollowPos, null, 1);

                var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Alt Engine v: " + altEngineVersion, 12);
		versionShit.scrollFactor.set();
                versionShit.screenCenter(X);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v: " + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
                versionShit.screenCenter(X);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		
		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('scripts/states/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/states/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/states/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						scriptArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if android
		addVirtualPad(UP_DOWN, A_B_X_Y);
		//virtualPad.y = -44;
	    #end
		callOnLuas('onMainCreatePost', []);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if (desktop || android)
			else if (FlxG.keys.anyJustPressed(debugKeys) #if android || _virtualpad.buttonX.justPressed #end)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			else if (FlxG.keys.anyJustPressed(debugKeys) #if android || _virtualpad.buttonY.justPressed #end)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new ExitGame());
			}
			#end
		}
		callOnLuas('onUpdate', [elapsed]);

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
		   //spr.screenCenter(X)
		    if(MainJSON.centerX == true){
			spr.screenCenter(X);
		    }
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
		callOnLuas('onChangeItem',[huh]);

	}
}
