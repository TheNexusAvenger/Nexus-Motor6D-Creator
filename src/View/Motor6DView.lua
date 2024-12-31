--[[
TheNexusAvenger

View for editting Motor6D properties.
--]]
--!strict

local Workspace = game:GetService("Workspace")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local NexusPluginFramework = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"))
local CreateHeaderRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateHeaderRow"))
local CreateInstancePropertyRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateInstancePropertyRow"))
local CreateRotationButtonRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateRotationButtonRow"))
local CreateSliderPropertyRow = require(script.Parent:WaitForChild("Row"):WaitForChild("CreateSliderPropertyRow"))
local PointSelection = require(NexusMotor6DCreatorPlugin:WaitForChild("Geometry"):WaitForChild("PointSelection"))
local Motor6DVisual = require(NexusMotor6DCreatorPlugin:WaitForChild("Geometry"):WaitForChild("Motor6DVisual"))
local PluginInstance = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))

local Motor6DView = PluginInstance:Extend()
Motor6DView:SetClassName("Motor6DView")

export type Motor6DView = {
    new: (Plugin: Plugin?) -> (Motor6DView),
    Extend: (self: Motor6DView) -> Motor6DView,

    LoadParts: (self: Motor6DView, Part0: Part, Part1: Part) -> (),
} & PluginInstance.PluginInstance & Frame



