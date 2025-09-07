--!nonstrict

--// This script simply just loads all the commands from the modules
for _, module in pairs(script:GetChildren()) do
    if module.Name == "Command" then
        continue
    end

    require(module)
end
