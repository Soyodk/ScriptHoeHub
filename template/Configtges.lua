local HttpService = game:GetService("HttpService")

local ThemeSection = Tabs.Settings:Section({
    Title = "Theme",
    TextSize = 20
})

local success, themeList = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Soyodk/ScriptHoeHub/refs/heads/main/Uilibray/78themes.lua"
    ))()
end)

if success and type(themeList) == "table" then
    for _, data in ipairs(themeList) do
        if data.Name and data.Theme then
            WindUI:AddTheme(data.Name, data.Theme)

            ThemeSection:Button({
                Title = data.Name,
                Callback = function()
                    WindUI:SetTheme(data.Name)
                    writefile("MellowHubConfig/last.json", HttpService:JSONEncode({
                        Last = data.Name
                    }))
                end
            })
        end
    end
else
    ThemeSection:Label({
        Title = "Failed to load themes"
    })
end

ThemeSection:Divider()

local configFolder = "MellowHubConfig"
local lastFile = configFolder .. "/last.json"

if not isfolder(configFolder) then
    makefolder(configFolder)
end

local function getSavedConfigs()
    local list = {}
    for _, file in ipairs(listfiles(configFolder)) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(list, name)
        end
    end
    table.sort(list)
    return list
end

local selectedConfig = nil

local ConfigDropdown = ThemeSection:Dropdown({
    Title = "Saved Configs",
    Values = getSavedConfigs(),
    Callback = function(value)
        selectedConfig = value
    end
})

ThemeSection:Input({
    Title = "Config Name",
    Placeholder = "my-config",
    Callback = function(value)
        selectedConfig = value
    end
})

local function applyConfig(data)
    if data.Theme then
        WindUI:SetTheme(data.Theme)
    end

    if data.Transparency then
        WindUI.TransparencyValue = data.Transparency
        Window:ToggleTransparency(data.Transparency > 0)
    end
end

local function saveLastConfig(name)
    writefile(lastFile, HttpService:JSONEncode({
        Last = name
    }))
end

local function saveConfig()
    if not selectedConfig or selectedConfig == "" then return end

    local data = {
        Theme = WindUI.CurrentTheme,
        Transparency = WindUI.TransparencyValue
    }

    writefile(
        configFolder .. "/" .. selectedConfig .. ".json",
        HttpService:JSONEncode(data)
    )

    saveLastConfig(selectedConfig)
    ConfigDropdown:SetValues(getSavedConfigs())
end

local function loadConfig(name)
    local path = configFolder .. "/" .. name .. ".json"
    if not isfile(path) then return end

    local data = HttpService:JSONDecode(readfile(path))
    applyConfig(data)
    saveLastConfig(name)
end

local function deleteConfig()
    if not selectedConfig then return end

    local path = configFolder .. "/" .. selectedConfig .. ".json"
    if isfile(path) then
        delfile(path)
        selectedConfig = nil
        ConfigDropdown:SetValues(getSavedConfigs())
    end
end

ThemeSection:Button({
    Title = "Save Config",
    Callback = saveConfig
})

ThemeSection:Button({
    Title = "Load Config",
    Callback = function()
        if selectedConfig then
            loadConfig(selectedConfig)
        end
    end
})

ThemeSection:Button({
    Title = "Delete Config",
    Callback = deleteConfig
})

if isfile(lastFile) then
    local last = HttpService:JSONDecode(readfile(lastFile))
    if last and last.Last then
        task.delay(0.3, function()
            loadConfig(last.Last)
        end)
    end
end
