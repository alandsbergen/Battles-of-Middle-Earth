--Variables

math.randomseed(tick())
local isenInf = script.Parent 
local id = isenInf.ID
local isenInfHum = isenInf.Humanoid
local isenInfCopy = game.ServerStorage.IsengardInfantryman:Clone()
local tool = isenInf.Sword
local sword = tool.Handle
local bG = isenInf.HumanoidRootPart.BodyGyro
local siegeLadders = game.Workspace.SiegeLadders
local siegeLadderTable = {siegeLadders.SiegeLadder1, siegeLadders.SiegeLadder2, siegeLadders.SiegeLadder3, siegeLadders.SiegeLadder4, siegeLadders.SiegeLadder5, siegeLadders.SiegeLadder6, siegeLadders.SiegeLadder7, siegeLadders.SiegeLadder8, siegeLadders.SiegeLadder9, siegeLadders.SiegeLadder10, siegeLadders.SiegeLadder11, siegeLadders.SiegeLadder12, siegeLadders.SiegeLadder13, siegeLadders.SiegeLadder14}
local ladderDist = math.huge
local closestLadder = nil
local closestLadderStart = nil
local closestLadderEnd = nil
local waitingSpots = {}
local targetReached = false
local target2Reached = false
local shieldRaise = isenInfHum:LoadAnimation(isenInf.ShieldRaise)
local shieldHold = isenInfHum:LoadAnimation(isenInf.ShieldHold)
local preSwingRight = isenInfHum:LoadAnimation(isenInf.PreSwingRightOneHanded)
local holdingPSR = isenInfHum:LoadAnimation(isenInf.HoldingPSROH)
local swingRight = isenInfHum:LoadAnimation(isenInf.SwingRightOneHanded)
local preSwingDown = isenInfHum:LoadAnimation(isenInf.PreSwingDownOneHanded)
local holdingPSD = isenInfHum:LoadAnimation(isenInf.HoldingPSDOH)
local swingDown = isenInfHum:LoadAnimation(isenInf.SwingDownOneHanded)
local preSwingLeft = isenInfHum:LoadAnimation(isenInf.PreSwingLeftOneHanded)
local holdingPSL = isenInfHum:LoadAnimation(isenInf.HoldingPSLOH)
local swingLeft = isenInfHum:LoadAnimation(isenInf.SwingLeftOneHanded)
local preLunge = isenInfHum:LoadAnimation(isenInf.PreLungeOneHanded)
local holdingPLu = isenInfHum:LoadAnimation(isenInf.HoldingPLuOH)
local lunge = isenInfHum:LoadAnimation(isenInf.LungeOneHanded)
local debounce = true
local attByNPC = game.ServerStorage.AttackedByNPC
local attByPlayer = game.ReplicatedStorage.AttackedByPlayer
local target = nil
local cp = game.Workspace.CapturePoints.DeepingWall
local cpCaptured = cp.Captured
local movingToNextCP = false
local pathfindingService = game:GetService("PathfindingService")
local pathParams = {AgentHeight = 5, AgentRadius = 2}
local waypoints = {}

bG.CFrame = isenInf.HumanoidRootPart.CFrame

--Find closest ladder

for i = 1, #siegeLadderTable do
	local ladder = siegeLadderTable[i]
	local ladderStart = ladder.ClimbLadderStart
	local ladderEnd = ladder.ClimbLadderEnd
	if (ladder.PrimaryPart.Position - isenInf.Torso.Position).magnitude < ladderDist then
		ladderDist = (ladder.PrimaryPart.Position - isenInf.Torso.Position).magnitude
		closestLadder = ladder
		closestLadderStart = ladderStart
		closestLadderEnd = ladderEnd
		waitingSpots = {closestLadder["1"], closestLadder["2"], closestLadder["3"], closestLadder["4"], closestLadder["5"], closestLadder["5"], closestLadder["6"], closestLadder["7"], closestLadder["8"], closestLadder["9"]}
	end
