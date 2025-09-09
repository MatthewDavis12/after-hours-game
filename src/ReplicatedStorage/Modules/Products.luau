--!strict

--// Products
--// A large table of data defining the various products in the game including gampassess 
--// and dev products

--// Services
local MarketplaceService = game:GetService("MarketplaceService")

--// Product Table
local Products = {
    Gamepasses = {
        VIP =   1441246853,
        Admin = 1444246696
    },
    DevProducts = {
    }
}

--// Validates the ownership of a gamepass for a player
function Products:ValidateGamepass(plr: Player, passName: string): boolean
    local passId: number = self.Gamepasses[passName]
    if not passId then
        return false
    end
    return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, passId)
end

return Products