--[[
TheNexusAvenger

Shows a selection of points in a 3 x 3 x 3 grid for a part.
--]]

local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local NexusPluginFramework = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"))

local PointSelection = NexusPluginFramework:GetResource("NexusInstance.NexusInstance"):Extend()
PointSelection:SetClassName("PointSelection")



--[[
Creates the point selection.
--]]
function PointSelection:__new()
    self:InitializeSuper()

    --Create the selection components.
    local PointSelectionContainer = Instance.new("Folder")
    PointSelectionContainer.Name = "PointSelectionContainer"
    PointSelectionContainer.Parent = CoreGui
    self.PointSelectionContainer = PointSelectionContainer

    self.Events = {}
    self.Points = {}
    for _ = 1, 27 do
        local Part = Instance.new("Part")
        Part.Anchored = true
        Part.Parent = PointSelectionContainer

        local BillboardGui = Instance.new("BillboardGui")
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Enabled = false
        BillboardGui.Size = UDim2.new(0.5, 0, 0.5, 0)
        BillboardGui.Adornee = Part
        BillboardGui.Parent = Part

        local SelectFrame = Instance.new("Frame")
        SelectFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        SelectFrame.Size = UDim2.new(1, 0, 1, 0)
        SelectFrame.Parent = BillboardGui

        local SelectFrameCorner = Instance.new("UICorner")
        SelectFrameCorner.CornerRadius = UDim.new(0.5, 0)
        SelectFrameCorner.Parent = SelectFrame

        local SelectFrameStroke = Instance.new("UIStroke")
        SelectFrameStroke.Color = Color3.new(0, 0, 0)
        SelectFrameStroke.Thickness = 2
        SelectFrameStroke.Parent = SelectFrame

        table.insert(self.Points, {
            Part = Part,
            BillboardGui = BillboardGui,
            Frame = SelectFrame,
        })
    end
end

--[[
Static function for prompting for a CFrame.
--]]
function PointSelection.PromptForCFrame(): CFrame
    local Selection = PointSelection.new()
    local SelectedCFrame = Selection:PromptSelection()
    Selection:Destroy()
    return SelectedCFrame
end

--[[
Sets the adorned part for the point selection.
--]]
function PointSelection:SetAdornPart(Part: BasePart?): nil
    --Return if the part hasn't changed.
    if self.LastPart == Part and (not Part or (self.LastSize == Part.Size and self.LastCFrame == Part.CFrame)) then
        return
    end

    --Disconnect the part events.
    if self.PartUpdateEvents and self.LastPart ~= Part then
        for _, Event in pairs(self.PartUpdateEvents) do
            Event:Disconnect()
        end
        self.PartUpdateEvents = nil
    end

    --Hide the frames if there is no part.
    if not Part then
        for _, FrameData in pairs(self.Points) do
            FrameData.BillboardGui.Enabled = false
        end
        self.LastPart = nil
        return
    end

    --Update the frames.
    for X = 1, 3 do
        for Y = 1, 3 do
            for Z = 1, 3 do
                local Index = ((X - 1) * 9) + ((Y - 1) * 3) + Z
                local Point = self.Points[Index]
                local PointCFrame = Part.CFrame * CFrame.new(Part.Size.X * 0.5 * (X - 2), Part.Size.Y * 0.5 * (Y - 2), Part.Size.Z * 0.5 * (Z - 2))
                Point.CFrame = PointCFrame
                Point.Part.CFrame = PointCFrame
                Point.BillboardGui.Enabled = true
            end
        end
    end
    self.LastSize = Part.Size
    self.LastCFrame = Part.CFrame

    --Connect the events.
    if self.LastPart ~= Part then
        self.PartUpdateEvents = {}
        table.insert(self.PartUpdateEvents, Part:GetPropertyChangedSignal("Size"):Connect(function()
            self:SetAdornPart(Part)
        end))
        table.insert(self.PartUpdateEvents, Part:GetPropertyChangedSignal("CFrame"):Connect(function()
            self:SetAdornPart(Part)
        end))
    end
    self.LastPart = Part
