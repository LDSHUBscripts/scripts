local G = getgenv()
G.Key = "SAaRlAiS_aBhImRaAdHG2"

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RobSilas/lds-hub/main/library.txt"))()

local window = lib:start("Arm Wrestle Simulator", "2.0", true)

local tabEvent = window:addTab("Event")
local tabTrain = window:addTab("Auto Train")
local tabBoss = window:addTab("Auto Boss")
local tabEggs = window:addTab("Auto Egg")
local tabMachines = window:addTab("Machines")

local Pl = game.Players.LocalPlayer
local Char = Pl.Character or Pl:WaitForChild("Character")

local function TeleportTo(Cords)
	Char:SetPrimaryPartCFrame(Cords * CFrame.new(0, 0, 5))
end

local ComboEventWorld= tabEvent:addCombo("Select World", "", {"Summer", "Pirate", "Waterpark"})

local function SaveBestDumbellEvent()
	local player = game.Players.LocalPlayer
	if player.Character then
		local character = player.Character
		if character:FindFirstChildWhichIsA("Tool") then
			return true
		end
	end
	return false
end

local function FindBestTierEvent()
	local SelectedWorld = ComboEventWorld:getValue()

	local PunchBags = nil
	for _, zone in pairs(workspace.Zones:GetChildren()) do
		if string.find(zone.Name, SelectedWorld) then
			PunchBags = zone.Interactables.Training.PunchBags
			break
		end
	end

	for i = 6, 1, -1 do
		local Punchs = PunchBags:FindFirstChild("Tier" .. i)
		if Punchs then
			local StrengthReq = Punchs:GetAttribute("StrengthRequired")
			local StrengthPlr = Pl:GetAttribute("TotalSummerKnuckles")
			if math.round(StrengthPlr) > math.round(StrengthReq) then
				return Punchs
			end
		end
	end

	return nil
end

local function FindBestToolEvent(Type)
	game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onUnequipRequest:FireServer()
	local Vip = Pl:GetAttribute("VIP")
	local SelectedWorld = ComboEventWorld:getValue()

	if Type == "Knucles" then
		local Tier = FindBestTierEvent()
		if Tier then
			local punchBagName = Vip and "VIP" or Tier
			wait(5)
			TeleportTo(workspace.Zones[SelectedWorld].Interactables.Training.PunchBags[punchBagName].Primary.CFrame)

			while G.Settings["Auto Train Event (Selected)"] do
				local args = {
					[1] = SelectedWorld,
					[2] = Vip and "VIP" or Tier,
					[3] = not Vip
				}
				game:GetService("ReplicatedStorage").Packages.Knit.Services.PunchBagService.RE.onGiveStats:FireServer(unpack(args))
				wait()
			end
		end
	else
		local toolsFolder = game:GetService("ReplicatedStorage").Tools[Type]
		local Request = (Type == "Dumbells" or Type == "Grips") and "onGuiEquipRequest" or "onEquipRequest"
		local NumberRequest = nil; if Type == "Dumbells" or Type == "Grips" then NumberRequest = 12 elseif Type == "Barbells" then NumberRequest = 3 end
		local ferramentasValidas = {}

		for i = NumberRequest, 1, -1 do
			wait(0.5)
			if not SaveBestDumbellEvent() then
				local args = {
					[1] = SelectedWorld,
					[2] = Type,
					[3] = SelectedWorld .. i
				}
				game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE[Request]:FireServer(unpack(args))
			else
				return true
			end
		end
	end
end

local ComboTrainEvent = tabEvent:addCombo("Select Train", "Select the Mode for the auto train event", {"Dumbells", "Barbells", "Grips", "Knucles"})

