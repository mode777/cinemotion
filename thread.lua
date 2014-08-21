local thread = {}
local threads = {}
local status = coroutine.status
local resume = coroutine.resume
local time = love.timer.getTime

function thread.new(Func)
    local co
    local func
    --interface for a thread
    local i = {}
    function i:run(...)
        if not func then error("Thread needs a function to run") end
        co = coroutine.create(func)
        threads[co] = true
        assert(resume(co,...))
        return self
    end
    function i:isFinished()
        if co then
            return status(co) == "dead"
        end
    end

    function i:isRunning()
        if co then
            return not status(co) == "dead"
        end
    end

    function i:kill()
        if co then threads[co] = nil end
        co = nil
    end

    function i:setFunction(Func)
        func = Func
    end

    if Func then i:setFunction(Func) end
    return i
end

function thread.update()
    local delete = {}
    --restart all threads
    for cr,_ in pairs(threads) do
        local state = status(cr)
        if state == "running" then error("Unfinished coroutine caught")
        elseif state == "dead" then threads[cr] = nil
            --resume coroutine
        elseif state == "suspended" then
            assert(resume(cr))

        end

    end
end

function thread.waitThread(cr)
    if not cr then error("You have to provide a thread to thread.waitThread. Supplied:"..tostring(cr)) end
    while not cr:isFinished() do thread.yield() end
end

function thread.waitCondition(func)
    while not func() do thread.yield() end
end

function thread.wait(s)
    local t = time()
    while time() < t+s do thread.yield() end
end

function thread.waitKey(s)
    local t = time()
    while time() < t+s do
        local i,j,k,l = cine.input.getCurrentInput()
        if i then
            while not cine.input.isReleased(i,j,k,l) and time() < t+s do
                thread.yield()
            end
            if cine.input.isReleased(i,j,k,l) then break end
        end
        thread.yield()
    end
end

function thread.active()
    local c = 0
    for _,_ in pairs(threads) do c = c+1 end
    return c
end

function thread.clearAll()
    threads = {}
end

thread.yield = coroutine.yield

thread._DOC={
    waitThread={"Blocks current thread until another thread is finished.",{ {"thread","Thread","This function will also accept tweens (animations) as they have the same interface"} }},
}

return thread