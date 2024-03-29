--[[
TheNexusAvenger

Visualizes a Motor6D.
--]]
--!strict

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local NexusInstance = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("NexusInstance"):WaitForChild("NexusInstance"))

local Motor6DVisual = NexusInstance:Extend()
Motor6DVisual:SetClassName("Motor6DVisual")

export type Motor6DVisual = {
    new: () -> (Motor6DVisual),
    Extend: (self: Motor6DVisual) -> (Motor6DVisual),

    StartCFrame: CFrame,
    C0: CFrame,
    C1: CFrame,
    Velocity: number,
    Enabled: boolean,
} & NexusInstance.NexusInstance



--[[
Creates the Motor6D visual.
--]]
function Motor6DVisual:__new(): ()
    NexusInstance.__new(self)

    --Create the visible components.
    local Motor6DVisualContainer = Instance.new("Folder")
    Motor6DVisualContainer.Name = "Motor6DVisualContainer"
    Motor6DVisualContainer.Parent = CoreGui
    self.Motor6DVisualContainer = Motor6DVisualContainer

    local CenterPart = Instance.new("Part")
    CenterPart.Size = Vector3.zero
    CenterPart.Anchored = true
    CenterPart.Parent = Motor6DVisualContainer

    local Part0Adorn = Instance.new("CylinderHandleAdornment")
    Part0Adorn.AlwaysOnTop = true
    Part0Adorn.ZIndex = 0
    Part0Adorn.Radius = 0.05
    Part0Adorn.Color3 = Color3.new(0, 0, 1)
    Part0Adorn.Adornee = CenterPart
    Part0Adorn.Parent = Motor6DVisualContainer

    local Part1StaticAdorn = Instance.new("CylinderHandleAdornment")
    Part1StaticAdorn.AlwaysOnTop = true
    Part1StaticAdorn.ZIndex = 0
    Part1StaticAdorn.Radius = 0.05
    Part1StaticAdorn.Color3 = Color3.new(1, 0, 0)
    Part1StaticAdorn.Adornee = CenterPart
    Part1StaticAdorn.Parent = Motor6DVisualContainer

    local Part1RotatingAdorn = Instance.new("CylinderHandleAdornment")
    Part1RotatingAdorn.AlwaysOnTop = true
    Part1RotatingAdorn.ZIndex = 0
    Part1RotatingAdorn.Radius = 0.05
    Part1RotatingAdorn.Color3 = Color3.new(0, 1, 0)
    Part1RotatingAdorn.Adornee = CenterPart
    Part1RotatingAdorn.Parent = Motor6DVisualContainer

    local OuterRotationCircle = Instance.new("CylinderHandleAdornment")
    OuterRotationCircle.Name = "OuterRotationCircle"
    OuterRotationCircle.AlwaysOnTop = true
    OuterRotationCircle.Height = 0.05
    OuterRotationCircle.Color3 = Color3.new(0, 1, 0)
    OuterRotationCircle.Transparency = 0.5
    OuterRotationCircle.Adornee = CenterPart
    OuterRotationCircle.Parent = Motor6DVisualContainer

    local InnerRotationCircle = Instance.new("CylinderHandleAdornment")
    InnerRotationCircle.AlwaysOnTop = true
    InnerRotationCircle.Height = 0.05
    InnerRotationCircle.Radius = 1.1
    InnerRotationCircle.InnerRadius = 1.05
    InnerRotationCircle.Color3 = Color3.new(0, 1, 0)
    InnerRotationCircle.Transparency = 0.5
    InnerRotationCircle.Adornee = CenterPart
    InnerRotationCircle.Parent = Motor6DVisualContainer

    local RotationDirection1 = Instance.new("ConeHandleAdornment")
    RotationDirection1.AlwaysOnTop = true
    RotationDirection1.ZIndex = 0
    RotationDirection1.Radius = 0.25
    RotationDirection1.Height = 1
    RotationDirection1.Color3 = Color3.new(0, 1, 0)
    RotationDirection1.Adornee = CenterPart
    RotationDirection1.Parent = Motor6DVisualContainer

    local RotationDirection2 = Instance.new("ConeHandleAdornment")
    RotationDirection2.AlwaysOnTop = true
    RotationDirection2.ZIndex = 0
    RotationDirection2.Radius = 0.25
    RotationDirection2.Height = 1
    RotationDirection2.Color3 = Color3.new(0, 1, 0)
    RotationDirection2.Adornee = CenterPart
    RotationDirection2.Parent = Motor6DVisualContainer

    --Store the visual values.
    self.StartCFrame = CFrame.new()
    self.C0 = CFrame.new()
    self.C1 = CFrame.new()
    self.Velocity = 0
    self.Enabled = true

    --Set up updating.
    self.UpdateEvent = RunService.RenderStepped:Connect(function()
        local C1Offset = self.C0:Inverse() * CFrame.new(self.C0.Position, (self.C0 * self.C1:Inverse()).Position)
        C1Offset = CFrame.new(-C1Offset.Position) * C1Offset * CFrame.new(0, 0, -self.C1.Position.Magnitude / 2)
        local Velocity = (self.Velocity == 0 and 0.05 or self.Velocity)
        local Rotation = tick() * 60 * Velocity
        local BaseRotationCFrame = self.C0 * CFrame.Angles(0, 0, Rotation % (math.pi * 2))
        local OuterCircleRadius = ((((2 * C1Offset.X) ^ 2) + ((2 * C1Offset.Y) ^ 2)) ^ 0.5) + 0.025

        Part0Adorn.Visible = self.Enabled
        Part1StaticAdorn.Visible = self.Enabled
        Part1RotatingAdorn.Visible = self.Enabled
        OuterRotationCircle.Visible = self.Enabled
        InnerRotationCircle.Visible = self.Enabled
        RotationDirection1.Visible = self.Enabled
        RotationDirection2.Visible = self.Enabled

        CenterPart.CFrame = self.StartCFrame
        Part0Adorn.CFrame = CFrame.new(Vector3.zero, self.C0.Position) * CFrame.new(0, 0, -self.C0.Position.Magnitude / 2)
        Part0Adorn.Height = self.C0.Position.Magnitude
        Part1StaticAdorn.Height = self.C1.Position.Magnitude
        Part1RotatingAdorn.Height = self.C1.Position.Magnitude
        Part1StaticAdorn.CFrame = self.C0 * C1Offset
        Part1RotatingAdorn.CFrame = BaseRotationCFrame * C1Offset
        InnerRotationCircle.CFrame = self.C0
        OuterRotationCircle.CFrame = self.C0 * CFrame.new(0, 0, C1Offset.Z * 2)
        RotationDirection1.CFrame = BaseRotationCFrame * CFrame.new(0.5, 1, 0) * CFrame.Angles(0, math.rad(90), 0)
        RotationDirection2.CFrame = BaseRotationCFrame * CFrame.new(-0.5, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
        OuterRotationCircle.InnerRadius = OuterCircleRadius - 0.05
        OuterRotationCircle.Radius = OuterCircleRadius
    end)
end

--[[
Destroys the Motor6D visual.
--]]
function Motor6DVisual:Destroy(): ()
    NexusInstance.Destroy(self)
    self.Motor6DVisualContainer:Destroy()
    self.UpdateEvent:Disconnect()
end



return (Motor6DVisual :: any) :: Motor6DVisual