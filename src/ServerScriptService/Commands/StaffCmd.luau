--!strict

--// User Commands
--// This script contains all the user level commands in the game.

--// Services
local Players = game:GetService("Players")

--// Command module
local Command = require("../Commands/Command")

--// To
--// Teleports the staff member to the user in the server.
Command:Register({
	Token = "to",
	Short = "to",
	PermLevel = "Staff",
	Description = "Teleports the staff member to the user in the server.",
	Run = function(plr, args)
		local target = args
		local char = plr.Character
		
		for _, p in Players:GetPlayers() do
			if p.Name:lower() ~= target then
				continue
			end
			
			if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then
				return
			end
			
			local targetChar = p.Character
			local targetHRP: Part = targetChar:FindFirstChild("HumanoidRootPart") :: Part
			
			local frontOffset = targetHRP.CFrame.LookVector * 3 -- 3 studs in front
			char:MoveTo(targetHRP.Position + frontOffset)
		end
	end,
})

return {}