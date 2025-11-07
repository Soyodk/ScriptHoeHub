local supported = {
    9872472334, -- adicione mais IDs aqui
    1234567890,
}

local id = game.GameId
local ms = game:GetService("MarketplaceService")

local function isSupported(id)
    for _, v in ipairs(supported) do
        if v == id then
            return true
        end
    end
    return false
end

local ok, info = pcall(function()
    return ms:GetProductInfo(game.PlaceId)
end)

if isSupported(id) then
    local name = ok and info.Name or "Unknown Game"
    WindUI:Notify({
        Title = "Game detected",
        Desc = "Supported game: " .. name,
        Icon = "check"
    })
else
    WindUI:Notify({
        Title = "Game not supported",
        Desc = "This game is not compatible.",
        Icon = "x"
    })
end
