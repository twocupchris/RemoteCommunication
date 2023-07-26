local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Terrain = workspace.Terrain

local Denominator = Random.new()

local Folder
local Parts = {}
local OldOrientations = {}
local Initiated = {}
local PLAYERS = {}

local PartsOrigin = Vector3.new(1000, 1000, 1000)

local Secure = {}

function RandomString(Length)
	local Array = {}
	for i = 1, Length do
		Array[i] = string.char(math.random(32, 126))
	end
	return table.concat(Array)
end

function Ban(Player)
	Player.Kick(Player, "banned") --put ban stuff here or something idk
end

function IsClient()
	if not RunService.IsClient(RunService) then
		return false
	end
	if RunService.IsServer(RunService) then
		return false
	end
	if not Players.LocalPlayer then
		return false
	end
	if not Players.LocalPlayer.GetMouse(Players.LocalPlayer) then
		return false
	end
	local Success, Error = pcall(function()
		RunService.RenderStepped.Wait(RunService.RenderStepped)
	end)
	if not Success and Error == "RenderStepped event can only be used from local scripts" then
		return false
	end

	return true
end

function PartIntegrityCheck(Player)
	local Part = Parts[Player.UserId]
	if not Part then
		Ban(Player)
		return
	end
	if Part.Parent ~= Folder then
		Ban(Player)
		return
	end
	if Part.Name ~= tostring(Player.UserId * 69420) then
		Ban(Player)
		return
	end

	if Part.Material ~= Enum.Material.Plastic then
		Ban(Player)
		return
	end
	if Part.Shape ~= Enum.PartType.Block then
		Ban(Player)
		return
	end
	if Part.Size:FuzzyEq(Vector3.new(4, 1, 2)) then
		Ban(Player)
		return
	end
	if Part.BrickColor ~= BrickColor.new("Medium stone grey") then
		Ban(Player)
		return
	end
	if Part.Color ~= BrickColor.new("Medium stone grey").Color then
		Ban(Player)
		return
	end
end

function GetPlayerFromUserId(UserId)
	for _, Player in next, Players:GetPlayers() do
		if Player.UserId == UserId then
			return Player
		end
	end
end

function Secure.ServerInit(Origin)
	if not IsClient() then
		PartsOrigin = Origin

		Folder = Instance.new("Folder")
		Folder.Name = RandomString(20)
		Folder.Parent = Terrain
		
		local Animation = Instance.new("Animation")
		Animation.Name = RandomString(20)
		Animation.AnimationId = "rbxassetid://7122246358"
		Animation.Parent = workspace.Terrain

		spawn(function()
			while RunService.Stepped:Wait() do
				Folder.Name = RandomString(20)
				Animation.Name = RandomString(20)
			end
		end)

		spawn(function()
			while RunService.Stepped:Wait() do
				for PlayerUserId, Part in next, Parts do
					PartIntegrityCheck(GetPlayerFromUserId(PlayerUserId))

					local Player = GetPlayerFromUserId(PlayerUserId)
					Part:SetNetworkOwner()
					if Part.Orientation == OldOrientations[Part.Name] then
						Ban(Player)
					end
					Part.Position = PartsOrigin
					Part:SetNetworkOwner(Player)
					wait(0.5)
					OldOrientations[Part.Name] = Part.Orientation
				end
				
				for _, Player in next, PLAYERS do
					if Player.Character and Player.Character:FindFirstChild("Humanoid") then
						for _, Track in next, Player.Character.Humanoid:GetPlayingAnimationTracks() do
							if Track.Animation then
								if Track.Animation.AnimationId == Animation.AnimationId then
									Ban(Player)
								end
							end
						end
					end
				end
			end
		end)

		return Folder
	end
end

function Secure.ClientInit()
	if IsClient() then
		local OrientationRandom = Random.new()
		spawn(function()
			local Terrain = workspace.Terrain
			repeat RunService.RenderStepped.Wait(RunService.RenderStepped) until Terrain
			local Folder = Terrain.FindFirstChildOfClass(Terrain, "Folder")
			local Part = Folder.WaitForChild(Folder, tostring(Players.LocalPlayer.UserId * 69420))


			while RunService.RenderStepped.Wait(RunService.RenderStepped) do
				Part.Position = PartsOrigin
				Part.CFrame *= CFrame.Angles(math.rad(OrientationRandom.NextNumber(OrientationRandom, 0, 360)), math.rad(OrientationRandom.NextNumber(OrientationRandom, 0, 360)), math.rad(OrientationRandom.NextNumber(OrientationRandom, 0, 360)))
			end
		end)
	end
end

function Secure.Ban()
	if IsClient() then
		local Part = Parts[Players.LocalPlayer.UserId]
		if not Part then
			repeat RunService.RenderStepped:Wait() until Part
		end
		Part.Anchored = true
		Part:Destroy()
		
		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			local Animation = workspace.Terrain:FindFirstChildOfClass("Animation")
			if Animation then
				Players.LocalPlayer.Character.Humanoid:LoadAnimation(Animation):Play()
			end
		end
	end
end

function Secure.AddPlayer(Player)
	if not Player:HasAppearanceLoaded() then
		Player.CharacterAppearanceLoaded:Wait()
	end
	local Part = Instance.new("Part")
	Part.Name = tostring(Player.UserId * 69420)
	Part.Parent = Folder
	
	table.insert(PLAYERS, Player)

	Parts[Player.UserId] = Part

	Part:SetNetworkOwner(Player)
end

function Secure.RemovePlayer(Player)
	PartIntegrityCheck(Player)
	Parts[Player.UserId]:Destroy()
	Parts[Player.UserId] = nil
	
	local Index = table.find(PLAYERS, Player)
	if Index then
		table.remove(PLAYERS, Index)
	end
end

return Secure