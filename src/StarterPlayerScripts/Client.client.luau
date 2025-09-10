--!strict

--// Loads all modules for the client to use and setup dependencies before 
--   module code for tools and other things are exectued.

--// Local player 
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

--// Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

--// Load client character module
local CharacterModule: any = require(Modules.Character)

--// Load Effects
local Effects: any = require(Modules.Effects)

--// Client connections
plr.CharacterAdded:Connect(function(char: Model)
    CharacterModule:LoadCharacter()
end)



