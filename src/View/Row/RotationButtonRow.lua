--[[
TheNexusAvenger

Row of buttons for quickly rotating a rotation slider.
--]]

local NexusPluginFramework = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))

local RotationButtonRow = NexusPluginFramework:GetResource("Base.PluginInstance"):Extend()
RotationButtonRow:SetClassName("RotationButtonRow")



--[[
Creates the button row.
--]]
function RotationButtonRow:__new(Text, Slider)
    self:InitializeSuper("Frame")

    --Create the child buttons.
    local Minus90Button = NexusPluginFramework.new("TextButton")
    Minus90Button.AnchorPoint = Vector2.new(0.5, 0)
    Minus90Button.Size = UDim2.new(0.125, 0, 1, 0)
    Minus90Button.Position = UDim2.new(0.2, 0, 0, 0)
    Minus90Button.Text = "< 90°"
    Minus90Button.Parent = self
    Minus90Button.MouseButton1Down:Connect(function()
        self:AddAngle(-90)
    end)

    local Minus45Button = NexusPluginFramework.new("TextButton")
    Minus45Button.AnchorPoint = Vector2.new(0.5, 0)
    Minus45Button.Size = UDim2.new(0.125, 0, 1, 0)
    Minus45Button.Position = UDim2.new(0.35, 0, 0, 0)
    Minus45Button.Text = "< 45°"
    Minus45Button.Parent = self
    Minus45Button.MouseButton1Down:Connect(function()
        self:AddAngle(-45)
    end)

    local Plus45Button = NexusPluginFramework.new("TextButton")
    Plus45Button.AnchorPoint = Vector2.new(0.5, 0)
    Plus45Button.Size = UDim2.new(0.125, 0, 1, 0)
    Plus45Button.Position = UDim2.new(0.65, 0, 0, 0)
    Plus45Button.Text = "45° >"
    Plus45Button.Parent = self
    Plus45Button.MouseButton1Down:Connect(function()
        self:AddAngle(45)
    end)

    local Plus90Button = NexusPluginFramework.new("TextButton")
    Plus90Button.AnchorPoint = Vector2.new(0.5, 0)
    Plus90Button.Size = UDim2.new(0.125, 0, 1, 0)
    Plus90Button.Position = UDim2.new(0.8, 0, 0, 0)
    Plus90Button.Text = "90° >"
    Plus90Button.Parent = self
    Plus90Button.MouseButton1Down:Connect(function()
        self:AddAngle(90)
    end)

    local AxisText = NexusPluginFramework.new("TextLabel")
    AxisText.Size = UDim2.new(1, 0, 1, 0)
    AxisText.Text = Text
    AxisText.Font = Enum.Font.SourceSansBold
    AxisText.TextXAlignment = Enum.TextXAlignment.Center
    AxisText.Parent = self

    --Set the defaults.
    self:DisableChangeReplication("Slider")
    self.Slider = Slider
    self.BackgroundTransparency = 1
    self.Size = UDim2.new(1, -2, 0, 20)
end

--[[
Adds an angle to the slider.
--]]
function RotationButtonRow:AddAngle(Angle)
    local NewValue = ((self.Slider.Value + 180 + Angle) % 360) - 180
    if NewValue == -180 then
        NewValue = 180
    end
    self.Slider.Value = NewValue
end



return RotationButtonRow