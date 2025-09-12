--!strict

--// Initilize the datastore.
local Datastore = require("../ServerStorage/Modules/Datastore")
Datastore:Initialize()

--// Initialize the attack register
local AttackRegister: any = require("../ServerStorage/Modules/AttackRegister")
AttackRegister:Listen()

--// Initialize ServerEvents
local ServerEvents: any = require("../ServerStorage/Modules/ServerEvents")
ServerEvents:Listen()