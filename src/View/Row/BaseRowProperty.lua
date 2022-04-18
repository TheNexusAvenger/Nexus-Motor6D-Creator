--[[
TheNexusAvenger

Base row frame for a property.
--]]

local NexusPluginFramework = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))

local BaseRowProperty = NexusPluginFramework:GetResource("Base.PluginInstance"):Extend()
BaseRowProperty:SetClassName("BaseRowProperty")


--[[
Creates the base row property.
--]]
function BaseRowProperty:__new()
    self:InitializeSuper("Frame")

    --Create the child frames.
    local NameFrame = NexusPluginFramework.new("Frame")
    NameFrame.BorderSizePixel = 1
    NameFrame.ClipsDescendants = true
    NameFrame.Parent = self

    local NameText = NexusPluginFramework.new("TextLabel")
    NameText.Size = UDim2.new(1, -4, 1, 0)
    NameText.Position = UDim2.new(0, 4, 0, 0)
    NameText.TextXAlignment = Enum.TextXAlignment.Left
    NameText.TextYAlignment = Enum.TextYAlignment.Center
    NameText.Parent = NameFrame

    local PropertyAdornFrame = NexusPluginFramework.new("Frame")
    PropertyAdornFrame.BorderSizePixel = 1
    PropertyAdornFrame.ClipsDescendants = true
    PropertyAdornFrame.Parent = self
    self:DisableChangeReplication("PropertyAdornFrame")
    self.PropertyAdornFrame = PropertyAdornFrame

    --Connect the custom properties.
    self:DisableChangeReplication("NameWidth")
    self:GetPropertyChangedSignal("NameWidth"):Connect(function()
        NameFrame.Size = UDim2.new(0, self.NameWidth, 1, 0)
        PropertyAdornFrame.Size = UDim2.new(1, -(self.NameWidth + 1), 1, 0)
        PropertyAdornFrame.Position = UDim2.new(0, self.NameWidth + 1, 0, 0)
    end)
    self:DisableChangeReplication("Text")
    self:GetPropertyChangedSignal("Text"):Connect(function()
        NameText.Text = self.Text
    end)

    --Set the defaults.
    self.Size = UDim2.new(1, -2, 0, 22)
    self.NameWidth = 80
    self.Text = "Property"
end



return BaseRowProperty