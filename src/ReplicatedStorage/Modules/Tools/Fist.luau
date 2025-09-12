--!strict

--// Fist
--
--   Client code for the fist tool. The fist themsevles will be fully coded here
--   and required via the client script in the tool. If more documentation is needed
--   it will be here in the header of this module.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Remotes
local AttackRegister: RemoteEvent = ReplicatedStorage:WaitForChild("Remotes").AttackRegister

--// Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Effects = require(Modules:WaitForChild("Effects"))
local Character = require(Modules:WaitForChild("Character"))
local Animations = require(Modules:WaitForChild("Animations"))

--// Loading animations
local animations = Character:GetAnimations() :: Animations.AnimationsObject

--// AttackPartList type def
--   Top level string key is the rig type
--   string key is the attack
--   string value is the body part
type T_AttackPartList = {[string]: {string}}

--// Type definition for the Fist
type T_Fist = {
    --// Determines the speed of the fist attacks.
    animeSpeed:        number,
    --// Swing sound
    punchSwing:        Sound,
    --// Hit sound
    punchAttack:       Sound,
    --// Indicates the total number of attack animations
    animeCount:        number,
    --// Used for attack debouncing.
    isPunching:        boolean,
    --// Helps map body parts to attack moves.
    attackParts:       T_AttackPartList,
    --// Used to track the current combo animation index.
    currentComboIndex: number,
    --// Initiates attacking.
    Attack:            (self: T_Fist)->(),
    --// OnEquipped initiates
    OnEquip:           (self: T_Fist)->(),
    Unequip:           (self: T_Fist)->()
}

--// Helper to help us detect players we hit. 
local function getPlayerInBoundary(char: Model, bodyPart: Part): (Part?, Model?)
    local partsInBound = workspace:GetPartBoundsInBox(bodyPart.CFrame, bodyPart.Size * 2)
    if #partsInBound == 0 then
        return
    end

    for _, obj: Part in pairs(partsInBound) do
        local objMod: Model? = obj:FindFirstAncestorOfClass("Model") :: Model
        if not objMod or not objMod:FindFirstChild("Humanoid") or objMod == char then
            continue
        end
        return obj, objMod
    end

    return
end


--// Fist Object
return function(fist: Tool): T_Fist
    local controller: LocalScript = fist:FindFirstChild("Controller") :: LocalScript

    return {
        animeSpeed = 1,
        animeCount = animations:GetCount("^FistAttack%d"), 
        punchSwing = controller:WaitForChild("PunchSwing") :: Sound,
        punchAttack = controller:WaitForChild("PunchHit") :: Sound,
        isPunching = false,
        currentComboIndex = 1,
        attackParts = {
            R6 = {
                "Right Arm",
                "Left Arm",
                "Right Leg",
                "Left Leg",
                "Head"
            },
            R15 = {
                "RightLowerArm",
                "LeftLowerArm",
                "RightLowerLeg",
                "LeftLowerLeg",
                "Head"
            }
        },

        --// On equip function
        OnEquip = function(self)
            local charMode = require(Modules.Character)
            local animations = charMode:GetAnimations()
            if not animations then
                return
            end
            animations:Play("FistIdle")
        end,

        --// Unequip function
        Unequip = function(self)
            local charMode = require(Modules.Character)
            local animations = charMode:GetAnimations()
            if not animations then
                return
            end

            animations:Stop()
            self.isPunching = false
        end,

        --// Initialize attacking.
        Attack = function(self)
            if self.isPunching then
                return
            end

            local canDamage = true
            local charMod = require(Modules.Character)
            local char = charMod:GetCharacter()
            if not char or charMod:IsDead() then
                return
            end

            self.isPunching = true
            local animations = charMod:GetAnimations() :: Animations.AnimationsObject
            local trackName: string = "FistAttack"..tostring(self.currentComboIndex)
            local track: AnimationTrack? = animations:Play(trackName, 0.1, 1, self.animeSpeed)
            if not track then
                return
            end

            --// Perform hit detection and wait for attack move cooldowns.
            local animeEnd: number = track.Length / self.animeSpeed
            self.punchSwing:Play()

            while animeEnd > track.TimePosition do
                task.wait()
                if not canDamage then
                    continue
                end                

                local rigAttackList = self.attackParts[charMod:GetRigType()]
                local bodyPart: Part? = char:FindFirstChild(rigAttackList[self.currentComboIndex]) :: Part
                if not bodyPart then
                    continue
                end

                local plrBodyPart: Part?, plrHit: Model? = getPlayerInBoundary(char, bodyPart)
                if not (plrBodyPart and plrHit) then
                    continue
                end

                canDamage = false
                if not plrHit:FindFirstChild("Fist") then
                    continue
                end
                
                --// Effects: Replicates locally.
                --   AttackRegsiter: Regsiters damage and replicates effects to the other players
                task.spawn(function()
                    local newPunch: Sound = self.punchAttack:Clone()
                    newPunch.Parent = plrHit
                    newPunch:Play()
                    newPunch.Ended:Wait()
                    newPunch:Destroy()
                end)
                
                Effects:Replicate("Weapons", "Attack", plrBodyPart, plrHit)
                AttackRegister:FireServer("Weapons", "Attack", plrBodyPart, plrHit, self.currentComboIndex)
            end

            self.currentComboIndex =  self.currentComboIndex + 1 > self.animeCount and 1 or self.currentComboIndex + 1
            self.isPunching = false
        end
    }
end
