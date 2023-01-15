--[[
TheNexusAvenger

Row property for a slider.
--]]
--!strict

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local NexusPluginFramework = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"))
local BaseRowProperty = require(script.Parent:WaitForChild("BaseRowProperty"))

local SliderRowProperty = BaseRowProperty:Extend()
SliderRowProperty:SetClassName("InstanceRowProperty")

export type SliderRowProperty = {
    new: () -> (SliderRowProperty),
    Extend: (self: SliderRowProperty) -> (SliderRowProperty),

    Value: number,
    MinimumValue: number,
    MaximumValue: number,
} & BaseRowProperty.BaseRowProperty



--[[
Creates the slider row property.
--]]
function SliderRowProperty:__new(): ()
    BaseRowProperty.__new(self)

    --Create the additional frames.
    local InputTextBox = NexusPluginFramework.new("TextBox")
    InputTextBox.Size = UDim2.new(0, 40, 0, 22)
    InputTextBox.Parent = self.PropertyAdornFrame

    local InputSlider = NexusPluginFramework.new("Slider")
    InputSlider.AnchorPoint = Vector2.new(1, 0)
    InputSlider.Size = UDim2.new(1, -42, 1, 0)
    InputSlider.Position = UDim2.new(1, 0, 0, 0)
    InputSlider.Parent = self.PropertyAdornFrame
    InputSlider:ConnectTextBox(InputTextBox)

    --Connect the custom properties.
    self:DisableChangeReplication("Value")
    self:GetPropertyChangedSignal("Value"):Connect(function()
        InputSlider.Value = self.Value
    end)
    InputSlider:GetPropertyChangedSignal("Value"):Connect(function()
        self.Value = InputSlider.Value
    end)
    self:DisableChangeReplication("MinimumValue")
    self:GetPropertyChangedSignal("MinimumValue"):Connect(function()
        InputSlider.MinimumValue = self.MinimumValue
    end)
    self:DisableChangeReplication("MaximumValue")
    self:GetPropertyChangedSignal("MaximumValue"):Connect(function()
        InputSlider.MaximumValue = self.MaximumValue
    end)

    --Set the defaults.
    self.Value = 0
    self.MinimumValue = -0.5
    self.MaximumValue = 0.5
end



return (SliderRowProperty :: any) :: SliderRowProperty