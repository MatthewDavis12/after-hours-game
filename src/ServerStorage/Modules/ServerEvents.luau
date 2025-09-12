--!strict

--// Server Events
--   Listens for misc events such as sign updates and things like that.
--   Primarily just to keep all event connections in one place.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Sign = require("../../ReplicatedStorage/Modules/Sign")

--// Remotes
local Remotes = ReplicatedStorage.Remotes
local SignEvent: RemoteEvent = Remotes.SignEvent :: RemoteEvent

--// ServerEvent Object type defintion
type T_ServerEvents = {
    Listen: (self: T_ServerEvents) -> ()
}

--// ServerEvent Object
local ServerEvents: T_ServerEvents = {
    Listen = function(self)
        --// SignEvent
        --   Handles all updates to players signs.
        SignEvent.OnServerEvent:Connect(function(plr: Player, property: string, value: any)
            local data: Configuration = plr:FindFirstChild("Data") :: Configuration
            local signData: Configuration = data:FindFirstChild("Sign") :: Configuration

            if not signData:GetAttribute(property) then
                warn(`Failed to set sign data: Property {property}`)
                return
            end

            signData:SetAttribute(property, value)
            Sign:UpdateSign(plr)
        end)
    end
}; return ServerEvents