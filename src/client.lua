local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Secure = require(ReplicatedStorage:WaitForChild("SecureModule"))
Secure.ClientInit()

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	--Secure:Ban()
end)

LocalPlayer.CharacterAdded:Connect(function(Character)
	Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		Secure:Ban()
	end)
end)