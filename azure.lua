-- MyWindStyleLib.lua - Код библиотеки (Должен быть загружен через loadstring)

local UI_State = {
    CurrentTheme = "Dark", 
    Configuration = {}
}

-- === КОНФИГУРАЦИЯ СТИЛЯ И ЦВЕТА ===
local Themes = {
    Dark = {
        ACCENT = Color3.fromRGB(0, 150, 255),
        PRIMARY_BG = Color3.fromRGB(18, 18, 18),
        PANEL_BG = Color3.fromRGB(30, 30, 30),
        ELEMENT_BG = Color3.fromRGB(45, 45, 45),
        TEXT = Color3.fromRGB(255, 255, 255),
        MUTED_TEXT = Color3.fromRGB(150, 150, 150),
    },
    Light = {
        ACCENT = Color3.fromRGB(255, 80, 0),
        PRIMARY_BG = Color3.fromRGB(240, 240, 240),
        PANEL_BG = Color3.fromRGB(255, 255, 255),
        ELEMENT_BG = Color3.fromRGB(220, 220, 220),
        TEXT = Color3.fromRGB(0, 0, 0),
        MUTED_TEXT = Color3.fromRGB(100, 100, 100),
    }
}
local CurrentColors = Themes[UI_State.CurrentTheme]

local PLAYERS = game:GetService("Players")
local UI_SERVICE = game:GetService("UserInputService")
local HTTP_SERVICE = game:GetService("HttpService")

-- === LUCIDE ICONS MAPPING (ОБНОВЛЕННЫЕ ID АССЕТОВ) ===
local ICON_ASSET_IDS = {
    zap = "rbxassetid://13160015076",     -- Zap (Молния)
    settings = "rbxassetid://7059346386", -- Settings (Шестеренка)
    
    -- ЗАГЛУШКИ: Замените, если нужны реальные иконки
    user = "rbxassetid://555555555",     
    lock = "rbxassetid://111111111",     
    toggle_on = "rbxassetid://444444444", 
    toggle_off = "rbxassetid://666666666",
    button = "rbxassetid://222222222",   
    default = "rbxassetid://333333333",   
}

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (АНАЛОГИЧНЫ ПРЕДЫДУЩЕМУ ОТВЕТУ) ===

local function GetIconAssetId(iconName)
    local id = ICON_ASSET_IDS[iconName:lower()]
    return id or ICON_ASSET_IDS.default
end

local function ValidateKey(providedKey, validKeys)
    for _, key in ipairs(validKeys) do
        if key == providedKey then return true end
    end
    return false
end

local function CreateErrorPrompt(title, subtitle)
    -- ... (логика окна ошибки)
end

local function CreateImageIcon(parent, iconName, color, size, position, alignment)
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = size or UDim2.new(0, 18, 0, 18)
    imageLabel.Image = GetIconAssetId(iconName)
    imageLabel.ImageColor3 = color or CurrentColors.MUTED_TEXT
    imageLabel.BackgroundTransparency = 1
    imageLabel.Parent = parent
    imageLabel.Position = position or UDim2.new(0, 0, 0, 0)
    imageLabel.AnchorPoint = alignment or Vector2.new(0, 0)
    return imageLabel
end

local function ApplyTheme(themeName)
    -- ... (логика переключения темы)
    local colors = Themes[themeName]
    if not colors then return end

    UI_State.CurrentTheme = themeName
    CurrentColors = colors
    UI_State.Configuration.Theme = themeName

    local window = UI_State.Window
    if not window then return end
    
    window.BackgroundColor3 = colors.PRIMARY_BG
    -- (Здесь должна быть полная логика перерисовки, как в предыдущем ответе)
    
    print("🎨 Theme set to: " .. themeName)
end

local function SaveConfiguration()
    UI_State.Configuration.Theme = UI_State.CurrentTheme
    local jsonConfig = HTTP_SERVICE:JSONEncode(UI_State.Configuration)
    print("💾 Конфигурация сохранена (имитация writefile):")
    print(jsonConfig)
    return jsonConfig
end

