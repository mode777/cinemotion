#cinemotion

A modular game framework to go on top of LOVE2D

##Set Up

Put the "engine" folder in your love directory and edit your "main.lua" to look like this.

    ENGINE_PATH = "engine" --change if you rename the cinemotion folder
    local engine = require(ENGINE_PATH) --local is optional here
    engine.registerCallbacks() --take over love's callback functions. Declaring your own will break the engine.

