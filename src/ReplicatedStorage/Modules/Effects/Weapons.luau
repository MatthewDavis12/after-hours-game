--!strict

--// Weapons
--   Responsible for rendering various weapon effects such as bullets, punches that land
--   and so on.

--// Services
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")
local Core: any = require(Modules:WaitForChild("Core"))

--// Visual Effects
local weaponEffects: Folder = ReplicatedStorage:WaitForChild("WeaponEffects")

--// WeaponEffects Object type definition
type T_WeaponEffects = {
    --// Attack: Basic visuals for fighting moves
    Attack: (self: T_WeaponEffects, ...any) -> (),
    --// Replicate is a receiver function to help bridge the proxy (Effects) and the 
    --   effect methods
    Replicate: (self: T_WeaponEffects, effectMethod: string, ...any) -> ()
}

--// WeaponEffects Object
local WeaponEffects: T_WeaponEffects = {
    --// Regular punch attacks
    Attack = function(self: T_WeaponEffects, ...: any)
        local _, targetChar: Model = ... 
        local attackEffect = weaponEffects:FindFirstChild("Attack") :: Instance
        local newEffect: Attachment = Core.Clone(attackEffect:FindFirstChild("Effect") :: Instance) {
            Parent = targetChar:FindFirstChild("HumanoidRootPart") :: Part 
        }

        Debris:AddItem(newEffect, 5)
        for _, v in pairs(newEffect:GetChildren()) do
            if not v:IsA("ParticleEmitter") then
                return
            end
            v:Emit()
        end
    end,

    --// Replicate event receiver
    Replicate = function(self: T_WeaponEffects, effectMethod: string, ...: any)
        assert(self[effectMethod], `Invalid effect type {effectMethod}`)
        self[effectMethod](self, ...)
    end
}; return WeaponEffects