-- ========================================
-- SETTINGS TAB - Theme & Config Section (Corrigido, Otimizado e com Nome "Mellow Hub")
-- ========================================

local HttpService = game:GetService("HttpService")

local ThemeSection = Tabs.Settings:Section({
    Title = "Theme & Config",
    TextSize = 20
})

ThemeSection:Divider()

-- Carregar temas externos (opcional - com fallback)
local themeList = {}
local success, loadedThemes = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Soyodk/ScriptHoeHub/refs/heads/main/Uilibray/78themes.lua",
        true
    ))()
end)

if success and type(loadedThemes) == "table" then
    themeList = loadedThemes
    print("✅ Temas externos carregados com sucesso! (Mellow Hub)")
else
    warn("⚠️ Falha ao carregar temas externos (Mellow Hub): " .. tostring(loadedThemes))
    ThemeSection:Label({ Title = "Failed to load external themes" })
end

-- Adicionar os temas carregados à tabela WindUI.Themes
for _, data in ipairs(themeList) do
    if data.Name and data.Theme and type(data.Theme) == "table" then
        WindUI.Themes[data.Name] = data.Theme
        
        -- Botão para aplicar o tema
        ThemeSection:Button({
            Title = data.Name,
            Callback = function()
                WindUI:SetTheme(data.Name)
                settings.Theme = data.Name
                saveSettings()  -- salva no seu sistema de settings.json
                
                -- Salva como último tema usado
                pcall(function()
                    writefile("MellowHubConfig/last.json", HttpService:JSONEncode({ Last = data.Name }))
                end)
            end
        })
    end
end

ThemeSection:Divider()

-- Configuração de pastas e arquivos (agora com nome "MellowHubConfig")
local configFolder = "MellowHubConfig"
local lastFile = configFolder .. "/last.json"

if not isfolder(configFolder) then
    makefolder(configFolder)
end

-- Função para listar configs salvas
local function getSavedConfigs()
    local list = {}
    for _, file in ipairs(listfiles(configFolder)) do
        local name = file:match("([^/\\]+)%.json$")
        if name and name ~= "last" then  -- ignora o last.json
            table.insert(list, name)
        end
    end
    table.sort(list)
    return list
end

local selectedConfig = nil

-- Dropdown de configs salvas
local ConfigDropdown = ThemeSection:Dropdown({
    Title = "Saved Configs",
    Values = getSavedConfigs(),
    Callback = function(value)
        selectedConfig = value
    end
})

-- Campo para digitar nome da config
ThemeSection:Input({
    Title = "Config Name",
    Placeholder = "my-config",
    Callback = function(value)
        selectedConfig = value
    end
})

-- Aplicar uma config
local function applyConfig(data)
    if data.Theme and WindUI.Themes[data.Theme] then
        WindUI:SetTheme(data.Theme)
        settings.Theme = data.Theme
    end

    if data.Transparency then
        settings.Transparency = data.Transparency
        WindUI.TransparencyValue = data.Transparency
        -- Se WindUI tiver método para toggle transparency
        pcall(function()
            Window:ToggleTransparency(data.Transparency > 0)
        end)
    end

    saveSettings()  -- salva também no seu sistema principal
end

-- Salvar último config usado
local function saveLastConfig(name)
    pcall(function()
        writefile(lastFile, HttpService:JSONEncode({ Last = name }))
    end)
end

-- Salvar config atual
local function saveConfig()
    if not selectedConfig or selectedConfig == "" then
        warn("Nome da config inválido! (Mellow Hub)")
        return
    end

    local data = {
        Theme = settings.Theme or WindUI.CurrentTheme or "RedBlack",
        Transparency = settings.Transparency or WindUI.TransparencyValue or 0.15
    }

    local success, err = pcall(function()
        writefile(
            configFolder .. "/" .. selectedConfig .. ".json",
            HttpService:JSONEncode(data)
        )
    end)

    if success then
        saveLastConfig(selectedConfig)
        ConfigDropdown:SetValues(getSavedConfigs())
        print("Config salva com sucesso: " .. selectedConfig .. " (Mellow Hub)")
    else
        warn("Falha ao salvar config (Mellow Hub): " .. tostring(err))
    end
end

-- Carregar config
local function loadConfig(name)
    local path = configFolder .. "/" .. name .. ".json"
    if not isfile(path) then
        warn("Config não encontrada: " .. path .. " (Mellow Hub)")
        return
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if success and data then
        applyConfig(data)
        saveLastConfig(name)
        print("Config carregada: " .. name .. " (Mellow Hub)")
    else
        warn("Falha ao carregar config (Mellow Hub): " .. tostring(data))
    end
end

-- Deletar config
local function deleteConfig()
    if not selectedConfig then return end

    local path = configFolder .. "/" .. selectedConfig .. ".json"
    if isfile(path) then
        delfile(path)
        selectedConfig = nil
        ConfigDropdown:SetValues(getSavedConfigs())
        print("Config deletada: " .. selectedConfig .. " (Mellow Hub)")
    end
end

-- Botões
ThemeSection:Button({ Title = "Save Config", Callback = saveConfig })
ThemeSection:Button({ 
    Title = "Load Config", 
    Callback = function()
        if selectedConfig then loadConfig(selectedConfig) end
    end
})
ThemeSection:Button({ Title = "Delete Config", Callback = deleteConfig })

-- Carregar último tema/config usado (se existir)
if isfile(lastFile) then
    local success, last = pcall(function()
        return HttpService:JSONDecode(readfile(lastFile))
    end)
    
    if success and last and last.Last then
        task.delay(0.5, function()
            loadConfig(last.Last)
        end)
    end
end

print("Mellow Hub - Config & Themes loaded successfully!")
