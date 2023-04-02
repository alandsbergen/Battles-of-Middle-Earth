local function func1()
	local torso = workspace.NPC.Torso
	local humanoid = workspace.NPC.Humanoid
	local timeStart = tick()
	for i = 1, 100000 do
		if (torso.Position - humanoid.WalkToPoint).magnitude > 1 then
			
		end
	end
	local timeEnd = tick()
	print("func1: " .. (timeEnd - timeStart) * 1000 .. " ms")
end

local function func2()
	local moving = workspace.NPC.Moving.Value
	local timeStart = tick()
	for i = 1, 100000 do
		moving = true
		if moving then
			
		end
		moving = false
	end
	local timeEnd = tick()
	print("func2: " .. (timeEnd - timeStart) * 1000 .. " ms")
end

local PathfindingService = game:GetService("PathfindingService")

local path = PathfindingService:CreatePath({
	AgentRadius = 6,
	AgentHeight = 5,
	AgentCanJump = true,
	WaypointSpacing = 4,
	Costs = nil
})

local function func3()
	local timeStart = tick()
	local waypoints
	local nextWaypointIndex = 2
	local reachedConnection = nil
	local npc = workspace.LivingNPCs.NPC
	local humanoid = npc.Humanoid
	local destination = workspace.Destination.Position
	for i = 1, 50 do
		local success, errorMessage = pcall(function()
			path:ComputeAsync(npc.PrimaryPart.Position, destination)
		end)
	end
	local timeEnd = tick()
	print("func3: " .. (timeEnd - timeStart) * 1000 .. " ms")
end

local function func4()
	local timeStart = tick()
	local npc = workspace.LivingNPCs.NPC
	local pos = npc.Torso.AssemblyRootPart.Position
	local humanoid = npc.Humanoid
	local destination = workspace.Destination.Position
	for i = 1, 50 do
		local result = workspace:Raycast(pos, destination - pos)
		humanoid:MoveTo(destination)
	end
	local timeEnd = tick()
	print("func4: " .. (timeEnd - timeStart) * 1000 .. " ms")
end


--func1()
--func2()
-- func2 is roughly 28x faster than func1

func3()
func4()
-- func4 is roughly 74000x faster than func3 without the raycast, and roughly 25000x faster with the raycast