end

--Move to ladder

while not targetReached do
	local dist = math.huge
	local waitingSpot = nil
	if closestLadderStart.Occupied.Value == true then
		repeat 
			for i,pWaitingSpot in pairs(waitingSpots) do
				if pWaitingSpot.Occupied.Value == false then
					if (pWaitingSpot.Position - closestLadderStart.Position).magnitude < dist then
						dist = (pWaitingSpot.Position - closestLadderStart.Position).magnitude
						waitingSpot = pWaitingSpot
						waitingSpot.Occupied.Value = true
						isenInfHum:MoveTo(waitingSpot.Position)
					end
				else
					isenInfHum:MoveTo(isenInf.Torso.Position)
					wait(1)
				end
			end
		until waitingSpot
	else
		isenInfHum:MoveTo(closestLadderStart.Position)
		isenInfHum.MoveToFinished:Connect(function()
			targetReached = true
			closestLadderStart.Occupied.Value = true
		end)
	end
	wait(0.1)
end

--Move up ladder

while not target2Reached do
	while closestLadder.NumberOfClimbers.Value ~= 0 do
		wait(0.25)
	end
	local waitingSpot = nil
	closestLadder.NumberOfClimbers.Value = closestLadder.NumberOfClimbers.Value + 1
	isenInfHum:MoveTo(closestLadderEnd.Position)
	local num = 10
	for i,pWaitingSpot in pairs(waitingSpots) do
		if pWaitingSpot.Occupied.Value == true then
			local waitingSpotNum = tonumber(pWaitingSpot.Name)
			if waitingSpotNum < 10 then
				num = waitingSpotNum
				closestLadder[tostring(waitingSpotNum)].Occupied.Value = false
			end
		else
			closestLadderStart.Occupied.Value = false
		end	
	end
	wait(1)
	closestLadder.NumberOfClimbers.Value = closestLadder.NumberOfClimbers.Value - 1
	isenInfHum.MoveToFinished:Connect(function()
		target2Reached = true
		local physicsService = game:GetService("PhysicsService")
		physicsService:SetPartCollisionGroup(isenInf.FakeHead, "IsengardNPCs"); physicsService:SetPartCollisionGroup(isenInf.HumanoidRootPart, "IsengardNPCs"); physicsService:SetPartCollisionGroup(isenInf["Left Arm"], "IsengardNPCs"); physicsService:SetPartCollisionGroup(isenInf["Left Leg"], "IsengardNPCs"); physicsService:SetPartCollisionGroup(isenInf["Right Arm"], "IsengardNPCs"); physicsService:SetPartCollisionGroup(isenInf["Right Leg"], "IsengardNPCs"); physicsService:SetPartCollisionGroup(isenInf.Torso, "IsengardNPCs")
	end)
	wait(0.25)
end

--Respawn (work in progress)

isenInfHum.Died:Connect(function()
	wait(2)
	script.Parent:Destroy()
	wait(30)
	isenInfCopy.Parent = game.Workspace
end)

--Look for enemy

local function targetFunction(pos)
	local dist = math.huge
	local humanoid = nil
	local torso = nil
	local chr = nil
	local plr = nil
	repeat
		wait(0.1)
		if cpCaptured.Value == 1 then
			return nil
		end
		local children = game.Workspace:GetChildren()
		for i,child in pairs(children) do
			humanoid = child:FindFirstChild("Humanoid")
			if humanoid and humanoid.Parent.Name ~= "IsengardInfantryman" and humanoid.Health > 1.1 then 		
				chr = humanoid.Parent
				plr = game.Players:GetPlayerFromCharacter(chr)
				if not plr then
					torso = child:FindFirstChild("Torso")
				elseif plr then
					if plr.Team.Name == "Rohirrim" then
						torso = child:FindFirstChild("Torso")
					end
				end
				if torso then
					if (torso.Position - isenInf.Torso.Position).magnitude < 25 then
						dist = (torso.Position - isenInf.Torso.Position).magnitude
						target = torso
					end
				end	
			end
		end
	until target
	return target
