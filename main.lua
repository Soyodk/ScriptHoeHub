-- Lista de jogos suportados (GameId principal)
local supported = {
    [9872472334] = true, -- Jogo 1
    [1234567890] = true, -- Jogo 2
}

local ms = game:GetService("MarketplaceService")
local ok, info = pcall(function()
    return ms:GetProductInfo(game.PlaceId)
end)

-- Usa GameId (principal) para checar compatibilidade
local gameId = game.GameId
local isSupported = supported[gameId]

if isSupported then
    local name = ok and info.Name or "Unknown Game"
    WindUI:Notify({
        Title = "Game detected",
        Desc = "Supported game: " .. name,
        Icon = "check"
    })
else
    WindUI:Notify({
        Title = "Game not supported (buggy)",
        Desc = "This game is not compatible.",
        Icon = "x"
    })
end
