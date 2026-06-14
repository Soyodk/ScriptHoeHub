-- Evade Loader (Clean English Version)

local supported = {
    [9872472334] = true,  -- Evade
}

local ms = game:GetService("MarketplaceService")
local gameId = game.GameId
local placeId = game.PlaceId

local ok, info = pcall(function()
    return ms:GetProductInfo(placeId)
end)

local gameName = ok and info.Name or "Unknown Game"

if supported[gameId] then
    WindUI:Notify({
        Title = "Game Detected",
        Desc = "Supported game: " .. gameName .. "\nLoading script...",
        Icon = "check"
    })
    
    task.spawn(function()
        local success, err = pcall(function()
            -- Load the Evade script
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Soyodk/ScriptHoeHub/refs/heads/main/Script/evade2.lua"))()
        end)
        
        if not success then
            WindUI:Notify({
                Title = "Load Error",
                Desc = err or "Unknown error occurred",
                Icon = "x"
            })
        end
    end)
else
    WindUI:Notify({
        Title = "Game Not Supported",
        Desc = "This game is not compatible.\nGameId: " .. gameId,
        Icon = "x"
    })
end