--[[
Creates the Motor6D view.
--]]
function Motor6DView:__new(Plugin: Plugin?): ()
    PluginInstance.__new(self, "Frame")
    self.BorderSizePixel = 1

    --Create the part property rows.
    local Scope = CreateFusionScope()
    local PartPropertiesHeader = CreateHeaderRow(Scope, "Parts")
    PartPropertiesHeader.Parent = self:GetWrappedInstance()

    local Part0 = Scope:Value(nil :: BasePart?)
    local Part0PropertyRow = CreateInstancePropertyRow(Scope, "Part0", Plugin, Part0)
    Part0PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 1)
    Part0PropertyRow.Parent = self:GetWrappedInstance()

    local Part1 = Scope:Value(nil :: BasePart?)
    local Part1PropertyRow = CreateInstancePropertyRow(Scope, "Part1", Plugin, Part1)
    Part1PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 2)
    Part1PropertyRow.Parent = self:GetWrappedInstance()

    --Create the position property rows.
    local PositionPropertiesHeader = CreateHeaderRow(Scope, "Position Offset")
    PositionPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 3)
    PositionPropertiesHeader.Parent = self:GetWrappedInstance()

    local PositionXOffset = Scope:Value(0)
    local PositionXSlider = CreateSliderPropertyRow(Scope, "X AXis", PositionXOffset)
    PositionXSlider.Position = UDim2.new(0, 0, 0, 23 * 4)
    PositionXSlider.Parent = self:GetWrappedInstance()

    local PositionYOffset = Scope:Value(0)
    local PositionYSlider = CreateSliderPropertyRow(Scope, "Y Axis", PositionYOffset)
    PositionYSlider.Position = UDim2.new(0, 0, 0, 23 * 5)
    PositionYSlider.Parent = self:GetWrappedInstance()

    local PositionZOffset = Scope:Value(0)
    local PositionZSlider = CreateSliderPropertyRow(Scope, "Z Axis", PositionZOffset)
    PositionZSlider.Position = UDim2.new(0, 0, 0, 23 * 6)
    PositionZSlider.Parent = self:GetWrappedInstance()

    --Create the rotation property rows.
    local RotationPropertiesHeader = CreateHeaderRow(Scope, "Rotation Offset")
    RotationPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 7)
    RotationPropertiesHeader.Parent = self:GetWrappedInstance()

    local RotationXAngle = Scope:Value(0)
    local RotationXSlider = CreateSliderPropertyRow(Scope, "X Axis", RotationXAngle, NumberRange.new(-180, 180))
    RotationXSlider.Position = UDim2.new(0, 0, 0, 23 * 8)
    RotationXSlider.Parent = self:GetWrappedInstance()

    local RotationYAngle = Scope:Value(0)
    local RotationYSlider = CreateSliderPropertyRow(Scope, "Y Axis", RotationYAngle, NumberRange.new(-180, 180))
    RotationYSlider.Position = UDim2.new(0, 0, 0, 23 * 9)
    RotationYSlider.Parent = self:GetWrappedInstance()

    --Create the motor property rows.
    local MotorPropertiesHeader = CreateHeaderRow(Scope, "Motor")
    MotorPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 10)
    MotorPropertiesHeader.Parent = self:GetWrappedInstance()

    local MaxVelocity = Scope:Value(0)
    local MaxVelocitySlider = CreateSliderPropertyRow(Scope, "MaxVelocity", MaxVelocity, NumberRange.new(0, 0.25))
    MaxVelocitySlider.Position = UDim2.new(0, 0, 0, 23 * 11)
    MaxVelocitySlider.Parent = self:GetWrappedInstance()

    --Create the toggle for local/global rotation.
    local LocalSpaceCheckbox = NexusPluginFramework.new("Checkbox")
    LocalSpaceCheckbox.Size = UDim2.new(0, 13, 0, 13)
    LocalSpaceCheckbox.Position = UDim2.new(0, 4, 0, (23 * 12) + 4)
    LocalSpaceCheckbox.Value = "Checked"
    LocalSpaceCheckbox.Parent = self

    local LocalSpaceText = NexusPluginFramework.new("TextLabel")
    LocalSpaceText.Size = UDim2.new(0, 200, 0, 13)
    LocalSpaceText.Position = UDim2.new(0, 24, 0, (23 * 12) + 4)
    LocalSpaceText.Text = "Rotation relative to selected pivot."
    LocalSpaceText.Parent = self

    --Create the slider toggle buttons.
    local XAxisButtons = CreateRotationButtonRow(Scope, "X Axis", RotationXAngle)
    XAxisButtons.Position = UDim2.new(0, 0, 0, 300)
    XAxisButtons.Parent = self:GetWrappedInstance()

    local YAxisButtons = CreateRotationButtonRow(Scope, "Y Axis", RotationYAngle)
    YAxisButtons.Position = UDim2.new(0, 0, 0, 300 + (24 * 1))
    YAxisButtons.Parent = self:GetWrappedInstance()

    --Create the lower buttons.
    local CreateButton = NexusPluginFramework.new("TextButton")
    CreateButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
    CreateButton.BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder
    CreateButton.Size = UDim2.new(0, 90, 0, 22)
    CreateButton.AnchorPoint = Vector2.new(0.5, 0)
    CreateButton.Position = UDim2.new(0.3, 0, 0, 370)
    CreateButton.Text = "Create"
    CreateButton.TextColor3 = Enum.StudioStyleGuideColor.DialogMainButtonText
    CreateButton.Parent = self

    local SelectPivotButton = NexusPluginFramework.new("TextButton")
    SelectPivotButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogButton
    SelectPivotButton.BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder
    SelectPivotButton.Size = UDim2.new(0, 90, 0, 22)
    SelectPivotButton.AnchorPoint = Vector2.new(0.5, 0)
    SelectPivotButton.Position = UDim2.new(0.7, 0, 0, 370)
    SelectPivotButton.Text = "Select Pivot"
    SelectPivotButton.TextColor3 = Enum.StudioStyleGuideColor.DialogButtonText
    SelectPivotButton.Parent = self

    --Create the checkbox for setting the desired angle to the max.
    local MaxAngleCheckbox = NexusPluginFramework.new("Checkbox")
    MaxAngleCheckbox.Size = UDim2.new(0, 13, 0, 13)
    MaxAngleCheckbox.Position = UDim2.new(0, 4, 0, 400)
    MaxAngleCheckbox.Value = "Unchecked"
    MaxAngleCheckbox.Parent = self

    local MaxAngleText = NexusPluginFramework.new("TextLabel")
    MaxAngleText.Size = UDim2.new(0, 200, 0, 13)
    MaxAngleText.Position = UDim2.new(0, 24, 0, 400)
    MaxAngleText.Text = "Set the desired angle to spin forever."
    MaxAngleText.Parent = self

    --Add the custom properties.
    self:DisableChangeReplication("Part0Property")
    self.Part0Property = Part0
    self:DisableChangeReplication("Part1Property")
    self.Part1Property = Part1
    self:DisableChangeReplication("PositionXOffset")
    self.PositionXOffset = PositionXOffset
    self:DisableChangeReplication("PositionYOffset")
    self.PositionYOffset = PositionYOffset
    self:DisableChangeReplication("PositionZOffset")
    self.PositionZOffset = PositionZOffset
    self:DisableChangeReplication("RotationXAngle")
    self.RotationXAngle = RotationXAngle
    self:DisableChangeReplication("RotationYAngle")
    self.RotationYAngle = RotationYAngle
    self:DisableChangeReplication("MaxVelocity")
    self.MaxVelocity = MaxVelocity
    self:DisableChangeReplication("LocalSpaceCheckbox")
    self.LocalSpaceCheckbox = LocalSpaceCheckbox
    self:DisableChangeReplication("MaxAngleCheckbox")
    self.MaxAngleCheckbox = MaxAngleCheckbox
    self:DisableChangeReplication("Preview")
    local Preview = Motor6DVisual.new()
    Scope:Observer(Preview.Enabled):onBind(function()
        CreateButton.Disabled = not Fusion.peek(Preview.Enabled)
    end)
    self.Preview = Preview
    self:DisableChangeReplication("PivotPart")
    self:DisableChangeReplication("CurrentMotor")

    --Connect updating the pivot part.
    local LastPart0, LastPart1 = nil, nil
    Scope:Observer(Part0):onChange(function()
        local CurrentPart0 = Fusion.peek(Part0)
        if self.PivotPart and self.PivotPart == LastPart0 then
            self.PivotPart = CurrentPart0
        end
        LastPart0 = CurrentPart0
        self:UpdateCurrentMotor()
    end)
    Scope:Observer(Part1):onChange(function()
        local CurrentPart1 = Fusion.peek(Part1)
        if not self.PivotPart or (self.PivotPart and self.PivotPart == LastPart1) then
            self.PivotPart = CurrentPart1
        end
        LastPart1 = CurrentPart1
        self:UpdateCurrentMotor()
    end)

    --Connect the buttons.
    local SelectPivotDB = true
    local CurrentSelection = nil
    SelectPivotButton.MouseButton1Down:Connect(function()
        if SelectPivotDB then
            --Clear the existing selection.
            SelectPivotDB = false
            if CurrentSelection then
                CurrentSelection:Destroy()
                CurrentSelection = nil
            end

            --Start the new selection.
            local NewSelection = PointSelection.new()
            CurrentSelection = NewSelection
            if Plugin then
                Plugin:Activate(true)
            end
            task.spawn(function()
                --Get the selection.
                local SelectionPart, SelectionCFrame = NewSelection:PromptSelection()
                if NewSelection ~= CurrentSelection then return end

                --Update the sliders.
                if SelectionCFrame and SelectionPart then
                    local RelativeCFrame = SelectionPart.CFrame:Inverse() * SelectionCFrame
                    PositionXOffset:set(RelativeCFrame.X / SelectionPart.Size.X)
                    PositionYOffset:set(RelativeCFrame.Y / SelectionPart.Size.Y)
                    PositionZOffset:set(RelativeCFrame.Z / SelectionPart.Size.Z)
                    self.PivotPart = SelectionPart
                end

                --Clear the selection.
                if Plugin then
                    Plugin:Deactivate()
                end
                if NewSelection then
                    NewSelection:Destroy()
                end
            end)
            SelectPivotDB = true
        end
    end)

    local CreateDB = true
    CreateButton.MouseButton1Down:Connect(function()
        if CreateDB and Fusion.peek(self.Preview.Enabled) then
            CreateDB = false

            local Part0, Part1 = Fusion.peek(Part0), Fusion.peek(Part1)
            if Part0 and Part1 then
                --Create the motor.
                ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorBeforeSetMotor")
                if not self.CurrentMotor then
                    local Motor6D = Instance.new("Motor6D")
                    Motor6D.Part0 = Part0
                    Motor6D.Part1 = Part1
                    Motor6D.Parent = Motor6D.Part0
                    self.CurrentMotor = Motor6D
                end

                --Update the motor.
                self.CurrentMotor.C0 = Fusion.peek(self.Preview.C0)
                self.CurrentMotor.C1 = Fusion.peek(self.Preview.C1)
                self.CurrentMotor.MaxVelocity = Fusion.peek(MaxVelocity)
                if MaxAngleCheckbox.Value == "Checked" then
                    self.CurrentMotor.DesiredAngle = 2 ^ 1000
                end
                ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorAfterSetMotor")
            end
            CreateDB = true
        end
    end)

    self:GetPropertyChangedSignal("CurrentMotor"):Connect(function()
        CreateButton.Text = (self.CurrentMotor and "Update" or "Create")
    end)

    --Update the preview.
    RunService.RenderStepped:Connect(function()
        self:UpdatePreview()
    end)
    self:UpdateCurrentMotor()