tabEvent:addToggle("Auto Train Event (Selected)", "","big", false, function(value) 
	local SelectedMode = ComboTrainEvent:getValue()
	if value then
		if SelectedMode then
			lib:SendNotification("Looking for the best ".. SelectedMode .. "!!", "It may take a few seconds!", true)
			if FindBestToolEvent(SelectedMode) then
				if SelectedMode ~= "Knucles" then
					while G.Settings["Auto Train Event (Selected)"] and wait() do
						game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onClick:FireServer()
						print("sim")
					end
				end
			end
		elseif SelectedMode == nil or SelectedMode == "" or not SelectedMode then
			lib:activatedWarn()
		end
	end
end)

local folderBossEvent = tabEvent:addFolder("Auto Boss")

local BossesEventTable = {
	["Summer"] = {"Captain Fin", "Coco Chiller", "Scuba Diver", "Deep Diver", "Lifeguard Brad"},
	["PirateCove"] = {"The Explorer", "Long Beard", "Treasure Hunter", "Lady No-Beard", "Mister Tentacles", "Kraken"},
	["Waterpark"] = {"Mad Swimmer", "Park Owner", "Lifeguard Marina", "Flopper The Fish", "Chad", "Small Ryan", "Emily The Brute", "Garry Gecko", "Chomper"}
}

local ComboBossEvent = folderBossEvent:addCombo("Select Boss", "Select the Mode for the auto boss event", {"Captain Fin", "Coco Chiller", "Scuba Diver", "Deep Diver", "Lifeguard Brad", "The Explorer", "Long Beard", "Treasure Hunter", "Lady No-Beard", "Mister Tentacles", "Mad Swimmer", "Park Owner", "Lifeguard Marina", "Flopper The Fish", "Chad", "Small Ryan", "Emily The Brute", "Garry Gecko", "Chomper", "Kraken"})

folderBossEvent:addToggle("Auto Click Boss", "","big", false, function(value) 
	if value then
		while G.Settings["Auto Click Boss"] do
			wait()
			game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onClickRequest:FireServer()
		end
	end
end)

folderBossEvent:addToggle("Auto Boss Event (Selected)", "","big", false, function(value) 
	if value then
		local SelectedBoss = ComboBossEvent:getValue()
		local CorrectNameBoss = SelectedBoss:gsub(" ", "")
		local WorldSelectedBoss = nil
		
		if SelectedBoss == "Kraken" then
			CorrectNameBoss = "AlmightyKraken"
		end
		
		for World, Table in pairs(BossesEventTable) do
			for nameBoss, _ in pairs(Table) do
				if nameBoss == SelectedBoss then
					WorldSelectedBoss = World
				end
			end
		end
		
		if CorrectNameBoss and WorldSelectedBoss then
			print(CorrectNameBoss, WorldSelectedBoss)
			while G.Settings["Auto Boss Event (Selected)"] do 
				wait()
				local args = {
					[1] = CorrectNameBoss,
					[2] = workspace.GameObjects.ArmWrestling[WorldSelectedBoss].NPC[CorrectNameBoss].Table,
					[3] = WorldSelectedBoss
				}

				game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onEnterNPCTable:FireServer(unpack(args))
			end
		end
	end	
end)

local folderEggEvent = tabEvent:addFolder("Auto Egg")

local ComboEggEvent = folderEggEvent:addCombo("Select Egg", "Select the Mode for the auto egg event", {"Sand Egg", "Pirate Egg", "Kraken Egg", "Splashy Egg", "Floaty Egg"})

folderEggEvent :addToggle("Remove Egg Animation", "","small", false, function(value) 	
	local gui = game.Players.LocalPlayer.PlayerGui.OpenerUI
	if value then
		gui.Enabled = false
	else
		gui.Enabled = true
	end
end)

