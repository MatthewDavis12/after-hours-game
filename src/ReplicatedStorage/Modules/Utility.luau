--!strict

--// Utility
--// Contains helper functions for various QoL of tasks such as formatting long numbers,
--// math functions, and time based functions

--// Players
local Players = game:GetService("Players")

--// Camera
local camera = workspace.CurrentCamera

--// Constants
local WORLD_POS_RAY_FILTER = RaycastParams.new()
WORLD_POS_RAY_FILTER.FilterType = Enum.RaycastFilterType.Exclude

--// Utility object
local Utility: any = {}

--// Format Numbers
function Utility:FormatNumberWithCommas(number: number): string?
    local strNum: string = tostring(number)
    return strNum:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^(-?),", "%1")
end

--// Get 3D mouse pos
function Utility:GetWorldModelFromScreen(mousePos: Vector2, filter: {any}): (Vector3?, Model?)
    WORLD_POS_RAY_FILTER.FilterDescendantsInstances = filter
    local worldRay: Ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y, 1)
    local partsInRay = workspace:Raycast(camera.CFrame.Position, worldRay.Direction * 40, WORLD_POS_RAY_FILTER)
    if not partsInRay then
        return
    end

    local model = partsInRay.Instance:FindFirstAncestorOfClass("Model")
    if not (model and Players:GetPlayerFromCharacter(model)) then
        return
    end

    return partsInRay.Position, model
end

return Utility