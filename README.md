#cinemotion
##Abstract
cinemotion is a modular framework to go on top of Löve2D. It is aimed to provide you with the tools you need to rapidly
develop games in Löve2D by adding some functionality that love is missing. cinemotions philosophy is to enable you to
develop Löve2D games faster and easier but also not to constrain you by forcing a single development style or object
behaviour on you. To be more specific: cinemotion  won't provide you with a "tiled" importer but rather give you the
tools to build one yourself with only a few lines of code. cinemotion tries to follow this strategy of giving you a few
primitives on which you can start building your game objects.

cinemotion will further take care of some unpleasant element of game developement you will have to take care of once
your game gets bigger, such as:
* Asset management
* Collision detection
* Viewport culling
* Scene manegement

cinemotion was inspired and borrows concepts from various frameworks libraries and game engines, such as the MOAI Framework, jQuery, Construct
and Adventure Game Studio.

##Set Up

Put the "engine" folder in your love project folder and edit your "main.lua" to look like this.
```lua
    ENGINE_PATH = "engine" --change if you rename the cinemotion folder
    local engine = require(ENGINE_PATH) --local is optional here
    engine.registerCallbacks() --don't declare your own callback
```
The engine will run by the scene file "init.sce" in the root folder by default.
This will open a rudementary menu that let's run your own scene files ot change debug settings.
If you don't want this, you can either edit the "init.sce" or change the default scene file to load on start by editing the config.cfg file.
On windows this will be located in "C:\users\yourname\AppData\Roaming\LOVE\yourproject". where yourname is the name you are currently logged on and yourpoject will be the identity of your game set in the "conf.lua" with "t.identity". If you downloaded the project, this will be "cinemotion".

##Tutorial

###Getting started

Start the project like you would usually do with a love project (i.e. on windows: by running "love.exe foldername" or putting is into a zip file and renaming the extension to love)

A simple menu will pop up, that let's your change your settings and run scene files. If you select "Run Scene" you will only see one entry, called "init.sce". This is the menu screen you're looking at right now.

The first important thing to notice here is, that cinemotion organises it's game logic in scenes (you don't have to use them though).
Think of a scene as the biggest distinguishable part of your game. It could be a level or a gui or a menu. So let's create a scene.

####Our first scene

Create a new file in your project root directory.
Call it "helloworld.sce" and open it. (TIPP: You can set up your favourite code editor to treat it like a lua file, to get syntax highlighting)

Paste this into your new file. (TIPP: Some code editors/IDEs let you create templates.)

```lua
    local cm = require(ENGINE_PATH)
    local scene = {}

    function scene.onLoad()
        --initialize your scene here
    end

    function scene.onUpdate()
        --update your scene here.
    end

    function scene.onStop()
        --define what is going to happen when your scene stops
    end

    return scene
```

If you have worked with love before these function might seem familiar. Like the love functions (e.g. love.load()) these are callbacks for your scenes.
We can put code in there, to tell our scene what to do at a specific time and state. What is different however is, that these callbacks are all coroutines.
A later chapter might explain this in greater detail for now, just keep in mind that, unlike love's callbacks, you might pause and resume cinemotion callbacks at will.

Go into the "scene.onLoad" function add add the following lines.
```lua
        local layer = cm.layer.new()
        local font = cm.sourceFont.new()
        local text = cm.sprite.new(100,100,font,"Hello World")

        layer:addSprite(text)
```
Run the engine, navigate to run scene and run "helloworld"
If you did everything right, you should see the text "Hello World" on screen.

#####What happened?

Let's have a closer look at our code.
```lua
    local layer = cm.layer.new()
```
First we create a new layer. cm is the local variable we loaded the cinemotion interface at the beginning of the file.

If you want cinemotion to put something on screen, you have to put it into a layer first.
If you ever worked with a picture editing programm like photoshop the concept of layers might be familiar to you.
```lua
    local font = cm.sourceFont.new()
```
Next we create a font. As we supplied no further parameters we will load löve's standart font. Fonts in cinemotion belong to a group of objects in cinemotion called sources. A source is an asset
(which in most cases you load into the game form disk) many game objects (sprites) might share.
The concept of sources is heavily inspired by moai framework's concepts of decks.
A source can be a sound file, an image, a tileset, a spritesheet, a font and much more. Sources can be shared, e.g. many
in-game sprites might share the same source.
```lua
    local text = cm.sprite.new(100,100,font,"Hello World")

    layer:addSprite(text)
```
Now for the actual text on screen. We create a sprite, which is an object, that gets drawn to screen. In the parameters
 we first provide the X and Y coordinates for our sprite(100,100), provide a source (font) and provide an Index
 ("Hello World").

 An Index is, what connects a sprite and a source. Indices may vary depending of the kind of source used. On a tileset,
 it might be...