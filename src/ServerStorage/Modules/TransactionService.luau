--!strict

--// Transaction Service
--   Manages all product, gamepass and store request in the game

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local BannerData = require(Modules.BannerData) :: any

--// Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TransactionEvent = Remotes:FindFirstChild("Transactions")

--// Transaction Service
local TransactionService = {}

--// Start Service connections
function TransactionService:Listen()
    --// Event used for all in-game purchased with in game currency.
    TransactionEvent.OnServerEvent:Connect(function(plr: Player, transactionType: string, ...: any?)
        local data = plr:FindFirstChild("Data") :: Instance

        if transactionType == "Banner" then
            local action, name = ... 
            local bannerData = data:FindFirstChild("OwnedBanners") :: Instance

            --// Process equip request
            if action == "Equip" and bannerData:GetAttribute(name :: string) then
                data:SetAttribute("EquippedBanner", name)
                return
            end

            --// Process banner purchases
            if action == "Buy" and not bannerData:GetAttribute(name :: string) and BannerData[name] then
                local plrCash = data:GetAttribute("Cash")
                if BannerData[name].Cost > plrCash or data:GetAttribute("Level") < BannerData[name].Level then
                    return
                end
               
                data:SetAttribute("Cash", plrCash - BannerData[name].Cost)
                bannerData:SetAttribute(name :: string, true)
                return
            end
        end
    end)
end

return TransactionService