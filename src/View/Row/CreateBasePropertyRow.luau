--Creates a base row frame for a property.
--!strict

local BASE_PROPERTY_WIDTH = 80

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local NexusPluginComponents = require(NexusMotor6DCreatorPlugin:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))

local Fusion = NexusPluginComponents.Fusion
local Children = Fusion.Children

return function(Scope: NexusPluginComponents.FusionScope, PropertyName: NexusPluginComponents.UsedAs<string>, CreateValueFrames: () -> ({Instance})): Frame
    return Scope:Create("Frame")({
        Size = UDim2.new(1, -2, 0, 22),
        [Children] = {
            Scope:Create("Frame")({
                BorderSizePixel = 1,
                Size = UDim2.new(0, BASE_PROPERTY_WIDTH, 1, 0),
                ClipsDescendants = true,
                [Children] = {
                    Scope:Create("TextLabel")({
                        Size = UDim2.new(1, -4, 1, 0),
                        Position = UDim2.new(0, 4, 0, 0),
                        Text = PropertyName,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }),
                },
            }),

            Scope:Create("Frame")({
                BorderSizePixel = 1,
                Size = UDim2.new(1, -(BASE_PROPERTY_WIDTH + 1), 1, 0),
                Position = UDim2.new(0, BASE_PROPERTY_WIDTH + 1, 0, 0),
                ClipsDescendants = true,
                [Children] = CreateValueFrames(),
            }),
        },
    }) :: Frame
end