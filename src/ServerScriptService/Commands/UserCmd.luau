--!strict

--// User Commands
--// This script contains all the user level commands in the game.

--// Services
local Players = game:GetService("Players")

--// Command module
local Command = require("../Commands/Command")

--// Headless
--// Makes the players head transparent as well as the
--// face decal
Command:Register({
	Token = "headless",
	Short = "hl",
	Help = "/headless, /hl",
	PermLevel = "User",
	Description = "Makes the players head invisible.",
	Run = function(plr, args)
		if not (plr.Character and plr.Character:FindFirstChild("Head")) then
			return
		end
	
		local enabled = args == "no" and 0 or 1
		plr.Character.Head.Transparency = enabled
		
		local face: Decal? = plr.Character.Head:FindFirstChild("face") :: Decal
		if face then
			face.Transparency = enabled
		end
	end,
})

--// Refresh
--// Refreshes the users character
Command:Register({
	Token = "refresh",
	Short = "re",
	PermLevel = "User",
	Description = "Refreshes the users character.",
	Run = function(plr, args)
		if not (plr.Character and plr.Character:FindFirstChild("Humanoid")) then
			return
		end
		
		local s, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(plr.UserId)
		end)
		
		if s then
			plr.Character.Humanoid:ApplyDescription(desc)
		end
	end,
})

--// Korblox
--// Enables the korblox package on the user
Command:Register({
	Token = "korblox",
	Short = "kb",
	PermLevel = "User",
	Description = "Enables the Korblox package on the user's character.",
	Run = function(plr, args)
		if not (plr.Character and plr.Character:FindFirstChild("Humanoid")) then
			return
		end
		
		local char = plr.Character
		local desc = char.Humanoid:GetAppliedDescription()
		desc.RightLeg = 139607718
		char.Humanoid:ApplyDescription(desc)
	end,
})

--// Sit
--// Sits the user
Command:Register({
	Token = "sit",
	Short = "sit",
	PermLevel = "User",
	Description = "Sits the user",
	Run = function(plr, args)
		local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
		if hum then
			hum.Sit = true
		end
	end,
})

return {}