--!strict

--// Profile
--   Logic for the profile in the phone.

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utility = require(Modules.Utility)
local BannerData = require(Modules.BannerData) :: any

--// Map
local map = workspace:WaitForChild("Map")

--// Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ProfileEvent = Remotes:WaitForChild("ProfileEvent")
local Transactions = Remotes:WaitForChild("Transactions")

--// Plr
local plr = Players.LocalPlayer

--// Color Wheel
local ColorWheel = require(script:WaitForChild("Color")) :: any

--// Profile object
local Profile = {
    --// Connection cache for real time updates from the players profile
    --   currently being viewed
    updates = {},
    --// Tracker to control the amount of profile updates the client can send
    --   to the server
    lastProfileUpdate = 0,
    --// Constant for the update delay
    PROFILE_UPDATE_DELAY = 1
}

--// Open profile application
function Profile:Open(targetPlr: Player)
    local data = targetPlr:WaitForChild("Data")
    local nametagData = data:WaitForChild("NameTag")
    local editButton = self.interface:WaitForChild("EditButton")
    local editBanner = self.interface:WaitForChild("EditBanner")

    --// Update profile values
    local plrNameLabel = self.interface:WaitForChild("PlayerName")
    local plrIcon = self.interface:WaitForChild("ProfileImage")
    local plrDisplay = self.interface:WaitForChild("PlayerDisplay")
    plrNameLabel.Text = `@{targetPlr.Name}` 
    plrIcon.Image = Players:GetUserThumbnailAsync(targetPlr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

    --// Udpate display name
    local currentDisplay = nametagData:GetAttribute("Text") :: string
    plrDisplay.Text = currentDisplay == "" and targetPlr.DisplayName or currentDisplay

    --// Check customize UI
    if self.interface.Customize.Visible then
        self.interface.Customize.Visible = plr == targetPlr
    end

    --// Monitor profile color updates
    local outerShadow = self.interface.OuterShadow.ShadowImage
    outerShadow.ImageColor3 = data:GetAttribute("ProfileColor")

    self.updates["ProfileColor"] = data:GetAttributeChangedSignal("ProfileColor"):Connect(function()
        outerShadow.ImageColor3 = data:GetAttribute("ProfileColor") 
    end)

    --// Monitor AboutMe updates
    local aboutMe = self.interface.AboutMe
    aboutMe.Text = data:GetAttribute("AboutMe")

    self.updates["AboutMe"] = data:GetAttributeChangedSignal("AboutMe"):Connect(function()
        aboutMe.Text = data:GetAttribute("AboutMe")
    end)

    --// Monitor EquippedBanner updates
    local bannerImage = self.interface.TopShadow.BannerImage
    local equippedBanner = BannerData[data:GetAttribute("EquippedBanner")]
    bannerImage.Image = equippedBanner and equippedBanner.Image or bannerImage.Image

    self.updates["EquippedBanner"] = data:GetAttributeChangedSignal("EquippedBanner"):Connect(function()
        local equippedBanner = BannerData[data:GetAttribute("EquippedBanner")]
        bannerImage.Image = equippedBanner and equippedBanner.Image or bannerImage.Image

        if plr ~= targetPlr then
            return
        end
        --// Update banner text
    end)

    --// Monitor Level updates
    local plrLevel = self.interface.PlayerLevel
    plrLevel.Text = `Level {data:GetAttribute("Level")}`

    self.updates["Level"] = data:GetAttributeChangedSignal("Level"):Connect(function()
        plrLevel.Text = `Level {data:GetAttribute("Level")}`
    end)

    local isLocalPlr = plr == targetPlr
    editButton.Visible = isLocalPlr
    editBanner.Visible = isLocalPlr
    aboutMe.Interactable = isLocalPlr
    self.interface.Visible = true
end

--// Close profile application
function Profile:Close()
    local editButton = self.interface:WaitForChild("EditButton")
    local editBanner = self.interface:WaitForChild("EditBanner")

    --// Close customization
    self.interface.Customize.Visible = false

    --// Close color wheel
    if self.colorWheel and self.colorWheel.Instance then
        self.colorWheel:Destroy()
    end

    --// Remove all connections
    for conName, con in pairs(self.updates) do
        self.updates[conName]:Disconnect()
        self.updates[conName] = nil
    end

    self.interface.Visible = false
    editButton.Visible = false 
    editBanner.Visible = false
end

--// Setup application interface
--   Just to seperate this logic from the initialization
function Profile:SetupAppInterface()
    local data = plr:WaitForChild("Data")
    local ownedBanners = data:WaitForChild("OwnedBanners")
    local editButton = self.interface:WaitForChild("EditButton")
    local editBanner = self.interface:WaitForChild("EditBanner")
    local customize = self.interface:WaitForChild("Customize") 
    local lastTransactionRequest = 0

    --// Color Wheel
    editButton.MouseButton1Click:Connect(function()
        if self.colorWheel and self.colorWheel.Instance then
            return
        end

        self.colorWheel = ColorWheel.new(self.interface.Parent, {
            Size = 0.4,
            Position = UDim2.fromScale(0.55, 0.36)
        })

        --// Bindable Connections
        --// The color wheel contains three bindables that stream data.
        --// FinishedEvent: Streams the final color selected in the wheel.
        --// UpdateEvent: Streams the updated color based on the new position of the wheel
        --//              selector.
        --// CancelEvent: Streams the cancel notification.
        local updatEvent = self.colorWheel.Instance:WaitForChild("UpdateEvent")
        local finishedEvent = self.colorWheel.Instance:WaitForChild("FinishedEvent")
        local outterShadow = self.interface:WaitForChild("OuterShadow"):WaitForChild("ShadowImage")

        finishedEvent.Event:Connect(function(color: Color3)
            if tick() - self.lastProfileUpdate < self.PROFILE_UPDATE_DELAY then
                return
            end

            self.lastProfileUpdate = tick()
            local color255 = Color3.fromRGB(color.R * 255, color.G * 255, color.B * 255)
            ProfileEvent:FireServer("ProfileColor", color255)
        end)

        updatEvent.Event:Connect(function(color: Color3)
            local color255 = Color3.fromRGB(color.R * 255, color.G * 255, color.B * 255)
            outterShadow.ImageColor3 = color255
        end)
    end)
    
    --// About Me
    local aboutMe = self.interface.AboutMe
    aboutMe.FocusLost:Connect(function()
        local oldAboutMe = data:GetAttribute("AboutMe")
        if oldAboutMe == aboutMe.Text or aboutMe.Text == "" then
            return
        end

        ProfileEvent:FireServer("AboutMe", aboutMe.Text)
    end)

    --// Banner Editor
    editBanner.MouseButton1Click:Connect(function()
        customize.Visible = not customize.Visible
    end)

    --// Banner Close
    customize.Exit.MouseButton1Click:Connect(function()
        customize.Visible = false
    end)

    --// Load Banners
    local bannerList = customize.Banners.BannerList
    local bannerTemplate = bannerList.BannerTemplate
    task.wait(1)

    for bannerName, bannerData in pairs(BannerData) do
        local newBanner = bannerTemplate:Clone()
        local isLockedFrame = newBanner:FindFirstChild("Locked")
        local bannerCost = isLockedFrame:FindFirstChild("Text")
        local scrollSize = bannerList.AbsoluteSize
        local originalSize = UDim2.new(0, scrollSize.X, 0, scrollSize.Y)
        local bannerNameLabel = newBanner.BannerName:FindFirstChild("Text")
        bannerNameLabel.Text = bannerName
        newBanner.Size =  originalSize
        newBanner:SetAttribute("OriginalSize", originalSize)
        newBanner.Image = bannerData.Image
        newBanner.Visible = true
        newBanner.Parent = bannerList
        newBanner.Name = bannerName
        bannerCost.Text = `({bannerData.Level}) {bannerData.Cost}$`
        newBanner.LayoutOrder = ownedBanners:GetAttribute(bannerName) and -bannerData.Cost or bannerData.Cost
        isLockedFrame.Visible = data:GetAttribute("Level") < bannerData.Level or not ownedBanners:GetAttribute(bannerName)

        --// Mouse connection
        newBanner.MouseButton1Click:Connect(function()
            if tick() - lastTransactionRequest < 1 then
                return
            end

            lastTransactionRequest = tick()
            local isOwned = ownedBanners:GetAttribute(bannerName)

            if isOwned then
                --// Attempt to equip
                Transactions:FireServer("Banner", "Equip", bannerName)
                return
            end

            --// Attempt to purchase
            if data:GetAttribute("Level") < bannerData.Level or data:GetAttribute("Cash") < bannerData.Cost then
                warn(`Player can't buy {bannerName}`)
                return
            end

            Transactions:FireServer("Banner", "Buy", bannerName)
        end)
    end

    --// Update List Size
    bannerList.CanvasSize = UDim2.new(0, 0, 0, bannerList.UIListLayout.AbsoluteContentSize.Y)
    bannerList.UIListLayout.Changed:Connect(function(property)
        if property ~= "AbsoluteContentSize" then
            return
        end
        bannerList.CanvasSize = UDim2.new(0, 0, 0, bannerList.UIListLayout.AbsoluteContentSize.Y)
    end)

    bannerList.Changed:Connect(function(property)
        if property ~= "AbsoluteSize" then
            return
        end

        local scrollSize = bannerList.AbsoluteSize
        for _, banner in pairs(bannerList:GetChildren()) do
            if not banner:IsA("ImageButton") then
                continue
            end

            local newSize = UDim2.new(0, scrollSize.X, 0, scrollSize.Y)
            banner.Size = newSize
            banner:SetAttribute("OriginalSize", newSize)
        end
    end)

    --// Update banner list
    ownedBanners.AttributeChanged:Connect(function(bannerOwned)
        local bannerUI = bannerList:FindFirstChild(bannerOwned)
        if not bannerUI then
            return
        end
        
        local isLocked = bannerUI:FindFirstChild("Locked")
        isLocked.Visible = false
        bannerUI.LayoutOrder = -bannerUI.LayoutOrder
    end)
end

--// Initialize profile application
function Profile:Initialize(appButton, appInterface)
    self.button = appButton
    self.interface = appInterface

    --// Setup application interface
    self:SetupAppInterface()

    --// Home screen button
    appButton.MouseButton1Click:Connect(function()
        self:Close()
        self:Open(plr)
    end)

    --// Close button
    local closeButton = self.interface:WaitForChild("Exit")
    closeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)

    --// Load profile button
    local plrNameLabel = self.button:WaitForChild("Name")
    local plrIcon = self.button:WaitForChild("RobloxIcon")
    plrNameLabel.Text = plr.Name
    plrIcon.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

    --// User input connections
    UserInputService.InputChanged:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
        if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local pos, model = Utility:GetWorldModelFromScreen(inputObject.Position, {plr.Character, map})
        if not (pos and model and model ~= plr.Character) then
            if self.mouseTarget then
                self.mouseTarget.ViewProfile.Enabled = false
            end
            self.mouseTarget = nil
            return
        end

        model.ViewProfile.Enabled = true
        self.mouseTarget = model
    end)

    --// User input began
    UserInputService.InputBegan:Connect(function(inputObject: InputObject, gpe: boolean)
        if gpe or (inputObject.UserInputType ~= Enum.UserInputType.Touch and inputObject.UserInputType ~= Enum.UserInputType.MouseButton1) then
            return
        end

        if not self.mouseTarget then
            return
        end

        local targetPlr = Players:GetPlayerFromCharacter(self.mouseTarget)
        if not targetPlr then
            return
        end

        self:Close()
        self:Open(targetPlr)
    end)
end

return Profile