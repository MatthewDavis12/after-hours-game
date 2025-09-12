--!strict

--// Sign
--   Contains helper functions to update signs for players

type T_Sign = {
    --// Method used to update the sign of a player based on values
    UpdateSign: (self: T_Sign, plr: Player) -> ()
}

local Sign: T_Sign = {
    --// Update Sign
    --   Method used to update user signs
    UpdateSign = function(self, plr)
        local data: Configuration = plr:FindFirstChild("Data") :: Configuration
        local signData: Configuration = data:FindFirstChild("Sign") :: Configuration
        if not (data and signData) then
            return
        end

        local char: Model? = plr.Character
        if not char then
            return
        end

        local sign: Tool? = plr.Backpack:FindFirstChild("Sign") :: Tool? or char:FindFirstChild("Sign") :: Tool?
        if not sign then
            return
        end

        local handle: UnionOperation = sign:FindFirstChild("Handle") :: UnionOperation
        local textFrame: SurfaceGui = handle:FindFirstChild("TextFrame") :: SurfaceGui
        local signText: TextBox = textFrame:FindFirstChild("Text") :: TextBox
        signText.FontFace = Font.fromName(signData:GetAttribute("Font") :: string, Enum.FontWeight.Bold)
        signText.Text = signData:GetAttribute("Text") :: string
        signText.TextColor3 = signData:GetAttribute("Color") :: Color3
    end
}; return Sign