local NPCMovement = require(game.ServerScriptService.NPCMovement)
local checkIfStuck = coroutine.wrap(NPCMovement.CheckIfStuck)

local function initializeNPC(npc, livingNPCTable)
	local npcCopy = npc:Clone()
	npcCopy.Parent = workspace
	table.insert(livingNPCTable, {
		NPC = npcCopy,
		Moving = false,
		Destination = Vector3.new(math.random(0,100), 0, math.random(0,100))
	})
end

local function beginRound(npcCounts)
	local livingNPCTable = {}	
	local deadNPCTable = {}
	local npc = game.ServerStorage:FindFirstChild("NPC")
	for i = 1, #npcCounts do
		for j = 1, npcCounts[i] do
			initializeNPC(npc, livingNPCTable)
		end
	end
	
	--checkIfStuck(livingNPCTable)
	for i = 1, 20 do
		NPCMovement.FollowPath(livingNPCTable[i].NPC, livingNPCTable[i].Destination)
	end
	
end


local RoundStart = game.ServerScriptService.RoundController:FindFirstChild("RoundStart") 
local RoundStartConnection = RoundStart.Event:Connect(beginRound)