end

--Move to enemy

local movementFunction = coroutine.create(function()
	while true do
		if cpCaptured.Value == 1 then
			movingToNextCP = true
		end
		if target then
			target.Parent.Humanoid.Died:Connect(function()
				target = nil
			end)
		end
		if not target and not movingToNextCP then
			target = targetFunction(isenInf.Torso.Position)
		end
		if target and (isenInf.Torso.Position - target.Position).magnitude > 6 then
			local lV = target.CFrame.LookVector
			isenInfHum:MoveTo(target.Position + 6 * lV)
			bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
		elseif target and (isenInf.Torso.Position - target.Position).magnitude <= 6 then
			bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
		elseif not target and movingToNextCP then
			local function followPath()
				local destination = game.Workspace.Destination
				local path = pathfindingService:CreatePath(pathParams)
				path:ComputeAsync(isenInf.HumanoidRootPart.Position,destination.Position)
				waypoints = {}
				waypoints = path:GetWaypoints()
				for i,waypoint in pairs(waypoints) do
					if target then
						break
					end
					isenInfHum:MoveTo(waypoint.Position)
					isenInfHum.MoveToFinished:Wait()
				end
				if target and (isenInf.Torso.Position - target.Position).magnitude > 6 then
					local targetDied = false
					while not targetDied do
						target.Parent.Humanoid.Died:Connect(function()
							targetDied = true
							target = nil
						end)
						local lV = target.CFrame.LookVector
						if (isenInf.Torso.Position - target.Position).magnitude <= 6 then
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						else
							isenInfHum:MoveTo(target.Position + 6 * lV)
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						end
						wait(0.2)
					end
				end
				if (isenInf.HumanoidRootPart.Position - destination.Position).magnitude > 5 then
					followPath()
				else
					return true
				end
			end
			if not followPath() then
				followPath()
			end
			local function followPath2()
				local targetReached = false
				while not targetReached do
					if target then
						break
					end
					isenInfHum.MoveToFinished:Connect(function()
						targetReached = true
					end)
					isenInfHum:MoveTo(game.Workspace.One.Position)
					wait(0.2)
				end
				if target and not targetReached then
					local targetDied = false
					while not targetDied do
						target.Parent.Humanoid.Died:Connect(function()
							targetDied = true
							target = nil
						end)
						local lV = target.CFrame.LookVector
						if (isenInf.Torso.Position - target.Position).magnitude <= 6 then
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						else
							isenInfHum:MoveTo(target.Position + 6 * lV)
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						end
						wait(0.2)
					end
				end
				if (isenInf.HumanoidRootPart.Position - game.Workspace.One.Position).magnitude > 5 then
					followPath2()
				else
					return true
				end
			end
			if not followPath2() then
				followPath2()
			end
			local function followPath3()
				targetReached = false
				while not targetReached do
					if target then
						break
					end
					isenInfHum.MoveToFinished:Connect(function()
						targetReached = true
						target = nil
					end)
					isenInfHum:MoveTo(game.Workspace.Two.Position)
					wait(0.2)
				end
				if target and not targetReached then
					local targetDied = false
					while not targetDied do
						target.Parent.Humanoid.Died:Connect(function()
							targetDied = true
							target = nil
						end)
						local lV = target.CFrame.LookVector
						if (isenInf.Torso.Position - target.Position).magnitude <= 6 then
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						else
							isenInfHum:MoveTo(target.Position + 6 * lV)
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						end
						wait(0.2)
					end
				end
				if (isenInf.HumanoidRootPart.Position - game.Workspace.Two.Position).magnitude > 5 then
					followPath3()
				else
					return true
				end
			end
			if not followPath3() then
				followPath3()
			end
			local function followPath4()
				targetReached = false
				while not targetReached do
					if target then
						break
					end
					isenInfHum.MoveToFinished:Connect(function()
						targetReached = true
						movingToNextCP = false
					end)
					isenInfHum:MoveTo(game.Workspace.Three.Position)
					wait(0.2)
				end
				if target and not targetReached then
					local targetDied = false
					while not targetDied do
						target.Parent.Humanoid.Died:Connect(function()
							targetDied = true
							target = nil
						end)
						local lV = target.CFrame.LookVector
						if (isenInf.Torso.Position - target.Position).magnitude <= 6 then
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						else
							isenInfHum:MoveTo(target.Position + 6 * lV)
							bG.CFrame = CFrame.new(isenInf.PrimaryPart.Position, target.Position)
						end
						wait(0.2)
					end
				end
				if (isenInf.HumanoidRootPart.Position - game.Workspace.Three.Position).magnitude > 5 then
					followPath4()
				else
					return true
				end
			end
			if not followPath4() then
				followPath4()
			end
		end
	wait(0.1)
	end
end)

