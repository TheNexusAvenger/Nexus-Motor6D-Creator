--[[
TheNexusAvenger

View for editting Motor6D properties.
--]]

local NexusPluginFramework = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"))
local Header = require(script.Parent:WaitForChild("Row"):WaitForChild("Header"))
local InstanceRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("InstanceRowProperty"))
local SliderRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("SliderRowProperty"))

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

    --Create the position property rows.
    local PositionPropertiesHeader = Header.new()
    PositionPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 3)
    PositionPropertiesHeader.Text = "Position Offset"
    PositionPropertiesHeader.Parent = self

    local PositionXSlider = SliderRowProperty.new()
    PositionXSlider.Position = UDim2.new(0, 0, 0, 23 * 4)
    PositionXSlider.Text = "X Axis"
    PositionXSlider.Parent = self

    local PositionYSlider = SliderRowProperty.new()
    PositionYSlider.Position = UDim2.new(0, 0, 0, 23 * 5)
    PositionYSlider.Text = "Y Axis"
    PositionYSlider.Parent = self

    local PositionZSlider = SliderRowProperty.new()
    PositionZSlider.Position = UDim2.new(0, 0, 0, 23 * 6)
    PositionZSlider.Text = "Z Axis"
    PositionZSlider.Parent = self

    --Create the rotation property rows.
    local RotationPropertiesHeader = Header.new()
    RotationPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 7)
    RotationPropertiesHeader.Text = "Rotation Offset"
    RotationPropertiesHeader.Parent = self

    local RotationXSlider = SliderRowProperty.new()
    RotationXSlider.Position = UDim2.new(0, 0, 0, 23 * 8)
    RotationXSlider.Text = "X Axis"
    RotationXSlider.MinimumValue = -180
    RotationXSlider.MaximumValue = 180
    RotationXSlider.Parent = self

    local RotationYSlider = SliderRowProperty.new()
    RotationYSlider.Position = UDim2.new(0, 0, 0, 23 * 9)
    RotationYSlider.Text = "Y Axis"
    RotationYSlider.MinimumValue = -180
    RotationYSlider.MaximumValue = 180
    RotationYSlider.Parent = self

    local RotationZSlider = SliderRowProperty.new()
    RotationZSlider.Position = UDim2.new(0, 0, 0, 23 * 10)
    RotationZSlider.Text = "Z Axis"
    RotationZSlider.MinimumValue = -180
    RotationZSlider.MaximumValue = 180
    RotationZSlider.Parent = self

    --Create the toggle for local/global rotation.
    local LocalSpaceCheckbox = NexusPluginFramework.new("Checkbox")
    LocalSpaceCheckbox.Size = UDim2.new(0, 13, 0, 13)
    LocalSpaceCheckbox.Position = UDim2.new(0, 4, 0, (23 * 11) + 4)
    LocalSpaceCheckbox.Value = "Checked"
    LocalSpaceCheckbox.Parent = self

    local LocalSpaceText = NexusPluginFramework.new("TextLabel")
    LocalSpaceText.Size = UDim2.new(0, 200, 0, 13)
    LocalSpaceText.Position = UDim2.new(0, 24, 0, (23 * 11) + 4)
    LocalSpaceText.Text = "Rotation relative to selected pivot"
    LocalSpaceText.Parent = self
end



return Motor6DView