--!strict

--// Controls the behavior of the fists.

--// Fist Tool
local fist: Tool = script.Parent

--// Fist Module
local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local NewFist = require(Modules.Tools:WaitForChild("Fist"))
local FistModule = NewFist(fist)

fist.Activated:Connect(function()
    FistModule:Attack()
end)

fist.Equipped:Connect(function()
    FistModule:OnEquip()
end)

fist.Unequipped:Connect(function() 
    FistModule:Unequip()
end)
