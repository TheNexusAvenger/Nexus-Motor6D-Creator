--Window for creating Motor6Ds.
--!strict

local Workspace = game:GetService("Workspace")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local NexusPluginComponents = require(NexusMotor6DCreatorPlugin:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))
local PointSelection = require(NexusMotor6DCreatorPlugin:WaitForChild("Geometry"):WaitForChild("PointSelection"))
local Motor6DVisual = require(NexusMotor6DCreatorPlugin:WaitForChild("Geometry"):WaitForChild("Motor6DVisual"))
local CreateHeaderRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateHeaderRow"))
local CreateInstancePropertyRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateInstancePropertyRow"))
local CreateRotationButtonRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateRotationButtonRow"))
local CreateSliderPropertyRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateSliderPropertyRow"))

local CreateCheckbox = NexusPluginComponents.Input.CreateCheckbox
local CreateFusionScope = NexusPluginComponents.CreateFusionScope
local Fusion = NexusPluginComponents.Fusion
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Motor6DWindow = {}
Motor6DWindow.__index = Motor6DWindow

export type Motor6DWindow = {
    Window: DockWidgetPluginGui,
    Values: {
        Part0: NexusPluginComponents.Value<BasePart?>,
        Part1: NexusPluginComponents.Value<BasePart?>,
        PivotPart: NexusPluginComponents.Value<BasePart?>,
        Motor6D: NexusPluginComponents.Value<Motor6D?>,
        PositionXOffset: NexusPluginComponents.Value<number>,
        PositionYOffset: NexusPluginComponents.Value<number>,
        PositionZOffset: NexusPluginComponents.Value<number>,
        RotationXAngle: NexusPluginComponents.Value<number>,
        RotationYAngle: NexusPluginComponents.Value<number>,
        MaxVelocity: NexusPluginComponents.Value<number>,
        UseLocalSpace: NexusPluginComponents.Value<NexusPluginComponents.CheckboxState>,
        SetDesiredAngleInfinite: NexusPluginComponents.Value<NexusPluginComponents.CheckboxState>,
    },
} & typeof(setmetatable({}, Motor6DWindow))



