--//Services
local serverStorage = game:GetService('ServerStorage')
local players = game:GetService('Players')
local repStorage = game:GetService('ReplicatedStorage')
local tweenS = game:GetService('TweenService')
local debris = game:GetService('Debris')
local collectionService = game:GetService('CollectionService')

--//Server Storage
--/Modules
local mKnife = require(serverStorage.Modules.Knife)

--/Models
local fModels = serverStorage.Models

--//Bindable Events
local eStun = serverStorage.BindableEvents.Stun

--//Replicated Storage
--/Events
local event = repStorage.Events.Event

--/Gui's
local damageBar = repStorage.Guis.DamageTookGui

--//Tables
local plrKnifes = {}

--//Collection Service
local connections = {}

local bloodTable = table.create(3)

for _, blood in ipairs(serverStorage.Models.Blood:GetChildren()) do
	table.insert(bloodTable, blood)
end

local function bloodAdded(bloodParticle)
	connections[bloodParticle] = game:GetService('RunService').Heartbeat:Connect(function()
		local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Blacklist; rayParams.FilterDescendantsInstances = {bloodParticle}

		local ray = workspace:Raycast(bloodParticle.Position, Vector3.new(0, -1, 0), rayParams)

		if ray then
			if ray.Instance.Parent:FindFirstChild('Humanoid') == nil and ray.Instance.Parent.Parent:FindFirstChild('Humanoid') == nil then
				bloodParticle:Destroy()

				local bloodImage = bloodTable[math.random(1, #bloodTable)]:Clone()

				bloodImage.Parent = workspace
				bloodImage.Position = ray.Position
				coroutine.wrap(function()
					task.wait(10)
					bloodImage:Destroy()
				end)()
			end
		end
	end)
end


local function onInstanceRemoved(object)
	if connections[object] then
		connections[object]:disconnect()
		connections[object] = nil
	end
end

collectionService:GetInstanceAddedSignal('Blood'):Connect(bloodAdded)
collectionService:GetInstanceRemovedSignal('Blood'):Connect(onInstanceRemoved)

--//Players thing

local function HPChanged(HP, hum ,humHP, char)
	local dmg = math.floor(HP - humHP)

	local damageGui = damageBar:Clone()
	damageGui.TextLabel.Text = dmg
	damageGui.Parent = char.HumanoidRootPart

	task.wait(.3)

	local tInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

	local upTween = tweenS:Create(damageGui, tInfo, {StudsOffset = damageGui.StudsOffset + Vector3.new(0, 1, 0)}):Play()
	local textFade = tweenS:Create(damageGui.TextLabel, tInfo, {TextTransparency = 1}):Play()

	debris:AddItem(damageGui, 2)
end

players.PlayerAdded:Connect(function(plr)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local hum = char:WaitForChild('Humanoid')
	local humHP = hum.Health
	
	local knifie =  mKnife.new(plr, fModels)
	plrKnifes[plr] = knifie
	
	hum.HealthChanged:Connect(function(HP)
		HPChanged(HP, hum, humHP, char)

		humHP = hum.Health
	end)
	
	plr.CharacterAdded:Connect(function(character)
		local huma = character:WaitForChild('Humanoid')
		local humaHP = huma.Health
		
		huma.HealthChanged:Connect(function(HP)
			HPChanged(HP, huma, humaHP, character)
			
			humHP = huma.Health
		end)
		
		--//New knife for plr
		local plyr = players:GetPlayerFromCharacter(character)
		
		plrKnifes[plyr] = nil
		
		local knifie =  mKnife.new(plr, fModels)
		plrKnifes[plyr] = knifie
	end)
end)

players.PlayerRemoving:Connect(function(plr)
	plrKnifes[plr] = nil
end)

--//Other Events

event.OnServerEvent:Connect(function(plr, name, ...)
	if name == 'stab' then
		local Knife = plrKnifes[plr]
		
		if Knife.deb == false then
			Knife.deb = true
			
			local waitTime = .2
			if ... then waitTime = 1.9 end
			
			Knife.swing(plr, Knife, players, repStorage, serverStorage, tweenS, collectionService, plrKnifes, ...)
			
			task.wait(waitTime)
			Knife.deb = false
		end
	elseif name == 'block' then
		local knife = plrKnifes[plr]
		
		if ... and knife.blockDeb == false then
			knife.block = true
		else
			knife.blockDeb = true
			
			plrKnifes[plr].block = false
			
			task.wait(.5)
			
			knife.blockDeb = false
		end
	end
end)

eStun.Event:Connect(function(plr, hum)
	plrKnifes[plr].stun = tick()
	
	hum.WalkSpeed = 0
	hum.JumpPower = 0

	task.wait(.5)
	if (tick() - plrKnifes[plr].stun) > .5 then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
	end
end)
