--!strict

--// Emotes
--   Logic for the emotes application in the phone

--// Services
local Players = game:GetService("Players")

--// Player
local plr = Players.LocalPlayer

--// Emote animations
local Animations = require(script:WaitForChild("Animations")) :: any

--// Emotes App
local Emotes = {}

--// Setup application interface
function Emotes:SetupAppInterface()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
    local categoryList = self.interface:WaitForChild("List").Scroll
    local categoryTemplate = categoryList:WaitForChild("Category")
    local animationBtnTemplate = categoryList:WaitForChild("Animation")

    for categoryOrder: number, category: string in ipairs(Animations.LayoutOrder) do
        if categoryList:FindFirstChild(category) then
            return
        end

        --// Create category button
        local categoryUI = categoryTemplate:Clone()
        categoryUI.Name = category
        categoryUI.Parent = categoryList
        categoryUI.Visible = true
        categoryUI.LayoutOrder = categoryOrder
        categoryUI.Header.Text = category
        categoryUI.Arrow.Rotation = -90

        --// Create animation buttons under the category
        --   button.
        local animations = Animations[category]
        for animationName, animationData in pairs(animations) do
            local animationBtn = animationBtnTemplate:Clone()
            animationBtn.Name = animationName
            animationBtn.Parent = categoryList
            animationBtn.LayoutOrder = categoryOrder
            animationBtn.DanceName.Text = animationName
            animationBtn.Visible = false
            animationBtn.Sound.Visible = animationData.Audio ~= nil

            --// Create animation object
            local animationR15Obj = Instance.new("Animation")
            local animationR6Obj = Instance.new("Animation")
            animationR15Obj.AnimationId = `rbxassetid://{animationData.AnimationId.R15}`
            animationR6Obj.AnimationId = `rbxassetid://{animationData.AnimationId.R6}`

            --// Remove the objects later
            task.defer(function()
                animationR6Obj:Destroy()
                animationR15Obj:Destroy()
            end)

            --// Play animations on button click
            print(`R6: {animationR6Obj.AnimationId}, R15: {animationR15Obj.AnimationId}`)
            local animationR6 = animationData.AnimationId.R6 and animator:LoadAnimation(animationR6Obj)
            local animationR15 = animationData.AnimationId.R15 and animator:LoadAnimation(animationR15Obj)
            animationBtn.MouseButton1Click:Connect(function()
                local char = plr.Character
                print("Clicked")
                if not char then
                    return
                end

                local hum = char:WaitForChild("Humanoid")
                local rigType = hum.RigType
                if (rigType == Enum.HumanoidRigType.R15 and not animationR15) or (rigType == Enum.HumanoidRigType.R6 and animationR6) then
                    return
                end
                print("Clicked2")

                if self.currentAnimation then
                    self.currentAnimation:Stop()
                    self.currentAnimation = nil :: any
                end

                self.currentAnimation = rigType == Enum.HumanoidRigType.R15 and animationR15 or animationR6
                self.currentAnimation:Play()
            end)
        end

        --// Category ui button
        local animationVisible = false
        categoryUI.MouseButton1Click:Connect(function()
            animationVisible = not animationVisible
            categoryUI.Arrow.Rotation = animationVisible and 0 or -90

            for animationName in pairs(animations) do
                local animationUI = categoryList:FindFirstChild(animationName)
                if not animationUI then
                    continue
                end
                animationUI.Visible = animationVisible
            end
        end)
    end
end

--// Initialize the emotes app
function Emotes:Initialize(appButton, appInterface)
    self.button = appButton
    self.interface = appInterface
    self:SetupAppInterface()

    --// Open emotes app
    self.button.MouseButton1Click:Connect(function()
        self.interface.Visible = true
    end)
end

return Emotes