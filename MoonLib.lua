-- MoonLib UI Library
-- Полностью переработанная версия Rayfield UI

local MoonLib = {}
MoonLib.__index = MoonLib

-- Конфигурация
MoonLib.Settings = {
    ToggleKey = Enum.KeyCode.RightShift,
    DefaultTheme = "Lunar",
    Watermark = "MoonLib",
    Version = "1.0.0"
}

-- Цветовые темы
MoonLib.Themes = {
    Lunar = {
        Main = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(240, 240, 255),
        DarkText = Color3.fromRGB(180, 180, 200),
        Success = Color3.fromRGB(85, 255, 127),
        Warning = Color3.fromRGB(255, 170, 0),
        Error = Color3.fromRGB(255, 85, 85)
    },
    Midnight = {
        Main = Color3.fromRGB(10, 10, 20),
        Secondary = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(170, 80, 255),
        Text = Color3.fromRGB(230, 230, 250),
        DarkText = Color3.fromRGB(160, 160, 180),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 100, 100)
    }
}

-- Сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Утилиты
function MoonLib:Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

function MoonLib:Tween(object, goals, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, goals)
    tween:Play()
    return tween
end

function MoonLib:RoundCorners(object, cornerRadius)
    local corner = self:Create("UICorner", {
        Parent = object,
        CornerRadius = UDim.new(0, cornerRadius or 6)
    })
    return corner
end

function MoonLib:CreateStroke(object, color, thickness)
    local stroke = self:Create("UIStroke", {
        Parent = object,
        Color = color or Color3.new(1, 1, 1),
        Thickness = thickness or 1
    })
    return stroke
end

