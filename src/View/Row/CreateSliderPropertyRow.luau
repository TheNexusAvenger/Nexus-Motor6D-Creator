--Creates a property row for an instance.
--!strict

local NexusMotor6DCreatorPlugin = script.Parent.Parent.Parent
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local CreateSlider = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Input"):WaitForChild("CreateSlider"))
local CreateBasePropertyRow = require(NexusMotor6DCreatorPlugin:WaitForChild("View"):WaitForChild("Row"):WaitForChild("CreateBasePropertyRow"))

local OnEvent = Fusion.OnEvent
local Out = Fusion.Out



--[[
Formats the number for a text box.
--]]
local function FormatNumber(Number: number): string
    local Text = string.format("%.3f", Number)
    Text = string.match(Text, "(%-?%d-)%.0+$") or string.match(Text, "(%-?[%d%.]-)0+$") or Text
    return Text
end



return function(Scope: CreateFusionScope.FusionScope, PropertyName: Fusion.UsedAs<string>, Value: Fusion.Value<number>, Range: Fusion.UsedAs<NumberRange>?): Frame
    local Focused = Scope:Value(false)
    local TextBoxText = Scope:Value(tostring(Fusion.peek(Value)))
    Scope:Observer(Value):onBind(function()
        if Fusion.peek(Focused) then return end
        TextBoxText:set(FormatNumber(Fusion.peek(Value)))
    end)
    Scope:Observer(TextBoxText):onBind(function()
        local NewValue = tonumber(Fusion.peek(TextBoxText))
        if NewValue then
            if math.abs(Fusion.peek(Value) - NewValue) > 0.001 then
                Value:set(NewValue)
            end
        elseif not Fusion.peek(Focused) then
            TextBoxText:set(FormatNumber(Fusion.peek(Value)))
        end
    end)

    return CreateBasePropertyRow(Scope, PropertyName, function()
        return {
            --Text box.
            Scope:Create("TextBox")({
                Size = UDim2.new(0, 40, 0, 22),
                Text = Scope:Computed(function(use)
                    return use(TextBoxText)
                end),
                [Out("Text")] = TextBoxText,
                [OnEvent("Focused")] = function()
                    Focused:set(true)
                end,
                [OnEvent("FocusLost")] = function()
                    Focused:set(false)

                    local NewValue = tonumber(Fusion.peek(TextBoxText))
                    if NewValue then
                        Value:set(NewValue)
                    else
                        TextBoxText:set(FormatNumber(Fusion.peek(Value)))
                    end
                end,
            }),

            --Input slider.
            Scope:Hydrate(CreateSlider(Scope, Value, {
                ValueRange = Range or NumberRange.new(-0.5, 0.5),
            }))({
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.new(1, -42, 1, 0),
                Position = UDim2.new(1, 0, 0, 0),
            }),
        }
    end)
end