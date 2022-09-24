local module = {}

module.__index = module
module.__metatable = 'Protected'

local bloodM = require(game:GetService('ServerStorage').Modules.Blood)

function module.new(plr, fModels)
	local tKnife = {}
	setmetatable(tKnife, module)
	
	tKnife.knife = fModels.Knife:Clone()
	tKnife.stun = tick()
	tKnife.deb = false
	
	tKnife.block = false
	tKnife.blockDeb = false
	
	local rArm = plr.Character['Right Arm']
	
	local weld = Instance.new('Weld', rArm)
	
	weld.Part0 = rArm
	weld.Part1 = tKnife.knife
	
	weld.C1 = CFrame.new(0, 1.5, .5)
	
	tKnife.knife.Parent = rArm
	
	return tKnife
end

function module.swing(plr, tKnife, plrs, repSt, serverSt, tweenS, collectionS, plrKnifes, final)
	local Knife = tKnife.knife
	
	local rayParams = RaycastParams.new() 
	rayParams.FilterDescendantsInstances = {plr.Character, Knife}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local rayResult = workspace:Raycast(plr.Character.HumanoidRootPart.Position, plr.Character.HumanoidRootPart.CFrame.lookVector * 5, rayParams)
	
	if rayResult then
		local hum = rayResult.Instance.Parent:FindFirstChild('Humanoid') or rayResult.Instance.Parent.Parent:FindFirstChild('Humanoid')
		
		if hum then
			if hum.Parent.Name == 'Dummy' then
				hum:TakeDamage(3)

				coroutine.wrap(function()
					for i = 1, 3 do
						bloodM.new(rayResult.Position, serverSt, collectionS)
					end
				end)()

			elseif hum.Parent.Name == 'Dummy' and final then
				hum:TakeDamage(5)
			
				coroutine.wrap(function()
					for i = 1, 3 do
						bloodM.new(rayResult.Position, serverSt, collectionS)
					end
				end)()

				local dummyHRP = hum.Parent.HumanoidRootPart

				local linearV = Instance.new('LinearVelocity', dummyHRP)

				linearV.Attachment0 = dummyHRP.RootAttachment
				linearV.VectorVelocity = -(dummyHRP.CFrame.lookVector * 20)
				linearV.MaxForce = math.huge

				task.wait(.5)
				linearV:Destroy()	
			else

				local char = hum.Parent

				local hrp = char.HumanoidRootPart
				local hHRP = plr.Character.HumanoidRootPart

				local plyr = plrs:GetPlayerFromCharacter(hum.Parent)

				if final then
					local damage = 5

					if plrKnifes[plyr].block then
						damage = 1
					end

					hum:TakeDamage(damage)

					coroutine.wrap(function()
						for i = 1, 3 do
							bloodM.new(rayResult.Position, serverSt, collectionS)
						end
					end)()

					repSt.Events.Damaged:FireClient(plyr, hHRP)

					local animator = hum:FindFirstChildOfClass("Animator")

					for i,v in ipairs(animator:GetPlayingAnimationTracks()) do
						if v.Name ~= 'Block' then continue end
						v:Stop()
					end

					local linearV = Instance.new('LinearVelocity', hrp)

					linearV.Attachment0 = hrp.RootAttachment
					linearV.VectorVelocity = -(hrp.CFrame.lookVector * 20)
					linearV.MaxForce = math.huge

					serverSt.BindableEvents.Stun:Fire(plyr, hum)

					task.wait(.5)
					linearV:Destroy()
				else
					local damage = 3

					if plrKnifes[plyr].block then
						damage = .5
					end

					hum:TakeDamage(damage)

					coroutine.wrap(function()
						for i = 1, 3 do
							bloodM.new(rayResult.Position, serverSt, collectionS)
						end
					end)()

					repSt.Events.Damaged:FireClient(plyr, hHRP, true)

					local animator = hum:FindFirstChildOfClass("Animator")
					for i,v in ipairs(animator:GetPlayingAnimationTracks()) do
						if v.Name ~= 'Block' then continue end
						v:Stop()
					end

					serverSt.BindableEvents.Stun:Fire(plyr, hum)
				end
			end
		end
	end
end
	
return module