--Attacking

local combatFunction = coroutine.create(function()
	while true do
		if not shieldHold.IsPlaying then
			local x = math.random(50,100)
			wait(x/100)
			shieldRaise:Play()
			shieldRaise.Stopped:Connect(function()
			shieldHold:Play()
			end)
		end
		if target and (isenInf.PrimaryPart.Position - target.Position).magnitude < 7 then
			local x = math.random(80,330)
			wait(x/100)
			local y = math.random(1,4)
			if y == 1 then
				shieldHold:Stop()
				preSwingRight:Play()
				preSwingRight.Stopped:Wait()
				holdingPSR:Play()
				local z = math.random(0,50)
				wait(z/100)
				holdingPSR:Stop()
				swingRight:Play()
				tool.GripForward = Vector3.new(-0.005,0,1)		
				tool.GripPos = Vector3.new(0.005,0.009,-0.99)
				tool.GripRight = Vector3.new(-1,0.007,-0.005)
				tool.GripUp = Vector3.new(0.007,1,-0)
				wait(0.3)		
				tool.GripForward = Vector3.new(-1,0,0)
				tool.GripPos = Vector3.new(0,0,-1.5)
				tool.GripRight = Vector3.new(0,1,0)
				tool.GripUp = Vector3.new(0,0,1)
				swingRight.Stopped:Wait()
			elseif y == 2 then
				shieldHold:Stop()
				preSwingDown:Play()
				preSwingDown.Stopped:Wait()
				holdingPSD:Play()
				local z = math.random(0,50)
				wait(z/100)		
				holdingPSD:Stop()
				swingDown:Play()
				swingDown.Stopped:Wait()
			elseif y == 3 then
				shieldHold:Stop()
				preSwingLeft:Play()
				preSwingLeft.Stopped:Wait()
				holdingPSL:Play()	
				local z = math.random(0,50)
				wait(z/100)			
				holdingPSL:Stop()
				swingLeft:Play()
				wait(0.1)
				tool.GripForward = Vector3.new(-0.005,0,1)
				tool.GripPos = Vector3.new(0.005,0.009,-0.99)
				tool.GripRight = Vector3.new(-1,0.007,-0.005)
				tool.GripUp = Vector3.new(0.007,1,-0)
				wait(0.25)
				tool.GripForward = Vector3.new(-1,0,0)
				tool.GripPos = Vector3.new(0,0,-1.5)
				tool.GripRight = Vector3.new(0,1,0)
				tool.GripUp = Vector3.new(0,0,1)
				swingLeft.Stopped:Wait()
			elseif y == 4 then
				shieldHold:Stop()
				preLunge:Play()
				preLunge.Stopped:Wait()
				holdingPLu:Play()
				local z = math.random(0,50)
				wait(z/100)	
				holdingPLu:Stop()
				lunge:Play()
				wait(0.15)
				tool.GripForward = Vector3.new(0.784,0,0.621)
				tool.GripPos = Vector3.new(0.339,0,-1.382)
				tool.GripRight = Vector3.new(0,-1,0)
				tool.GripUp = Vector3.new(-0.621,0,0.784)
				wait(0.3525)		
				tool.GripForward = Vector3.new(-1,0,0)
				tool.GripPos = Vector3.new(0,0,-1.5)
				tool.GripRight = Vector3.new(0,1,0)
				tool.GripUp = Vector3.new(0,0,1)				
			end	
		end
	wait(0.1)
	end
end)

