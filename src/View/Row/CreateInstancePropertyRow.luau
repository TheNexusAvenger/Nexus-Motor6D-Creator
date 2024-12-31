--Creates a property row for an instance.
--!strict

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local PartSelection = require(NexusMotor6DCreatorPlugin:WaitForChild("Geometry"):WaitForChild("PartSelection"))
local CreateBasePropertyRow = require(NexusMotor6DCreatorPlugin:WaitForChild("View"):WaitForChild("Row"):WaitForChild("CreateBasePropertyRow"))

local OnEvent = Fusion.OnEvent

return function(Scope: CreateFusionScope.FusionScope, PropertyName: Fusion.UsedAs<string>, Plugin: Plugin?, Object: Fusion.Value<BasePart?>): Frame
    local Selecting = Scope:Value(false)
    local ToggleSelectionButtonTextColor = Scope:PluginColor(Enum.StudioStyleGuideColor.MainText)
    local CurrentPartSelection: PartSelection.PartSelection? = nil
    return CreateBasePropertyRow(Scope, PropertyName, function()
        return {
            Scope:Create("TextLabel")({
                Size = UDim2.new(1, -4, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                Text = Scope:Computed(function(use)
                    local CurrentObject = use(Object)
                    return CurrentObject and CurrentObject.Name or ""
                end),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
            }),

            Scope:Create("TextButton")({
                Size = UDim2.new(0, 24, 0, 22),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Text = Scope:Computed(function(use)
                    return use(Selecting) and "X" or "..."
                end),
                TextColor3 = Scope:Computed(function(use)
                    return use(Selecting) and Color3.fromRGB(255, 0, 0) or use(ToggleSelectionButtonTextColor)
                end),
                Font = Scope:Computed(function(use)
                    return use(Selecting) and Enum.Font.FredokaOne or Enum.Font.SourceSans
                end),
                [OnEvent("MouseButton1Down")] = function()
                    --Toggle selecting.
                    Selecting:set(not Fusion.peek(Selecting))

                    --Handle the selection.
                    if Fusion.peek(Selecting) then
                        --Start the selection.
                        local NewSelection = PartSelection.new()
                        CurrentPartSelection = NewSelection

                        --Activate the plugin to use the mouse.
                        if Plugin then
                            Plugin:Activate(true)
                        end

                        --Get the selection and finish the selection.
                        local Selection = NewSelection:PromptSelection()
                        if CurrentPartSelection ~= NewSelection then return end
                        Object:set(Selection)
                        Selecting:set(false)
                        if Plugin then
                            Plugin:Deactivate()
                        end
                        NewSelection:Destroy()
                    else
                        --Cancel the selection.
                        if not CurrentPartSelection then return end
                        CurrentPartSelection:Destroy()
                        CurrentPartSelection = nil
                    end
                end,
            }),
        }
    end)
end