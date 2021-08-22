package;

import Section.DialogueSection;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var dialogue:Alphabet;
	var dialogueList:Array<DialogueSection> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new()
	{
		super();

		var dialogueList:Array<DialogueSection> = PlayState.SONG.dialogue;

		switch (PlayState.SONG.stageDefault)
		{
			case 'school-evil':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'school':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'stage':
				FlxG.sound.playMusic(Paths.music('smileFace'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		if (atSchool())
		{
			bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
			bgFade.scrollFactor.set();
			bgFade.alpha = 0;
			add(bgFade);

			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}, 5);

			box = new FlxSprite(-20, 45);
		}
		else
			box = new FlxSprite(40);

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				box.frames = Paths.getSparrowAtlas('dialogue/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('dialogue/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
			case 'thorns':
				box.frames = Paths.getSparrowAtlas('dialogue/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
			default:
				box.frames = Paths.getSparrowAtlas('dialogue/speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);

				box.animation.addByPrefix('normalOpenAngry', 'AHH speech bubble', 24, false);
				box.animation.addByPrefix('normalAngry', 'speech bubble loud open', 24, true);
		}

		this.dialogueList = dialogueList;

		if (atSchool())
		{
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('dialogue/${PlayState.SONG.player2}Portrait');
			portraitLeft.animation.addByPrefix('enter', 'Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;

			portraitRight = new FlxSprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('dialogue/${PlayState.SONG.player1}Portrait');
			portraitRight.animation.addByPrefix('enter', 'Portrait Enter', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;

			box.animation.play('normalOpen');

			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));

			box.updateHitbox();
			add(box);

			box.screenCenter(X);
			portraitLeft.screenCenter(X);

			handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('dialogue/hand_textbox'));
			add(handSelect);

			dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
			dropText.font = 'Pixel Arial 11 Bold';
			dropText.color = 0xFFD89494;
			add(dropText);

			swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
			swagDialogue.font = 'Pixel Arial 11 Bold';
			swagDialogue.color = 0xFF3F2021;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
			add(swagDialogue);
		}
		else
		{
			box.animation.play('normalOpen');

			box.setGraphicSize(Std.int(box.width * 0.9));

			box.screenCenter(X);
			box.updateHitbox();
			add(box);

			dialogue = new Alphabet(0, 80, "", false, true);
			add(dialogue);
		}
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (atSchool())
		{
			if (PlayState.SONG.song.toLowerCase() == 'roses')
				portraitLeft.visible = false;

			dropText.text = swagDialogue.text;
		}

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name.startsWith('normalOpen') && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			if (!atSchool())
				remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					FlxG.sound.music.fadeOut(2.2, 0);

					if (atSchool())
					{
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							swagDialogue.alpha -= 1 / 5;
							dropText.alpha = swagDialogue.alpha;
						}, 5);
					}
					else
					{
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							dialogue.alpha -= 1 / 5;
						}, 5);
					}

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		if (atSchool())
		{
			if (dialogueList[0].isPlayer1)
			{
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			}
			else if (!dialogueList[0].isPlayer1)
			{
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			}
		}
		else
			box.flipX = dialogueList[0].isPlayer1;
	}

	function cleanDialog():Void
	{
		if (atSchool())
		{
			swagDialogue.resetText(dialogueList[0].dialogue);
			swagDialogue.start(0.04, true);
		}
		else
		{
			var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0].dialogue, false, true, 'gf');
			dialogue = theDialog;
			add(theDialog);
		}
	}

	function atSchool():Bool
	{
		return PlayState.SONG.stageDefault.startsWith('school');
	}
}
