--[[
TheNexusAvenger

Runs the Nexus Motor6D Creator plugin.
--]]

local NexusPluginComponents = require(script:WaitForChild("NexusPluginComponents"))
local Motor6DWindow = require(script:WaitForChild("View"):WaitForChild("Motor6DWindow"))


--Create the window.
local OutputView = Motor6DWindow.new(plugin)

--Create the toolbar.
local NexusMotor6DCreatorToolbar = plugin:CreateToolbar("Nexus Motor6D Creator")
local NexusMotor6DCreatorButton = NexusMotor6DCreatorToolbar:CreateButton("Motor6D Creator", "Opens the window for creating Motor6Ds.", "") --TODO: Add icon.
NexusPluginComponents.new("PluginToggleButton", NexusMotor6DCreatorButton, OutputView)