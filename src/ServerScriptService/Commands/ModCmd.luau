--!nonstrict

--// User Commands
--// This script contains all the user level commands in the game.

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Command module
local Command = require("../Commands/Command")

--// Dependencies
local FlyEvent = ReplicatedStorage.Remotes.FlyEvent

--// Fly
--// Enables flying for the admin.
Command:Register({
	Token = "fly",
	Short = "fly",
	PermLevel = "Mod",
	Description = "Enables flying for the admin.",
	Run = function(plr, args)
		FlyEvent:FireClient(plr, "start")
	end,
})

--// Unfly
--// Disables flying for the admin.
Command:Register({
	Token = "unfly",
	Short = "uf",
	PermLevel = "Mod",
	Description = "Disables flying for the admin.",
	Run = function(plr, args)
		FlyEvent:FireClient(plr, "stop")
	end,
})

--// Jump Power
--// Sets the admins jump power
Command:Register({
	Token = "jumppower",
	Short = "jp",
	PermLevel = "Mod",
	Description = "Sets the admins jump power.",
	Run = function(plr, args)
		local power = tonumber(args)
		if not power then
			return
		end
		
		local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
		if hum then
			hum.JumpHeight = power
		end
	end,
})

--// Walk Speed
--// Sets the admins walk speed
Command:Register({
	Token = "speed",
	Short = "speed",
	PermLevel = "Mod",
	Description = "Sets the admins walk speed",
	Run = function(plr, args)
		local power = tonumber(args)
		if not power then
			return
		end

		local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
		if hum then
			hum.WalkSpeed = power
		end
	end,
})

--// Char
--// Sets the users character appearance to the specified roblox user.
Command:Register({
	Token = "char",
	Short = "char",
	PermLevel = "Mod",
	Description = "Sets the users character appearance to the specified roblox user.",
	Run = function(plr, args)
		local targetName = args
		
		local success, targetUserId = pcall(function()
			return Players:GetUserIdFromNameAsync(targetName)
		end)
		
		if success then
			local ok, desc = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(targetUserId)
			end)
			if ok and plr.Character and plr.Character:FindFirstChild("Humanoid") then
				plr.Character.Humanoid:ApplyDescription(desc)
			end
		end
	end,
})

return {}