--Creates a header row for a list of properties.
--!strict

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local Children = Fusion.Children

return function(Scope: CreateFusionScope.FusionScope, Text: Fusion.UsedAs<string>): Frame
    return Scope:Create("Frame")({
        Size = UDim2.new(1, -2, 0, 22),
        [Children] = {
            Scope:Create("Frame")({
                BackgroundColor3 = Enum.StudioStyleGuideColor.HeaderSection,
                BorderSizePixel = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ClipsDescendants = true,
                [Children] = {
                    Scope:Create("TextLabel")({
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        Font = Enum.Font.SourceSansBold,
                        Text = Text,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }),
                },
            }),
        },
    }) :: Frame
end