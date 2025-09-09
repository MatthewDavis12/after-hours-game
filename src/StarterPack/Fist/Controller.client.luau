--!strict

--// Controls the behavior of the fists.

--// Fist Module
local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local NewFist = require(Modules.Tools:WaitForChild("Fist"))
local FistModule = NewFist()

--// Fist Tool
local fist: Tool = script.Parent
fist.Activated:Connect(function()
    FistModule:Attack()
end)