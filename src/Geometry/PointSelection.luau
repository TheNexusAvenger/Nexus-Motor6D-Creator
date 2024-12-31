--Shows a selection of points in a 3 x 3 x 3 grid for a part.
--!strict

local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local CreateFusionScope = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local GetMouseTarget = require(NexusMotor6DCreatorPlugin:WaitForChild("Util"):WaitForChild("GetMouseTarget"))

local Children = Fusion.Children
local Out = Fusion.Out

local PointSelection = {}
PointSelection.__index = PointSelection

type PointData = {
    CFrame: Fusion.UsedAs<CFrame>,
    AbsoluteSize: Fusion.Value<Vector2>,
}
export type PointSelection = {
    Scope: CreateFusionScope.FusionScope,
    AdornPart: Fusion.Value<BasePart?>,
    SelectedPointIndex: Fusion.Value<number?>,
    Points: {PointData},
} & typeof(setmetatable({}, PointSelection))



--[[
Creates the point selection.
--]]
function PointSelection.new(): PointSelection
    --Create the points container.
    local Scope = CreateFusionScope()
    local PointSelectionContainer = Scope:New("Folder")({
        Name = "PointSelectionContainer",
        Parent = CoreGui,
    })

    --Create the values for the adorned part.
    local AdornPart = Scope:Value(nil) :: Fusion.Value<BasePart?>
    local AdornPartCFrame = Scope:Value(CFrame.identity)
    local AdornPartSize = Scope:Value(Vector3.zero)
    local AdornPartConnections = {} :: {RBXScriptConnection}
    Scope:Observer(AdornPart):onChange(function()
        --Clear the previous connections.
        for _, EventConnection in AdornPartConnections do
            EventConnection:Disconnect()
        end
        AdornPartConnections = {}

        --Set up the new part, or reset the state if there is no part.
        local CurrentAdornPart = Fusion.peek(AdornPart)
        if CurrentAdornPart then
            AdornPartCFrame:set(CurrentAdornPart.CFrame)
            table.insert(AdornPartConnections, CurrentAdornPart:GetPropertyChangedSignal("CFrame"):Connect(function()
                AdornPartCFrame:set(CurrentAdornPart.CFrame)
            end))

            AdornPartSize:set(CurrentAdornPart.Size)
            table.insert(AdornPartConnections, CurrentAdornPart:GetPropertyChangedSignal("Size"):Connect(function()
                AdornPartSize:set(CurrentAdornPart.Size)
            end))
        else
            AdornPartCFrame:set(CFrame.identity)
            AdornPartSize:set(Vector3.zero)
        end
    end)

    --Create the points.
    local Points = {}
    local SelectedPointIndex = Scope:Value(nil) :: Fusion.Value<number?>
    for X = -0.5, 0.5, 0.5 do
        for Y = -0.5, 0.5, 0.5 do
            for Z = -0.5, 0.5, 0.5 do
                local PointIndex = #Points + 1
                local PointCFrame = Scope:Computed(function(use)
                    local CurrentAdornPartCFrame = use(AdornPartCFrame)
                    local CurrentAdornPartSize = use(AdornPartSize)
                    return CurrentAdornPartCFrame * CFrame.new(X * CurrentAdornPartSize.X, Y * CurrentAdornPartSize.Y, Z * CurrentAdornPartSize.Z)
                end)
                local AbsoluteSize = Scope:Value(Vector2.zero)

                local PointAdornPart = Scope:New("Part")({
                    Anchored = true,
                    CFrame = PointCFrame,
                    Parent = PointSelectionContainer,
                })
                Scope:New("BillboardGui")({
                    AlwaysOnTop = true,
                    Enabled = Scope:Computed(function(use)
                        return use(AdornPart) ~= nil
                    end),
                    Size = UDim2.new(0.5, 0, 0.5, 0),
                    Adornee = PointAdornPart,
                    Parent = PointAdornPart,
                    [Children] = {
                        Scope:New("Frame")({
                            BackgroundColor3 = Scope:Computed(function(use)
                                return use(SelectedPointIndex) == PointIndex and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                            end),
                            Size = UDim2.new(1, 0, 1, 0),
                            [Out("AbsoluteSize")] = AbsoluteSize,
                            [Children] = {
                                Scope:New("UICorner")({
                                    CornerRadius = UDim.new(0.5, 0),
                                }),

                                Scope:New("UIStroke")({
                                    Color = Color3.fromRGB(0, 0, 0),
                                    Thickness = 2,
                                }),
                            },
                        }),
                    },
                })

                table.insert(Points, {
                    CFrame = PointCFrame,
                    AbsoluteSize = AbsoluteSize,
                } :: PointData)
            end
        end
    end

    --Create and return the object.
    return setmetatable({
        Scope = Scope,
        AdornPart = AdornPart,
        SelectedPointIndex = SelectedPointIndex,
        Points = Points,
    }, PointSelection) :: PointSelection
end

--[[
Updates the selected frame.
--]]
function PointSelection.UpdateSelectedFrame(self: PointSelection, X: number, Y: number): ()
    --Reset the selected point index.
    if not Fusion.peek(self.AdornPart) then
        self.SelectedPointIndex:set(nil)
        return
    end

    --Get the closest point.
    local CurrentPointIndex = nil
	local ClosestDepth = math.huge
	for i, PointData in self.Points do
		local ScreenPosition = Workspace.CurrentCamera:WorldToScreenPoint(Fusion.peek(PointData.CFrame).Position)
		local Depth = ScreenPosition.Z
		if Depth > 0 and ClosestDepth > Depth then
			local Radius = Fusion.peek(PointData.AbsoluteSize).X / 2
			local MouseToCenter = (((X - ScreenPosition.X) ^ 2) + ((Y - ScreenPosition.Y) ^ 2)) ^ 0.5
			if MouseToCenter <= Radius then
				CurrentPointIndex = i
				ClosestDepth = Depth
			end
		end
	end

    --Set the index of the point.
    self.SelectedPointIndex:set(CurrentPointIndex)
end

--[[
Prompts for a CFrame selection.
--]]
function PointSelection.PromptSelection(self: PointSelection): (BasePart?, CFrame?)
    --Connect updating the mouse.
    table.insert(self.Scope, UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        --Update the selected frame and return if one exists.
        self:UpdateSelectedFrame(Input.Position.X, Input.Position.Y)
        if Fusion.peek(self.SelectedPointIndex) then
            return
        end

        --Update the selection.
        local NewAdorn = GetMouseTarget(Input.Position.X, Input.Position.Y)
        self.AdornPart:set(NewAdorn)
        self:UpdateSelectedFrame(Input.Position.X, Input.Position.Y)
    end))

    --Wait for a mouse click.
    while true do
        local Input, Processed = UserInputService.InputBegan:Wait()
        if not Processed and Input.UserInputType == Enum.UserInputType.MouseButton1 then break end
    end

    --Return the CFrame.
    local CurrentSelectedPointIndex = Fusion.peek(self.SelectedPointIndex)
    return Fusion.peek(self.AdornPart), CurrentSelectedPointIndex and Fusion.peek(self.Points[CurrentSelectedPointIndex].CFrame)
end

--[[
Destroys the point selection.
--]]
function PointSelection.Destroy(self: PointSelection): ()
    self.Scope:doCleanup()
end



return PointSelection