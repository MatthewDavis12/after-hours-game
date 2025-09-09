--!strict

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DatastoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// UserDataStore
local UserData = require("./Datastore/User")
local UserDataStore = DatastoreService:GetDataStore(UserData:Name())

--// Group Manager
local Groups = require("../../ReplicatedStorage/Modules/Group")

--// Command Manager
local Command = require("../../ServerScriptService/Commands/Command")

--// Modules
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
    Connections = {} :: {[string]: {[string]: RBXScriptConnection}}
}

--// Helper function that allows us to recursively create
--// the objects needed for the public values
local function generateRecursiveDataObjects(parent: Configuration?, userData: any, dataContName: string, plr: Player): Configuration
    local dataContainer: Configuration = Instance.new("Configuration")
    dataContainer.Name = dataContName

    for dataKey: string, dataValue in userData do
        if not dataKey:match("^%u.+") then
            continue
        end

        if typeof(dataValue) == "table" then
            generateRecursiveDataObjects(dataContainer, dataValue, dataKey, plr)
            continue
        end

        dataContainer:SetAttribute(dataKey, dataValue)
    end

    --// Connection for updating values in the table.
    --// This allows us to update the players data in the table based on changes to the attributes
    --// and releases the stress of managing data key by key
    Datastore.Connections[plr.Name][dataContName] = dataContainer.AttributeChanged:Connect(function(attribute: string)
        userData[attribute] = dataContainer:GetAttribute(attribute)

        if attribute == "Level" then
            Nametag:UpdateTag(plr)
        end
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
        userData = UserData:New()
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

        --// Character Updates 
        local char: Model = plr.Character or plr.CharacterAdded:Wait()
        local hum: Humanoid = char:WaitForChild("Humanoid") :: Humanoid
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        Nametag:NewTag(plr)

        plr.CharacterAdded:Connect(function(char: Model)
            local hum: Humanoid = char:WaitForChild("Humanoid") :: Humanoid
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            Nametag:NewTag(plr)
        end)
    end)

    Players.PlayerRemoving:Connect(function(plr: Player)
        self:Save(plr)
    end)

    --// TODO
    --// BindToClose here for server shutdowns
end

return Datastore