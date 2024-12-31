--Shows a selection box for selecting parts.
--!strict

local SELECTION_START_COLOR = Color3.fromRGB(0, 200, 0)
local SELECTION_END_COLOR = Color3.fromRGB(255, 255, 255)

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local GetMouseTarget = require(NexusMotor6DCreatorPlugin:WaitForChild("Util"):WaitForChild("GetMouseTarget"))

local PartSelection = {}
PartSelection.__index = PartSelection

export type PartSelection = {
    SelectionBox: SelectionBox,
    Selection: BasePart?,
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, PartSelection))



--[[
Creates the part selection.
--]]
function PartSelection.new(): PartSelection
    --Create the selection box.
    local SelectionBox = Instance.new("SelectionBox")
    SelectionBox.Color3 = SELECTION_START_COLOR
    SelectionBox.LineThickness = 0.05
    SelectionBox.Parent = CoreGui

    --Create the object.
    local self = setmetatable({
        SelectionBox = SelectionBox,
        EventConnections = {},
    }, PartSelection) :: PartSelection

    --Animate the SelectionBox color.
    table.insert(self.EventConnections, RunService.RenderStepped:Connect(function()
        SelectionBox.Color3 = SELECTION_START_COLOR:Lerp(SELECTION_END_COLOR, (math.sin((tick() * math.pi) % (math.pi * 2)) + 1) * 0.5)
    end))

    --Return the object.
    return self
end

--[[
Prompts for a part selection.
--]]
function PartSelection.PromptSelection(self: PartSelection): BasePart?
    --Connect updating the mouse.
    table.insert(self.EventConnections, UserInputService.InputChanged:Connect(function(Input)
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
function PartSelection.Destroy(self: PartSelection): ()
    for _, Event in self.EventConnections do
        Event:Disconnect()
    end
    self.EventConnections = {}
    
    self.Selection = nil
    self.SelectionBox:Destroy()
end



return PartSelection