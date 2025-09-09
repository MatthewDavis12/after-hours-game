--!strict

--// Module defintion
--//
--// SchemaVersion: The schema version is used to calculate if a merge in default data and player data
--// is needed. For example, if we add another key to the default user data "Gems" well the old player data
--// will also need to contain the "Gems" key. Therefore we create the new key in the default data and then
--// update the SchemaVersion. 
--//
--// When the SchemaVersion is compared to the UserDataModule and the old player data and they're different
--// the default data  and old player data tables will be merged to include all new keys
--// 
--// DatastoreName: The datastore name is just the name of the player datastore.
local UserDataModule: any = {
    SchemaVersion = 1,
    DatastoreName = "Final5"
}

--// User Checklist data type
type UserChecklist = {[string]: boolean}

--// User Settings data type
type UserSettings = {
    TimeOfDay:        number,
    FieldOfView:      number,
    OpenProfiles:     boolean,
    HighGraphics:     boolean,
    PlayerCollisions: boolean,
}

--// User data type definition
export type UserData = {
    Cash:            number,
    Level:           number,
    Kills:           number,
    Likes:           number,
    Version:         number,
    OutfitID:        number,
    AboutMe:         string,
    ProfileColor:    string,
    EquippedBanner:  string,
    firstTimeJoined: boolean,
    Settings:        UserSettings,
    Gamepasses:      UserChecklist, 
    OwnedBanners:    UserChecklist, 
}

--// Returns new data based on the UserData data type.
function UserDataModule:New(): UserData
        return {
            Cash = 50,
            Level = 1,
            Kills = 0,
            Likes = 0,
            Version = self.SchemaVersion,
            OutfitID = 0,
            AboutMe = "",
            ProfileColor = "",
            EquippedBanner = "",
            firstTimeJoined = true,
            Gamepasses = {},
            OwnedBanners = {},
            Settings = {
                TimeOfDay = 12,
                FieldOfView = 70,
                OpenProfiles = true,
                HighGraphics = true,
                PlayerCollisions = false
            }
    }
end

--// Returns the data store name
function UserDataModule:Name(): string
    return self.DatastoreName
end

return UserDataModule