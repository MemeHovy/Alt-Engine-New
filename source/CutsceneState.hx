package;

import flixel.FlxG;
import FlxVideo;

using StringTools;

#if sys
import sys.FileSystem;
#end

class CutsceneState extends MusicBeatState // PlayState is alreadly laggy enough so nowOPTIMIZED CUTSENES EVERRR
{
	public var finishCallback:Void->Void;
	public var songName:String;
	public var endingCutscene:Bool = false;
	public var playCutscene:Bool = true;

	public var video:FlxVideo;

	public function new(songName:String, isEnd:Bool, ?finishCallback:Void->Void, ?playCut:Bool = true)
	{
		super();

		if (finishCallback != null)
			this.finishCallback = finishCallback;

		this.songName = songName;
		endingCutscene = isEnd;
		playCutscene = playCut;
	}

	override public function create()
	{
		if (songName != null)
		{
			chooseVideo();
		}
		else
		{
			finish();
		}
	}

	function chooseVideo()
	{
		var videoplay:String = null;
		var skippable:Null<Bool> = null;
		var focus:Null<Bool> = true;
	
		if (endingCutscene)
			{
				switch (StringTools.replace(songName.toLowerCase(), '-', ' '))
				{
					case 'tiny mad old':
						switch(PlayState.variant){
							case 0:
								videoplay = 'EndCutscene-Noob';
								focus = false;
								skippable = true;
							case 1:
								videoplay = 'EndCutscene-ProShit';
								focus = false;
								skippable = true;
							case 2:
								videoplay = 'EndCutscene-Pro';
								focus = false;
								skippable = true;
						}
				}
			}
			else
			{
			switch (StringTools.replace(songName.toLowerCase(), '-', ' '))
			{
				case 'all star old':
					trace("huh");
					videoplay = 'AllStar-Cutscene';
					focus = false;
					skippable = true;
				case 'tiny mad old':
					switch(PlayState.variant){
				    	case 0:
				        	videoplay = 'TinyMad-Cutscene-Noob';
							focus = false;
							skippable = true;
				    	case 1:
					    	videoplay = 'TinyMad-Cutscene-ProShit';
							focus = false;
							skippable = true;
				    	case 2:
					    	videoplay = 'TinyMad-Cutscene-Pro';
							focus = false;
							skippable = true;
					}
			}
		}

		if(playCutscene){
	    	if (videoplay != null && skippable != null && focus != null)
	    	{
	     		playVideo(videoplay, skippable, focus);
	    		trace("playing");
	    	}
	    	else
	    	{
	        	finish();
		     	trace("fuck you");
	     	}
    	}else{
			finish();
		    trace("fuck you no video");
		}
	}

	public function playVideo(videoName:String, ?skippable:Bool = false, ?focus:Bool = true)
		{
			#if VIDEOS_ALLOWED
			var foundFile:Bool = false;
			var fileName:String = Paths.video(videoName);
	
			if (FileSystem.exists(fileName))
			{
				foundFile = true;
			}
	
			if (foundFile)
			{
				var video = new FlxVideo(fileName, skippable, focus);
	
				video.finishCallback = function()
				{
					finish();
				}
				return;
			}
			else
			{
				FlxG.log.warn('Couldnt find video file: ' + fileName);
				finish();
			}
			#else
			finish();
			#end
		}
	
		public function finish()
		{
			if (video != null)
			{
				video.destroy();
			}
			if (finishCallback != null)
				finishCallback();
		}
	}