local function SetupBaseUI(config)
    -- ... (логика создания базового UI)
    local player = PLAYERS.LocalPlayer
    local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
    
    local Window = Instance.new("Frame", ScreenGui)
    Window.Name = "WindUI_Window"
    Window.Size = UDim2.new(0, 700, 0, 500)
    Window.BackgroundColor3 = CurrentColors.PRIMARY_BG
    Window.Draggable = true
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 8)
    
    local TabBar = Instance.new("Frame", Window)
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0.3, 0, 1, 0)
    TabBar.BackgroundColor3 = CurrentColors.PANEL_BG
    
    local TabList = Instance.new("ScrollingFrame", TabBar)
    TabList.Name = "TabList"
    TabList.BackgroundTransparency = 1
    
    local ContentPanel = Instance.new("ScrollingFrame", Window)
    ContentPanel.Name = "ContentPanel"
    ContentPanel.BackgroundColor3 = CurrentColors.PRIMARY_BG

    return Window, TabList, ContentPanel
end

local function CreateElementFrameBase(contentFrame, text, subtitle)
    -- ... (логика создания базового фрейма элемента)
    local MainFrame = Instance.new("Frame", contentFrame)
    MainFrame.Size = UDim2.new(0.95, 0, 0, 45)
    MainFrame.BackgroundColor3 = CurrentColors.PANEL_BG
    local TitleLabel = Instance.new("TextLabel", MainFrame)
    TitleLabel.TextColor3 = CurrentColors.TEXT
    TitleLabel.BackgroundColor3 = CurrentColors.PANEL_BG
    return MainFrame
end

-- === ОСНОВНОЙ API БИБЛИОТЕКИ ===
local MyWindStyle = {}

function MyWindStyle:CreateWindow(config)
    
    -- Проверка ключа
    local keySettings = config.KeySettings or {}
    if config.KeySystem and not ValidateKey(keySettings.Key[1] or "", keySettings.Key or {}) then
        CreateErrorPrompt(keySettings.Title or "ACCESS DENIED", keySettings.Note or "Invalid key provided.")
        return nil
    end

    local Window, TabList, ContentPanel = SetupBaseUI(config)
    UI_State.Window = Window
    UI_State.TabList = TabList 
    UI_State.ContentPanel = ContentPanel
    
    -- Keybind
    local toggleKey = config.ToggleUIKeybind or "K"
    UI_SERVICE.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode[toggleKey] and not gameProcessed then
            Window.Visible = not Window.Visible
        end
    end)
    
    local WindowAPI = {
        ApplyTheme = ApplyTheme,
        SaveConfiguration = SaveConfiguration
    }
    
    function WindowAPI:CreateTab(name, lucideIconName)
        local tabFrame = Instance.new("Frame", ContentPanel)
        tabFrame.Visible = #ContentPanel:GetChildren() == 1
        -- ... (остальная логика создания вкладки)
        
        local TabButton = Instance.new("TextButton", TabList)
        TabButton.Text = name
        TabButton.TextColor3 = CurrentColors.TEXT
        TabButton.BackgroundColor3 = (#ContentPanel:GetChildren() == 1) and CurrentColors.ELEMENT_BG or CurrentColors.PANEL_BG
        
        CreateImageIcon(TabButton, lucideIconName, CurrentColors.MUTED_TEXT, nil, UDim2.new(0, 8, 0.5, 0), Vector2.new(0, 0.5))

        TabButton.MouseButton1Click:Connect(function()
             -- ... (логика переключения вкладок)
        end)
        
        local TabAPI = {}
        
        function TabAPI:CreateButton(text, subtitle, callback)
            local MainFrame = CreateElementFrameBase(tabFrame, text, subtitle)
            CreateImageIcon(MainFrame, "button", CurrentColors.ACCENT, nil, UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5))
            -- ... (логика кнопки)
        end
        
        function TabAPI:CreateToggle(text, subtitle, defaultValue, callback)
            local MainFrame = CreateElementFrameBase(tabFrame, text, subtitle)
            -- ... (логика тоглла)
            local StatusIcon = CreateImageIcon(MainFrame, defaultValue and "toggle_on" or "toggle_off", CurrentColors.ACCENT, nil, UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5))
            -- ... (логика тоглла)
        end
        
        return TabAPI
    end
    
    ApplyTheme(UI_State.CurrentTheme)
    return WindowAPI
end

return MyWindStyle -- Обязательный возврат API для лоадера
