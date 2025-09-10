--!strict

--// Effects
--   A proxy for performing various types of visual effects on the client.
--   Handles client request to render effects based on arguments.
--   Effects are split up into their own categories defined by the modules inside this one.

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Constants
local ReplicateEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Remotes").Replicate

--// Effects Object type definition
type Effects = {
    --// Contains all the modules needed to perform visual
    --   effects.
    _modules:  {[string]: any},
    --// Replicate is used to query the correct module and call on the
    --   "Replicate" implementation.
    Replicate: (self: Effects, effectType: string, ...any) -> (),
    --// Helper function that's really useless but we're going to use
    --   it to store effects
    NewEffect: (self: Effects, effectModule: ModuleScript) -> ()
}


--// Effects Object
local Effects: Effects = {
    _modules = {},

    --// Forward replication request to the proper submodule
    Replicate = function(self: Effects, effectType: string, ...: any)
        for moduleName: string, moduleData: any in pairs(self._modules) do
            if moduleName ~= effectType then
                continue
            end
            moduleData:Replicate(...)
            return
        end
        warn(`Failed to fetch client effect module {effectType}`)
    end,

    --// Helper function to store new effects
    NewEffect = function(self: Effects, effectModule: ModuleScript)
        local effectData: any = require(effectModule) :: any
        self._modules[effectModule.Name] = effectData
    end
}

--// Load all effects module
for _, effectModule: ModuleScript in pairs(script:GetChildren()) do
    Effects:NewEffect(effectModule)
end

--// Receive all replication requests
ReplicateEvent.OnClientEvent:Connect(function(plr: Player, effectType: string, ...: any)
    if plr == Players.LocalPlayer then
        return
    end

    Effects:Replicate(effectType, ...)
end)

return Effects
