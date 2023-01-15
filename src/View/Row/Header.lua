--[[
TheNexusAvenger

Header row for a list of properties.
--]]

local NexusPluginFramework = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))
local PluginInstance = NexusPluginFramework:GetResource("Base.PluginInstance")

local Header = PluginInstance:Extend()
Header:SetClassName("Header")


--[[
Creates the header.
--]]
function Header:__new()
    PluginInstance.__new(self, "Frame")

    --Create the child frames.
    local NameFrame = NexusPluginFramework.new("Frame")
    NameFrame.BackgroundColor3 = Enum.StudioStyleGuideColor.HeaderSection
    NameFrame.BorderSizePixel = 1
    NameFrame.Size = UDim2.new(1, 0, 1, 0)
    NameFrame.ClipsDescendants = true
    NameFrame.Parent = self

    local NameText = NexusPluginFramework.new("TextLabel")
    NameText.Size = UDim2.new(1, 0, 1, 0)
    NameText.Position = UDim2.new(0, 0, 0, 0)
    NameText.Font = Enum.Font.SourceSansBold
    NameText.TextXAlignment = Enum.TextXAlignment.Center
    NameText.TextYAlignment = Enum.TextYAlignment.Center
    NameText.Parent = NameFrame

    --Connect the custom property.
    self:DisableChangeReplication("Text")
    self:GetPropertyChangedSignal("Text"):Connect(function()
        NameText.Text = self.Text
    end)

    --Set the defaults.
    self.Size = UDim2.new(1, -2, 0, 22)
    self.Text = "Header"
end



return Header