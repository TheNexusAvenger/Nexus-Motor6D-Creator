--[[
TheNexusAvenger

Runs the Nexus Motor6D Creator plugin.
--]]
--!strict

local Selection = game:GetService("Selection")

local NexusPluginComponents = require(script:WaitForChild("NexusPluginComponents"))
local Motor6DWindow = require(script:WaitForChild("View"):WaitForChild("Motor6DWindow"))
local CreateWeldWindow = require(script:WaitForChild("View"):WaitForChild("CreateWeldWindow"))



--Create the windows.
local MotorView = Motor6DWindow.new(plugin)
local WeldWindow = CreateWeldWindow(plugin)

--Create the toolbar.
local Motor6DCreatorToolbar = plugin:CreateToolbar("Motor6D Creator")
local Motor6DCreatorButton = Motor6DCreatorToolbar:CreateButton("Motor6D Creator", "Opens the window for creating Motor6Ds.", "rbxassetid://9414272825")
local WeldCreatorButton = Motor6DCreatorToolbar:CreateButton("Weld Creator", "Toggles the window for creating welds.", "rbxassetid://9414273305")
NexusPluginComponents.new("PluginToggleButton", WeldCreatorButton, WeldWindow)
if MotorView.Window.Enabled then
    Motor6DCreatorButton:SetActive(true)
end

--Connect the toolbar.
MotorView.Window:GetPropertyChangedSignal("Enabled"):Connect(function()
    Motor6DCreatorButton:SetActive(MotorView.Window.Enabled)
end)

Motor6DCreatorButton.Click:Connect(function()
    --Show the window.
    MotorView.Window.Enabled = true

    --Get the Motor6D or the first 2 parts in the current selection.
    local Motor6Ds = {}
    local Parts = {}
    for _, PartOrMotor in Selection:Get() do
        pcall(function()
            if PartOrMotor:IsA("BasePart") then
                table.insert(Parts, PartOrMotor)
            elseif PartOrMotor:IsA("Motor6D") then
                table.insert(Motor6Ds, PartOrMotor)
            end
        end)
        if #Parts == 2 then
            break
        end
    end
    if #Motor6Ds > 0 then
        MotorView:LoadParts(Motor6Ds[1].Part0, Motor6Ds[1].Part1)
    elseif #Parts > 0 then
        MotorView:LoadParts(Parts[1], Parts[2])
    end
end)