folderEggEvent:addToggle("Auto Egg Event (Selected)", "","big", false, function(value) 
	if value then
		while G.Settings["Auto Egg Event (Selected)"] and wait() do

			local Octo, Triple = Pl:GetAttribute("OctoEggs"), Pl:GetAttribute("TripleEggs")
			local eggSelected = ComboEggEvent:getValue()
			eggSelected = string.gsub(eggSelected, " Egg", "")

			local function SendRemote(Args)
				game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(Args))
			end

			while G.Settings["Auto Egg (Selected)"] do
				wait()
				if Octo then
					local args = { [1] = eggSelected, [2] = {}, [4] = false, [5] = true }
					SendRemote(args)
				elseif Triple then
					local args = { [1] = eggSelected, [2] = {}, [3] = true, [4] = false }
					SendRemote(args)
				else
					local args = { [1] = eggSelected, [2] = {}, [3] = false}
					SendRemote(args)
				end
			end
		end
	end
end)

local folderMerchantEvent = tabEvent:addFolder("Auto Merchant")

local ComboMerchantEvent = folderMerchantEvent:addCombo("Select Merchant", "Select the Mode for the Auto Merchant", {"All Merchants","Summer Merchant", "Pirate Merchant", "Poolside Merchant"})
local ComboMerchantItemEvent = folderMerchantEvent:addCombo("Select Item", "Select the Mode for the Auto Merchant", {"All Item", "Green Item", "Blue Item", "Red Item"})

folderMerchantEvent:addToggle("Auto Merchant Event (Selected)", "","big", false, function(value) 
	if value then
		local SelectedItem = ComboMerchantItemEvent:getValue()
		local SelectedMerchant = ComboMerchantEvent:getValue()

		local function Invoke(args)
			game:GetService("ReplicatedStorage").Packages.Knit.Services.LimitedMerchantService.RF.BuyItem:InvokeServer(unpack(args))
		end

		local ArgsList = {}
		local MerchantArl = {}

		if SelectedMerchant == "All Merchants" then
			table.insert(MerchantArl, "Summer Merchant")
			table.insert(MerchantArl, "Pirate Merchant")
			table.insert(MerchantArl, "Poolside Merchant")
		else
			table.insert(MerchantArl, SelectedMerchant)
		end

		for _, merchant in ipairs(MerchantArl) do
			if SelectedItem == "All Item" then
				table.insert(ArgsList, {merchant, 1})
			elseif SelectedItem == "Green Item" then
				table.insert(ArgsList, {merchant, 1})
				table.insert(ArgsList, {merchant, 2})
				table.insert(ArgsList, {merchant, 3})
			elseif SelectedItem == "Blue Item" then
				table.insert(ArgsList, {merchant, 4})
			elseif SelectedItem == "Red Item" then
				table.insert(ArgsList, {merchant, 5})
			end
		end

		while G.Settings["Auto Merchant Event (Selected)"] do
			wait()
			for _, args in ipairs(ArgsList) do
				Invoke(args)
			end
		end
	end
end)

tabEvent:addToggle("Auto Spin Fortune Kraken", "","big", false, function(value) 
	if value then
		while G.Settings["Auto Spin Fortune Kraken"] do
			wait()
			game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer("Kraken's Fortune")
		end
	end
end)

tabEvent:addToggle("Auto Open Summer Chest", "","big", false, function(value) 
	if value then
		while G.Settings["Auto Open Summer Chest"] do
			wait()
			game:GetService("ReplicatedStorage").Packages.Knit.Services.ChestService.RF.Open:InvokeServer("SummerChest")
		end
	end
end)


-- Auto Train

local ComboTrain = tabTrain:addCombo("Select Mode", "Select the Mode for the auto train", {"Dumbells", "Barbells", "Grips", "Knucles"})

local function SaveBestDumbell()
	local player = game.Players.LocalPlayer
	if player.Character then
		local character = player.Character
		if character:FindFirstChildWhichIsA("Tool") then
			return true
		end
	end
	return false
end

local function FindBestTier()
	local BestZone = Pl:GetAttribute("BestZone")
	local punchBags = game.Workspace.Zones[BestZone].Interactables.Training.PunchBags
	local bestTier = 0

	for _, punchBag in ipairs(punchBags:GetChildren()) do
		local tier = tonumber(punchBag.Name:match("Tier(%d+)"))

		if tier and tier > bestTier then
			bestTier = tier
		end
	end

	return bestTier
