--!strict

--// Collisions defines the collision groups and the methods that allow the
--// server to modify collision groups for various objects and models.

local Physics = game:GetService("PhysicsService")

--// Register collision groups
Physics:RegisterCollisionGroup("CollideOn")
Physics:RegisterCollisionGroup("CollideOff")

--// Setup collision rules
Physics:CollisionGroupSetCollidable("CollideOn", "CollideOn", true)
Physics:CollisionGroupSetCollidable("CollideOff", "CollideOn", false)
Physics:CollisionGroupSetCollidable("CollideOff", "CollideOff", false)

--// Collision Module
local Collision: any = {}

--// Set character collision group
function Collision:SetCollisionGroup(char: Model, collidable: boolean)
    for _, o in pairs(char:GetDescendants()) do
        if not o:IsA("BasePart") then
            continue
        end
        o.CollisionGroup = collidable and "CollideOn" or "CollideOff"
    end
end

return Collision