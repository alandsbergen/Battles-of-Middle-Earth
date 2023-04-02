local Unit = {}
Unit.__index = Unit

-- variables for storing animation tracks when loaded onto the humanoid after spawning the unit instance
local shieldRaise
local shieldHold
local preSwingRight1H
local holdingPreSwingRight1H
local swingRight1H
local preSwingDown1H
local holdingPreSwingDown1H
local swingDown1H
local preSwingLeft1H
local holdingPreSwingLeft1H
local swingLeft1H
local preLunge1H
local holdingPreLunge1H
local lunge1H

function Unit.new(instance)
	local newUnit = {}
	setmetatable(newUnit, Unit)
	
	newUnit.Instance = instance:Clone()
	newUnit.Name = instance.Name
	newUnit.Faction = instance.UnitInfo.Faction.Value
	newUnit.Class = instance.UnitInfo.Class.Value
	newUnit.Subclass = instance.UnitInfo.Subclass.Value
	newUnit.PrimaryWeapon = instance.UnitInfo.PrimaryWeapon.Value
	newUnit.SecondaryWeapon = instance.UnitInfo.SecondaryWeapon.Value
	newUnit.Shield = instance.UnitInfo.Shield.Value
	newUnit.OffensiveSkill = instance.UnitInfo.OffensiveSkill.Value
	newUnit.DefensiveSkill = instance.UnitInfo.DefensiveSkill.Value
	newUnit.Orders = "HOLD" --would prefer an enum here
	newUnit.Target = nil
	--newUnit.TargetIsPlayer = false --this value can only be trusted if target is non-nil
	
	--UnitInfo folder is no longer needed, as the data is now stored in the Unit object 
	--***MAY WANT TO CHANGE***
	newUnit.Instance.UnitInfo:Destroy() 
	
	return newUnit
end

function Unit:SetPosition(position)
	self.Instance:SetPrimaryPartCFrame(CFrame.new(position))
end

function Unit:GetPosition()
	return self.Instance.PrimaryPart.Position
end