end

--[[
Updates the selected frame.
--]]
function PointSelection:UpdateSelectedFrame(X: number, Y: number): nil
    --Reset the selected frame index.
    if not self.LastPart then
        self.SelectedFrameIndex = nil
        return
    end

    --Get the closest frame.
    local CurrentPointIndex = nil
	local ClosestDepth = math.huge
	for i, PointData in pairs(self.Points) do
		local ScreenPosition = Workspace.CurrentCamera:WorldToScreenPoint(PointData.CFrame.Position)
		local Depth = ScreenPosition.Z
		if Depth > 0 and ClosestDepth > Depth then
			local Radius = PointData.Frame.AbsoluteSize.X / 2
			local MouseToCenter = (((X - ScreenPosition.X) ^ 2) + ((Y - ScreenPosition.Y) ^ 2)) ^ 0.5
			if MouseToCenter <= Radius then
				CurrentPointIndex = i
				ClosestDepth = Depth
			end
		end
	end
    self.SelectedFrameIndex = CurrentPointIndex

    --Update the colors of the frames.
	for i, PointData in pairs(self.Points) do
		PointData.Frame.BackgroundColor3 = (CurrentPointIndex == i and Color3.new(0, 1, 0) or Color3.new(1, 1, 1))
	end
end

--[[
Prompts for a CFrame selection.
--]]
function PointSelection:PromptSelection(): CFrame
    --Connect updating the mouse.
    table.insert(self.Events, UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        --Update the selected frame and return if one exists.
        self:UpdateSelectedFrame(Input.Position.X, Input.Position.Y)
        if self.SelectedFrameIndex then
            return
        end

        --Get the position to raycast to.
        local MouseRay = Workspace.CurrentCamera:ScreenPointToRay(Input.Position.X, Input.Position.Y, 10000)
        local RawEndPosition = MouseRay.Origin + MouseRay.Direction
        local StartPosition = Workspace.CurrentCamera.CFrame.Position
        local EndPosition = (RawEndPosition - Workspace.CurrentCamera.CFrame.Position).Unit * 10000

        --Update the selected adorn part.
        local IgnoreList = {}
        local RaycastResult = nil
        local RaycastParameters = RaycastParams.new()
        RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParameters.FilterDescendantsInstances = IgnoreList
        RaycastParameters.IgnoreWater = true
        repeat
            --Perform the raycast.
            RaycastResult = Workspace:Raycast(StartPosition, EndPosition - StartPosition, RaycastParameters)
            if not RaycastResult then
                break
            end
            if not RaycastResult.Instance then
                break
            end
            local HitPart = RaycastResult.Instance
            if HitPart.Transparency < 1 then
                break
            end

            --Add the hit to the ignore list and allow it to retry.
            table.insert(IgnoreList, HitPart)
            RaycastParameters.FilterDescendantsInstances = IgnoreList
        until RaycastResult == nil

        --Update the selection.
        local NewAdorn = RaycastResult and RaycastResult.Instance
        self:SetAdornPart(NewAdorn)
        self:UpdateSelectedFrame(Input.Position.X, Input.Position.Y)
    end))

    --Wait for a mouse click.
    while true do
        local Input, Processed = UserInputService.InputBegan:Wait()
        if not Processed and Input.UserInputType == Enum.UserInputType.MouseButton1 then break end
    end

    --Return the CFrame.
    return self.SelectedFrameIndex and self.Points[self.SelectedFrameIndex].CFrame
end

--[[
Destroys the point selection.
--]]
function PointSelection:Destroy(): nil
    self.super:Destroy()

    self.PointSelectionContainer:Destroy()
    for _, Event in pairs(self.Events) do
        Event:Disconnect()
    end
    if self.PartUpdateEvents then
        for _, Event in pairs(self.PartUpdateEvents) do
            Event:Disconnect()
        end
    end
end



return PointSelection