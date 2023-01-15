--[[
TheNexusAvenger

Window for the Motor6D creator view.
--]]

local NexusPluginFramework = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"))
local Motor6DView = require(script.Parent:WaitForChild("Motor6DView"))
local PluginInstance = NexusPluginFramework:GetResource("Base.PluginInstance")

local Motor6DWindow = PluginInstance:Extend()
Motor6DWindow:SetClassName("Motor6DWindow")



--[[
Creates the Motor6D window.
--]]
function Motor6DWindow:__new(Plugin: Plugin)
    PluginInstance.__new(self, Plugin:CreateDockWidgetPluginGui("Motor6D Creator", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 300, 430, 300, 430)))
    self.Title = "Motor6D Creator"
    self.Name = "Motor6D Creator"

    --Add the Motor6D view.
    local View = Motor6DView.new(Plugin)
    View.Size = UDim2.new(1, -2, 1, -2)
    View.Position = UDim2.new(0, 1, 0, 1)
    View.Parent = self
    self:DisableChangeReplication("View")
    self.View = View
end



return Motor6DWindow