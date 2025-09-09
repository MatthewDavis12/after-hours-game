--!strict
--// Group Object
local Group: any = {
    GroupId = 35595868,
    Roles = {
        Owner = 200,
        Staff = 4,
        Mod = 3,
        User = 2
    }
}

--// Helper function to fetch the users role in the group
function Group:GetGroupRole(plr: Player): string?
    return plr:GetRoleInGroup(self.GroupId)
end

--// Helper function for getting the role
function Group:GetPermissionLevel(plr: Player): string?
    local currentRole: string = "Owner"
    local roleId = plr:GetRankInGroup(self.GroupId)

    for roleName: string, roleLevel in self.Roles do
        if roleId > roleLevel then
            continue
        end

        currentRole = roleName
        break
    end

    return currentRole
end

--// Check if users permissions are enough
function Group:ValidatePermissionLevel(userPerm: string, perm: string): boolean?
    local permId: number = self.Roles[perm]
    if not permId then
        print("Invalid perm id")
        return
    end

    for permName, permID in self.Roles do
        if permName ~= userPerm then
            continue
        end
        return  permID >= permId
    end

    return
end

return Group

