--[[
TheNexusAvenger

Row property for an instance reference.
--]]

local NexusPluginFramework = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))
local PartSelection = require(script.Parent.Parent.Parent:WaitForChild("Geometry"):WaitForChild("PartSelection"))
local BaseRowProperty = require(script.Parent:WaitForChild("BaseRowProperty"))

local InstanceRowProperty = BaseRowProperty:Extend()
InstanceRowProperty:SetClassName("InstanceRowProperty")



--[[
Creates the instance row property.
--]]
function InstanceRowProperty:__new()
    BaseRowProperty.__new(self)

    --Create the additional frames.
    local InstanceNameText = NexusPluginFramework.new("TextLabel")
    InstanceNameText.Size = UDim2.new(1, -4, 1, 0)
    InstanceNameText.Position = UDim2.new(0, 4, 0, 0)
    InstanceNameText.Text = ""
    InstanceNameText.TextXAlignment = Enum.TextXAlignment.Left
    InstanceNameText.TextYAlignment = Enum.TextYAlignment.Center
    InstanceNameText.Parent = self.PropertyAdornFrame

    local ToggleSelectionButton = NexusPluginFramework.new("TextButton")
    ToggleSelectionButton.Size = UDim2.new(0, 24, 0, 22)
    ToggleSelectionButton.AnchorPoint = Vector2.new(1, 0)
    ToggleSelectionButton.Position = UDim2.new(1, 0, 0, 0)
    ToggleSelectionButton.Text = "..."
    ToggleSelectionButton.Parent = self.PropertyAdornFrame

    --Connect the custom properties.
    local CurrentSelection = nil
    self:DisableChangeReplication("Plugin")
    self:DisableChangeReplication("Value")
    self:GetPropertyChangedSignal("Value"):Connect(function()
        InstanceNameText.Text = (self.Value and self.Value.Name or "")
    end)
    self:DisableChangeReplication("Selecting")
    self:GetPropertyChangedSignal("Selecting"):Connect(function()
        --Update the text.
        ToggleSelectionButton.Text = (self.Selecting and "X" or "...")
        ToggleSelectionButton.TextColor3 = (self.Selecting and Color3.new(1, 0, 0) or Enum.StudioStyleGuideColor.MainText)
        ToggleSelectionButton.Font = (self.Selecting and Enum.Font.FredokaOne or Enum.Font.SourceSans)

        --Clear the selection if it is complete.
        if not self.Selecting and CurrentSelection then
            CurrentSelection:Destroy()
            CurrentSelection = nil
        end
    end)
    self.Selecting = false

    --Connect the button.
    local DB = true
    ToggleSelectionButton.MouseButton1Down:Connect(function()
        if DB then
            --Toggle selecting.
            DB = false
            self.Selecting = not self.Selecting

            --Start selecting the part.
            if self.Selecting then
                --Start the selection.
                local NewSelection = PartSelection.new()
                CurrentSelection = NewSelection

                --Activate the plugin.
                if self.Plugin then
                    self.Plugin:Activate(true)
                end

                --Prompt the selection in the background.
                task.spawn(function()
                    local Selection = CurrentSelection:PromptSelection()
                    if CurrentSelection ~= NewSelection then return end
                    self.Value = Selection
                    self.Selecting = false
                    if self.Plugin then
                        self.Plugin:Deactivate()
                    end
                end)
            end
            DB = true
        end
    end)
end



return InstanceRowProperty