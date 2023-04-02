local PathfindingService = game:GetService("PathfindingService")

local path = PathfindingService:CreatePath({
	AgentRadius = 6,
	AgentHeight = 5,
	AgentCanJump = true,
	WaypointSpacing = 4,
	Costs = nil
})

local npc = game.Workspace.LivingNPCs.NPC
local humanoid = npc:FindFirstChild("Humanoid")

local TEST_DESTINATION = game.Workspace.Destination.Position

local waypoints
local nextWaypointIndex
local reachedConnection = nil
local blockedConnection
local stuckEvent = workspace.Stuck
local stuckConnection

local function checkIfStuck(npc)
	while true do
		wait(1)
		if npc.Torso.Velocity.magnitude < 4 then
			local pos = Vector2.new(npc.Torso.Position.X, npc.Torso.Position.Z)
			print(pos)
			npc.Humanoid.Jump = true
			wait(0.5)
			local newPos = Vector2.new(npc.Torso.Position.X, npc.Torso.Position.Z)
			print(newPos)
			print("speed: " .. npc.Torso.Velocity.Z)
			stuckEvent:Fire()
			coroutine.yield()
		end
	end
end

local stuckChecker = coroutine.wrap(checkIfStuck)

local function followPath(destination)
	-- Compute the path
	local success, errorMessage = pcall(function()
		path:ComputeAsync(npc.PrimaryPart.Position, destination)
	end)
	
	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		waypoints = path:GetWaypoints()
		
		-- Detect if NPC becomes stuck
		stuckConnection = stuckEvent.Event:Connect(function()
			stuckConnection:Disconnect()
			followPath(destination)
			return
		end)
		
		-- Detect if path becomes blocked
		--[[blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
			-- Check if the obstacle is further down the path
			if blockedWaypointIndex >= nextWaypointIndex then
				-- Stop detecting path blockage until path is recomputed
				blockedConnection:Disconnect()
				-- Call function to recompute new path
				followPath(destination)				
			end
		end)]]
		
		-- Detect when movement to next waypoint is complete
		if not reachedConnection then
			reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
				if reached and nextWaypointIndex < #waypoints then
					-- Increase waypoint index and move to next waypoint
					nextWaypointIndex += 1
					humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
				else
					reachedConnection:Disconnect()
					--blockedConnection:Disconnect()
				end
			end)
		end
		
		-- Initially move to second waypoint
		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
		stuckChecker(npc)
	else
		warn("Path not computed!", errorMessage)
	end
end

followPath(TEST_DESTINATION)