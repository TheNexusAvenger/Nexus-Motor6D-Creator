--[[
TheNexusAvenger

View for editting Motor6D properties.
--]]

local NexusPluginFramework = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"))
local Header = require(script.Parent:WaitForChild("Row"):WaitForChild("Header"))
local InstanceRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("InstanceRowProperty"))

local Motor6DView = NexusPluginFramework:GetResource("Base.PluginInstance"):Extend()
Motor6DView:SetClassName("Motor6DView")

--[[
Creates the Motor6D view.
--]]
function Motor6DView:__new()
    self:InitializeSuper("Frame")
    self.BorderSizePixel = 1

    --Create the part property rows.
    local PartPropertiesHeader = Header.new()
    PartPropertiesHeader.Text = "Parts"
    PartPropertiesHeader.Parent = self

    local Part0PropertyRow = InstanceRowProperty.new()
    Part0PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 1)
    Part0PropertyRow.Text = "Part0"
    Part0PropertyRow.Parent = self

    local Part1PropertyRow = InstanceRowProperty.new()
    Part1PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 2)
    Part1PropertyRow.Text = "Part1"
    Part1PropertyRow.Parent = self

    --Create the rotation property rows.
    local RotationPropertiesHeader = Header.new()
    RotationPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 3)
    RotationPropertiesHeader.Text = "Rotation"
    RotationPropertiesHeader.Parent = self

    --TODO: Create sliders.

    --Create the position property rows.
    local PositionPropertiesHeader = Header.new()
    PositionPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 7)
    PositionPropertiesHeader.Text = "Position"
    PositionPropertiesHeader.Parent = self

    --TODO: Create sliders.
end



return Motor6DView