--!strict

--// Utility
--// Contains helper functions for various QoL of tasks such as formatting long numbers,
--// math functions, and time based functions

--// Utility Module
local Utility: any = {}

--// Format Numbers
function Utility:FormatNumberWithCommas(number: number): string?
    local strNum: string = tostring(number)
    return strNum:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^(-?),", "%1")
end

return Utility