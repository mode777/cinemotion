#cinemotion

A modular game framework to go on top of LOVE2D

##Set Up

Put the "engine" folder in your love project folder and edit your "main.lua" to look like this.

    ENGINE_PATH = "engine" --change if you rename the cinemotion folder
    local engine = require(ENGINE_PATH) --local is optional here
    engine.registerCallbacks() --take over love's callback functions. Declaring your own will break the engine.

The engine will run by the scene file "init.sce" in the root folder by default.
This will open a rudementary menu that let's run your own scene files ot change debug settings.
If you don't want this, you can either edit the "init.sce" or change the default scene file to load on start by editing the config.cfg file.
On windows this will be located in "C:\users\yourname\AppData\Roaming\LOVE\yourproject". where yourname is the name you are currently logged on and yourpoject will be the identity of your game set in the "conf.lua" with "t.identity". If you downloaded the project, this will be "cinemotion".

##Tutorial

###Getting started

Start the project like you would usually do with a love project (i.e. on windows: by running "love.exe foldername" or putting is into a zip file and renaming the extension to love)