end

local function extrairNumero(nome, tipo)
	if tipo == "Barbells" then
		return tonumber(nome:match("Tier(%d+)"))
	else
		return tonumber(nome:match("(%d+)Kg"))
	end
end

local function FindBestTool(Type)
	game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onUnequipRequest:FireServer()

	local BestZone = Pl:GetAttribute("BestZone")
	local Vip = Pl:GetAttribute("VIP")

	local locations = workspace.Zones:FindFirstChild(BestZone).Interactables.Teleports.Locations:GetChildren()
	if Type == "Knucles" then
		local Tier = FindBestTier()

		if BestZone then
			if #locations > 0 then
				game:GetService("ReplicatedStorage").Packages.Knit.Services.ZoneService.RE.teleport:FireServer(locations[1])
			end
		end

		if Tier then
			local punchBagName = Vip and "VIP" or Tier
			wait(5)
			TeleportTo(workspace.Zones[BestZone].Interactables.Training.PunchBags[punchBagName].PrimaryPart.CFrame)

			while G.Settings["Auto Train (Selected)"] do
				local args = {
					[1] = BestZone,
					[2] = Vip and "VIP" or Tier,
					[3] = not Vip
				}
				game:GetService("ReplicatedStorage").Packages.Knit.Services.PunchBagService.RE.onGiveStats:FireServer(unpack(args))
				wait()
			end
		end
	else
		local toolsFolder = game:GetService("ReplicatedStorage").Tools[Type]
		local Request = (Type == "Dumbells" or Type == "Grips") and "onGuiEquipRequest" or "onEquipRequest"
		local ferramentasValidas = {}

		for _, ferramenta in pairs(toolsFolder:GetChildren()) do
			if ferramenta:IsA("Tool") then
				local numero = extrairNumero(ferramenta.Name, Type)
				if numero then
					table.insert(ferramentasValidas, {ferramenta = ferramenta, numero = numero})
				end
			end
		end

		table.sort(ferramentasValidas, function(a, b)
			return a.numero > b.numero
		end)

		for _, item in ipairs(ferramentasValidas) do
			wait(0.5)
			if not SaveBestDumbell() then
				local args = {
					[1] = BestZone,
					[2] = Type,
					[3] = item.ferramenta.Name
				}
				game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE[Request]:FireServer(unpack(args))
			else
				return true
			end
		end
	end
end

tabTrain:addToggle("Auto Train (Selected)", "","big", false, function(value) 
	local SelectedMode = ComboTrain:getValue()
	if value then
		if SelectedMode then
			lib:SendNotification("Looking for the best ".. SelectedMode .. "!!", "It may take a few seconds!", true)
			if FindBestTool(SelectedMode) then
				if SelectedMode ~= "Knucles" then
					while G.Settings["Auto Train (Selected)"] and wait() do
						game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onClick:FireServer()
					end
				end
			end
		elseif SelectedMode == nil or SelectedMode == "" or not SelectedMode then
			lib:activatedWarn()
		end
	end
end)

-- Auto Boss

local BossPath = require(game:GetService("ReplicatedStorage").Enums.ArmWrestleNPCTypes)
local BossTable = {}

for _, boss in pairs(BossPath) do
	table.insert(BossTable, boss)
end

local ComboBoss = tabBoss:addCombo("Select Boss", "Select the Boss for the auto boss", BossTable)

tabBoss:addToggle("Auto Boss (Selected)", "","big", false, function(value) 	
	if value then
		while G.Settings["Auto Boss (Selected)"] do
			wait()
			local SelectedBoss = ComboBoss:getValue()
			local pathZones = workspace:WaitForChild("GameObjects"):WaitForChild("ArmWrestling")
			for _, zones in pairs(pathZones:GetChildren()) do
				if zones:IsA("Folder") and (zones.Name ~= "6_OLD" and zones.Name ~= "Easter" and zones.Name ~= "GreekEvent") then
					local NPC = zones.NPC
					if NPC:FindFirstChild(SelectedBoss) then
						print(zones.Name)
						local ZoneId = zones.Name
						wait()
						local args = { [1] = SelectedBoss, [2] = workspace.GameObjects.ArmWrestling[ZoneId].NPC[SelectedBoss].Table, [3] = ZoneId}
						game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onEnterNPCTable:FireServer(unpack(args))

					end	
				end
			end
		end
	end
end)

