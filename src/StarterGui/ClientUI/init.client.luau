--!strict

--// Loads the modules that control the client UI, 
--// essentially just a proxy for the execution of the ui code.

--// Client Modules
local clientModules = {}
for _, mod in pairs(script:GetChildren()) do
    clientModules[mod.Name] = require(mod) :: any
    clientModules[mod.Name]:Initialize()
end