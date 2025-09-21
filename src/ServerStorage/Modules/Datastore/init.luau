--!strict

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DatastoreService = game:GetService("DataStoreService")

--// UserDataStore
local UserData = require("./Datastore/User")
local UserDataStore = DatastoreService:GetDataStore(UserData:Name())

--// Group Manager
local Groups = require("../../ReplicatedStorage/Modules/Group")

--// Command Manager
local Command = require("../../ServerScriptService/Commands/Command")

--// Modules
local Collisions = require("../Modules/Collisions")
local Sign = require("../../ReplicatedStorage/Modules/Sign")
local Nametag = require("../../ReplicatedStorage/Modules/Nametag")
local Products = require("../../ReplicatedStorage/Modules/Products")

--// Data
--// Data is considered one of two types "Private" and "Public".
--//
--// - Private: Data that can't been accessed by the client. Private data is only used
--//   for server processing and sensitive data (ie. passwords). This data type is limited to the
--//   player data table. These keys will be indicated with a LOWER CASE character at the beginning of the 
--//   key string
--//
--// - Public: Data that is accessible "Publicly" by the client. These values are represented
--//   by object values which are used to also update the public data. These keys will be indicated by the
--//   UPPER CASE character at the beginning of the key string.

--// Public type defs
export type DatastoreName = string

--// Private type defs
type UserDataList = {[string]: UserData.UserData}

--// Datastore Object
local Datastore: any = {
    Players = {} :: UserDataList,
    LeaderstatValues = {
        {"Level", "IntValue"},
        {"Kills", "IntValue"},
        {"Cash", "IntValue"}
    } :: {{string}},
    Connections = {} :: {[string]: {[string]: RBXScriptConnection}}
}

--// Helper function to merge old data to the new schema
local function mergeDataRecursive(oldData: UserData.UserData, dataSchema: UserData.UserData)
    for dataKey: string, dataValue: any in pairs(dataSchema) do
        if not oldData[dataKey] or typeof(oldData[dataKey]) ~= typeof(dataValue) then
            oldData[dataKey] = dataValue
            continue
        end

        if typeof(dataValue) == "table" and not dataKey:match("Color") then
            mergeDataRecursive(oldData[dataKey], dataValue)
        end
    end
end

--// Helper function that allows us to recursively create
--// the objects needed for the public values
local function generateRecursiveDataObjects(parent: Configuration?, userData: any, dataContName: string, plr: Player): Configuration
    local dataContainer: Configuration = Instance.new("Configuration")
    dataContainer.Name = dataContName

    for dataKey: string, dataValue in userData do
        if not dataKey:match("^%u.+") then
            continue
        end

        if typeof(dataValue) == "table" and not dataKey:match("Color") then
            generateRecursiveDataObjects(dataContainer, dataValue, dataKey, plr)
            continue
        end

        dataContainer:SetAttribute(dataKey, dataKey:match("Color") and Color3.fromRGB(unpack(dataValue)) or dataValue)
    end

    --// Connection for updating values in the table.
    --// This allows us to update the players data in the table based on changes to the attributes
    --// and releases the stress of managing data key by key
    Datastore.Connections[plr.Name][dataContName] = dataContainer.AttributeChanged:Connect(function(attribute: string)
        if attribute == "Level" then
            Nametag:UpdateTag(plr)
        elseif attribute:match("Color") then
            local color: Color3 = dataContainer:GetAttribute(attribute) :: Color3
            userData[attribute] = {color.R * 255, color.G * 255, color.B * 255}
            return
        end

        userData[attribute] = dataContainer:GetAttribute(attribute)
    end)

    dataContainer.Parent = parent and parent or dataContainer.Parent
    return dataContainer
end

--// Create data container
function Datastore.createDataContainer(plr: Player, userData: UserData.UserData): Configuration
    Datastore.Connections[plr.Name] = {}
    local dataContainer: Configuration = generateRecursiveDataObjects(nil, userData, "Data", plr)
    dataContainer.Parent = plr
    return dataContainer
end

--// Save user data
function Datastore:Save(plr: Player)
    if RunService:IsStudio() then
        return
    end

    local plrData: UserData.UserData = self.Players[plr.Name]
    UserDataStore:UpdateAsync(tostring(plr.UserId), function(pastData: any)
        print(`Saving data`)
        return plrData
    end)
end

--// Load user data
function Datastore:Load(plr: Player): Configuration?
    local success, userData = pcall(function()
        return UserDataStore:GetAsync(tostring(plr.UserId)) 
    end)

    if not success then
        print("Failed to perform GetAsync: "..userData)
        return
    end

    if not userData then
        print(`Generating new data set`)
        userData = UserData:New()
    end

    print(`Verifying schema verison...`)
    --// Check for schema version
    if not userData.version or userData.version ~= UserData.SchemaVersion then
        print(`Schema version mismatch, migrating user data to new schema`)
        mergeDataRecursive(userData, UserData:New())
        userData.version = UserData.SchemaVersion
    else
        print(`Schema version up-to-date. Loading player data.`)
    end

    --// Build leaderstats folder
    local ls: Folder = Instance.new("Folder") :: Folder
    ls.Name = "leaderstats"
    ls.Parent = plr

    for _, statData: {string} in pairs(self.LeaderstatValues) do
        local statName: string, statValueType: string = unpack(statData)
        local newValue: IntValue = Instance.new(statValueType) :: IntValue
        newValue.Value = userData[statName]
        newValue.Name = statName
        newValue.Parent = ls
    end

    self.Players[plr.Name] = userData
    return self.createDataContainer(plr, userData)
end

--// Initialize the data store
function Datastore:Initialize()
    Players.PlayerAdded:Connect(function(plr: Player)  
        local plrData: Configuration = self:Load(plr)
        if not plrData then
            print(plrData)
            return
        end

        plr:SetAttribute("Role", Groups:GetGroupRole(plr))             --// Assigns the players role in the group for other things
        plr:SetAttribute("Permission", Groups:GetPermissionLevel(plr)) --// Assign permission levels to player

        --// Update gamepasses
        local passData: Configuration? = plrData:FindFirstChild("Gamepasses") :: Configuration
        if not passData then
            return
        end

        for passName in pairs(Products.Gamepasses) do
            if not Products:ValidateGamepass(plr, passName) then
                continue
            end
            passData:SetAttribute(passName, true)
        end

        --// Attempt to process player messages as commands
        plr.Chatted:Connect(function(msg: string)
            Command:Processor(plr, msg)
        end)

        --// Update Char helper function
        local function UpdateChar(char: Model)
            local hum: Humanoid = char:WaitForChild("Humanoid") :: Humanoid
            local root = char:WaitForChild("HumanoidRootPart")
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
            Nametag:NewTag(plr)
            Sign:UpdateSign(plr)

            --// Update Collisions
            local plrSettings: Configuration = plrData:FindFirstChild("Settings") :: Configuration
            if not plrSettings then
                return
            end

            local viewProfile: BillboardGui = char:WaitForChild("ViewProfile") :: BillboardGui
            viewProfile.Adornee = root
            Collisions:SetCollisionGroup(char, plrSettings:GetAttribute("PlayerCollisions"))
        end

        --// Character Updates 
        local char: Model = plr.Character or plr.CharacterAdded:Wait()
        UpdateChar(char)

        plr.CharacterAdded:Connect(UpdateChar)
    end)

    Players.PlayerRemoving:Connect(function(plr: Player)
        self:Save(plr)
    end)

    --// TODO
    --// BindToClose here for server shutdowns
end

return Datastore