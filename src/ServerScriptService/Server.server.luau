--!strict

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Initilize the datastore.
local Datastore = require("../ServerStorage/Modules/Datastore")
Datastore:Initialize()

--// Initialize the attack register
local AttackRegister: any = require("../ServerStorage/Modules/AttackRegister")
AttackRegister:Listen()