--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║         PURPLE HUB - MM2 EXAMPLE IMPLEMENTATION              ║
    ║            With Key in Tab Support                           ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    This is an example of how to use the Purple Hub system
    to create a functional MM2 exploit hub.
    
    Usage:
    1. Load the PurpleHub module
    2. Create a new hub instance
    3. Add tabs and elements
    4. Implement your functions
]]

-- Load the Purple Hub module
local PurpleHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/purple-hub/main/purple-hub-script.lua"))()

-- Create hub instance
local Hub = PurpleHub.new("Purple Hub - MM2")

-- ============================================================================
-- CONFIGURATION TAB
-- ============================================================================
Hub:AddTab("Config")

-- Key in Tab support - allows toggling features with keyboard
local KeyInTabEnabled = Hub:AddToggle("Config", "Key in Tab", false, function(value)
    print("Key in Tab: " .. tostring(value))
end)

-- Password/Key input
local PasswordInput = Hub:AddTextBox("Config", "Hub Password", "Enter password", function(value)
    print("Password entered: " .. value)
end)

-- Hub visibility toggle
local HubVisible = Hub:AddToggle("Config", "Hub Visible", true, function(value)
    Hub.MainPanel.Visible = value
end)

-- ============================================================================
-- PLAYER TAB (Empty for extension)
-- ============================================================================
Hub:AddTab("Player")

Hub:AddLabel("Player", "Player Features")
Hub:AddButton("Player", "Add Feature Here", function()
    print("Implement player features")
end)

-- Example: Speed slider (empty implementation)
local speedSlider = Hub:AddSlider("Player", "Speed", 0, 100, 50, function(value)
    print("Speed set to: " .. value)
    -- Implement speed modification here
end)

-- Example: Jump power toggle
local jumpToggle = Hub:AddToggle("Player", "Infinite Jump", false, function(value)
    print("Infinite Jump: " .. tostring(value))
    -- Implement infinite jump here
end)

-- ============================================================================
-- COMBAT TAB (Empty for extension)
-- ============================================================================
Hub:AddTab("Combat")

Hub:AddLabel("Combat", "Combat Features")

-- Example: ESP toggle
local espToggle = Hub:AddToggle("Combat", "Player ESP", false, function(value)
    print("ESP: " .. tostring(value))
    -- Implement ESP here
end)

-- Example: Aimbot toggle
local aimbotToggle = Hub:AddToggle("Combat", "Aimbot", false, function(value)
    print("Aimbot: " .. tostring(value))
    -- Implement aimbot here
end)

-- Example: Damage slider
local damageSlider = Hub:AddSlider("Combat", "Damage Multiplier", 1, 10, 1, function(value)
    print("Damage multiplier: " .. value)
    -- Implement damage modification here
end)

-- ============================================================================
-- VISUAL TAB (Empty for extension)
-- ============================================================================
Hub:AddTab("Visual")

Hub:AddLabel("Visual", "Visual Features")

-- Example: Chams toggle
local chamsToggle = Hub:AddToggle("Visual", "Chams", false, function(value)
    print("Chams: " .. tostring(value))
    -- Implement chams here
end)

-- Example: Wallhack toggle
local wallhackToggle = Hub:AddToggle("Visual", "Wallhack", false, function(value)
    print("Wallhack: " .. tostring(value))
    -- Implement wallhack here
end)

-- Example: FOV slider
local fovSlider = Hub:AddSlider("Visual", "FOV", 60, 120, 80, function(value)
    print("FOV: " .. value)
    -- Implement FOV change here
end)

-- ============================================================================
-- SETTINGS TAB
-- ============================================================================
Hub:AddTab("Settings")

Hub:AddLabel("Settings", "Hub Settings")

-- Theme toggle
local darkMode = Hub:AddToggle("Settings", "Dark Mode", true, function(value)
    print("Dark Mode: " .. tostring(value))
end)

-- Auto-load toggle
local autoLoad = Hub:AddToggle("Settings", "Auto-load on Join", true, function(value)
    print("Auto-load: " .. tostring(value))
end)

-- Notification toggle
local notifications = Hub:AddToggle("Settings", "Notifications", true, function(value)
    print("Notifications: " .. tostring(value))
end)

