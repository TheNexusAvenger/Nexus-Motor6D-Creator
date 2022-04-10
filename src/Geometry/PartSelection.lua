--[[
TheNexusAvenger

Shows a selection box for selecting parts.
--]]

local SELECTION_START_COLOR = Color3.new(0, 200 / 255, 0)
local SELECTION_END_COLOR = Color3.new(1, 1, 1)

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local NexusPluginFramework = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"))
local GetMouseTarget = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("GetMouseTarget"))

local PartSelection = NexusPluginFramework:GetResource("NexusInstance.NexusInstance"):Extend()
PartSelection:SetClassName("PartSelection")



--[[
Creates the part selection.
--]]
function PartSelection:__new()
    self:InitializeSuper()

    --Create the selection box.
    local SelectionBox = Instance.new("SelectionBox")
    SelectionBox.Color3 = SELECTION_START_COLOR
    SelectionBox.LineThickness = 0.05
    SelectionBox.Parent = CoreGui
    self.SelectionBox = SelectionBox

    self.Events = {}
    table.insert(self.Events, RunService.RenderStepped:Connect(function()
        SelectionBox.Color3 = SELECTION_START_COLOR:Lerp(SELECTION_END_COLOR, (math.sin((tick() * math.pi) % (math.pi * 2)) + 1) * 0.5)
    end))
end

--[[
Static function for prompting for a part.
--]]
function PartSelection.PromptForPart(): BasePart?
    local Selection = PartSelection.new()
    local SelectedPart = Selection:PromptSelection()
    Selection:Destroy()
    return SelectedPart
end

--[[
Prompts for a part selection.
--]]
function PartSelection:PromptSelection(): BasePart?
    --Connect updating the mouse.
    table.insert(self.Events, UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        --Update the selection.
        self.Selection = GetMouseTarget(Input.Position.X, Input.Position.Y)
        self.SelectionBox.Adornee = self.Selection
    end))

    --Wait for a mouse click.
    while true do
        local Input, Processed = UserInputService.InputBegan:Wait()
        if not Processed and Input.UserInputType == Enum.UserInputType.MouseButton1 then break end
    end

    --Return the CFrame.
    return self.Selection
end

--[[
Destroys the part selection.
--]]
function PartSelection:Destroy(): nil
    self.super:Destroy()

    self.SelectionBox:Destroy()
    for _, Event in pairs(self.Events) do
        Event:Disconnect()
    end
end



return PartSelection