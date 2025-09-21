--!strict

--// Phone
--   Logic for the on screen phone as well as the applications.

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Local player
local plr: Player = Players.LocalPlayer
local playerGui: PlayerGui = plr:WaitForChild("PlayerGui") :: PlayerGui 
local camera = workspace.CurrentCamera

--// Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Apps = Modules:WaitForChild("Apps")

--// Phone Ui
local phoneContainer: ScreenGui = playerGui:WaitForChild("Phone") :: ScreenGui
local phoneBody: Frame = phoneContainer:WaitForChild("Main") :: Frame
local phoneFrame: Frame = phoneContainer:WaitForChild("Phone") :: Frame
local phoneButton: ImageButton = phoneFrame:WaitForChild("PhoneButton") :: ImageButton
local phoneScreen: CanvasGroup = phoneBody:WaitForChild("PhoneScreen") :: CanvasGroup
local profileUI = playerGui:WaitForChild("Profile")

--// Tween Data
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

--// Client phone object
local Phone: any = {
    isOpen = false,
    phoneCloseFOV = 60,
    phoneClosePos = UDim2.new(0.15, 0, 1.4, 0),
    phoneOpenPos = UDim2.new(0.15, 0, 0.5, 0),
    appData = {}
}

--// Close all applications
function Phone:CloseAll()
    for _, appData in pairs(self.appData) do
        appData:Close()
    end
end

--// Open Phone
function Phone:TogglePhone() 
    local Char = require(Modules.Character)
    local animations = Char:GetAnimations()
    if not animations then
        return
    end

    local toggleCamFOV = TweenService:Create(
        camera, 
        tweenInfo, 
        {FieldOfView = not self.isOpen and self.phoneCloseFOV or 70}
    )
    local togglePhoneAnime = TweenService:Create(
        phoneBody, 
        tweenInfo, 
        {Position = not self.isOpen and self.phoneOpenPos or self.phoneClosePos}
    )
    local togglePhoneScreen = TweenService:Create(
        phoneScreen:FindFirstChild("SleepScreen"), 
        TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), 
        {BackgroundTransparency = not self.isOpen and 1 or 0}
    )
   
    self.isOpen = not self.isOpen
    if not self.isOpen then
        togglePhoneScreen:Play()
        togglePhoneScreen.Completed:Wait()
        animations:Stop()
        self:CloseAll()
    else
        animations:Play("PhoneToggle")
    end

    toggleCamFOV:Play()
    togglePhoneAnime:Play()
    togglePhoneAnime.Completed:Wait()

    --// Tween out sleep screen
    if self.isOpen then
        togglePhoneScreen:Play()
    end
end

--// Initialize
function Phone:Initialize()
    --// Initialize phone button
    phoneButton.MouseButton1Click:Connect(function()
        self:TogglePhone()
    end)

    --// TODO
    --   Initialize applications: Pass the application container to the initializer.
    local homeScreen = phoneScreen:WaitForChild("HomeScreen")
    local appsContainer = homeScreen:WaitForChild("Apps")   
    for _, object in pairs(appsContainer:GetDescendants()) do 
        if not object:IsA("ImageButton") then
            continue  
        end

        local appModule = Apps:FindFirstChild(object.Name)
        if not appModule then
            continue
        end

        --// Initialize an application
        local appData = require(appModule) :: any
        local appInterface = phoneScreen:FindFirstChild(`{object.Name}Screen`)
        if not appInterface then
            continue
        end

        self.appData[object.Name] = appData
        appData:Initialize(object, appInterface)
    end

    --// Because the phone is setup weird
    --   we have to manually do the same code in the for loop
    --   for the profile. THIS IS GOOFY!
    --   This is temp until I can recode and redesign the phone.
    local profileButton = homeScreen:WaitForChild("ProfilePage")
    local profileInterface = profileUI:WaitForChild("Profile")
    local profileModule = Apps:FindFirstChild("Profile")
    self.appData[profileInterface.Name] = require(profileModule) :: any
    self.appData.Profile:Initialize(profileButton, profileInterface)
end

return Phone