-- Основной класс Window
function MoonLib:CreateWindow(options)
    options = options or {}
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Theme = options.Theme or self.Settings.DefaultTheme
    }
    
    -- Создание основного интерфейса
    local ScreenGui = self:Create("ScreenGui", {
        Name = "MoonLibUI",
        DisplayOrder = 10,
        ResetOnSpawn = false
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
    
    local MainFrame = self:Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = self.Themes[Window.Theme].Main,
        BorderSizePixel = 0
    })
    
    self:RoundCorners(MainFrame, 8)
    self:CreateStroke(MainFrame, self.Themes[Window.Theme].Accent, 2)
    
    -- Заголовок окна
    local TitleFrame = self:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Themes[Window.Theme].Secondary,
        BorderSizePixel = 0
    })
    
    self:RoundCorners(TitleFrame, 8)
    
    local TitleLabel = self:Create("TextLabel", {
        Parent = TitleFrame,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Name or "MoonLib Window",
        TextColor3 = self.Themes[Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Контейнер для вкладок
    local TabContainer = self:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1
    })
    
    -- Панель вкладок
    local TabButtonsFrame = self:Create("Frame", {
        Parent = TabContainer,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    local TabContentFrame = self:Create("Frame", {
        Parent = TabContainer,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })
    
    -- Функции Window
    function Window:CreateTab(name)
        local Tab = {
            Name = name,
            Sections = {},
            Buttons = {}
        }
        
        local TabButton = self:Create("TextButton", {
            Parent = TabButtonsFrame,
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(0, (#Window.Tabs * 85), 0, 0),
            BackgroundColor3 = MoonLib.Themes[Window.Theme].Secondary,
            Text = "",
            BorderSizePixel = 0
        })
        
        MoonLib:RoundCorners(TabButton, 6)
        
        local TabButtonLabel = self:Create("TextLabel", {
            Parent = TabButton,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = MoonLib.Themes[Window.Theme].Text,
            TextSize = 12,
            Font = Enum.Font.Gotham
        })
        
        local TabContent = self:Create("ScrollingFrame", {
            Parent = TabContentFrame,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = MoonLib.Themes[Window.Theme].Accent,
            Visible = false
        })
        
        local UIListLayout = self:Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- Функции Tab
        function Tab:CreateSection(name)
            local Section = {
                Name = name,
                Elements = {}
            }
            
            local SectionFrame = MoonLib:Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = MoonLib.Themes[Window.Theme].Secondary,
                LayoutOrder = #self.Sections + 1
            })
            
            MoonLib:RoundCorners(SectionFrame, 6)
            MoonLib:CreateStroke(SectionFrame, MoonLib.Themes[Window.Theme].Accent, 1)
            
            local SectionLabel = MoonLib:Create("TextLabel", {
                Parent = SectionFrame,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = MoonLib.Themes[Window.Theme].Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ElementsContainer = MoonLib:Create("Frame", {
                Parent = SectionFrame,
                Size = UDim2.new(1, -20, 1, -30),
                Position = UDim2.new(0, 10, 0, 25),
                BackgroundTransparency = 1
            })
            
            local ElementsListLayout = MoonLib:Create("UIListLayout", {
                Parent = ElementsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            Section.Frame = SectionFrame
            Section.ElementsContainer = ElementsContainer
            
            -- Функции Section
            function Section:CreateToggle(options)
                local Toggle = {
                    Value = options.Default or false,
                    Callback = options.Callback or function() end
                }
                
                local ToggleFrame = MoonLib:Create("Frame", {
                    Parent = ElementsContainer,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    LayoutOrder = #self.Elements + 1
                })
                
                local ToggleButton = MoonLib:Create("TextButton", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundColor3 = Toggle.Value and MoonLib.Themes[Window.Theme].Accent or MoonLib.Themes[Window.Theme].Secondary,
                    Text = "",
                    BorderSizePixel = 0
                })
                
                MoonLib:RoundCorners(ToggleButton, 4)
                
                local ToggleLabel = MoonLib:Create("TextLabel", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Toggle",
                    TextColor3 = MoonLib.Themes[Window.Theme].Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    ToggleButton.BackgroundColor3 = Toggle.Value and MoonLib.Themes[Window.Theme].Accent or MoonLib.Themes[Window.Theme].Secondary
                    Toggle.Callback(Toggle.Value)
                end)
                
                table.insert(self.Elements, Toggle)
                return Toggle
            end
            
            function Section:CreateButton(options)
                local Button = {
                    Callback = options.Callback or function() end
                }
                
                local ButtonFrame = MoonLib:Create("TextButton", {
                    Parent = ElementsContainer,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = MoonLib.Themes[Window.Theme].Accent,
                    Text = options.Name or "Button",
                    TextColor3 = MoonLib.Themes[Window.Theme].Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    LayoutOrder = #self.Elements + 1
                })
                
                MoonLib:RoundCorners(ButtonFrame, 6)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Button.Callback()
                end)
                
                table.insert(self.Elements, Button)
                return Button
            end
            
            function Section:CreateSlider(options)
                local Slider = {
                    Value = options.Default or options.Range[1],
                    Callback = options.Callback or function() end
                }
                
                local SliderFrame = MoonLib:Create("Frame", {
                    Parent = ElementsContainer,
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    LayoutOrder = #self.Elements + 1
                })
                
                local SliderLabel = MoonLib:Create("TextLabel", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Slider",
                    TextColor3 = MoonLib.Themes[Window.Theme].Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValue = MoonLib:Create("TextLabel", {
                    Parent = SliderFrame,
                    Size = UDim2.new(0, 40, 0, 15),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(Slider.Value),
                    TextColor3 = MoonLib.Themes[Window.Theme].DarkText,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderTrack = MoonLib:Create("Frame", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, 0, 0, 15),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = MoonLib.Themes[Window.Theme].Secondary,
                    BorderSizePixel = 0
                })
                
                MoonLib:RoundCorners(SliderTrack, 4)
                
                local SliderFill = MoonLib:Create("Frame", {
                    Parent = SliderTrack,
                    Size = UDim2.new((Slider.Value - options.Range[1]) / (options.Range[2] - options.Range[1]), 0, 1, 0),
                    BackgroundColor3 = MoonLib.Themes[Window.Theme].Accent,
                    BorderSizePixel = 0
                })
                
                MoonLib:RoundCorners(SliderFill, 4)
                
                local SliderButton = MoonLib:Create("TextButton", {
                    Parent = SliderTrack,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0
                })
                
                local function updateSlider(value)
                    local min, max = options.Range[1], options.Range[2]
                    local newValue = math.clamp(value, min, max)
                    Slider.Value = math.floor(newValue / options.Increment) * options.Increment
                    SliderValue.Text = tostring(Slider.Value)
                    SliderFill.Size = UDim2.new((Slider.Value - min) / (max - min), 0, 1, 0)
                    Slider.Callback(Slider.Value)
                end
                
                SliderButton.MouseButton1Down:Connect(function()
                    local connection
                    connection = RunService.Heartbeat:Connect(function()
                        local percent = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                        local value = options.Range[1] + (options.Range[2] - options.Range[1]) * percent
                        updateSlider(value)
                    end)
                    
                    local function disconnect()
                        connection:Disconnect()
                        UserInputService.InputEnded:Wait()
                    end
                    
                    UserInputService.InputEnded:Connect(disconnect)
                end)
                
                table.insert(self.Elements, Slider)
                return Slider
            end
            
            function Section:CreateDropdown(options)
                local Dropdown = {
                    Value = options.Default or options.List[1],
                    Callback = options.Callback or function() end,
                    Open = false
                }
                
                local DropdownFrame = MoonLib:Create("Frame", {
                    Parent = ElementsContainer,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    LayoutOrder = #self.Elements + 1
                })
                
                local DropdownButton = MoonLib:Create("TextButton", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundColor3 = MoonLib.Themes[Window.Theme].Secondary,
                    Text = Dropdown.Value,
                    TextColor3 = MoonLib.Themes[Window.Theme].Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0
                })
                
                MoonLib:RoundCorners(DropdownButton, 4)
                
                local DropdownList = MoonLib:Create("ScrollingFrame", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = MoonLib.Themes[Window.Theme].Main,
                    ScrollBarThickness = 3,
                    Visible = false,
                    BorderSizePixel = 0
                })
                
                MoonLib:RoundCorners(DropdownList, 4)
                MoonLib:CreateStroke(DropdownList, MoonLib.Themes[Window.Theme].Accent, 1)
                
                local function toggleDropdown()
                    Dropdown.Open = not Dropdown.Open
                    DropdownList.Visible = Dropdown.Open
                    
                    if Dropdown.Open then
                        MoonLib:Tween(DropdownList, {Size = UDim2.new(1, 0, 0, math.min(#options.List * 25, 100))}, 0.2)
                    else
                        MoonLib:Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                for i, option in ipairs(options.List) do
                    local OptionButton = MoonLib:Create("TextButton", {
                        Parent = DropdownList,
                        Size = UDim2.new(1, -10, 0, 20),
                        Position = UDim2.new(0, 5, 0, (i-1)*25),
                        BackgroundColor3 = MoonLib.Themes[Window.Theme].Secondary,
                        Text = option,
                        TextColor3 = MoonLib.Themes[Window.Theme].Text,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        BorderSizePixel = 0
                    })
                    
                    MoonLib:RoundCorners(OptionButton, 2)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownButton.Text = option
                        Dropdown.Callback(option)
                        toggleDropdown()
                    end)
                end
                
                table.insert(self.Elements, Dropdown)
                return Dropdown
            end
            
            table.insert(self.Sections, Section)
            return Section
        end
        
        -- Обработчик клика по вкладке
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Content.Visible = false
            end
            Window.CurrentTab = Tab
            Tab.Content.Visible = true
        end)
        
        table.insert(Window.Tabs, Tab)
        
        -- Автоматически выбираем первую вкладку
        if #Window.Tabs == 1 then
            Tab.Content.Visible = true
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    -- Переключение видимости окна
    local function toggleVisibility()
        MainFrame.Visible = not MainFrame.Visible
    end
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == MoonLib.Settings.ToggleKey then
            toggleVisibility()
        end
    end)
    
    -- Делаем окно перетаскиваемым
    local dragging = false
    local dragInput, dragStart, startPos
    
    TitleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return Window
end

-- Инициализация
function MoonLib:Init()
    print("MoonLib UI Library loaded successfully!")
    print("Version: " .. self.Settings.Version)
    print("Toggle Key: " .. tostring(self.Settings.ToggleKey))
end

-- Экспорт библиотеки
MoonLib:Init()
return MoonLib