tabBoss:addToggle("Auto Click", "","big", false, function(value) 
	while G.Settings["Auto Click"] do
		wait()
		game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onClickRequest:FireServer()

	end
end)

-- Auto Egg

local EggPath = game:GetService("ReplicatedStorage"):WaitForChild("Eggs")
local EggsTable = {}

for _, egg in pairs(EggPath:GetChildren()) do
	table.insert(EggsTable, egg.Name)
end

local ComboEgg = tabEggs:addCombo("Select Egg", "Select the Egg for the auto open egg", EggsTable)

tabEggs:addToggle("Remove Egg Animation", "","small", false, function(value) 	
	local gui = game.Players.LocalPlayer.PlayerGui.OpenerUI
	if value then
		gui.Enabled = false
	else
		gui.Enabled = true
	end
end)

tabEggs:addToggle("Auto Open Egg (Selected)", "","big", false, function(value) 	
	if value then
		local SelectEgg = ComboEgg:getValue()
		while G.Settings["Auto Open Egg (Selected)"] and wait() do

			local Octo, Triple = Pl:GetAttribute("OctoEggs"), Pl:GetAttribute("TripleEggs")
			local eggSelected = ComboEgg:getValue()
			eggSelected = string.gsub(eggSelected, " Egg", "")

			local function SendRemote(Args)
				game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(Args))
			end

			while G.Settings["Auto Egg (Selected)"] do
				wait()
				if Octo then
					local args = { [1] = eggSelected, [2] = {}, [4] = false, [5] = true }
					SendRemote(args)
				elseif Triple then
					local args = { [1] = eggSelected, [2] = {}, [3] = true, [4] = false }
					SendRemote(args)
				else
					local args = { [1] = eggSelected, [2] = {} }
					SendRemote(args)
				end
			end
		end
	end
end)

tabEggs:addToggle("Auto Open Egg (Event/8x)", "","big", false, function(value) 	
	if value then
		while G.Settings["Auto Open Egg (Event)"] do
			wait()
			local args = {[1] = 8,}
			game:GetService("ReplicatedStorage").Packages.Knit.Services.EventService.RF.ClaimEgg:InvokeServer(unpack(args))
		end
	end
end)

-- Garden

local folderGarden = tabMachines:addFolder("Auto Garden")

local SeedInventory = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Inventory.Display.Items.MainFrame.ScrollingFrame.SeedsStorage.Objects
local UpgradeFruits = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.ItemCrafting.Logic.List.ScrollingFrame
local ModuleMerchant = require(game:GetService("ReplicatedStorage").Data.Merchant)

local SeedTable = {}

local UpgradeToCombo = {}
local UpgradeFruitsTable = {}

local FarmerToCombo = {}
local FarmerMerchantTable = {}

local FishermanToCombo = {}
local FishermanMerchantTable = {}

table.insert(FarmerToCombo, "All")
table.insert(FishermanToCombo, "All")
table.insert(UpgradeToCombo, "All")

for _, seed in pairs(SeedInventory:GetChildren()) do
	if seed:IsA("Frame") then
		local SeedCorrectText = seed.Name:match("^(.-)/")
		table.insert(SeedTable, SeedCorrectText)
	end
end

for _, seed in pairs(UpgradeFruits:GetChildren()) do
	if seed:IsA("Frame") then
		local SeedCorrectText = seed.Name:gsub("/", "")
		local text, number = SeedCorrectText:match("([^%d]+)(%d+)")
		UpgradeFruitsTable[text] = number
		table.insert(UpgradeToCombo, text)
	end
