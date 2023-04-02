--Variables

math.randomseed(tick())
local rohInf = script.Parent 
local id = rohInf.ID
local rohInfHum = rohInf.Humanoid
local tool = rohInf.Sword
local sword = tool.Handle
local bG = rohInf.HumanoidRootPart.BodyGyro
local preSwingRight = rohInfHum:LoadAnimation(rohInf.PreSwingRightOneHanded)
local holdingPSR = rohInfHum:LoadAnimation(rohInf.HoldingPSROH)
local swingRight = rohInfHum:LoadAnimation(rohInf.SwingRightOneHanded)
local preSwingDown = rohInfHum:LoadAnimation(rohInf.PreSwingDownOneHanded)
local holdingPSD = rohInfHum:LoadAnimation(rohInf.HoldingPSDOH)
local swingDown = rohInfHum:LoadAnimation(rohInf.SwingDownOneHanded)
local preSwingLeft = rohInfHum:LoadAnimation(rohInf.PreSwingLeftOneHanded)
local holdingPSL = rohInfHum:LoadAnimation(rohInf.HoldingPSLOH)
local swingLeft = rohInfHum:LoadAnimation(rohInf.SwingLeftOneHanded)
local preLunge = rohInfHum:LoadAnimation(rohInf.PreLungeOneHanded)
local holdingPLu = rohInfHum:LoadAnimation(rohInf.HoldingPLuOH)
local lunge = rohInfHum:LoadAnimation(rohInf.LungeOneHanded)
local shieldRaise = rohInfHum:LoadAnimation(rohInf.ShieldRaise)
local shieldHold = rohInfHum:LoadAnimation(rohInf.ShieldHold)
local blockFunctionPlaying = false
local attackFunctionPlaying = false
local target = nil
local debounce = true
local attByNPC = game.ServerStorage.AttackedByNPC
local attByPlayer = game.ReplicatedStorage.AttackedByPlayer
local deepingWallCaptured = game.Workspace.CapturePoints.DeepingWall.Captured
local hornburgCaptured = game.Workspace.CapturePoints.Hornburg.Captured

bG.CFrame = rohInf.HumanoidRootPart.CFrame

--Respawn

rohInfHum.Died:Connect(function()
	wait(2)
	script.Parent:Destroy()
	wait(30)
	local rohInfCopy = game.ServerStorage.RohirrimInfantryman:Clone()
	if deepingWallCaptured.Value == 1 and hornburgCaptured.Value == 0 then
		rohInfCopy.RohirrimInfantrymanScript1:Destroy()
		--do stuff
	end
	rohInfCopy.Parent = game.Workspace
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
		local children = game.Workspace:GetChildren()
		for i,child in pairs(children) do
			humanoid = child:FindFirstChild("Humanoid")
			if humanoid and humanoid.Parent.Name ~= "RohirrimInfantryman" and humanoid.Health > 1.1 then 		
				chr = humanoid.Parent
				plr = game.Players:GetPlayerFromCharacter(chr)
				if not plr then
					torso = child:FindFirstChild("Torso")
				elseif plr then
					if plr.Team.Name == "Isengard" then
						torso = child:FindFirstChild("Torso")
					end
				end
				if torso then
					local rLeg = child:FindFirstChild("Right Leg")
					if (rLeg.Position.X <= -25.9 and rLeg.Position.X >= -67.8 and rLeg.Position.Y >= 50.9 and rLeg.Position.Y <= 56 and rLeg.Position.Z <= -70.4 and rLeg.Position.Z >= -159.4) or (rLeg.Position.X <= -8.2 and rLeg.Position.X > -25.9 and rLeg.Position.Y >= 50.9 and rLeg.Position.Y <= 56 and rLeg.Position.Z > -70.4 and rLeg.Position.Z <= 25.8) or (rLeg.Position.X < -8.2 and rLeg.Position.X >= -37.5 and rLeg.Position.Y >= 50.9 and rLeg.Position.Y <= 56 and rLeg.Position.Z > 25.8 and rLeg.Position.Z <= 124.4) or (rLeg.Position.X <= -25.1 and rLeg.Position.X >= -77.6 and rLeg.Position.Y >= 50.9 and rLeg.Position.Y <= 56 and rLeg.Position.Z > 124.4 and rLeg.Position.Z <= 234.6) or (rLeg.Position.X <= -73.4 and rLeg.Position.X >= -92.4 and rLeg.Position.Y >= 50.9 and rLeg.Position.Y <= 58.4 and rLeg.Position.Z >= 209.5 and rLeg.Position.Z <= 231.1) or (rLeg.Position.X <= - 75.7 and rLeg.Position.X >= -91.4 and rLeg.Position.Y >= 38.4 and rLeg.Position.Y <= 51 and rLeg.Position.Z > 209.4 and rLeg.Position.Z <= 230) 
						and (torso.Position - rohInf.Torso.Position).magnitude <= 25 then
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
		if target then
			target.Parent.Humanoid.Died:Connect(function()
				target = nil
			end)
		end
		if not target then
			target = targetFunction(rohInf.Torso.Position)
		end
		if target and (rohInf.Torso.Position - target.Position).magnitude > 6 then
			local lV = target.CFrame.LookVector
			rohInfHum:MoveTo(target.Position + 6 * lV)
			bG.CFrame = CFrame.new(rohInf.PrimaryPart.Position, target.Position)
		elseif target and (rohInf.Torso.Position - target.Position).magnitude <= 6 then
			bG.CFrame = CFrame.new(rohInf.PrimaryPart.Position, target.Position)
		end
	wait(0.5)
	end
end)

--Attacking

local combatFunction = coroutine.create(function()
	while true do
		wait(0.1)
		if not shieldHold.IsPlaying then
			local x = math.random(50,100)
			wait(x/100)
			shieldRaise:Play()
			shieldRaise.Stopped:Connect(function()
			shieldHold:Play()
			end)
		end
		if target and (rohInf.PrimaryPart.Position - target.Position).magnitude < 7 then
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
							if enemypart.Parent.Name == "RohirrimInfantryman" or ((track.Animation.Name == "ShieldRaise" or track.Animation.Name == "ShieldHold") and enemypart.Name == "Shield") then
								wait(1)
								debounce = true
								return
							else
								npcHum:TakeDamage(30)
								attByNPC:Fire(rohInf, id.Value)
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
		if target.Parent.ID.Value ~= attackerIDValue and attacker.Name ~= "RohirrimInfantryman" then
			target = attacker.Torso
		end
	else
		if attacker.Name ~= "RohirrimInfantryman" then
			target = attacker.Torso
		end
	end
end)
attByPlayer.OnServerEvent:Connect(function(player,playerchr)
	if target then
		if target ~= playerchr and player.Team.Name ~= "Rohirrim" then
			target = playerchr.Torso
		end
	else
		if player.Team.Name ~= "Rohirrim" then
			target = playerchr.Torso
		end
	end
end)

--[[Miscellaneous Notes]]--

--[[
	
	- Health drops to ~1.01 (i.e. not 0) when resetting character.

--]]

