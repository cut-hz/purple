--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║         PURPLE GLASS HUB - Delta Executor Script             ║
    ║     Modular UI System with Wind UI-like Element Generation   ║
    ║                   Multi-Game Support (MM2+)                  ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    Features:
    - Glassmorphism UI with purple theme
    - Modular tab system
    - Draggable panels with minimize
    - Key in Tab support
    - Extensible component library
    - Wind UI-like API
]]

local PurpleHub = {}
PurpleHub.__index = PurpleHub

-- ============================================================================
-- COLOR PALETTE (Glassmorphism Purple Theme)
-- ============================================================================
local Colors = {
    Background = Color3.fromRGB(18, 18, 35),      -- Deep purple
    CardBg = Color3.fromRGB(40, 30, 80),          -- Card background
    Primary = Color3.fromRGB(167, 139, 250),      -- Purple accent
    Secondary = Color3.fromRGB(100, 80, 180),     -- Secondary purple
    Text = Color3.fromRGB(250, 250, 250),         -- White text
    TextSecondary = Color3.fromRGB(180, 180, 200), -- Secondary text
    Border = Color3.fromRGB(100, 80, 150),        -- Border color
    Success = Color3.fromRGB(76, 175, 80),        -- Green
    Error = Color3.fromRGB(244, 67, 54),          -- Red
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        pcall(function()
            instance[prop] = value
        end)
    end
    return instance
end

local function CreateLabel(text, size, color)
    local label = CreateInstance("TextLabel", {
        Text = text,
        TextSize = size,
        TextColor3 = color,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    })
    return label
end

local function CreateButton(text, size, callback)
    local button = CreateInstance("TextButton", {
        Text = text,
        TextSize = size,
        TextColor3 = Colors.Text,
        BackgroundColor3 = Colors.Primary,
        BackgroundTransparency = 0.2,
        BorderColor3 = Colors.Primary,
        BorderSizePixel = 1,
        Font = Enum.Font.GothamBold,
    })
    
    button.MouseButton1Click:Connect(callback or function() end)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.1
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0.2
    end)
    
    return button
end

-- ============================================================================
-- MAIN HUB CLASS
-- ============================================================================
function PurpleHub.new(hubName)
    local self = setmetatable({}, PurpleHub)
    
    self.Name = hubName or "Purple Hub"
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsDragging = false
    self.DragStart = nil
    self.KeyBinds = {}
    self.Settings = {}
    
    self:CreateUI()
    
    return self
end

function PurpleHub:CreateUI()
    -- Main container
    local screenGui = CreateInstance("ScreenGui", {
        Name = "PurpleHubGui",
        ResetOnSpawn = false,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    screenGui.Parent = game:GetService("CoreGui")
    
    self.ScreenGui = screenGui
    
    -- Main panel (glassmorphism effect)
    local mainPanel = CreateInstance("Frame", {
        Name = "MainPanel",
        Size = UDim2.new(0, 400, 0, 500),
        Position = UDim2.new(0.5, -200, 0.5, -250),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.15,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
    })
    mainPanel.Parent = screenGui
    
    -- Add corner radius
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 12)})
    corner.Parent = mainPanel
    
    self.MainPanel = mainPanel
    
    -- Header
    local header = CreateInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    })
    header.Parent = mainPanel
    
    -- Header corner
    local headerCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 12)})
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = CreateLabel(self.Name, 18, Colors.Primary)
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Minimize button
    local minimizeBtn = CreateButton("−", 20, function()
        self:ToggleMinimize()
    end)
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
    minimizeBtn.Parent = header
    
    -- Close button
    local closeBtn = CreateButton("✕", 20, function()
        self:Close()
    end)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
    closeBtn.Parent = header
    
    -- Make header draggable
    self:MakeDraggable(header)
    
    -- Tab bar
    local tabBar = CreateInstance("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    })
    tabBar.Parent = mainPanel
    
    local tabLayout = CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
    })
    tabLayout.Parent = tabBar
    
    self.TabBar = tabBar
    
    -- Content area
    local contentArea = CreateInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 90),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    contentArea.Parent = mainPanel
    
    self.ContentArea = contentArea
    
    -- Padding
    local padding = CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })
    padding.Parent = contentArea
    
    -- Content layout
    local contentLayout = CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Fill,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 8),
    })
    contentLayout.Parent = contentArea
    
    self.ContentLayout = contentLayout
    
    self.IsMinimized = false