end

for NumeroItem, Table in  pairs(ModuleMerchant.MerchantTypes.Farmer) do
	table.insert(FarmerToCombo, Table.Trade.Title)
	FarmerMerchantTable[NumeroItem] = {Table.Trade.Title, Table.Stock}
end

for NumeroItem, Table in  pairs(ModuleMerchant.MerchantTypes.Fisherman) do
	table.insert(FishermanToCombo, Table.PlayerOffer.Title)
	FishermanMerchantTable[NumeroItem] = {Table.PlayerOffer.Title, Table.Stock}
end

local ComboSeed = folderGarden:addCombo("Select Seed", "Select the Seed for the auto seed plant", SeedTable)

folderGarden:addToggle("Auto Plant/Harvest (Selected)", "Activating this option will open the slime cure machine","Big", false, function(value) 	
	if value then
		local SeedSelected = ComboSeed:getValue()

		while G.Settings["Auto Plant/Harvest (Selected)"] and wait() do
			spawn(function()
				for i = 1, 6 do 
					game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemPlantingService.RF.Harvest:InvokeServer(tostring(i))
				end
			end)
			spawn(function()
				for i = 1, 6 do 
					local args = {
						[1] = SeedSelected,
						[2] = "1",
						[3] = tostring(i)
					}

					game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemPlantingService.RF.Plant:InvokeServer(unpack(args))
				end
			end)
		end
	end
end)

folderGarden:addToggle("Auto Casting/Fishing", "","Big", true, function(value) 	
	if value then
		local Fishing = false
		local GuiProgress = game:GetService("Players").LocalPlayer.PlayerGui.NetCasting.Progress
		TeleportTo(workspace.Zones.Garden.Interactables.NetSetup.Touch.Region.Touch.CFrame * CFrame.new(0,5,0))
		while G.Settings["Auto Casting/Fishing"] and wait() do

			game:GetService("ReplicatedStorage").Packages.Knit.Services.NetService.RF.StartCatching:InvokeServer("Regular")

			repeat
				wait()
				local Rotation = game:GetService("Players").LocalPlayer.PlayerGui.NetCasting.Progress.Circle.Rotation

				local args = {
					[1] = Rotation,
					[2] = Rotation
				}

				game:GetService("ReplicatedStorage").Packages.Knit.Services.NetService.RF.VerifyCatch:InvokeServer(unpack(args))
			until not GuiProgress.Visible or not G.Settings["Auto Casting/Fishing"]

		end
	end
end)

local ComboFarmerMerchant = folderGarden:addCombo("Select Item (Farmer)", "", FarmerToCombo)
local CombFisherman = folderGarden:addCombo("Select Item (Fisherman)", "", FishermanToCombo)
local CombUpgrades = folderGarden:addCombo("Select Item (Upgrade Fruits)", "", UpgradeToCombo)

folderGarden:addToggle("Auto Buy All Farmer (Selected)", "","Big", false, function(value)
	if value then
		while G.Settings["Auto Buy All Farmer (Selected)"] and wait() do
			local SelectedItem = ComboFarmerMerchant:getValue()
			for NumeroItem, Data in pairs(FarmerMerchantTable) do
				local title = Data[1] 
				local Stock = Data[2] 
				if SelectedItem ~= "All" then
					if title == SelectedItem then
						for i = 1, Stock do
							game:GetService("ReplicatedStorage").Packages.Knit.Services.MerchantService.RF.BuyItem:InvokeServer("Farmer", NumeroItem)
							if not G.Settings["Auto Buy All Farmer (Selected)"] then
								break
							end
						end
					end
				else
					for i = 1, Stock do
						game:GetService("ReplicatedStorage").Packages.Knit.Services.MerchantService.RF.BuyItem:InvokeServer("Farmer", NumeroItem)
						if not G.Settings["Auto Buy All Farmer (Selected)"] then
							break
						end
					end
				end
			end
		end
	end
end)

