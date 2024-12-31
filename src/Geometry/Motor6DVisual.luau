--Visualizes a Motor6D.
--!strict

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local Children = Fusion.Children

local Motor6DVisual = {}
Motor6DVisual.__index = Motor6DVisual

export type Motor6DValues = {
    Visible: Fusion.UsedAs<boolean>,
    StartCFrame: Fusion.Value<CFrame?>,
    C0: Fusion.UsedAs<CFrame>,
    C1: Fusion.UsedAs<CFrame>,
    MaxVelocity: Fusion.Value<number>,
}
export type Motor6DVisual = {
    Scope: CreateFusionScope.FusionScope,
} & typeof(setmetatable({}, Motor6DVisual))



--[[
Creates the Motor6D visual.
--]]
function Motor6DVisual.new(ParentScope: CreateFusionScope.FusionScope, Values: Motor6DValues): Motor6DVisual
    --Create the values.
    local Scope = ParentScope:innerScope() :: CreateFusionScope.FusionScope
    local Visible = Values.Visible
    local StartCFrame = Values.StartCFrame
    local C0 = Values.C0
    local C1 = Values.C1
    local Velocity = Values.MaxVelocity

    local CurrentTime = Scope:Value(tick())
    local C1Offset = Scope:Computed(function(use)
        local CurrentC0, CurrentC1 = use(C0) :: CFrame, use(C1) :: CFrame
        local Offset = CurrentC0:Inverse() * CFrame.new(CurrentC0.Position, (CurrentC0 * CurrentC1:Inverse()).Position)
        return CFrame.new(-Offset.Position) * Offset * CFrame.new(0, 0, -CurrentC1.Position.Magnitude / 2)
    end)
    local C0WithRotation = Scope:Computed(function(use)
        local CurrentVelocity = use(Velocity)
        local Rotation = use(CurrentTime) * 60 * (CurrentVelocity == 0 and 0.05 or CurrentVelocity)
        return (use(C0) :: CFrame) * CFrame.Angles(0, 0, Rotation % (math.pi * 2))
    end)
    local OuterCircleRadius = Scope:Computed(function(use)
        local CurrentC1Offset = use(C1Offset)
        return ((((2 * CurrentC1Offset.X) ^ 2) + ((2 * CurrentC1Offset.Y) ^ 2)) ^ 0.5) + 0.025
    end)
    table.insert(Scope, RunService.RenderStepped:Connect(function()
        if not Fusion.peek(Visible) then return end
        CurrentTime:set(tick())
    end))

    --Create the visible components.
    local CenterPart = Scope:New("Part")({
        Size = Vector3.zero,
        Anchored = true,
        CFrame = Scope:Computed(function(use)
            return use(StartCFrame) or CFrame.identity
        end),
    })
    Scope:New("Folder")({
        Name = "Motor6DVisualContainer",
        Parent = CoreGui,
        [Children] = {
            CenterPart,

            --Part0 to center line.
            Scope:New("CylinderHandleAdornment")({
                AlwaysOnTop = true,
                ZIndex = 0,
                Radius = 0.05,
                Color3 = Color3.fromRGB(0, 0, 255),
                Visible = Visible,
                Adornee = CenterPart,
                Height = Scope:Computed(function(use)
                    return use(C0).Position.Magnitude
                end),
                CFrame = Scope:Computed(function(use)
                    local CurrentC0 = use(C0) :: CFrame
                    return CFrame.new(Vector3.zero, CurrentC0.Position) * CFrame.new(0, 0, -CurrentC0.Position.Magnitude / 2)
                end),
            }),

            --Part1 to center line.
            Scope:New("CylinderHandleAdornment")({
                AlwaysOnTop = true,
                ZIndex = 0,
                Radius = 0.05,
                Color3 = Color3.fromRGB(255, 0, 0),
                Visible = Visible,
                Adornee = CenterPart,
                Height = Scope:Computed(function(use)
                    return (use(C1) :: CFrame).Position.Magnitude
                end),
                CFrame = Scope:Computed(function(use)
                    return (use(C0) :: CFrame) * use(C1Offset)
                end),
            }),

            --Rotating Part1 to center line.
            Scope:New("CylinderHandleAdornment")({
                AlwaysOnTop = true,
                ZIndex = 0,
                Radius = 0.05,
                Color3 = Color3.fromRGB(0, 255, 0),
                Visible = Visible,
                Adornee = CenterPart,
                Height = Scope:Computed(function(use)
                    return (use(C1) :: CFrame).Position.Magnitude
                end),
                CFrame = Scope:Computed(function(use)
                    return use(C0WithRotation) * use(C1Offset)
                end),
            }),

            --Part1 rotation circle.
            Scope:New("CylinderHandleAdornment")({
                AlwaysOnTop = true,
                Height = 0.05,
                Color3 = Color3.fromRGB(0, 255, 0),
                Transparency = 0.5,
                Visible = Visible,
                Adornee = CenterPart,
                CFrame = Scope:Computed(function(use)
                    return (use(C0) :: CFrame) * CFrame.new(0, 0, use(C1Offset).Z * 2)
                end),
                InnerRadius = Scope:Computed(function(use)
                    return use(OuterCircleRadius) - 0.05
                end),
                Radius = OuterCircleRadius,
            }),

            --Center rotation cicle.
            Scope:New("CylinderHandleAdornment")({
                AlwaysOnTop = true,
                Height = 0.05,
                Radius = 1.1,
                InnerRadius = 1.05,
                Color3 = Color3.fromRGB(0, 255, 0),
                Transparency = 0.5,
                Visible = Visible,
                Adornee = CenterPart,
                CFrame = C0,
            }),

            --First center rotation direction indicator.
            Scope:New("ConeHandleAdornment")({
                AlwaysOnTop = true,
                ZIndex = 0,
                Radius = 0.25,
                Height = 1,
                Color3 = Color3.fromRGB(0, 255, 0),
                Visible = Visible,
                Adornee = CenterPart,
                CFrame = Scope:Computed(function(use)
                    return use(C0WithRotation) * CFrame.new(0.5, 1, 0) * CFrame.Angles(0, math.rad(90), 0)
                end),
            }),

            --second center rotation direction indicator.
            Scope:New("ConeHandleAdornment")({
                AlwaysOnTop = true,
                ZIndex = 0,
                Radius = 0.25,
                Height = 1,
                Color3 = Color3.fromRGB(0, 255, 0),
                Visible = Visible,
                Adornee = CenterPart,
                CFrame = Scope:Computed(function(use)
                    return use(C0WithRotation) * CFrame.new(-0.5, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
                end),
            }),
        },
    })

    --Create and return the object.
    return setmetatable({
        Scope = Scope,
    }, Motor6DVisual) :: Motor6DVisual
end

--[[
Destroys the Motor6D visual.
--]]
function Motor6DVisual.Destroy(self: Motor6DVisual): ()
    self.Scope:doCleanup()
end



return Motor6DVisual