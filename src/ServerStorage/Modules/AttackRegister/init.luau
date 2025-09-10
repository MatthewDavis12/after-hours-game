--!strict

--// AttackRegister
--   Listens for attack registration requests, calculates and applies damage and
--   sends client replication requests.

--// AttackRegister type definition
type T_AttackRegister = {
    --// Listen for attack register request
    Listen: (self: T_AttackRegister) -> (),
    --// Calculates damage for various types of attacks
    caluculateDamage: (self: T_AttackRegister, plr: Player, attackType: string, attackMethod: string, ...any) -> ()
}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Remotes
local ReplicateEvent: RemoteEvent = ReplicatedStorage.Remotes.Replicate
local AttackRegisterEvent: RemoteEvent = ReplicatedStorage.Remotes.AttackRegister

--// Attack Regsiter Object
local AttackRegister: T_AttackRegister = {
    --// Listen for attack registeration requests.
    Listen = function(self: T_AttackRegister)
        AttackRegisterEvent.OnServerEvent:Connect(function(plr: Player, attackType: string, attackMethod: string, ...: any)
            self:caluculateDamage(plr, attackType, attackMethod, ...)            
        end)
    end,

    --// Calculate damage for attacks and send client replication requests
    caluculateDamage = function(self: T_AttackRegister, plr: Player, attackType: string, attackMethod: string, ...: any)
        local plrChar: Model? = plr.Character
        local replicateEffect: boolean = false
        if not plrChar then
            return
        end

        local plrRP: Part = plrChar:FindFirstChild("HumanoidRootPart") :: Part

        if attackMethod == "Attack" then
            local _, targetChar: Model = ...
            if not targetChar:FindFirstChild("Fist") then 
                return
            end

            local targetRP: Part = targetChar:FindFirstChild("HumanoidRootPart") :: Part
            local targetHumanoid: Humanoid = targetChar:FindFirstChild("Humanoid") :: Humanoid

            if (plrRP.Position - targetRP.Position).Magnitude <= 10 then
                if targetHumanoid.Health - 5 <= 0 then
                    --// Give player a kill here
                end

                targetHumanoid.Health -= 5
                replicateEffect = true
            end
        end

        if not replicateEffect then
            return
        end

        ReplicateEvent:FireAllClients(plr, attackType, attackMethod, ...)
    end
}; return AttackRegister