folderGarden:addToggle("Auto Buy All Fisherman (Selected)", "","Big", false, function(value)
	if value then
		while G.Settings["Auto Buy All Fisherman (Selected)"] and wait() do
			local SelectedItem = CombFisherman:getValue()
			for NumeroItem, Data in pairs(FarmerMerchantTable) do
				local title = Data[1] 
				local Stock = Data[2] 
				if SelectedItem ~= "All" then
					if title == SelectedItem then
						for i = 1, Stock do
							game:GetService("ReplicatedStorage").Packages.Knit.Services.MerchantService.RF.BuyItem:InvokeServer("Fisherman", NumeroItem)
							if not G.Settings["Auto Buy All Fisherman (Selected)"] then
								break
							end
						end
					end
				else
					for i = 1, Stock do
						game:GetService("ReplicatedStorage").Packages.Knit.Services.MerchantService.RF.BuyItem:InvokeServer("Fisherman", NumeroItem)
						if not G.Settings["Auto Buy All Fisherman (Selected)"] then
							break
						end
					end
				end
			end
		end
	end
end)

folderGarden:addToggle("Auto Upgrade All (Selected)", "","Big", false, function(value)
	if value then
		while G.Settings["Auto Upgrade All (Selected)"] and wait() do
			local SelectedItem = CombUpgrades:getValue()
			for Text, Data in pairs(UpgradeFruitsTable) do
				if SelectedItem ~= "All" then
					if SelectedItem == Text then
						game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemCraftingService.RF.UpgradeSnack:InvokeServer({["Item"] = Text,["Tier"] = Data})
					end
				else
					game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemCraftingService.RF.UpgradeSnack:InvokeServer({["Item"] = Text,["Tier"] = Data})
				end
			end
		end
	end
end)

-- Auto Golden

local folderAutoGolden = tabMachines:addFolder("Auto Golden")


	

-- Auto Mutate

local folderAutoMutate = tabMachines:addFolder("Auto Mutate")

local PetsActives = {}
local PetsPlayerLast = {}
local PetsPlayerComp = {}

local function UpdatePetsTable(bolean)
	local result = game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.getOwned:InvokeServer(Pl)
	for i, g in pairs(result) do
		local Id = i
		local Key = g.Key
		local Cure = g.Cure

		if not table.find(PetsActives, Key) then
			table.insert(PetsActives, Key)
		end

		if bolean then
			PetsPlayerLast[Id] = {Key, Cure}
		else
			PetsPlayerComp[Id] = {Key, Cure}
		end
	end
end

UpdatePetsTable()

local ComboPetMutate = folderAutoMutate:addCombo("Select Pet", "", PetsActives)
local ComboModeMutate = folderAutoMutate:addCombo("Select Mode", "", {"Glowing", "Rainbow", "Ghost"})

folderAutoMutate:addClick("Mutate All Pets (No Kits!)", "","Big", false, function(value)
	if value then
		UpdatePetsTable(true)

		for IdPet, petData in pairs(PetsPlayerLast) do
			if petData[2] == nil then
				local args = {[1] = IdPet, [2] = {}}
				game:GetService("ReplicatedStorage").Packages.Knit.Services.PetCombineService.RF.mutate:InvokeServer(unpack(args))
			end
		end
	end
end)	

