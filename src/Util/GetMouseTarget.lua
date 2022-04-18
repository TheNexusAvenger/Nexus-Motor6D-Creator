--[[
TheNexusAvenger

Returns the part the mouse is hovering over.
--]]

local Workspace = game:GetService("Workspace")

return function(X: number, Y: number): BasePart?
    --Get the position to raycast to.
    local MouseRay = Workspace.CurrentCamera:ScreenPointToRay(X, Y, 10000)
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

    --Return the result.
    return RaycastResult and RaycastResult.Instance.Locked ~= true and RaycastResult.Instance
end