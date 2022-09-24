local module = {}

module.__index = module
module.__metatable = 'Protected'

function module.new(pos, serverSt, collectionS)
	coroutine.wrap(function()
		local bloodDrip = serverSt.Models.BloodDrip:Clone()
		bloodDrip.Parent = workspace
		bloodDrip.Position = pos

		collectionS:AddTag(bloodDrip, 'Blood') --Vector3.new(math.random(-35,35), math.random(0,65), math.random(-35,35))  --linearVel.VectorVelocity = Vector3.new(randomNums[math.random(1, #randomNums)], -10, randomNums[math.random(1, #randomNums)])

		local linearVel = Instance.new('LinearVelocity', bloodDrip); linearVel.Attachment0 = bloodDrip.Attachment; linearVel.VectorVelocity = Vector3.new(math.random(-35,35), math.random(0,65), math.random(-35,35)); linearVel.MaxForce = math.huge

		task.wait(.5)

		linearVel:Destroy()
	end)()
end

return module
