--!strict

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DatastoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// UserDataStore
local UserData = require("./Datastore/User")
local UserDataStore = DatastoreService:GetDataStore(UserData:Name())

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
    Players = {} :: UserDataList
}

--// Helper function that allows us to recursively create
--// the objects needed for the public values
local function generateRecursiveDataObjects(parent: Configuration?, userData: any, dataContName: string): Configuration
    local dataContainer: Configuration = Instance.new("Configuration")
    dataContainer.Name = dataContName

    for dataKey: string, dataValue in userData do
        if not dataKey:match("^%u.+") then
            continue
        end

        if typeof(dataValue) == "table" then
            generateRecursiveDataObjects(dataContainer, dataValue, dataKey)
            continue
        end

        dataContainer:SetAttribute(dataKey, dataValue)
    end

    dataContainer.Parent = parent and parent or dataContainer.Parent
    return dataContainer
end

--// Create data container
function Datastore.createDataContainer(plr: Player, userData: UserData.UserData)
    local dataContainer: Configuration = generateRecursiveDataObjects(nil, userData, "Data")
    dataContainer.Parent = plr
end

--// Save user data
function Datastore:Save(datastoreName: DatastoreName): boolean?
    return
end

--// Load user data
function Datastore:Load(plr: Player)
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

    self.createDataContainer(plr, userData)
    self.Players[plr.Name] = userData
end

--// Initialize the data store
function Datastore:Initialize()
    Players.PlayerAdded:Connect(function(plr: Player)  
        self:Load(plr)
    end)

    Players.PlayerRemoving:Connect(function(plr: Player)
        self:Save(plr)
    end)

    --// TODO
    --// BindToClose here for server shutdowns
end

return Datastore