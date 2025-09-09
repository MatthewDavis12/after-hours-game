--!strict

--// Character
--  
--   Contains the client object to control and access data about the character.
--   This is primarily to keep our lifecycle connections like CharacterAdded and CharacterRemoved in a single place.
--// Type Defintions
--   
--   The type definitions are going to follow a blueprint that says
--   fields that start with a lower case letter

--// Local player
local Players = game:GetService("Players")
local plr: Player = Players.LocalPlayer
local char: Model = plr.Character or plr.CharacterAdded:Wait()

--// Animations
local _Animations: any = require("../Modules/Animations")

--// Character Object type definition
type T_Character = {
    --// The character model for the client
    character:     Model?,
    --// AnimationObject for character animations
    animations:    _Animations.AnimationsObject?,
    --// LoadCharacter initilizes the character object
    LoadCharacter: (self: T_Character) -> (),
    --// Method to pull the value of the character field
    GetCharacter:  (self: T_Character) -> Model?,
    --// Method to fetch the animations for the character
    GetAnimations: (self: T_Character) -> _Animations.AnimationsObject?,
    --// Helper function to get the rig type of the character
    GetRigType:    (self: T_Character) -> string,
    --// Helper function to detect when the character is dead
    IsDead:        (self: T_Character) -> boolean
}

--// Character object
local Character: T_Character = {
    character = char,
    animations = _Animations.new(char),

    --// LoadCharacter initlizes the character object
    LoadCharacter = function(self)
        local char: Model = plr.Character or plr.CharacterAdded:Wait()
        self.character = char
        self.animations = _Animations.new(char)
    end,

    --// GetCharacter fetches the character private field
    GetCharacter = function(self): Model?
        return self.character
    end,

    --// GetAnimations fetches the animations for the character
    GetAnimations = function(self): _Animations.AnimationsObject?
        return self.animations
    end,

    --// Helper function to get the rig type of the character
    GetRigType = function(self): string
        if not self.character then
            return "R6"
        end

        local hum: Humanoid = self.character:FindFirstChild("Humanoid") :: Humanoid
        return hum.RigType.Name
    end,

    --// Dead man function
    IsDead = function(self): boolean
        if not self.character then
            return true
        end

        local hum: Humanoid = self.character:FindFirstChild("Humanoid") :: Humanoid
        return hum.Health < 1
    end
}; return Character