folderAutoMutate:addToggle("Auto Mutate (Selected Pet/Mode)", "","Big", false, function(value) 
	local PetSelected = ComboPetMutate:getValue()
	local ModeSelected = ComboModeMutate:getValue()
	local Using = false


	if value then
		while G.Settings["Auto Mutate (Selected Pet/Mode)"] and wait() do
			if PetSelected and ModeSelected then
				UpdatePetsTable(true)
				for IdPet, petData in pairs(PetsPlayerLast) do
					if not Using then
						if petData[1] == PetSelected and petData[2] == nil then
							Using = true
							local args = {[1] = IdPet, [2] = {}}
							game:GetService("ReplicatedStorage").Packages.Knit.Services.PetCombineService.RF.mutate:InvokeServer(unpack(args))
							UpdatePetsTable(false)
							for IdPetS, petDataS in pairs(PetsPlayerComp) do
								if not PetsPlayerLast[IdPetS] and petDataS[2] ~= nil then
									local Key = petDataS[1]
									local Cure = petDataS[2]
									if Cure ~= ModeSelected then
										game:GetService("ReplicatedStorage").Packages.Knit.Services.PetCombineService.RF.cure:InvokeServer(IdPetS)
										Using = false
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)	

local folderAutoSlime = tabMachines:addFolder("Auto Slime")

local ComboSlime = folderAutoSlime :addCombo("Select Slime", "Select the Slime Color for the auto slimer pet", {"Yellow", "Blue", "Purple", "Red"})

folderAutoSlime:addToggle("Open Cure Slime", "Activating this option will open the slime cure machine","small", false, function(value) 	
	if value then
		game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Deslime.Visible = true
	else
		game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Deslime.Visible = false
	end
end)

folderAutoSlime:addToggle("Auto Lock Slimed Pet", "By activating this option, every time you catch a pet with the selected slime it will automatically block","small", false, function(value) 	
end)

folderAutoSlime:addToggle("Auto Slime (Selected)", "Activating this option you will start making slime on available pets and healing them until they all turn the color of the selected slime.","big", false, function(value) 
	if value then
		local InvPets = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Inventory.Display.Pets.ScrollingFrame.Pets
		local DeslimeGui = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Deslime
		local Timer = DeslimeGui.Progress.Timer
		local SlimeSelected = ComboSlime:getValue()
		if SlimeSelected then
			while G.Settings["Auto Slime (Selected)"] do
				wait(0.5)
				if DeslimeGui.Progress.Visible then
					if Timer.Text == "READY!" then
						game:GetService("ReplicatedStorage").Packages.Knit.Services.PetDeslimeService.RE.onClaim:FireServer() 
					else
						repeat
							wait(0.5)
						until Timer.Text == "READY!"
						game:GetService("ReplicatedStorage").Packages.Knit.Services.PetDeslimeService.RE.onClaim:FireServer() 
					end
				end

				local PetMaking = false

				for _, pets in ipairs(InvPets:GetChildren()) do
					if pets:IsA("Frame") and pets:FindFirstChild("Toggle") then
						local Toggle = pets.Toggle
						local CraftType = Toggle:GetAttribute("CraftType")
						local Slime = Toggle:GetAttribute("Slime")
						local Lock = Toggle.LockPet
						local ID = Toggle:GetAttribute("GUID")
						local NamePet = Toggle:GetAttribute("Key")
						if G.Settings["Auto Lock Slimed Pet"] then
							if Slime == SlimeSelected then
								local args = {
									[1] = {
										[ID] = true
									}
								}

								game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.updateLocked:InvokeServer(unpack(args))
							end 
						end
						if not Lock.Visible and CraftType == "Goliath" and (Slime ~= SlimeSelected) then
							if not PetMaking then
								if Slime then
									local usingCure = false

									if not usingCure then
										usingCure = true
										game:GetService("ReplicatedStorage").Packages.Knit.Services.PetDeslimeService.RE.onPurchase:FireServer(ID)
										wait(5)
										repeat
											wait(0.5)
										until Timer.Text == "READY!"

										game:GetService("ReplicatedStorage").Packages.Knit.Services.PetDeslimeService.RE.onClaim:FireServer() 
										usingCure = false
									end
								elseif (Slime ~= SlimeSelected) or Slime == nil then
									game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.slimify:InvokeServer(ID)
								end
							end
							PetMaking = true
						end
					end
				end
			end
		else
			lib:activatedWarn()	
			G.Settings["Auto Slime (Selected)"] = false
		end
	end
end)