--[[
Creates a Motor6D window.
--]]
function Motor6DWindow.new(Plugin: Plugin): Motor6DWindow
    --Create the window.
    local PluginGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 300, 430, 300, 430)
    local Window = Plugin:CreateDockWidgetPluginGui("Motor6D Creator", PluginGuiInfo)
    Window.Title = "Motor6D Creator"
    Window.Name = "Motor6D Creator"

    --Create the values.
    local Scope = CreateFusionScope()
    local Part0 = Scope:Value(nil :: BasePart?)
    local Part1 = Scope:Value(nil :: BasePart?)
    local PivotPart = Scope:Value(nil :: BasePart?)
    local Motor6D = Scope:Value(nil :: Motor6D?)
    local PositionXOffset = Scope:Value(0)
    local PositionYOffset = Scope:Value(0)
    local PositionZOffset = Scope:Value(0)
    local RotationXAngle = Scope:Value(0)
    local RotationYAngle = Scope:Value(0)
    local MaxVelocity = Scope:Value(0)
    local UseLocalSpace = Scope:Value("Checked" :: NexusPluginComponents.CheckboxState) :: any --Luau typing doesn't seem to handle custom singleton instnaces in this use.
    local SetDesiredAngleInfinite = Scope:Value("Unchecked" :: NexusPluginComponents.CheckboxState) :: any --Luau typing doesn't seem to handle custom singleton instnaces in this use.

    local ActivePivotPart = Scope:Computed(function(use)
        return use(PivotPart) or use(Part1)
    end)
    local ActivePivotPartCFrame = Scope:ValueFromProperty(ActivePivotPart, "CFrame") :: NexusPluginComponents.Value<CFrame?>
    local ActivePivotPartSize = Scope:ValueFromProperty(ActivePivotPart, "Size") :: NexusPluginComponents.Value<Vector3?>
    local Part0CFrame = Scope:ValueFromProperty(Part0, "CFrame") :: NexusPluginComponents.Value<CFrame?>
    local Part1CFrame = Scope:ValueFromProperty(Part1, "CFrame") :: NexusPluginComponents.Value<CFrame?>
    local C0 = Scope:Computed(function(use)
        local CurrentPart0CFrame = use(Part0CFrame) :: CFrame
        local CurrentActivePivotPartCFrame = use(ActivePivotPartCFrame) :: CFrame
        local CurrentActivePivotPartSize = use(ActivePivotPartSize) :: Vector3
        if not CurrentPart0CFrame or not CurrentActivePivotPartCFrame or not CurrentActivePivotPartSize then return CFrame.identity end
        local PivotCFrame = CurrentActivePivotPartCFrame * CFrame.new(CurrentActivePivotPartSize * Vector3.new(use(PositionXOffset), use(PositionYOffset), use(PositionZOffset)))
        if use(UseLocalSpace) ~= "Checked" then
            PivotCFrame = CFrame.new(PivotCFrame.Position)
        end
        PivotCFrame = PivotCFrame * CFrame.Angles(math.rad(use(RotationXAngle)), math.rad(use(RotationYAngle)), 0)
        return CurrentPart0CFrame:Inverse() * PivotCFrame
    end)
    local C1 = Scope:Computed(function(use)
        local CurrentPart0CFrame = use(Part0CFrame)
        local CurrentPart1CFrame = use(Part1CFrame)
        if not CurrentPart0CFrame or not CurrentPart1CFrame then return CFrame.identity end
        return CurrentPart1CFrame:Inverse() * (CurrentPart0CFrame * use(C0))
    end)
    local Part0Anchored = Scope:ValueFromProperty(Part0, "Anchored") :: NexusPluginComponents.Value<boolean?>
    local Part1Anchored = Scope:ValueFromProperty(Part1, "Anchored") :: NexusPluginComponents.Value<boolean?>

    --Create the view.
    local CreateButtonEnabled = Scope:Computed(function(use)
        return use(Part0) ~= nil and use(Part1) ~= nil
    end)
    local CurrentPivotSelection: PointSelection.PointSelection? = nil
    task.spawn(function()
        --Wait for the window to become visible.
        while not Window.Enabled do
            Window:GetPropertyChangedSignal("Enabled"):Wait()
        end

        --Create the view.
        Scope:Create("Frame")({
            BorderSizePixel = 1,
            Size = UDim2.new(1, -2, 1, -2),
            Position = UDim2.new(0, 1, 0, 1),
            Parent = Window,
            [Children] = {
                --Part0/Part1 properties.
                Scope:Hydrate(CreateHeaderRow(Scope, "Parts"))({
                    Position = UDim2.new(0, 0, 0, 23 * 0),
                }),
                Scope:Hydrate(CreateInstancePropertyRow(Scope, "Part0", Plugin, Part0))({
                    Position = UDim2.new(0, 0, 0, 23 * 1),
                }),
                Scope:Hydrate(CreateInstancePropertyRow(Scope, "Part1", Plugin, Part1))({
                    Position = UDim2.new(0, 0, 0, 23 * 2),
                }),

                --Position offset properties.
                Scope:Hydrate(CreateHeaderRow(Scope, "Position Offset"))({
                    Position = UDim2.new(0, 0, 0, 23 * 3),
                }),
                Scope:Hydrate(CreateSliderPropertyRow(Scope, "X AXis", PositionXOffset))({
                    Position = UDim2.new(0, 0, 0, 23 * 4),
                }),
                Scope:Hydrate(CreateSliderPropertyRow(Scope, "Y AXis", PositionYOffset))({
                    Position = UDim2.new(0, 0, 0, 23 * 5),
                }),
                Scope:Hydrate(CreateSliderPropertyRow(Scope, "Z AXis", PositionZOffset))({
                    Position = UDim2.new(0, 0, 0, 23 * 6),
                }),

                --Rotation offset properties.
                Scope:Hydrate(CreateHeaderRow(Scope, "Rotation Offset"))({
                    Position = UDim2.new(0, 0, 0, 23 * 7),
                }),
                Scope:Hydrate(CreateSliderPropertyRow(Scope, "X Axis", RotationXAngle, NumberRange.new(-180, 180)))({
                    Position = UDim2.new(0, 0, 0, 23 * 8),
                }),
                Scope:Hydrate(CreateSliderPropertyRow(Scope, "Y Axis", RotationYAngle, NumberRange.new(-180, 180)))({
                    Position = UDim2.new(0, 0, 0, 23 * 9),
                }),

                --Velocity property.
                Scope:Hydrate(CreateHeaderRow(Scope, "Motor"))({
                    Position = UDim2.new(0, 0, 0, 23 * 10),
                }),
                Scope:Hydrate(CreateSliderPropertyRow(Scope, "MaxVelocity", MaxVelocity, NumberRange.new(0, 0.25)))({
                    Position = UDim2.new(0, 0, 0, 23 * 11),
                }),

                --Local space toggle.
                Scope:Hydrate(CreateCheckbox(Scope, UseLocalSpace))({
                    Size = UDim2.new(0, 13, 0, 13),
                    Position = UDim2.new(0, 4, 0, (23 * 12) + 4),
                }),

                Scope:Create("TextLabel")({
                    Size = UDim2.new(0, 200, 0, 13),
                    Position = UDim2.new(0, 24, 0, (23 * 12) + 4),
                    Text = "Rotation relative to selected pivot.",
                }),

                --Rotation buttons.
                Scope:Hydrate(CreateRotationButtonRow(Scope, "X Axis", RotationXAngle))({
                    Position =  UDim2.new(0, 0, 0, 300),
                }),
                Scope:Hydrate(CreateRotationButtonRow(Scope, "Y Axis", RotationYAngle))({
                    Position = UDim2.new(0, 0, 0, 300 + (24 * 1)),
                }),

                --Create/update button.
                Scope:Create("TextButton", CreateButtonEnabled)({
                    BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton,
                    BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder,
                    Size = UDim2.new(0, 90, 0, 22),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.3, 0, 0, 370),
                    Text = Scope:Computed(function(use)
                        return use(Motor6D) and "Update" or "Create"
                    end),
                    TextColor3 = Enum.StudioStyleGuideColor.DialogMainButtonText,
                    [OnEvent("MouseButton1Down")] = function()
                        local CurrentPart0, CurrentPart1 = Fusion.peek(Part0), Fusion.peek(Part1)
                        if not CurrentPart0 or not CurrentPart1 then return end

                        --Create the motor.
                        ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorBeforeSetMotor")
                        if not Fusion.peek(Motor6D) then
                            local NewMotor6D = Instance.new("Motor6D")
                            NewMotor6D.Part0 = CurrentPart0
                            NewMotor6D.Part1 = CurrentPart1
                            NewMotor6D.Parent = NewMotor6D.Part0
                            Motor6D:set(NewMotor6D)
                        end

                        --Update the motor.
                        local CurrentMotor6D = Fusion.peek(Motor6D) :: Motor6D
                        CurrentMotor6D.C0 = Fusion.peek(C0)
                        CurrentMotor6D.C1 = Fusion.peek(C1)
                        CurrentMotor6D.MaxVelocity = Fusion.peek(MaxVelocity)
                        if Fusion.peek(SetDesiredAngleInfinite) == "Checked" then
                            CurrentMotor6D.DesiredAngle = 2 ^ 1000
                        end
                        ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorAfterSetMotor")
                    end,
                }),

                --Select pivot button.
                Scope:Create("TextButton")({
                    BackgroundColor3 = Enum.StudioStyleGuideColor.DialogButton,
                    BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder,
                    Size = UDim2.new(0, 90, 0, 22),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.7, 0, 0, 370),
                    Text = "Select Pivot",
                    TextColor3 = Enum.StudioStyleGuideColor.DialogButtonText,
                    [OnEvent("MouseButton1Down")] = function()
                        --Clear the previous selection.
                        if CurrentPivotSelection then
                            CurrentPivotSelection:Destroy()
                            CurrentPivotSelection = nil
                        end

                        --Start the new selection.
                        local NewPivotSelection = PointSelection.new()
                        CurrentPivotSelection = NewPivotSelection
                        Plugin:Activate(true)

                        task.spawn(function()
                            --Get the selection.
                            local SelectionPart, SelectionCFrame = NewPivotSelection:PromptSelection()
                            if NewPivotSelection ~= CurrentPivotSelection then return end

                            --Update the sliders.
                            if SelectionCFrame and SelectionPart then
                                local RelativeCFrame = SelectionPart.CFrame:Inverse() * SelectionCFrame
                                PositionXOffset:set(RelativeCFrame.X / SelectionPart.Size.X)
                                PositionYOffset:set(RelativeCFrame.Y / SelectionPart.Size.Y)
                                PositionZOffset:set(RelativeCFrame.Z / SelectionPart.Size.Z)
                                PivotPart:set(SelectionPart)
                            end

                            --Clear the selection.
                            Plugin:Deactivate()
                            NewPivotSelection:Destroy()
                        end)
                    end,
                }),

                --Infinite desired angle toggle.
                Scope:Hydrate(CreateCheckbox(Scope, SetDesiredAngleInfinite))({
                    Size = UDim2.new(0, 13, 0, 13),
                    Position = UDim2.new(0, 4, 0, 400),
                }),

                Scope:Create("TextLabel")({
                    Size = UDim2.new(0, 200, 0, 13),
                    Position = UDim2.new(0, 24, 0, 400),
                    Text = "Set the desired angle to spin forever.",
                }),

                --Anchored part warning.
                Scope:Create("TextLabel")({
                    Size = UDim2.new(1, -4, 0, 13),
                    Position = UDim2.new(0, 2, 0, 420),
                    Visible = Scope:Computed(function(use)
                        return use(Part0Anchored) and use(Part1Anchored)
                    end),
                    Text = "Both parts are anchored.",
                    TextColor3 = Enum.StudioStyleGuideColor.WarningText,
                    TextXAlignment = Enum.TextXAlignment.Center,
                }),
            },
        })

        --Create the Motor6D visual.
        local WindowVisible = Scope:ValueFromProperty(Window, "Enabled") :: NexusPluginComponents.Value<boolean?>
        Motor6DVisual.new(Scope, {
            Visible = Scope:Computed(function(use)
                if not use(WindowVisible) then return false end
                if not use(Part0) or not use(Part1) then return false end
                return true
            end),
            StartCFrame = Part0CFrame,
            C0 = C0,
            C1 = C1,
            MaxVelocity = MaxVelocity,
        } :: Motor6DVisual.Motor6DValues)
    end)

    --Create and return the object.
    return setmetatable({
        Window = Window,
        Values = {
            Part0 = Part0,
            Part1 = Part1,
            PivotPart = PivotPart,
            Motor6D = Motor6D,
            PositionXOffset = PositionXOffset,
            PositionYOffset = PositionYOffset,
            PositionZOffset = PositionZOffset,
            RotationXAngle = RotationXAngle,
            RotationYAngle = RotationYAngle,
            MaxVelocity = MaxVelocity,
            UseLocalSpace = UseLocalSpace,
            SetDesiredAngleInfinite = UseLocalSpace,
        },
    }, Motor6DWindow) :: Motor6DWindow
