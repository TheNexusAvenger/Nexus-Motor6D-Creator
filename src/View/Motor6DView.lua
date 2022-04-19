--[[
TheNexusAvenger

View for editting Motor6D properties.
--]]

local NexusPluginFramework = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"))
local Header = require(script.Parent:WaitForChild("Row"):WaitForChild("Header"))
local InstanceRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("InstanceRowProperty"))
local RotationButtonRow = require(script.Parent:WaitForChild("Row"):WaitForChild("RotationButtonRow"))
local SliderRowProperty = require(script.Parent:WaitForChild("Row"):WaitForChild("SliderRowProperty"))
local PointSelection = require(script.Parent.Parent:WaitForChild("Geometry"):WaitForChild("PointSelection"))

local Motor6DView = NexusPluginFramework:GetResource("Base.PluginInstance"):Extend()
Motor6DView:SetClassName("Motor6DView")



--[[
Creates the Motor6D view.
--]]
function Motor6DView:__new()
    self:InitializeSuper("Frame")
    self.BorderSizePixel = 1

    --Create the part property rows.
    local PartPropertiesHeader = Header.new()
    PartPropertiesHeader.Text = "Parts"
    PartPropertiesHeader.Parent = self

    local Part0PropertyRow = InstanceRowProperty.new()
    Part0PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 1)
    Part0PropertyRow.Text = "Part0"
    Part0PropertyRow.Parent = self

    local Part1PropertyRow = InstanceRowProperty.new()
    Part1PropertyRow.Position = UDim2.new(0, 0, 0, 23 * 2)
    Part1PropertyRow.Text = "Part1"
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

    local RotationZSlider = SliderRowProperty.new()
    RotationZSlider.Position = UDim2.new(0, 0, 0, 23 * 10)
    RotationZSlider.Text = "Z Axis"
    RotationZSlider.MinimumValue = -180
    RotationZSlider.MaximumValue = 180
    RotationZSlider.Parent = self

    --Create the toggle for local/global rotation.
    local LocalSpaceCheckbox = NexusPluginFramework.new("Checkbox")
    LocalSpaceCheckbox.Size = UDim2.new(0, 13, 0, 13)
    LocalSpaceCheckbox.Position = UDim2.new(0, 4, 0, (23 * 11) + 4)
    LocalSpaceCheckbox.Value = "Checked"
    LocalSpaceCheckbox.Parent = self

    local LocalSpaceText = NexusPluginFramework.new("TextLabel")
    LocalSpaceText.Size = UDim2.new(0, 200, 0, 13)
    LocalSpaceText.Position = UDim2.new(0, 24, 0, (23 * 11) + 4)
    LocalSpaceText.Text = "Rotation relative to selected pivot"
    LocalSpaceText.Parent = self

    --Create the slider toggle buttons.
    local XAxisButtons = RotationButtonRow.new("X Axis", RotationXSlider)
    XAxisButtons.Position = UDim2.new(0, 0, 0, 280)
    XAxisButtons.Parent = self

    local YAxisButtons = RotationButtonRow.new("Y Axis", RotationYSlider)
    YAxisButtons.Position = UDim2.new(0, 0, 0, 280 + (24 * 1))
    YAxisButtons.Parent = self

    local ZAxisButtons = RotationButtonRow.new("Z Axis", RotationZSlider)
    ZAxisButtons.Position = UDim2.new(0, 0, 0, 280 + (24 * 2))
    ZAxisButtons.Parent = self

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

    --Add the custom properties.
    self:DisableChangeReplication("PivotPart")

    --Connect the buttons.
    local SelectPivotDB = true
    local CurrentSelection = nil
    SelectPivotButton.MouseButton1Down:Connect(function()
        if SelectPivotDB then
            --Clear the existing selection.
            SelectPivotDB = false
            if CurrentSelection then
                CurrentSelection:Destroy()
            end

            --Start the new selection.
            local NewSelection = PointSelection.new()
            CurrentSelection = NewSelection
            task.spawn(function()
                --Get the selection.
                local SelectionCFrame = NewSelection:PromptSelection()
                local SelectionPart = NewSelection.LastPart
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
                if NewSelection then
                    NewSelection:Destroy()
                end
            end)
            SelectPivotDB = true
        end
    end)
end



return Motor6DView