-- A ServerScript, should be placed inside the ServerScriptService of the game.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MAX_SPEED = 16 -- studs per second (default walkspeed cap)
local TELEPORT_DISTANCE = 50

local playerData = {}

Players.PlayerAdded:Connect(function(player)
	playerData[player] = {
		lastPosition = nil,
		lastCheck = tick(),
		warnings = 0
	}
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player] = nil
end)

RunService.Heartbeat:Connect(function()
	for player, data in pairs(playerData) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local currentTime = tick()

			if data.lastPosition then
				local distance = (hrp.Position - data.lastPosition).Magnitude
				local timeDiff = currentTime - data.lastCheck
				local speed = distance / math.max(timeDiff, 0.1)

				-- Speed exploit detection
				if speed > MAX_SPEED then
					data.warnings += 1
					print(player.Name .. " flagged for speed exploit")

					if data.warnings >= 3 then
						player:Kick("Speed exploit detected. Player Kicked.")
					end
				end

				-- Teleport detection
				if distance > TELEPORT_DISTANCE then
					warn(player.Name .. " flagged for teleporting")
				end
			end

			data.lastPosition = hrp.Position
			data.lastCheck = currentTime
		end
	end
end)
