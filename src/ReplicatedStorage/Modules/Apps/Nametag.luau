--!strict

--// Nametag
--   Logic for the nametag application.

--// Service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Player
local plr = Players.LocalPlayer
local data = plr:WaitForChild("Data")

--// NametagEvent
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local NametagEvent = Remotes:WaitForChild("NametagEvent") :: RemoteEvent

--// Nametag Object
local Nametag = {}

--// Open Application
function Nametag:Open()
    self.interface.Visible = true
end

--// Close Application
function Nametag:Close()
    local customizeScreen = self.interface:WaitForChild("Customize")
    customizeScreen.Visible = false
    self.interface.Visible = false
end

--// Setup customization window connections
function Nametag:SetupCustomization(customizationScreen)
    local fonts = Enum.Font:GetEnumItems()
    local fontsFrame = customizationScreen:WaitForChild("FontsFrame")
    local colorFrame = customizationScreen:WaitForChild("ColorsFrame")

    --// Load fonts
    for _, font in pairs(fonts) do
        if font.Name == "Unknown" then
            continue
        end

        local newFont = fontsFrame.Holder:Clone()
        newFont.Name = font.Name
        newFont.FontText.Font = font.Name
        newFont.FontText.Text = font.Name
        newFont.Parent = fontsFrame
        newFont.Visible = true

        newFont.MouseButton1Click:Connect(function()
            NametagEvent:FireServer("Font", font.Name)
        end)
    end

    --// Program colors
    for _, colorButton in pairs(colorFrame:GetChildren()) do
        if not colorButton:IsA("ImageButton") then
            continue
        end

        colorButton.MouseButton1Click:Connect(function()
            NametagEvent:FireServer("Color", colorButton.BackgroundColor3)
        end)
    end
end

--// Nametag Application
function Nametag:Initialize(appButton, appInterface)
    self.button = appButton
    self.interface = appInterface

    local buttons = self.interface:FindFirstChild("Buttons")
    local nametagText = self.interface.NameTagBox.Nametag
    local nametagData = data:WaitForChild("NameTag")

    --// Add button
    buttons:WaitForChild("Add").MouseButton1Click:Connect(function()
        NametagEvent:FireServer("Text", nametagText.Text)
    end)

    --// Remove Button
    buttons:WaitForChild("Remove").MouseButton1Click:Connect(function()
        nametagText.Text = ""
        NametagEvent:FireServer("Text", nametagText.Text)
    end)
    
    --// Customization
    local customizeScreen = self.interface:WaitForChild("Customize")
    local backButton = self.interface:WaitForChild("Bottom"):WaitForChild("Buttons").Back
    local homeButton = self.interface:WaitForChild("Bottom"):WaitForChild("Buttons").Home

    homeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)

    backButton.MouseButton1Click:Connect(function()
        backButton.Visible = false
        customizeScreen.Visible = false
    end)

    buttons:WaitForChild("CustomizeTag").MouseButton1Click:Connect(function()
        backButton.Visible = true
        customizeScreen.Visible = true
    end)
   
    --// Hide tag button
    buttons:WaitForChild("HideTag").MouseButton1Click:Connect(function()
        local hideTag = nametagData:GetAttribute("HideTag")
        NametagEvent:FireServer("HideTag", not hideTag)
    end)

    --// Home screen button
    appButton.MouseButton1Click:Connect(function()
        self:Open()
    end)

    self:SetupCustomization(customizeScreen)
end

return Nametag