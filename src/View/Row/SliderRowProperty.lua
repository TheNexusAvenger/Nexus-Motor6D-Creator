--[[
TheNexusAvenger

Row property for a slider.
--]]

local NexusPluginFramework = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))

local InstanceRowProperty = require(script.Parent:WaitForChild("BaseRowProperty")):Extend()
InstanceRowProperty:SetClassName("InstanceRowProperty")



--[[
Creates the instance row property.
--]]
function InstanceRowProperty:__new()
    self:InitializeSuper()

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



return InstanceRowProperty