end

--[[
Loads 2 parts.
--]]
function Motor6DWindow.LoadParts(self: Motor6DWindow, Part0: BasePart?, Part1: BasePart?): ()
    --Update the selected motor.
    if Part0 and Part1 then
        for _, Motor6D in Workspace:GetDescendants() do
            if not Motor6D:IsA("Motor6D") then continue end
            if not ((Motor6D.Part0 == Part0 and Motor6D.Part1 == Part1) or (Motor6D.Part0 == Part1 and Motor6D.Part1 == Part0)) then continue end
            self.Values.Motor6D:set(Motor6D)
            Part0 = Motor6D.Part0
            Part1 = Motor6D.Part1
            break
        end
    end

    --Set the selected parts.
    self.Values.Part0:set(Part0)
    self.Values.Part1:set(Part1)

    --Set the sliders.
    local CurrentMotor = Fusion.peek(self.Values.Motor6D)
    if CurrentMotor and Part0 and Part1 then
        --Determine the relative part.
        local PivotPart = nil
        local PivotCFrame = Part0.CFrame * CurrentMotor.C0
        local Part1CFrame = Part0.CFrame * CurrentMotor.C0 * CurrentMotor.C1:Inverse() --Calculated in case used when the game is running.
        local PivotRelativePosition0 = (Part0.CFrame:Inverse() * PivotCFrame).Position / Part0.Size
        local PivotRelativePosition1 = (Part1CFrame:Inverse() * PivotCFrame).Position / Part1.Size
        if math.abs(PivotRelativePosition1.X) <= 0.5 and math.abs(PivotRelativePosition1.Y) <= 0.5 and math.abs(PivotRelativePosition1.Z) <= 0.5 then
            PivotPart = Part1
        elseif math.abs(PivotRelativePosition0.X) <= 0.5 and math.abs(PivotRelativePosition0.Y) <= 0.5 and math.abs(PivotRelativePosition0.Z) <= 0.5 then
            PivotPart = Part0
        else
            PivotPart = Part1
        end

        --Set the sliders.
        local PivotRelativeCFrame = PivotPart.CFrame:Inverse() * PivotCFrame
        local AngleX, AngleY, _ = PivotRelativeCFrame:ToEulerAnglesXYZ()
        self.Values.PositionXOffset:set(PivotRelativeCFrame.X / PivotPart.Size.X)
        self.Values.PositionYOffset:set(PivotRelativeCFrame.Y / PivotPart.Size.Y)
        self.Values.PositionZOffset:set(PivotRelativeCFrame.Z / PivotPart.Size.Z)
        self.Values.RotationXAngle:set(math.deg(AngleX))
        self.Values.RotationYAngle:set(math.deg(AngleY))
        self.Values.MaxVelocity:set(CurrentMotor.MaxVelocity)
        self.Values.PivotPart:set(PivotPart)
    else
        --Reset the sliders.
        self.Values.PositionXOffset:set(0)
        self.Values.PositionYOffset:set(0)
        self.Values.PositionZOffset:set(0)
        self.Values.RotationXAngle:set(0)
        self.Values.RotationYAngle:set(0)
        self.Values.MaxVelocity:set(0)
        self.Values.PivotPart:set(nil)
    end
    self.Values.UseLocalSpace:set("Checked")
    self.Values.SetDesiredAngleInfinite:set("Unchecked")
end



return Motor6DWindow