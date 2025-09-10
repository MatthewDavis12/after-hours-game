--!nonstrict

--// Core
--   Contains submodules that are used for core functionality. Unfortunately we don't need in this game but 
--   we depend on it.

--// Core Module type definition
--   string: Key that is the name of a core submodule.
--   any: Value of the table of the core submodule.
type T_Core = {[string]: any}

--// Core Module
local Core: T_Core = {}

--// Load submodules
for _, m: ModuleScript in pairs(script:GetChildren() :: {ModuleScript}) do
    Core[m.Name] = require(m)
end

return Core