-- BEGIN VARIABLES --

-- module
local NPCMovement = {}

-- constants
local STUCK_CHECK_WAIT_LENGTH = 1		-- seconds between each check for stuck NPCs
local MIN_SPEED_NOT_STUCK = 2			-- minimum speed at which an NPC is not considered stuck

-- pathfinding service setup
local PathfindingService = game:GetService("PathfindingService")
local pathDefaults = {
	AgentRadius = 3,	 -- larger than 2 to help prevent NPCs from getting stuck 
	AgentHeight = 5, 
	AgentCanJump = true, 
	WaypointSpacing = 4, 
	Costs = nil}
local path = PathfindingService:CreatePath(pathDefaults)

-- variables for pathfinding logic
local npcStuck = script:FindFirstChild("NPCStuck")
if not npcStuck then
	npcStuck = Instance.new("BindableEvent")
	npcStuck.Name = "NPCStuck"
	npcStuck.Parent = script
end

-- END VARIABLES --

-- BEGIN FUNCTIONS --

local function forceJump(npc)
	npc.Humanoid.Jump = true
end

function NPCMovement.FollowPath(npc, destination)
	local waypoints
	local nextWaypointIndex
	local reachedConnection = nil
	local stuckConnection
	
	local humanoid = npc:FindFirstChild("Humanoid")
	
	-- Compute the path
	local success, errorMessage = pcall(function()
		path:ComputeAsync(npc.Torso.AssemblyRootPart.Position, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		waypoints = path:GetWaypoints()

		-- Detect if NPC becomes stuck
		stuckConnection = npcStuck.Event:Connect(function()
			if not humanoid.TriedJump.Value then
				forceJump(npc)
				humanoid.TriedJump.Value = true
			else
				stuckConnection:Disconnect()
				NPCMovement.FollowPath(npc, destination)
			end
		end)

		-- Detect when movement to next waypoint is complete
		if not reachedConnection then
			reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
				if reached and nextWaypointIndex < #waypoints then
					-- Increase waypoint index and move to next waypoint
					nextWaypointIndex += 1
					humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
				else
					humanoid.Moving.Value = false
					reachedConnection:Disconnect()
				end
			end)
		end

		-- Initially move to second waypoint
		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
		humanoid.Moving.Value = true
	else
		warn("Path not computed!", errorMessage)
	end
end

function NPCMovement.CheckIfStuck(npcs)
	while true do
		wait(STUCK_CHECK_WAIT_LENGTH)
		local npcTable = npcs:GetChildren()
		for i,npc in pairs(npcTable) do
			if npc.Humanoid.Moving.Value and
				npc.Torso.AssemblyLinearVelocity.magnitude < MIN_SPEED_NOT_STUCK
			then
				npcStuck:Fire(npc)
			elseif npc.Humanoid.Moving.Value then
				npc.Humanoid.TriedJump.Value = false
			end
		end
	end
end

-- END FUNCTIONS --

return NPCMovement
