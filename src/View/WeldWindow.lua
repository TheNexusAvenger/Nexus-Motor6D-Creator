--[[
TheNexusAvenger

Window for creating welds.
--]]
--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local NexusMotor6DCreatorPlugin = script.Parent.Parent
local NexusPluginFramework = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"))
local PluginInstance = require(NexusMotor6DCreatorPlugin:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))

local WeldWindow = PluginInstance:Extend()
WeldWindow:SetClassName("WeldWindow")

export type WeldWindow = {
    new: (Plugin: Plugin) -> (WeldWindow),
    Extend: (self: WeldWindow) -> (WeldWindow),
} & PluginInstance.PluginInstance & DockWidgetPluginGui



--[[
Creates the Weld window.
--]]
function WeldWindow:__new(Plugin: Plugin): ()
    PluginInstance.__new(self, Plugin:CreateDockWidgetPluginGui("Weld Creator", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 50, 160, 50)))
    self.Title = "Weld Creator"
    self.Name = "Weld Creator"

    --Add the window components.
    local Background = NexusPluginFramework.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Parent = self

    local SelectionText = NexusPluginFramework.new("TextLabel")
    SelectionText.Size = UDim2.new(1, 0, 0, 16)
    SelectionText.Position = UDim2.new(0, 0, 0, 2)
    SelectionText.TextXAlignment = Enum.TextXAlignment.Center
    SelectionText.Parent = Background

    local WeldButton = NexusPluginFramework.new("TextButton")
    WeldButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
    WeldButton.BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder
    WeldButton.Size = UDim2.new(0, 80, 0, 22)
    WeldButton.AnchorPoint = Vector2.new(0.5, 0)
    WeldButton.Position = UDim2.new(0.5, 0, 0, 24)
    WeldButton.Text = "Weld"
    WeldButton.TextColor3 = Enum.StudioStyleGuideColor.DialogMainButtonText
    WeldButton.Parent = self

    --Connect the selection changing.
    self:DisableChangeReplication("Selection")
    self:GetPropertyChangedSignal("Selection"):Connect(function()
        if #self.Selection == 0 then
            SelectionText.Text = "No parts selected."
            WeldButton.Disabled = true
        elseif #self.Selection == 1 then
            SelectionText.Text = "No parts to weld."
            WeldButton.Disabled = true
        else
            SelectionText.Text = "Weld "..tostring(#self.Selection).." parts."
            WeldButton.Disabled = false
        end
    end)
    Selection.SelectionChanged:Connect(function()
        local NewSelection = {}
        for _, Part in Selection:Get() do
            pcall(function()
                if Part:IsA("BasePart") then
                    table.insert(NewSelection, Part)
                end
            end)
        end
        self.Selection = NewSelection
    end)
    self.Selection = {}

    --Connect the button.
    local DB = true
    WeldButton.MouseButton1Down:Connect(function()
        if DB then
            DB = false
            if #self.Selection > 1 then
                ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorBeforeCreateWelds")
                local StartPart = self.Selection[1]:GetWrappedInstance()
                for _, WeldPart in self.Selection do
                    WeldPart = WeldPart:GetWrappedInstance()
                    if WeldPart ~= StartPart then
                        local Weld = Instance.new("Weld")
                        Weld.C0 = StartPart.CFrame:Inverse() * WeldPart.CFrame
                        Weld.Part0  = StartPart
                        Weld.Part1 = WeldPart
                        Weld.Parent = StartPart
                    end
                end
                ChangeHistoryService:SetWaypoint("NexusMotor6DCreatorAfterCreateWelds")
            end
            DB = true
        end
    end)
end



return (WeldWindow :: any) :: WeldWindow