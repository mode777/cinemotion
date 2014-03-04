function love.conf(t)
    t.title = "cinemotion"        -- The title of the window the game is in (string)
    t.author = "Alex Klingenbeck"        -- The author of the game (string)
    t.identity = "cinemotion"            -- The name of the save directory (string)
    t.version = "0.9.0"         -- The LE version this game was made for (string)
    t.console = true          -- Attach a console (boolean, Windows only)
    t.release = false          -- Enable release mode (boolean)
    t.screen.width = 800   -- The window width (number)
    t.screen.height = 500     -- The window height (number)
    t.screen.fullscreen = true -- Enable fullscreen (boolean)
    t.screen.vsync = true       -- Enable vertical sync (boolean)
    t.screen.fsaa = 0           -- The number of FSAA-buffers (number)
end