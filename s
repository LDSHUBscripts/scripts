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
local ComboEventWorld= tabEvent:addCombo("Select World", "Select the Mode for the auto train event", {"Summer", "Pirate", "Waterpark"})

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

local ComboTrainEvent = tabEvent:addCombo("Select Mode", "Select the Mode for the auto train event", {"Dumbells", "Barbells", "Grips", "Knucles"})

tabEvent:addToggle("Auto Train Event (Selected)", "","big", false, function(value) 
	local SelectedMode = ComboTrainEvent:getValue()
	if value then
		if SelectedMode then
			lib:SendNotification("Looking for the best ".. SelectedMode .. "!!", "It may take a few seconds!", true)
			if FindBestToolEvent(SelectedMode) then
				if SelectedMode ~= "Knucles" then
					while G.Settings["Auto Train Event (Selected)"] and wait() do
						game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onClick:FireServer()
					end
				end
			end
		elseif SelectedMode == nil or SelectedMode == "" or not SelectedMode then
			lib:activatedWarn()
		end
	end
end)

local BossesEventTable = {
	["Summer"] = {"Captain Fin", "Coco Chiller", "Scuba Diver", "Deep Diver", "Lifeguard Brad"},
	["PirateCove"] = {"The Explorer", "Long Beard", "Treasure Hunter", "Lady No-Beard", "Mister Tentacles", "Kraken"},
	["Waterpark"] = {"Mad Swimmer", "Park Owner", "Lifeguard Marina", "Flopper The Fish", "Chad", "Small Ryan", "Emily The Brute", "Garry Gecko", "Chomper"}
}
local ComboBossEvent = tabEvent:addCombo("Select Boss", "Select the Mode for the auto boss event", {"Captain Fin", "Coco Chiller", "Scuba Diver", "Deep Diver", "Lifeguard Brad", "The Explorer", "Long Beard", "Treasure Hunter", "Lady No-Beard", "Mister Tentacles", "Mad Swimmer", "Park Owner", "Lifeguard Marina", "Flopper The Fish", "Chad", "Small Ryan", "Emily The Brute", "Garry Gecko", "Chomper", "Kraken"})

tabEvent:addToggle("Auto Click Boss", "","big", false, function(value) 
	if value then
		while G.Settings["Auto Click Boss"] do
			wait()
			game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onClickRequest:FireServer()
		end
	end
end)

tabEvent:addToggle("Auto Boss Event (Selected)", "","big", false, function(value) 
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

local ComboEggEvent = tabEvent:addCombo("Select Egg", "Select the Mode for the auto egg event", {"Sand Egg", "Pirate Egg", "Kraken Egg", "Splashy Egg", "Floaty Egg"})

tabEvent:addToggle("Remove Egg Animation", "","small", false, function(value) 	
	local gui = game.Players.LocalPlayer.PlayerGui.OpenerUI
	if value then
		gui.Enabled = false
	else
		gui.Enabled = true
	end
end)

tabEvent:addToggle("Auto Egg Event (Selected)", "","big", false, function(value) 
	if value then
		local ComboEgg = ComboEggEvent:getValue()
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
					local args = { [1] = eggSelected, [2] = {}, [3] = false}
					SendRemote(args)
				end
			end
		end
	end
end)

local ComboMerchantEvent = tabEvent:addCombo("Select Merchant", "Select the Mode for the Auto Merchant", {"All Merchants","Summer Merchant", "Pirate Merchant", "Poolside Merchant"})
local ComboMerchantItemEvent = tabEvent:addCombo("Select Item", "Select the Mode for the Auto Merchant", {"All Item", "Green Item", "Blue Item", "Red Item"})

tabEvent:addToggle("Auto Merchant Event (Selected)", "","big", false, function(value) 
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
