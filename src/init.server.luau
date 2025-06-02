--Runs the Nexus Motor6D Creator plugin.
--!strict

local Selection = game:GetService("Selection")

local NexusPluginComponents = require(script:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))
local Motor6DWindow = require(script:WaitForChild("View"):WaitForChild("Motor6DWindow"))
local CreateWeldWindow = require(script:WaitForChild("View"):WaitForChild("CreateWeldWindow"))

local CreatePluginToggleButton = NexusPluginComponents.Input.Plugin.CreatePluginToggleButton



--Create the windows.
local MotorView = Motor6DWindow.new(plugin)
local WeldWindow = CreateWeldWindow(plugin)

--Create the toolbar.
local Motor6DCreatorToolbar = plugin:CreateToolbar("Motor6D Creator")
local Motor6DCreatorButton = Motor6DCreatorToolbar:CreateButton("Motor6D Creator", "Opens the window for creating Motor6Ds.", "rbxassetid://9414272825")
local WeldCreatorButton = Motor6DCreatorToolbar:CreateButton("Weld Creator", "Toggles the window for creating welds.", "rbxassetid://9414273305")
CreatePluginToggleButton(WeldCreatorButton, WeldWindow)
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
    --This prioritizes Motor6Ds over parts.
    local Motor6D: Motor6D? = nil
    local Part0: BasePart? = nil
    local Part1: BasePart? = nil
    for _, PartOrMotor in Selection:Get() do
        pcall(function()
            if PartOrMotor:IsA("BasePart") then
                if not Part0 then
                    Part0 = PartOrMotor
                elseif not Part1 then
                    Part1 = PartOrMotor
                end
            elseif PartOrMotor:IsA("Motor6D") then
                if not Motor6D then
                    Motor6D = PartOrMotor
                end
            end
        end)
        if Motor6D or (Part0 and Part1) then
            break
        end
    end
    if Motor6D then
        MotorView:LoadParts(Motor6D.Part0, Motor6D.Part1)
    elseif Part0 then
        MotorView:LoadParts(Part0, Part1)
    end
end)