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
    SchemaVersion = 3,
    DatastoreName = "Final5"
}

--// Type to assist with data parsing when loading
export type Color3Data = {number}

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

--// User Sign Settings
type UserSignSettings = {
    Text:  string,
    Font:  string,
    Color: Color3Data
}

--// Nametag Settings
type UserNameTagSettings = {
    Text:    string,
    Font:    string,
    Color:   Color3Data,
    HideTag: boolean
}

--// User data type definition
export type UserData = {
    Cash:            number,
    Level:           number,
    Kills:           number,
    Likes:           number,
    version:         number,
    OutfitID:        number,
    AboutMe:         string,
    EquippedBanner:  string,
    firstTimeJoined: boolean,
    ProfileColor:    Color3Data,
    Settings:        UserSettings,
    Gamepasses:      UserChecklist, 
    OwnedBanners:    UserChecklist, 
    Sign:            UserSignSettings,
    NameTag:         UserNameTagSettings
}

--// Returns new data based on the UserData data type.
function UserDataModule:New(): UserData
        return {
            Cash = 50,
            Level = 1,
            Kills = 0,
            Likes = 0,
            version = self.SchemaVersion,
            OutfitID = 0,
            AboutMe = "",
            EquippedBanner = "",
            firstTimeJoined = true,
            ProfileColor = {255, 255, 255},
            Gamepasses = {},
            OwnedBanners = {},
            Settings = {
                TimeOfDay = 12,
                FieldOfView = 70,
                OpenProfiles = true,
                HighGraphics = true,
                PlayerCollisions = false
            },
            Sign = {
                Text = "",
                Font = "BuilderSans",
                Color = {255, 255, 255}
            },
            NameTag = {
                Text = "",
                Font = "BuilderSans",
                Color = {255, 255, 255},
                HideTag = false
            }
    }
end

--// Returns the data store name
function UserDataModule:Name(): string
    return self.DatastoreName
end

return UserDataModule