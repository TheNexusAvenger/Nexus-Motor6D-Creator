--Creates the window for welding parts.
--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return function(Plugin: Plugin): DockWidgetPluginGui
    --Create the window.
    local PluginGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 50, 160, 50)
    local Window = Plugin:CreateDockWidgetPluginGui("Weld Creator", PluginGuiInfo)
    Window.Title = "Weld Creator"
    Window.Name = "Weld Creator"

    task.spawn(function()
        --Wait for the window to become visible.
        while not Window.Enabled do
            Window:GetPropertyChangedSignal("Enabled"):Wait()
        end

        --Create the view.
        local Scope = CreateFusionScope()
        local LastSelectionChangeTime = Scope:Value(tick())
        local PartSelection = Scope:Computed(function(use)
            use(LastSelectionChangeTime)

            local NewSelection = {} :: {BasePart}
            for _, Part in Selection:Get() do
                pcall(function()
                    if not Part:IsA("BasePart") then return end
                    table.insert(NewSelection, Part)
                end)
            end
            return NewSelection
        end)
        local CanWeldParts = Scope:Computed(function(use)
            return #use(PartSelection) > 1
        end)
        local WeldButtonModifier = Scope:Computed(function(use)
            return use(CanWeldParts) and Enum.StudioStyleGuideModifier.Default or Enum.StudioStyleGuideModifier.Disabled
        end)
        
        Scope:Create("Frame")({
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Window,
            [Children] = {
                Scope:Create("TextLabel")({
                    Size = UDim2.new(1, 0, 0, 16),
                    Position = UDim2.new(0, 0, 0, 2),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Text = Scope:Computed(function(use)
                        local CurrentSelection = use(PartSelection)
                        if #CurrentSelection == 0 then
                            return "No parts selected."
                        elseif #CurrentSelection == 1 then
                            return "No parts to weld."
                        end
                        return `Weld {#CurrentSelection} parts.`
                    end),
                }),
                
                Scope:Create("TextButton")({
                    BackgroundColor3 = Scope:PluginColor(Enum.StudioStyleGuideColor.DialogMainButton, WeldButtonModifier),
                    BorderColor3 = Scope:PluginColor(Enum.StudioStyleGuideColor.DialogButtonBorder, WeldButtonModifier),
                    Size = UDim2.new(0, 80, 0, 22),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 24),
                    Active = CanWeldParts,
                    AutoButtonColor = CanWeldParts,
                    TextColor3 = Scope:PluginColor(Enum.StudioStyleGuideColor.DialogMainButtonText, WeldButtonModifier),
                    Text = "Weld",
                    [OnEvent("MouseButton1Down")] = function()
                        local CurrentPartSelection = Fusion.peek(PartSelection)
                        if #CurrentPartSelection <= 1 then return end
                        
                        --Create the initial waypoint to allow for undoing before welding.
                        ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorBeforeCreateWelds")
                        local StartPart = CurrentPartSelection[1]
                        for _, WeldPart in CurrentPartSelection do
                            if WeldPart == StartPart then continue end
                            local Weld = Instance.new("Weld")
                            Weld.C0 = StartPart.CFrame:Inverse() * WeldPart.CFrame
                            Weld.Part0  = StartPart
                            Weld.Part1 = WeldPart
                            Weld.Parent = StartPart
                        end

                        --Create the waypoint after the welds are created.
                        ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorAfterCreateWelds")
                    end,
                }),
            },
        })
        
        --Connect the selection changing.
        Selection.SelectionChanged:Connect(function()
            LastSelectionChangeTime:set(tick())
        end)
    end)

    --Return the window.
    return Window
end