--!strict

--// Nametag
--// Responsible for setting up and building connections required for the nametags.

--// Services
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Utility: any = require("../../ReplicatedStorage/Modules/Utility") :: any

--// Nametag Template
local nametagTemplate: BillboardGui = ReplicatedStorage:WaitForChild("Assets").Nametag

--// Nametag Module
local Nametag: any = {
    Tags = {} :: {[string]: BillboardGui},
    LevelColors = {
        {Level = 15000, Color = Color3.fromRGB(0, 255, 0)},
        {Level = 10000, Color = Color3.fromRGB(230, 0, 230)},
        {Level = 5000, Color = Color3.fromRGB(255, 0, 0)},
        {Level = 1000, Color = Color3.fromRGB(255, 251, 0)},
        {Level = 0, Color = Color3.fromRGB(255, 255, 255)},
    }
}

--// Creates a new nametag
function Nametag:NewTag(plr: Player)
    local newNameTemp: BillboardGui = nametagTemplate:Clone()
    local char: Model? = plr.Character or plr.CharacterAdded:Wait()
    local data: Configuration = plr:FindFirstChild("Data") :: Configuration
    if not char then
        return
    end

    --// Setup nametag onto player
    local head: Part = char:FindFirstChild("Head") :: Part
    newNameTemp.Name = tostring(plr.UserId)
    newNameTemp.Parent = char
    newNameTemp.Adornee = head
    newNameTemp.Enabled = true
    newNameTemp:AddTag("Nametag")

    self.Tags[tostring(plr.UserId)] = newNameTemp
    self:UpdateTag(plr)
end

--// Update name tag
function Nametag:UpdateTag(plr: Player)
    local tag: BillboardGui? = self.Tags[tostring(plr.UserId)]
    if not tag then 
        return
    end

    local data: Configuration = plr:FindFirstChild("Data") :: Configuration
    local nametagData: Configuration = data:FindFirstChild("NameTag") :: Configuration
    if not (data and nametagData) then
        return
    end

    --// Update name tag based on setting values
    local name: string = nametagData:GetAttribute("Text") :: string
    local username: TextLabel = tag:FindFirstChild("Username") :: TextLabel
    tag.Enabled = not nametagData:GetAttribute("HideTag") :: boolean
    username.TextColor3 = nametagData:GetAttribute("Color") :: Color3
    username.Text = `{#name == 0 and plr.DisplayName or name} (@{plr.Name})`
    username.FontFace = Font.fromName(nametagData:GetAttribute("Font") :: string, Enum.FontWeight.Bold)

    local level: number = data:GetAttribute("Level") :: number
    local afkState: boolean? = plr:GetAttribute("AFK") :: boolean?
    local levelTxt: TextLabel = tag:FindFirstChild("Level") :: TextLabel
    levelTxt.Text = (afkState and `(AFK) Level ` or `Level `)..Utility:FormatNumberWithCommas(level)

    --// Set Level Color
    for _, levelData in pairs(self.LevelColors) do
        if level < levelData.Level and levelData.Level ~= 0 then
            continue
        end
        levelTxt.TextColor3 = levelData.Color
        break
    end

    --// Setup Group tag icons
    local iconCont: Frame? = tag:FindFirstChild("Tags") :: Frame
    if not iconCont then
        return
    end

    local groupIcon: ImageLabel? = iconCont:FindFirstChild(plr:GetAttribute("Role") :: string) :: ImageLabel
    if groupIcon then
        groupIcon.Visible = true
    end

    --// TODO
    --// Setup Gamepass tag icon
    local gamepasses: Configuration? = data:FindFirstChild("Gamepasses") :: Configuration
    if not gamepasses then
        return
    end

    for passName: string in pairs(gamepasses:GetAttributes()) do
        local passIcon: ImageLabel? = iconCont:FindFirstChild(passName) :: ImageLabel
        if not passIcon then
            continue
        end
        passIcon.Visible = true
    end
end

--// Remove Tag
function Nametag:RemoveTag(plr: Player)
    local tag: BillboardGui? = self.Tags[tostring(plr.UserId)]
    if not tag then
        return
    end

    tag:Destroy()
    self.Tags[tostring(plr.UserId)] = nil
end

return Nametag