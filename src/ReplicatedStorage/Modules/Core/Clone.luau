--!strict

--// Clone
--   Clones instances. This is some goofy code so forget about this description.

--// Clone Metatable definition
type T_CallMeta = {
    --// Allows the primary table to be called like a function.
    --   self: The orginal table that was called as it was a function.
    -- 
    --   object: Defines the objective result of the table call. If it is a string, this defines the 
    --   name for an Event. If it is an Instance then it defines the object to be cloned. If it doesn't exist
    --   then it means the object needs to be created.
    --
    --   objectValue: Defines the value for object based on the type that object is. If object is the string "Child" then this
    --   will be the Instance that will be cloned.
    __call: (self: CloneObj, object: (Instance | string)?, objectValue: (Instance | string)?) -> ()
}

--// Clone Object table definition
type T_CloneObj = {
    --// Name of the object 
    _name: string,
    --// Method to build instances
    build: (self: CloneObj, object: (Instance | string)?) -> ((any, any) -> Instance)?
}

--// Public facing Clone type with metatable attached
export type CloneObj = typeof(setmetatable({} :: T_CloneObj, {} :: T_CallMeta))

--// Build function
--   Defined outside of the T_CloneObj because it was too much on the eyes.
--   So we point to it from inside the object.
local function buildFn(self: CloneObj, object: (Instance | string)?): ((any, any) -> Instance)?
    if not object then return end

    return function(instanceData: any, instanceParent: any?): Instance
        local instance
        local parent = instanceParent

        --// Figure out which instance we're working with.
        --   A string represents a child of a parent.
        --   An instance should indicate the actual instance we want to clone.
        if parent then
            instance = typeof(object) == "string" and parent:FindFirstChild(object)
        else
            instance = typeof(object) == "Instance" and object:Clone()
        end

        for dataKey: any, dataValue: any in pairs(instanceData) do
            local dataKeyType: any = typeof(dataKey)

            --// dataKeys that are strings define properties
            --   that are desired to be set.
            if dataKeyType == "string" then
                if dataKey == "Parent" and not parent then
                    parent = dataValue
                    continue
                end

                --// Attempt to set properties of the target instance
                local success: boolean = pcall(function()
                    if instance:FindFirstChild(dataKey) then
                        error(`Invalid property name {dataKey}, {dataKey} is a child of {instance}`)
                    end
                    instance[dataKey] = dataValue
                end)

                --// Error if the property we attempt to set the value for does
                --   not succeed
                assert(success, `Invalid property name"{dataKey}" for instance "{instance}"`)
            end
        end

        if parent then
            instance.Parent = parent
        end

        return instance
    end
end

--// Clone Object
local Clone: CloneObj = setmetatable({_name = "Clone", build = buildFn}, {__call = function(self: CloneObj, object: (Instance | string)?, objectValue: (Instance | string)?)
    return self:build(object)
end})

return Clone