end

--[[
Updates the current Motor6D for the current parts.
--]]
function Motor6DView:UpdateCurrentMotor(): ()
    --Return if the Part0 or Part1 aren't defined.
    local Part0 = Fusion.peek(self.Part0Property)
    local Part1 = Fusion.peek(self.Part1Property)
    if not Part0 or not Part1 then
        self.CurrentMotor = nil
        return
    end

    --Set the motor in Workspace where the Part0 and Part1 match.
    local MotorFound = false
    for _, Motor6D in Workspace:GetDescendants() do
        if Motor6D:IsA("Motor6D") then
            if (Motor6D.Part0 == Part0 and Motor6D.Part1 == Part1) or (Motor6D.Part0 == Part1 and Motor6D.Part1 == Part0) then
                MotorFound = true
                self.CurrentMotor = Motor6D
                break
            end
        end
    end
    if not MotorFound then
        self.CurrentMotor = nil
    end
end

--[[
Updates the Motor6D preview.
--]]
function Motor6DView:UpdatePreview(): ()
    --Hide the preview if the Part0 or Part1 are not defined.
    local Part0 = Fusion.peek(self.Part0Property)
    local Part1 = Fusion.peek(self.Part1Property)
    local PivotPart = self.PivotPart
    if not Part0 or not Part1 or not PivotPart then
        self.Preview.Enabled:set(false)
        return
    end
    self.Preview.Enabled:set(self.Parent and self.Parent.Enabled)

    --Update the preview.
    local Pivot = PivotPart.CFrame * CFrame.new(PivotPart.Size * Vector3.new(Fusion.peek(self.PositionXOffset), Fusion.peek(self.PositionYOffset), Fusion.peek(self.PositionZOffset)))
    local Rotation = CFrame.Angles(math.rad(Fusion.peek(self.RotationXAngle)), math.rad(Fusion.peek(self.RotationYAngle)), 0)
    if self.LocalSpaceCheckbox.Value ~= "Checked" then
        Pivot = CFrame.new(Pivot.Position)
    end
    Pivot = Pivot * Rotation
    self.Preview.StartCFrame:set(Part0.CFrame)
    self.Preview.C0:set(Part0.CFrame:Inverse() * Pivot)
    self.Preview.C1:set(Part1.CFrame:Inverse() * Pivot)
    self.Preview.Velocity:set(Fusion.peek(self.MaxVelocity))