Hub:AddButton("Settings", "Reset All Settings", function()
    print("Settings reset")
end)

Hub:AddButton("Settings", "Save Settings", function()
    print("Settings saved")
end)

-- ============================================================================
-- KEYBIND SYSTEM
-- ============================================================================

-- Global keybinds
local Keybinds = {}

-- Example: F key to toggle ESP
Keybinds.ToggleESP = Hub:AddKeyBind("Config", "Toggle ESP", "F", function()
    espToggle.Value = not espToggle.Value
    print("ESP toggled: " .. tostring(espToggle.Value))
end)

-- Example: V key to toggle Aimbot
Keybinds.ToggleAimbot = Hub:AddKeyBind("Config", "Toggle Aimbot", "V", function()
    aimbotToggle.Value = not aimbotToggle.Value
    print("Aimbot toggled: " .. tostring(aimbotToggle.Value))
end)

-- Example: X key to toggle Hub visibility
Keybinds.ToggleHub = Hub:AddKeyBind("Config", "Toggle Hub", "X", function()
    Hub:ToggleMinimize()
    print("Hub toggled")
end)

-- ============================================================================
-- KEY IN TAB IMPLEMENTATION
-- ============================================================================

local UserInputService = game:GetService("UserInputService")

-- When Key in Tab is enabled, pressing number keys switches tabs
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if not KeyInTabEnabled.Value then return end
    
    -- Tab switching with number keys (1-9)
    if input.KeyCode == Enum.KeyCode.One then
        Hub:SelectTab("Config")
        print("Switched to Config tab")
    elseif input.KeyCode == Enum.KeyCode.Two then
        Hub:SelectTab("Player")
        print("Switched to Player tab")
    elseif input.KeyCode == Enum.KeyCode.Three then
        Hub:SelectTab("Combat")
        print("Switched to Combat tab")
    elseif input.KeyCode == Enum.KeyCode.Four then
        Hub:SelectTab("Visual")
        print("Switched to Visual tab")
    elseif input.KeyCode == Enum.KeyCode.Five then
        Hub:SelectTab("Settings")
        print("Switched to Settings tab")
    end
end)

-- ============================================================================
-- GAME DETECTION & AUTO-LOAD
-- ============================================================================

local function GetCurrentGame()
    local placeId = game.PlaceId
    
    if placeId == 142823291 then
        return "MM2"
    elseif placeId == 606849621 then
        return "Arsenal"
    elseif placeId == 1224901064 then
        return "Jailbreak"
    else
        return "Unknown"
    end
end

local currentGame = GetCurrentGame()
print("Detected game: " .. currentGame)

-- ============================================================================
-- EXAMPLE: ADD MORE GAMES
-- ============================================================================

-- To add support for more games, create new tabs and functions:
--[[
if currentGame == "Arsenal" then
    Hub:AddTab("Arsenal")
    Hub:AddLabel("Arsenal", "Arsenal-specific features")
    -- Add Arsenal features here
end

if currentGame == "Jailbreak" then
    Hub:AddTab("Jailbreak")
    Hub:AddLabel("Jailbreak", "Jailbreak-specific features")
    -- Add Jailbreak features here
end
]]

-- ============================================================================
-- UTILITY FUNCTIONS (Add your implementations here)
-- ============================================================================

local function EnableESP()
    -- Implement ESP here
    print("[ESP] Enabled")
end

local function DisableESP()
    -- Implement ESP disable here
    print("[ESP] Disabled")
end

local function EnableAimbot()
    -- Implement Aimbot here
    print("[Aimbot] Enabled")
end

local function DisableAimbot()
    -- Implement Aimbot disable here
    print("[Aimbot] Disabled")
end

-- ============================================================================
-- SCRIPT LOADED MESSAGE
-- ============================================================================

print("╔════════════════════════════════════════╗")
print("║   Purple Hub Loaded Successfully!     ║")
print("║   Game: " .. currentGame)
print("║   Press X to toggle hub               ║")
print("║   Enable 'Key in Tab' for quick nav   ║")
print("╚════════════════════════════════════════╝")

-- Keep script alive
while true do
    wait(1)
end