end

function PurpleHub:MakeDraggable(element)
    local UserInputService = game:GetService("UserInputService")
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    element.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = mouse.X - self.MainPanel.AbsolutePosition.X
            startPos = self.MainPanel.Position
        end
    end)
    
    element.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = mouse.X - (self.MainPanel.AbsolutePosition.X + dragStart)
            self.MainPanel.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta,
                startPos.Y.Scale,
                startPos.Y.Offset
            )
        end
    end)
end

function PurpleHub:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        self.TabBar.Visible = false
        self.ContentArea.Visible = false
        self.MainPanel.Size = UDim2.new(0, 400, 0, 50)
    else
        self.TabBar.Visible = true
        self.ContentArea.Visible = true
        self.MainPanel.Size = UDim2.new(0, 400, 0, 500)
    end
end

function PurpleHub:AddTab(tabName)
    local tab = {
        Name = tabName,
        Elements = {},
        Frame = nil,
    }
    
    -- Create tab button
    local tabButton = CreateButton(tabName, 12, function()
        self:SelectTab(tabName)
    end)
    tabButton.Size = UDim2.new(0, 80, 1, 0)
    tabButton.Parent = self.TabBar
    
    -- Create tab content frame
    local tabFrame = CreateInstance("Frame", {
        Name = tabName .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
    })
    tabFrame.Parent = self.ContentArea
    
    local tabLayout = CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Fill,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 5),
    })
    tabLayout.Parent = tabFrame
    
    local tabPadding = CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
    })
    tabPadding.Parent = tabFrame
    
    tab.Frame = tabFrame
    tab.Button = tabButton
    
    self.Tabs[tabName] = tab
    
    -- Select first tab automatically
    if not self.ActiveTab then
        self:SelectTab(tabName)
    end
    
    return tab
end

function PurpleHub:SelectTab(tabName)
    -- Hide all tabs
    for name, tab in pairs(self.Tabs) do
        tab.Frame.Visible = false
        tab.Button.BackgroundTransparency = 0.3
    end
    
    -- Show selected tab
    if self.Tabs[tabName] then
        self.Tabs[tabName].Frame.Visible = true
        self.Tabs[tabName].Button.BackgroundTransparency = 0.1
        self.ActiveTab = tabName
    end
end

-- ============================================================================
-- COMPONENT BUILDERS (Wind UI Style)
-- ============================================================================

function PurpleHub:AddLabel(tabName, text)
    if not self.Tabs[tabName] then return end
    
    local label = CreateLabel(text, 14, Colors.TextSecondary)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Parent = self.Tabs[tabName].Frame
    
    return label
end

function PurpleHub:AddButton(tabName, text, callback)
    if not self.Tabs[tabName] then return end
    
    local button = CreateButton(text, 14, callback)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Parent = self.Tabs[tabName].Frame
    
    return button
end

function PurpleHub:AddToggle(tabName, text, defaultValue, callback)
    if not self.Tabs[tabName] then return end
    
    local container = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.5,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
    })
    container.Parent = self.Tabs[tabName].Frame
    
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8)})
    corner.Parent = container
    
    local label = CreateLabel(text, 12, Colors.Text)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = CreateInstance("TextButton", {
        Name = "Toggle",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BackgroundColor3 = defaultValue and Colors.Primary or Colors.Secondary,
        BorderSizePixel = 0,
        Text = "",
    })
    toggle.Parent = container
    
    local toggleCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10)})
    toggleCorner.Parent = toggle
    
    local toggleState = {Value = defaultValue or false}
    
    toggle.MouseButton1Click:Connect(function()
        toggleState.Value = not toggleState.Value
        toggle.BackgroundColor3 = toggleState.Value and Colors.Primary or Colors.Secondary
        if callback then callback(toggleState.Value) end
    end)
    
    return toggleState