function Unit:Spawn(position)
	if position then
		self.Instance:SetPrimaryPartCFrame(CFrame.new(position))
	end
	self.Instance.Parent = game.Workspace
	
	--load animations on the humanoid (unsure if this is necessary to do each time Unit.new is called, but we'll see)
	local humanoid = self.Instance.Humanoid
	local animations = game.ServerStorage.Animations
	shieldRaise = humanoid:LoadAnimation(animations.ShieldRaise)
	shieldHold = humanoid:LoadAnimation(animations.ShieldHold)
	preSwingRight1H = humanoid:LoadAnimation(animations.PreSwingRight1H)
	holdingPreSwingRight1H = humanoid:LoadAnimation(animations.HoldingPreSwingRight1H)
	swingRight1H = humanoid:LoadAnimation(animations.SwingRight1H)
	preSwingDown1H = humanoid:LoadAnimation(animations.PreSwingDown1H)
	holdingPreSwingDown1H = humanoid:LoadAnimation(animations.HoldingPreSwingDown1H)
	swingDown1H = humanoid:LoadAnimation(animations.SwingDown1H)
	preSwingLeft1H = humanoid:LoadAnimation(animations.PreSwingLeft1H)
	holdingPreSwingLeft1H = humanoid:LoadAnimation(animations.HoldingPreSwingLeft1H)
	swingLeft1H = humanoid:LoadAnimation(animations.SwingLeft1H)
	preLunge1H = humanoid:LoadAnimation(animations.PreLunge1H)
	holdingPreLunge1H = humanoid:LoadAnimation(animations.HoldingPreLunge1H)
	lunge1H = humanoid:LoadAnimation(animations.Lunge1H)
end

function Unit:ChangeOrders(order)
	self.Orders = order
end

--@param tableOfUnits a table of all units currently in the game, non-nil
function Unit:FindTarget(tableOfUnits)
	local dist = math.huge
	local target = nil
	local children = game.Workspace:GetChildren()
	for i,player in pairs(game.Players:GetChildren()) do
		local chr = player.LocalPlayer:FindFirstChild("Character")
		if chr then
			if (self.Faction.Value ~= player.Team.Name) and (chr.Humanoid.Health ~= 0) and (self.Instance.Torso.Position - chr.Torso.Position).magnitude < dist then
				dist = (self.Instance.Torso.Position - chr.Torso.Position).magnitude
				target = chr
			end
		end
	end
	for i,npc in pairs(tableOfUnits) do
		if (npc ~= self) and (self.Faction ~= npc.Faction) and (npc.Instance.Humanoid.Health ~= 0) and (self.Instance.Torso.Position - npc.Instance.Torso.Position).magnitude < dist then
			dist = (self.Instance.Torso.Position - npc.Instance.Torso.Position).magnitude
			target = npc.Instance
		end
	end
	self.Target = target
	return target
end

-- @param target an Instance
function Unit:MoveTo(target)
	if not target then
		return false
	else
		if (self:GetPosition() - target.PrimaryPart.Position).magnitude > 6 then --this is fine for now but eventually we want to use the pathfinding service for greater distances
			self.Instance.Humanoid:MoveTo(target.PrimaryPart.Position + 6 * target.PrimaryPart.CFrame.LookVector)
			self.Instance.HumanoidRootPart.BodyGyro.CFrame = CFrame.new(self.Instance.PrimaryPart.Position, target.PrimaryPart.Position)
		else
			self.Instance.HumanoidRootPart.BodyGyro.CFrame = CFrame.new(self.Instance.PrimaryPart.Position, target.PrimaryPart.Position)
		end
	end
	return true
end

function Unit:Attack()
	local tool = self.Instance.Weapon
	print(tool.GripForward)
	local attackChoice = math.random(1,4)
	if attackChoice == 1 then
		shieldHold:Stop()
		preSwingRight1H:Play()
		preSwingRight1H.Stopped:Wait()
		holdingPreSwingRight1H:Play()
		wait(math.random(0,50)/100)
		holdingPreSwingRight1H:Stop()
		swingRight1H:Play()
		tool.GripForward = Vector3.new(-0.005,0,1)		
		tool.GripPos = Vector3.new(0.005,0.009,-0.99)
		tool.GripRight = Vector3.new(-1,0.007,-0.005)
		tool.GripUp = Vector3.new(0.007,1,-0)
		wait(0.3)		
		tool.GripForward = Vector3.new(-1,0,0)
		tool.GripPos = Vector3.new(0,0,-1.5)
		tool.GripRight = Vector3.new(0,1,0)
		tool.GripUp = Vector3.new(0,0,1)
		swingRight1H.Stopped:Wait()
	elseif attackChoice == 2 then
		shieldHold:Stop()
		preSwingDown1H:Play()
		preSwingDown1H.Stopped:Wait()
		holdingPreSwingDown1H:Play()
		wait(math.random(0,50)/100)		
		holdingPreSwingDown1H:Stop()
		swingDown1H:Play()
		swingDown1H.Stopped:Wait()
	elseif attackChoice == 3 then
		shieldHold:Stop()
		preSwingLeft1H:Play()
		preSwingLeft1H.Stopped:Wait()
		holdingPreSwingLeft1H:Play()	
		wait(math.random(0,50)/100)			
		holdingPreSwingLeft1H:Stop()
		swingLeft1H:Play()
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
		swingLeft1H.Stopped:Wait()
	elseif attackChoice == 4 then
		shieldHold:Stop()
		preLunge1H:Play()
		preLunge1H.Stopped:Wait()
		holdingPreLunge1H:Play()
		wait(math.random(0,50)/100)	
		holdingPreLunge1H:Stop()
		lunge1H:Play()
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

function Unit:Defend()
	if not shieldHold.IsPlaying then
		shieldRaise:Play()
		shieldRaise.Stopped:Connect(function()
			shieldHold:Play()
		end)
		wait(0.2 * math.random(50,100))
		shieldHold:Stop()
	end
end

-- @param target an Instance
function Unit:Engage(target)
	while target and target.Humanoid.Health > 0 do --remember that resetting used to reduce health to not exactly 0; should test if this still presents a problem
		print("test")
		self:MoveTo(target) --probably can omit for NPC vs. NPC case, but let's test to make sure
		if math.random(1,self.OffensiveSkill) > 0 then
			self:Attack()
		elseif math.random(1,self.DefensiveSkill) > 50 then
			self:Defend()
		end
		wait(0.05 * math.random(3,5)) --wait is used to reduce lag; slightly randomized wait time is used to make fighting look less robotic
	end
end

return Unit
