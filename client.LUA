--//Player Vars
local plr = game:GetService('Players').LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild('Humanoid')
local hrp = char:WaitForChild('HumanoidRootPart')

--//Services
local uis = game:GetService('UserInputService')
local repStorage = game:GetService('ReplicatedStorage')
local tweenS = game:GetService('TweenService')
local debris = game:GetService('Debris')
local repFirst = game:GetService('ReplicatedFirst')

--//Events
local events = table.create(2)

for _, event in ipairs(repStorage.Events:GetChildren()) do
	events[event.Name] = event
end

--//Animations
local anims = table.create(5)

for _, track in ipairs(repFirst.Animations:GetChildren()) do
	local anim = hum:LoadAnimation(track)
	
	table.insert(anims, anim)
end

--//Tweens
local function slashTween(num)
	local slash = repStorage.Models.Slash:Clone()

	slash.CFrame = hrp.CFrame
	slash.Parent = hrp
	
	if num == 1 then
		tweenS:Create(slash, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = slash.CFrame * CFrame.Angles(0, math.rad(-90), 0), Transparency = 1}):Play()
	elseif num == 2 then
		slash.Rotation = Vector3.new(0, -120, 0)
		
		tweenS:Create(slash, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = slash.CFrame * CFrame.Angles(0, math.rad(90), 0), Transparency = 1}):Play()
	elseif num == 3 then
		slash:Destroy()
	end
	
	coroutine.wrap(function()
		task.wait(.5)
		slash:Destroy()
	end)()
end

--//Guis
local damageBar = repStorage.Guis.DamageTookGui

--//User Input
local mouseB1 = Enum.UserInputType.MouseButton1
local buttonF = Enum.KeyCode.F

--/Combat
local combo = 1
local comboR = tick()

local waitTime = .3
local deb = false

local blockDeb = false

uis.InputBegan:Connect(function(input)
	if input.UserInputType == mouseB1 and deb == false and hum.WalkSpeed ~= 0 then
		deb = true
		
		if (tick() - comboR) > 1 then combo = 1	end
		
		comboR = tick()
		
		if combo == 3 then
			events.Event:FireServer('stab', true)
			waitTime = 2
		else
			events.Event:FireServer('stab')
			waitTime = .3
		end
		
		slashTween(combo)
		
		anims[combo]:Play()
		anims[combo]:AdjustSpeed(1.6)
		combo += 1

		if combo == 4 then
			combo = 1
		end

		for i = 1, 5 do
			task.wait()
			local xOffset = math.random(-100, 100) / 500
			local yOffset = math.random(-100, 100) / 500

			hum.CameraOffset = Vector3.new(xOffset, yOffset, 0)
		end

		hum.CameraOffset = Vector3.new(0, 0, 0)
		
		task.wait(waitTime)
		deb = false
	end 
	
	if input.KeyCode == buttonF and blockDeb == false and hum.WalkSpeed ~= 0 then
		
		events.Event:FireServer('block', true)
		
		anims[5]:Play()
	end
end)

uis.InputEnded:Connect(function(input)
	if input.KeyCode == buttonF  and blockDeb == false then	
		blockDeb = true
		
		events.Event:FireServer('block')
		anims[5]:Stop()
		
		
		task.wait(.6)
		blockDeb = false
		print('unlocked')
	end
end)

--//Events
events.Damaged.OnClientEvent:Connect(function(hHRP, rotate)
	if rotate then tweenS:Create(hrp, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(hrp.Position, hHRP.Position)}):Play() end 
	
	anims[4]:Play()
		
	for i = 1, 5 do
		task.wait()
		local xOffset = math.random(-100, 100) / 500
		local yOffset = math.random(-100, 100) / 500

		hum.CameraOffset = Vector3.new(xOffset, yOffset, 0)
	end
end)
