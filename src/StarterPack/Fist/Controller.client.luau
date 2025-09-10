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