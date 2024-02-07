local G = getgenv()
G.Key = "SAaRlAiS_aBhImRaAdHG2"

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RobSilas/lds-hub/main/library.txt"))()

local window = lib:start("Pet Simulator 99", "1.0 Global", true)

local tabMachines = window:addTab("Machines")

local lplr = game:GetService("Players").LocalPlayer

local SaveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save)
local SaveFile = SaveModule.Get(lplr)
local PetInventory = SaveFile.Inventory.Pet

local petIdsAll = {}
local petIdsNormal = {}
local petIdsGolden = {}

local function findID(namePet)
	for petName, petData in pairs(PetInventory) do
		if namePet == petData.id then
			local Vrs = (petData.pt == 1 and "Golden ") or (petData.pt == 2 and "Rainbow ") or "Normal"
			if Vrs == "Normal" and petData._am and petData._am >= 10 then
				return petName
			end
		end
	end
end

local function findAmount(namePet)
	for petName, petData in pairs(PetInventory) do
		if namePet == petData.id then
			local Vrs = (petData.pt == 1 and "Golden ") or (petData.pt == 2 and "Rainbow ") or "Normal"
			if Vrs == "Normal" and petData._am and petData._am >= 10 then
				return petData._am
			end
		end
	end
end

local function NearMachine(Modo)
	local Machine = nil

	local machinePaths = {
		"10 | Mine",
		"31 | Desert Pyramids"
	}

	local player = game.Players.LocalPlayer
	local playerChar = player.Character

	if playerChar then
		for _, path in pairs(machinePaths) do
			local machine = workspace.Map:FindFirstChild(path)

			if machine then
				local machineInstance = nil

				if Modo == "Both" then
					
					for _, child in pairs(machine.INTERACT.Machines:GetChildren()) do
						if child:IsA("Model") then
							machineInstance = child
							break
						end
					end
				elseif Modo == "Golden" then
					machineInstance = machine.INTERACT.Machines:FindFirstChild("GoldMachine")
				elseif Modo == "Rainbow" then
					machineInstance = machine.INTERACT.Machines:FindFirstChild("RainbowMachine")
				end

				if machineInstance and machineInstance:IsA("Model") then
					local pad = machineInstance:FindFirstChild("Pad")
					if pad then
						local playerPos = playerChar:FindFirstChild("HumanoidRootPart").Position
						local machinePos = pad.Position

						if playerPos and machinePos and (playerPos - machinePos).magnitude < 100 then
							Machine = machineInstance
							break
						end
					end
				end
			end
		end
	end

	return Machine
end

local function activateMachine(machineType, args)
	local RemoteMachines = {
		Golden = game:GetService("ReplicatedStorage").Network.GoldMachine_Activate,
		Rainbow = game:GetService("ReplicatedStorage").Network.RainbowMachine_Activate
	}

	local machineFunction = RemoteMachines[machineType]
	if machineFunction then
		machineFunction:InvokeServer(unpack(args))
	end
end

for petName, petData in pairs(PetInventory) do
	local Vrs = (petData.pt == 1 and "Golden ") or (petData.pt == 2 and "Rainbow ") or "Normal"
	if Vrs == "Normal" or Vrs == "Golden" and petData._am and petData._am >= 10 then
		table.insert(petIdsAll, petData.id)
	end
end

for petName, petData in pairs(PetInventory) do
	local Vrs = (petData.pt == 1 and "Golden ") or (petData.pt == 2 and "Rainbow ") or "Normal"
	if Vrs == "Normal" and petData._am and petData._am >= 10 then
		table.insert(petIdsNormal, petData.id)
	end
end

for petName, petData in pairs(PetInventory) do
	if petData.pt == 1 and "Golden " and petData._am and petData._am >= 10 then
		table.insert(petIdsGolden, petData.id)
	end
end

local SelectModeMachines = tabMachines:addCombo("Select Mode", "", {"Both", "Rainbow", "Golden"})

local PetVSCC = petIdsAll
G.Settings["Machines"] = true

task.spawn(function()
	while G.Settings["Machines"] do
		wait()
		local Mode = SelectModeMachines:getValue()
		if Mode then
			if Mode == "Rainbow" then
				PetVSCC = petIdsGolden
			elseif Mode == "Golden" then
				PetVSCC = petIdsNormal
			else
				PetVSCC = petIdsAll
			end
		end
	end
end)

local ComboMachine = tabMachines:addMultiCombo("Select Pet", "", PetVSCC)

tabMachines:addToggle("Use Pet Selected", "z","small", false, function(value) 
end)

tabMachines:addToggle("Use All Pets", "z","small", false, function(value) 
end)

tabMachines:addToggle("Auto Teleport to Machine", "z","small", false, function(value) 
	while G.Settings["Auto Teleport to Machine"] do
		wait()
		local Mode = SelectModeMachines:getValue()
		print(Mode)
		local remotes = game.ReplicatedStorage.Network
		local teleportr = remotes.Teleports_RequestTeleport
		local hum = game.Players.LocalPlayer.Character.Humanoid

		local function teleport(destination)
			teleportr:InvokeServer(destination)
			
			repeat task.wait() until hum.FloorMaterial == Enum.Material.Air
			task.wait(0.5)
			repeat task.wait() until hum.FloorMaterial == Enum.Material.Plastic
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			task.wait(1)
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	
	if Mode == "Rainbow" then
		teleport("Desert Pyrmids")
	elseif Mode == "Golden" then
		teleport("Mine")
	end
	
	end
end)

tabMachines:addToggle("Auto Machine", "z","big", false, function(value) 

	local function processPets(pets, Mode)
		for _, pet in pairs(pets) do
			local amountPet = findAmount(pet)
			local petID = findID(pet)

			if amountPet then
				local args = {
					[1] = petID,
					[2] = math.floor(amountPet / 10)
				}

				if Mode == "Both" then
					local nearMachine = NearMachine(Mode)

					if nearMachine then
						activateMachine(nearMachine.Name, args)
					end
				elseif Mode == "Rainbow" or Mode == "Golden" then
					activateMachine(Mode, args)
				end
			end
			wait(2.5)
		end
	end

	while G.Settings["Auto Machine"] do
		wait()
		local Mode = SelectModeMachines:getValue()

		if G.Settings["Use All Pets"] then
			if not G.Settings["Use Pet Selected"] then
				local pets = petIdsNormal
				processPets(pets, Mode)
				petIdsNormal = {}
			else
				G.Settings["Use Pet Selected"] = false
			end
		end

		if G.Settings["Use Pet Selected"] then
			if not G.Settings["Use All Pets"] then
				local PetsSelected = ComboMachine:getValue()
				processPets(PetsSelected, Mode)
			else
				G.Settings["Use All Pets"] = false
			end
		end
	end


end)

