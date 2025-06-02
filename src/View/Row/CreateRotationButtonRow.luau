--Creates a row of buttons for quickly rotating a rotation slider.
--!strict

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local NexusPluginComponents = require(NexusMotor6DCreatorPlugin:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))

local Fusion = NexusPluginComponents.Fusion
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent



--[[
Adds an angle to the given value.
--]]
local function AddAngle(Angle: number, Value: NexusPluginComponents.Value<number>): ()
    local NewValue = ((Fusion.peek(Value) + 180 + Angle) % 360) - 180
    if NewValue == -180 then
        NewValue = 180
    end
    Value:set(NewValue)
end



return function(Scope: NexusPluginComponents.FusionScope, AxisName: string, Value: NexusPluginComponents.Value<number>): Frame
    return Scope:Create("Frame")({
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -2, 0, 20),
        [Children] = {
            --Subtract 90 degrees button.
            Scope:Create("TextButton")({
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0.125, 0, 1, 0),
                Position = UDim2.new(0.2, 0, 0, 0),
                Text = "< 90°",
                [OnEvent("MouseButton1Down")] = function()
                    AddAngle(-90, Value)
                end,
            }),

            --Subtract 45 degrees button.
            Scope:Create("TextButton")({
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0.125, 0, 1, 0),
                Position = UDim2.new(0.35, 0, 0, 0),
                Text = "< 45°",
                [OnEvent("MouseButton1Down")] = function()
                    AddAngle(-45, Value)
                end,
            }),

            --Axis label.
            Scope:Create("TextLabel")({
                Size = UDim2.new(1, 0, 1, 0),
                Text = AxisName,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Center,
            }),

            --Add 45 degrees button.
            Scope:Create("TextButton")({
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0.125, 0, 1, 0),
                Position = UDim2.new(0.65, 0, 0, 0),
                Text = "45° >",
                [OnEvent("MouseButton1Down")] = function()
                    AddAngle(45, Value)
                end,
            }),

            --Add 90 degrees button.
            Scope:Create("TextButton")({
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0.125, 0, 1, 0),
                Position = UDim2.new(0.8, 0, 0, 0),
                Text = "90° >",
                [OnEvent("MouseButton1Down")] = function()
                    AddAngle(45, Value)
                end,
            }),
        },
    }) :: Frame
end