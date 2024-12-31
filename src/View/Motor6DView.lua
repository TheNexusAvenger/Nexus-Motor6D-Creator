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
local Header = require(script.Parent:WaitForChild("Row"):WaitForChild("Header"))
local InstanceRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("InstanceRowProperty"))
local RotationButtonRow = require(script.Parent:WaitForChild("Row"):WaitForChild("RotationButtonRow"))
local SliderRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("SliderRowProperty"))
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
    local PartPropertiesHeader = Header.new()
    PartPropertiesHeader.Text = "Parts"
    PartPropertiesHeader.Parent = self

    local Part0PropertyRow = InstanceRowProperty.new()
    Part0PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 1)
    Part0PropertyRow.Text = "Part0"
    Part0PropertyRow.Plugin = Plugin
    Part0PropertyRow.Parent = self

    local Part1PropertyRow = InstanceRowProperty.new()
    Part1PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 2)
    Part1PropertyRow.Text = "Part1"
    Part0PropertyRow.Plugin = Plugin
    Part1PropertyRow.Parent = self

    --Create the position property rows.
    local PositionPropertiesHeader = Header.new()
    PositionPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 3)
    PositionPropertiesHeader.Text = "Position Offset"
    PositionPropertiesHeader.Parent = self

    local PositionXSlider = SliderRowProperty.new()
    PositionXSlider.Position = UDim2.new(0, 0, 0, 23 * 4)
    PositionXSlider.Text = "X Axis"
    PositionXSlider.Parent = self

    local PositionYSlider = SliderRowProperty.new()
    PositionYSlider.Position = UDim2.new(0, 0, 0, 23 * 5)
    PositionYSlider.Text = "Y Axis"
    PositionYSlider.Parent = self

    local PositionZSlider = SliderRowProperty.new()
    PositionZSlider.Position = UDim2.new(0, 0, 0, 23 * 6)
    PositionZSlider.Text = "Z Axis"
    PositionZSlider.Parent = self

    --Create the rotation property rows.
    local RotationPropertiesHeader = Header.new()
    RotationPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 7)
    RotationPropertiesHeader.Text = "Rotation Offset"
    RotationPropertiesHeader.Parent = self

    local RotationXSlider = SliderRowProperty.new()
    RotationXSlider.Position = UDim2.new(0, 0, 0, 23 * 8)
    RotationXSlider.Text = "X Axis"
    RotationXSlider.MinimumValue = -180
    RotationXSlider.MaximumValue = 180
    RotationXSlider.Parent = self

    local RotationYSlider = SliderRowProperty.new()
    RotationYSlider.Position = UDim2.new(0, 0, 0, 23 * 9)
    RotationYSlider.Text = "Y Axis"
    RotationYSlider.MinimumValue = -180
    RotationYSlider.MaximumValue = 180
    RotationYSlider.Parent = self

    --Create the motor property rows.
    local MotorPropertiesHeader = Header.new()
    MotorPropertiesHeader.Position = UDim2.new(0, 0, 0, 23 * 10)
    MotorPropertiesHeader.Text = "Motor"
    MotorPropertiesHeader.Parent = self

    local MaxVelocitySlider = SliderRowProperty.new()
    MaxVelocitySlider.Position = UDim2.new(0, 0, 0, 23 * 11)
    MaxVelocitySlider.Text = "MaxVelocity"
    MaxVelocitySlider.MinimumValue = 0
    MaxVelocitySlider.MaximumValue = 0.25
    MaxVelocitySlider.Parent = self

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
    local XAxisButtons = RotationButtonRow.new("X Axis", RotationXSlider)
    XAxisButtons.Position = UDim2.new(0, 0, 0, 300)
    XAxisButtons.Parent = self

    local YAxisButtons = RotationButtonRow.new("Y Axis", RotationYSlider)
    YAxisButtons.Position = UDim2.new(0, 0, 0, 300 + (24 * 1))
    YAxisButtons.Parent = self

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
    self.Part0Property = Part0PropertyRow
    self:DisableChangeReplication("Part1Property")
    self.Part1Property = Part1PropertyRow
    self:DisableChangeReplication("PositionXSlider")
    self.PositionXSlider = PositionXSlider
    self:DisableChangeReplication("PositionYSlider")
    self.PositionYSlider = PositionYSlider
    self:DisableChangeReplication("PositionZSlider")
    self.PositionZSlider = PositionZSlider
    self:DisableChangeReplication("RotationXSlider")
    self.RotationXSlider = RotationXSlider
    self:DisableChangeReplication("RotationYSlider")
    self.RotationYSlider = RotationYSlider
    self:DisableChangeReplication("MaxVelocitySlider")
    self.MaxVelocitySlider = MaxVelocitySlider
    self:DisableChangeReplication("LocalSpaceCheckbox")
    self.LocalSpaceCheckbox = LocalSpaceCheckbox
    self:DisableChangeReplication("MaxAngleCheckbox")
    self.MaxAngleCheckbox = MaxAngleCheckbox
    self:DisableChangeReplication("Preview")
    local Preview = Motor6DVisual.new()
    CreateFusionScope():Observer(Preview.Enabled):onBind(function()
        CreateButton.Disabled = not Fusion.peek(Preview.Enabled)
    end)
    self.Preview = Preview
    self:DisableChangeReplication("PivotPart")
    self:DisableChangeReplication("CurrentMotor")

    --Connect updating the pivot part.
    local LastPart0, LastPart1 = nil, nil
    Part0PropertyRow:GetPropertyChangedSignal("Value"):Connect(function()
        if self.PivotPart and self.PivotPart == LastPart0 then
            self.PivotPart = Part0PropertyRow.Value
        end
        LastPart0 = Part0PropertyRow.Value
        self:UpdateCurrentMotor()
    end)
    Part1PropertyRow:GetPropertyChangedSignal("Value"):Connect(function()
        if not self.PivotPart or (self.PivotPart and self.PivotPart == LastPart1) then
            self.PivotPart = Part1PropertyRow.Value
        end
        LastPart1 = Part1PropertyRow.Value
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
                    PositionXSlider.Value = RelativeCFrame.X / SelectionPart.Size.X
                    PositionYSlider.Value = RelativeCFrame.Y / SelectionPart.Size.Y
                    PositionZSlider.Value = RelativeCFrame.Z / SelectionPart.Size.Z
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

            local Part0, Part1 = Part0PropertyRow.Value, Part1PropertyRow.Value
            if Part0 and Part1 then
                --Create the motor.
                ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorBeforeSetMotor")
                if not self.CurrentMotor then
                    local Motor6D = Instance.new("Motor6D")
                    Motor6D.Part0 = Part0:GetWrappedInstance()
                    Motor6D.Part1 = Part1:GetWrappedInstance()
                    Motor6D.Parent = Motor6D.Part0
                    self.CurrentMotor = Motor6D
                end

                --Update the motor.
                self.CurrentMotor.C0 = Fusion.peek(self.Preview.C0)
                self.CurrentMotor.C1 = Fusion.peek(self.Preview.C1)
                self.CurrentMotor.MaxVelocity = MaxVelocitySlider.Value
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
    local Part0 = self.Part0Property.Value
    local Part1 = self.Part1Property.Value
    if not Part0 or not Part1 then
        self.CurrentMotor = nil
        return
    end

    --Set the motor in Workspace where the Part0 and Part1 match.
    local MotorFound = false
    Part0 = Part0:GetWrappedInstance()
    Part1 = Part1:GetWrappedInstance()
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
    local Part0 = self.Part0Property.Value
    local Part1 = self.Part1Property.Value
    local PivotPart = self.PivotPart
    if not Part0 or not Part1 or not PivotPart then
        self.Preview.Enabled:set(false)
        return
    end
    self.Preview.Enabled:set(self.Parent and self.Parent.Enabled)

    --Update the preview.
    local Pivot = PivotPart.CFrame * CFrame.new(PivotPart.Size * Vector3.new(self.PositionXSlider.Value, self.PositionYSlider.Value, self.PositionZSlider.Value))
    local Rotation = CFrame.Angles(math.rad(self.RotationXSlider.Value), math.rad(self.RotationYSlider.Value), 0)
    if self.LocalSpaceCheckbox.Value ~= "Checked" then
        Pivot = CFrame.new(Pivot.Position)
    end
    Pivot = Pivot * Rotation
    self.Preview.StartCFrame:set(Part0.CFrame)
    self.Preview.C0:set(Part0.CFrame:Inverse() * Pivot)
    self.Preview.C1:set(Part1.CFrame:Inverse() * Pivot)
    self.Preview.Velocity:set(self.MaxVelocitySlider.Value)
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
    self.Part0Property.Value = Part0
    self.Part1Property.Value = Part1

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
        self.PositionXSlider.Value = PivotRelativeCFrame.X / PivotPart.Size.X
        self.PositionYSlider.Value = PivotRelativeCFrame.Y / PivotPart.Size.Y
        self.PositionZSlider.Value = PivotRelativeCFrame.Z / PivotPart.Size.Z
        self.RotationXSlider.Value = math.deg(AngleX)
        self.RotationYSlider.Value = math.deg(AngleY)
        self.MaxVelocitySlider.Value = CurrentMotor.MaxVelocity
        self.PivotPart = PivotPart
    else
        --Reset the sliders.
        self.PositionXSlider.Value = 0
        self.PositionYSlider.Value = 0
        self.PositionZSlider.Value = 0
        self.RotationXSlider.Value = 0
        self.RotationYSlider.Value = 0
        self.MaxVelocitySlider.Value = 0
        self.PivotPart = Part1
    end
    self.LocalSpaceCheckbox.Value = "Checked"
    self.MaxAngleCheckbox.Value = "Unchecked"
end



return (Motor6DView :: any) :: Motor6DView