end

function PurpleHub:AddSlider(tabName, text, minValue, maxValue, defaultValue, callback)
    if not self.Tabs[tabName] then return end
    
    local container = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    container.Parent = self.Tabs[tabName].Frame
    
    local label = CreateLabel(text, 12, Colors.Text)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Parent = container
    
    local valueLabel = CreateLabel(tostring(defaultValue or minValue), 11, Colors.Primary)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBg = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Colors.Secondary,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
    })
    sliderBg.Parent = container
    
    local sliderCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4)})
    sliderCorner.Parent = sliderBg
    
    local sliderFill = CreateInstance("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0,
    })
    sliderFill.Parent = sliderBg
    
    local fillCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4)})
    fillCorner.Parent = sliderFill
    
    local sliderState = {Value = defaultValue or minValue}
    
    local UserInputService = game:GetService("UserInputService")
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderSize = sliderBg.AbsoluteSize.X
            local mousePos = math.clamp(mouse.X - sliderPos, 0, sliderSize)
            local percentage = mousePos / sliderSize
            
            sliderState.Value = math.floor(minValue + (maxValue - minValue) * percentage)
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            valueLabel.Text = tostring(sliderState.Value)
            
            if callback then callback(sliderState.Value) end
        end
    end)
    
    return sliderState
end

function PurpleHub:AddDropdown(tabName, text, options, defaultOption, callback)
    if not self.Tabs[tabName] then return end
    
    local container = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.5,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
    })
    container.Parent = self.Tabs[tabName].Frame
    
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8)})
    corner.Parent = container
    
    local label = CreateLabel(text, 12, Colors.Text)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdownBtn = CreateButton(defaultOption or options[1], 11, function()
        -- Dropdown logic here
    end)
    dropdownBtn.Size = UDim2.new(1, -120, 1, 0)
    dropdownBtn.Position = UDim2.new(0, 110, 0, 0)
    dropdownBtn.Parent = container
    
    local dropdownState = {Value = defaultOption or options[1]}
    
    return dropdownState
end

function PurpleHub:AddKeyBind(tabName, text, defaultKey, callback)
    if not self.Tabs[tabName] then return end
    
    local container = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.5,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
    })
    container.Parent = self.Tabs[tabName].Frame
    
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8)})
    corner.Parent = container
    
    local label = CreateLabel(text, 12, Colors.Text)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keyBtn = CreateButton(defaultKey, 11, function()
        -- Key bind listening
    end)
    keyBtn.Size = UDim2.new(0, 40, 1, 0)
    keyBtn.Position = UDim2.new(1, -45, 0, 0)
    keyBtn.Parent = container
    
    local keybindState = {Key = defaultKey, Callback = callback}
    
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[defaultKey] then
            if callback then callback() end
        end
    end)
    
    return keybindState
end

function PurpleHub:AddTextBox(tabName, text, placeholder, callback)
    if not self.Tabs[tabName] then return end
    
    local container = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Colors.CardBg,
        BackgroundTransparency = 0.5,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
    })
    container.Parent = self.Tabs[tabName].Frame
    
    local corner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8)})
    corner.Parent = container
    
    local label = CreateLabel(text, 12, Colors.Text)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local textBox = CreateInstance("TextBox", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        BackgroundTransparency = 0.3,
        BackgroundColor3 = Colors.Background,
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextSecondary,
        PlaceholderText = placeholder or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        BorderSizePixel = 0,
    })
    textBox.Parent = container
    
    local textBoxCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6)})
    textBoxCorner.Parent = textBox
    
    local textBoxState = {Value = ""}
    
    textBox.FocusLost:Connect(function(enterPressed)
        textBoxState.Value = textBox.Text
        if callback then callback(textBoxState.Value) end
    end)
    
    return textBoxState
end

function PurpleHub:Close()
    self.ScreenGui:Destroy()
end

-- ====================
return PurpleHub
