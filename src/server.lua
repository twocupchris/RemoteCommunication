local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Secure = require(ReplicatedStorage:WaitForChild("SecureModule"))

Secure.ServerInit(Vector3.new(999, 999, 999))

Players.PlayerAdded:Connect(Secure.AddPlayer)
Players.PlayerRemoving:Connect(Secure.RemovePlayer)