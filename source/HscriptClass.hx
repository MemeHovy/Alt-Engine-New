package;

#if hscript
import hscript.Interp;
import hscript.Parser;
#end
import openfl.utils.Assets;

#if hscript
class HscriptClass extends Interp {
	public static final Function_Stop:Dynamic = 1;
	public static final Function_Continue:Dynamic = 0;

    private var parser:Parser;

    public function new(file:String, ?canExecute:Bool = true){
        super();

        parser = new Parser();
        parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;

        setVariable("this", this);
		setVariable('import', function(daClass:String, ?asDa:String)
		{
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				openfl.Lib.application.window.alert('Class / Enum at $className does not exist.', 'Hscript Error!');
			else
			{
				if (daEnum != null)
				{
					var daEnumField = {};
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField(daEnumField, daConstructor, daEnum.createByName(daConstructor));

					if (asDa != null && asDa != '')
						setVariable(asDa, daEnumField);
					else
						setVariable(splitClassName[splitClassName.length - 1], daEnumField);
				}
				else
				{
					if (asDa != null && asDa != '')
						setVariable(asDa, daClass);
					else
						setVariable(splitClassName[splitClassName.length - 1], daClass);
				}
			}
		});
       
		setVariable('Function_Stop', Function_Stop);
		setVariable('Function_Continue', Function_Continue);

		setVariable('Date', Date);
		setVariable('DateTools', DateTools);
		setVariable('Lambda', Lambda);
		setVariable('Math', Math);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringBuf', StringBuf);
		setVariable('StringTools', StringTools);
        #if sys
		setVariable('Sys', Sys);
        #end
		setVariable('Type', Type);

        // setVariable('getClass', (className:String) -> Type.resolveClass(className));
        // setVariable('getEnum', (className:String) -> Type.resolveEnum(className));

        /*
        setVariable('getType', (type:Dynamic) -> {
            return (type is Dynamic) ? type : null;
        });
        setVariable('setType', (d:Any, e:Dynamic) -> {
            return (d is Any) ? d = e : e;
        });
        */

        setVariable('songTime', @:privateAccess PlayState.instance.songLength);
        setVariable('SUtil', SUtil);

        if (PlayState.instance != null)
            setVariable('PlayState', PlayState.instance);

        setVariable('FlxG', flixel.FlxG);
        setVariable('FlxSprite', flixel.FlxSprite);
        setVariable('FlxCamera', flixel.FlxCamera);
        setVariable('FlxTimer', flixel.util.FlxTimer);
        setVariable('FlxTween', flixel.tweens.FlxTween);
        setVariable('FlxEase', flixel.tweens.FlxEase);
        setVariable('FlxText', flixel.text.FlxText);

        setVariable('preloadImage', (s:String) -> Paths.image(s));
        setVariable('preloadSound', (s:String) -> Paths.sound(s));
        setVariable('preloadMusic', (s:String) -> Paths.music(s));

        setVariable('Json', haxe.Json);

        setVariable("curBeat", 0);
        setVariable("curStep", 0);
        setVariable("curSection", 0);

        setVariable("create", function() {});
        setVariable("createPost", function() {});
        setVariable("update", function(elapsed:Float) {});
        setVariable("updatePost", function(elapsed:Float) {});
        setVariable("startCountdown", function() {});
        setVariable("onCountdownStarted", function() {});
        setVariable("onCountdownTick", function(tick:Int) {});
        setVariable("onUpdateScore", function(miss:Bool) {});
        setVariable("onNextDialogue", function(counter:Int) {});
        setVariable("onSkipDialogue", function() {});
        setVariable("onSongStart", function() {});
        setVariable("eventEarlyTrigger", function(eventName:String) {});
        setVariable("onResume", function() {});
        setVariable("onPause", function() {});
        setVariable("onSpawnNote", function(note:Note) {});
        setVariable("onGameOver", function() {});
        setVariable("onEvent", function(name:String, val1:Dynamic, val2:Dynamic) {});
        setVariable("onMoveCamera", function(char:String) {});
        setVariable("onEndSong", function() {});
        setVariable("onGhostTap", function(key:Int) {});
        setVariable("onKeyPress", function(key:Int) {});
        setVariable("onKeyRelease", function(key:Int) {});
        setVariable("noteMiss", function(note:Note) {});
        setVariable("noteMissPress", function(direction:Int) {});
        setVariable("opponentNoteHit", function(note:Note) {});
        setVariable("goodNoteHit", function(note:Note) {});
        setVariable("noteHit", function(note:Note) {});
        setVariable("stepHit", function() {});
        setVariable("beatHit", function() {});
        setVariable("sectionHit", function() {});
        setVariable("onRecalculateRating", function() {});
        setVariable("Function_StopLua", FunkinLua.Function_Stop);
        setVariable("onOpenPauseMenu", function() {});

        if (Assets.exists(file) && canExecute){
            executeScript(file);
        }
    }

    public function setVariable(name:String, value:Dynamic){
        if (this == null) return;

        try{
            variables.set(name, value);
        }
        catch (e)
            openfl.Lib.application.window.alert(e.message, 'Hscript Error');
    }

    public function getVariable(name:String):Dynamic{
        if (this == null) return null;

        try{
            return variables.get(name);
        }
        catch (e)
            openfl.Lib.application.window.alert(e.message, 'Hscript Error');

        return null;
    }

    public function executeScript(file:String){
        try{
            this.execute(parser.parseString(Assets.getText(file)));
        }
        catch (e)
            openfl.Lib.application.window.alert(e.message, 'Hscript Error');

        SUtil.ActWrite('Script Loaded Succesfully: $file');
    }

    public function removeVariable(name:String):Void
	{
		if (this == null) return;

		try{
			variables.remove(name);
		}
		catch (e)
			openfl.Lib.application.window.alert(e.message, 'Hscript Error');
	}

	public function existsVariable(name:String):Bool
	{
		if (this == null) return false;

		try{
			return variables.exists(name);
		}
		catch (e)
			openfl.Lib.application.window.alert(e.message, 'Hscript Error');

		return false;
	}

	public function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic
	{
		if (this == null) return null;

		if (existsVariable(funcName))
		{
			try{
				return Reflect.callMethod(this, getVariable(funcName), args == null ? [] : args);
			}
			catch (e)
				openfl.Lib.application.window.alert(e.message, 'Hscript Error!');
		}

		return null;
	}    
}
#end