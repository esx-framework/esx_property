CreateThread(function()
    while true do
        Wait(60000)
        collectgarbage("collect")
    end
end)