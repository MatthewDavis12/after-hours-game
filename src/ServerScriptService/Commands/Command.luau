--!strict

--// Command
--//
--// Primary command processor as well as register. 
--// Contains all methods and prorperties used to implement commands
--//
--// TODO
--// Focus on permissions

--// For permission validation
local Groups = require("../../ReplicatedStorage/Modules/Group")

--// Command Template
--// Defines the command structure. If a command is passed
--// to the registry function and does not follow this template there
--// is a potential for things to go wrong.
export type Cmd = {
	--// Command name.
    Token:       string,                     
	--// Displays when a user does the /cmd.
	Help:        string?,					 
	--// Short handed version of the command.
	Short:       string,  					 
	--// Determines the level at which the command can be ran.
	PermLevel:   string,					 
	--// Short description that is displayed in the /cmd.
    Description: string,                     
 	--// The method that is called for the command code.
    Run:         (Player, ...string) -> (), 
}

--// Command object that manages all commands
local Command: any = {
	prefix = "/",
	commandRegistry = {} :: {[string]: Cmd}
}

--// QoL that allows us to change the prefix
function Command:SetPrefix(prfx: string)
	self.prefix = prfx
end

--// Registry commands to the Command Registry
function Command:Register(cmd: Cmd) 
	self.commandRegistry[cmd.Token] = cmd
end

--// Process commands before they are called.
--// For example when need to ensure the user has the proper permissions
--// before allowing them to run a command
function Command:Processor(plr: Player, msg: string)
	if not string.match(msg, "^"..self.prefix) then
		print()
		return
	end
	
	--// Query for the command. Once the command is found we'll
	--// check for proper permissions
	local token = msg:match("^"..self.prefix.."(%w+)")
	local cmd   = self:queryRegistry(token)
	if not token or not cmd then
		print("Invalid token: "..msg)
		return
	end

	local userPerm: unknown? = plr:GetAttribute("Permission")
	if not Groups:ValidatePermissionLevel(userPerm, cmd.PermLevel) then
		print("Not enough permissions: Requires "..cmd.PermLevel)
		return
	end
	
	--// Parse args then run the command
	local args = string.gsub(msg, self.prefix..token.."%s", "")
	cmd.Run(plr, args)
end

--// Query Registry: Internal
--// Internal method that allows us to easily query the command registry during lookups.
function Command:queryRegistry(token: string): Cmd?
	local cmd: Cmd? = self.commandRegistry[token]
	if cmd then
		return cmd
	end

	for regToken: string, regCmd: Cmd in pairs(self.commandRegistry) do
		if not regCmd.Short or (regCmd.Short:lower() ~= token and not string.match(regToken, "^"..token)) then
			continue
		end

		return regCmd
	end

	return
end

return Command