coroutine.resume(movementFunction)
coroutine.resume(combatFunction)

function hit(enemypart)
	
	--[[This first section runs a few checks: first to determine if what was hit is a part of another player and if debounce is set to true,
		and second to determine that the enemy player is not the player holding the weapon.]]
	
	local playerhum = tool.Parent.Humanoid
	local tracklist = playerhum:GetPlayingAnimationTracks()
	for i = 1, #tracklist do
		local track = tracklist[i]
		if track.Animation.Name == "SwingRightOneHanded"
		or track.Animation.Name == "SwingLeftOneHanded"
		or track.Animation.Name == "SwingDownOneHanded"
		or track.Animation.Name == "LungeOneHanded" then
			local playersService = game:GetService("Players")
			local enemyplayer = playersService:GetPlayerFromCharacter(enemypart.Parent)
			local playerhum = tool.Parent.Humanoid
			if not enemyplayer then
				local npcHum = enemypart.Parent:FindFirstChild("Humanoid")
				if npcHum then
					if debounce == false then
						return
					else
						debounce = false
						local tracklist = npcHum:GetPlayingAnimationTracks()
						for i,track in pairs(tracklist) do
							if enemypart.Parent.Name == "IsengardInfantryman" or ((track.Animation.Name == "ShieldRaise" 
								or track.Animation.Name == "ShieldHold") and enemypart.Name == "Shield") then
								wait(1)
								debounce = true
								return
							else
								npcHum:TakeDamage(30)
								attByNPC:Fire(isenInf, id.Value)
								wait(1)
								debounce = true
								return
							end
						end
					end
				else 
					wait(1)
					debounce = true
				end
			else
				local enemyhum = enemypart.Parent.Humanoid
				if enemyhum ~= playerhum then
					if debounce == false then
						return
					else
						debounce = false
						
		
		--[[Here we use a RemoteFunction to determine whether the enemy player is blocking or not. If the enemy isn't blocking, then the last 
			thing we check is whether the attacking player is using an attack animation.]]
		
						local getIfBlocking = game.ReplicatedStorage.GetIfBlocking
						local blocking = getIfBlocking:InvokeClient(enemyplayer)
						if blocking == true and enemypart.Name == "Shield" then
							wait(1)
							debounce = true
							return
						else
							enemyhum:TakeDamage(30)
							attByNPC:Fire(isenInf)
							wait(1)
							debounce = true
						end
					end
				else
					wait(1)
					debounce = true
				end
			end		
		end
	end
end

sword.Touched:Connect(hit)
attByNPC.Event:Connect(function(attacker, attackerIDValue)
	if target then
		if target.Parent.ID.Value ~= attackerIDValue and attacker.Name ~= "IsengardInfantryman" then
			target = attacker.Torso
		end
	else
		if attacker.Name ~= "IsengardInfantryman" then
			target = attacker.Torso
		end
	end
end)
attByPlayer.OnServerEvent:Connect(function(player,playerchr)
	if target then
		if target ~= playerchr and player.Team.Name ~= "Isengard" then
			target = playerchr.Torso
		end
	else
		if player.Team.Name ~= "Isengard" then
			target = playerchr.Torso
		end
	end
end)

--[[Miscellaneous Notes
	
	- Health drops to ~1.01 (i.e. not 0) when resetting character.

--]]