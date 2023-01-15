--[[
TheNexusAvenger

Header row for a list of properties.
--]]
--!strict

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local NexusPluginFramework = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"))
local PluginInstance = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))

local Header = PluginInstance:Extend()
Header:SetClassName("Header")

export type Header = {
    new: () -> (Header),
    Extend: (self: Header) -> (Header),

    Text: string,
} & PluginInstance.PluginInstance & Frame



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



return (Header :: any) :: Header