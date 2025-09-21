--!strict

--// Server Events
--   Listens for misc events such as sign updates and things like that.
--   Primarily just to keep all event connections in one place.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Sign = require("../../ReplicatedStorage/Modules/Sign")
local Nametag = require("../../ReplicatedStorage/Modules/Nametag")

--// Remotes
local Remotes = ReplicatedStorage.Remotes
local SignEvent: RemoteEvent = Remotes.SignEvent :: RemoteEvent
local NametagEvent: RemoteEvent = Remotes.NametagEvent :: RemoteEvent
local ProfileEvent: RemoteEvent = Remotes.ProfileEvent :: RemoteEvent

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

        --// NametagEvent
        --   Handles all nametag updates.
        NametagEvent.OnServerEvent:Connect(function(plr: Player, property: string, value: any)
            local data: Configuration = plr:FindFirstChild("Data") :: Configuration
            local tagData:  Configuration = data:FindFirstChild("NameTag") :: Configuration

            if tagData:GetAttribute(property) == nil then
                warn(`Failed to set tag data: Property {property}`)
                return
            end

            tagData:SetAttribute(property, value)
            Nametag:UpdateTag(plr)
        end)

        --// ProfileEvent
        --   Handles all change requests to the profile
        ProfileEvent.OnServerEvent:Connect(function(plr: Player, property: string, value: any)
            local data: Configuration = plr:FindFirstChild("Data") :: Configuration
            if data:GetAttribute(property) == nil then
                warn(`Failed to set tag data: Property {property}`)
                return
            end

            data:SetAttribute(property, value)
        end)
    end
}; return ServerEvents