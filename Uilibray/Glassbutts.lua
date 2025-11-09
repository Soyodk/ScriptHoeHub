--[[  
    🪟 GlassUI v2.0 — Biblioteca de Interface Personalizável
    Compatível com WindUI, Linoria e outras UI libs
    💡 Recursos:
      - Temas integrados e temas personalizados via código
      - Efeitos visuais (vidro, gradiente, sombra)
      - Suporte a botões simples, toggles (On/Off) e callbacks
      - Totalmente modular e sem interferência em outras UIs
--]]

local GlassUI = {}

-- 🎨 Temas padrão
local Themes = {
    ["Glass"] = {
        Background = Color3.fromRGB(25, 25, 25),
        Stroke = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(255, 255, 255),
        ButtonOn = Color3.fromRGB(0, 180, 100),
        ButtonOff = Color3.fromRGB(180, 0, 60),
        Transparency = 0.45
    },
    ["Dark"] = {
        Background = Color3.fromRGB(15, 15, 15),
        Stroke = Color3.fromRGB(90, 90, 90),
        Text = Color3.fromRGB(255, 255, 255),
        ButtonOn = Color3.fromRGB(0, 140, 90),
        ButtonOff = Color3.fromRGB(140, 0, 0),
        Transparency = 0.3
    },
    ["Neon"] = {
        Background = Color3.fromRGB(10, 10, 25),
        Stroke = Color3.fromRGB(0, 220, 255),
        Text = Color3.fromRGB(0, 255, 255),
        ButtonOn = Color3.fromRGB(0, 255, 180),
        ButtonOff = Color3.fromRGB(255, 0, 120),
        Transparency = 0.35
    }
}

-- 👤 Utilitário de criação de Gui
local function createScreenGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    return gui
end

-- 🧱 Função principal de criação
function GlassUI:CreateElement(config)
    local theme = Themes[config.Theme or "Glass"]
    local parentGui = config.Parent or createScreenGui(config.Title or "GlassUI")
    local mode = config.Type or "Toggle" -- "Toggle", "Button", ou "Clickable"
    local callback = config.Callback or function() end

    -- Frame base
    local frame = Instance.new("Frame")
    frame.Size = config.Size or UDim2.new(0, 90, 0, 90)
    frame.Position = config.Position or UDim2.new(0.5, -45, 0.15, 0)
    frame.BackgroundColor3 = theme.Background
    frame.BackgroundTransparency = config.Transparency or theme.Transparency
    frame.BorderSizePixel = 0
    frame.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, config.CornerRadius or 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Stroke
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.Size = UDim2.new(1.3,0,1.3,0)
    shadow.Position = UDim2.new(-0.15,0,-0.1,0)
    shadow.ZIndex = 0
    shadow.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,180,180))
    })
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.8),
        NumberSequenceKeypoint.new(1,1)
    })
    gradient.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0.4,0)
    label.Position = UDim2.new(0,0,0.05,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = theme.Text
    label.Text = config.Title or "Element"
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame

    local state = false
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.85,0,0.4,0)
    button.Position = UDim2.new(0.075,0,0.55,0)
    button.BackgroundColor3 = theme.ButtonOff
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Text = (mode == "Toggle") and "Off" or "Click"
    button.Parent = frame

    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0,6)
    bcorner.Parent = button

    local drag = Instance.new("UIDragDetector")
    drag.Parent = frame

    -- ⚙️ Comportamento
    if mode == "Toggle" then
        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = state and "On" or "Off"
            button.BackgroundColor3 = state and theme.ButtonOn or theme.ButtonOff
            callback(state)
        end)
    elseif mode == "Button" then
        button.MouseButton1Click:Connect(function()
            callback()
        end)
    elseif mode == "Clickable" then
        button.Visible = false
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                callback(state)
            end
        end)
    end

    return {
        Frame = frame,
        SetTheme = function(_, custom)
            if Themes[custom] then
                theme = Themes[custom]
            elseif typeof(custom) == "table" then
                theme = custom
            end
            frame.BackgroundColor3 = theme.Background
            stroke.Color = theme.Stroke
            label.TextColor3 = theme.Text
            button.BackgroundColor3 = state and theme.ButtonOn or theme.ButtonOff
        end,
        SetSize = function(_, newSize)
            frame.Size = newSize
        end,
        SetCorner = function(_, radius)
            corner.CornerRadius = UDim.new(0, radius)
        end,
        SetTransparency = function(_, value)
            frame.BackgroundTransparency = value
        end,
        Destroy = function()
            parentGui:Destroy()
        end
    }
end

-- 💾 Adicionar temas personalizados
function GlassUI:AddTheme(name, data)
    Themes[name] = data
end

return GlassUI