end

--[[
Loads 2 parts.
--]]
function Motor6DView:LoadParts(Part0: Part, Part1: Part): ()
    --Update the selected motor.
    if Part0 and Part1 then
        for _, Motor6D in Workspace:GetDescendants() do
            if Motor6D:IsA("Motor6D") then
                if (Motor6D.Part0 == Part0 and Motor6D.Part1 == Part1) or (Motor6D.Part0 == Part1 and Motor6D.Part1 == Part0) then
                    self.CurrentMotor = Motor6D
                    Part0 = Motor6D.Part0
                    Part1 = Motor6D.Part1
                    break
                end
            end
        end
    end

    --Set the part selection values.
    self.Part0Property:set(Part0)
    self.Part1Property:set(Part1)

    --Set the sliders.
    local CurrentMotor = self.CurrentMotor
    if self.CurrentMotor then
        --Determine the relative part.
        local PivotPart = nil
        local PivotCFrame = Part0.CFrame * CurrentMotor.C0
        local PivotRelativePosition0 = (Part0.CFrame:Inverse() * PivotCFrame).Position / Part0.Size
        local PivotRelativePosition1 = (Part1.CFrame:Inverse() * PivotCFrame).Position / Part1.Size
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
        self.PositionXOffset:set(PivotRelativeCFrame.X / PivotPart.Size.X)
        self.PositionYOffset:set(PivotRelativeCFrame.Y / PivotPart.Size.Y)
        self.PositionZOffset:set(PivotRelativeCFrame.Z / PivotPart.Size.Z)
        self.RotationXAngle:set(math.deg(AngleX))
        self.RotationYAngle:set(math.deg(AngleY))
        self.MaxVelocity:set(CurrentMotor.MaxVelocity)
        self.PivotPart = PivotPart
    else
        --Reset the sliders.
        self.PositionXOffset:set(0)
        self.PositionYOffset:set(0)
        self.PositionZOffset:set(0)
        self.RotationXAngle:set(0)
        self.RotationYAngle:set(0)
        self.MaxVelocity:set(0)
        self.PivotPart = Part1
    end
    self.LocalSpaceCheckbox.Value = "Checked"
    self.MaxAngleCheckbox.Value = "Unchecked"
end



return (Motor6DView :: any) :: Motor6DView