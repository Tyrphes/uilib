local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Tyrphes/hmm/main/Protected.lua"))()


local hidestar = false

local UI = UILib.CreateLib("Anime Fighter","Synapse")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local Auto = UI:NewTab("Auto Farm")

local AutoFarm = Auto:NewSection("Auto Farm Boss")
local Graphic = UI:NewTab("Misc")
local Misc = Graphic:NewSection("Misc")

local selectedEggMaxOpen = nil
local multistar = false
local AutoStar = Auto:NewSection("Auto Star")
local eggStats = require(game.ReplicatedStorage.ModuleScripts.EggStats)
local eggData = {}
local eggDisplayNameToNameLookUp = {}
local plr = game.Players.LocalPlayer
local autofarm = false
local boss =  nil
local bossspawn = nil
local function getallboss()
	local bosstable = {}
	local moblist = game.Workspace.Worlds[plr.World.Value].Enemies:GetChildren()
	for i,v in pairs(moblist) do
		if v:FindFirstChild("SpecialId") and string.find(v:FindFirstChild("SpecialId").Value,"Boss") and not table.find(bosstable,v.DisplayName.Value) then
			table.insert(bosstable,v.DisplayName.Value)
		end
	end
	return bosstable
end

function getEggStats()
	for eggName, info in pairs(eggStats) do
		if info.Currency ~= "Robux" and not info.Hidden then
			local eggModel = game.Workspace.Worlds:FindFirstChild(eggName, true)
			local s = string.format("%s (%s)", info.DisplayName, eggName)
			table.insert(eggData, s)
			eggDisplayNameToNameLookUp[s] = eggName
		end
	end

	return eggData
end
getEggStats()
local function GetBossObject(BossName)
	local closestDistance, closestHumanoid = 35, nil
	local Enemies = game.Workspace.Worlds[plr.World.Value].Enemies:GetChildren()
	local enemySpawns = game.Workspace.Worlds[plr.World.Value].EnemySpawners:GetChildren()
	for i,v in pairs(Enemies) do
		if v.DisplayName.Value == BossName then


			if v then
				if v.PrimaryPart then
					local distance = plr:DistanceFromCharacter(v.PrimaryPart.Position)
					if distance < closestDistance then

						boss = v
					end
				end

			end
		end
	end
	for i,v in pairs(enemySpawns) do
		if v.CurrentEnemy.Value == boss then
			bossspawn = v
		end
	end
end
local debounce = false
local function retreat()
	VIM:SendKeyEvent(true,"R",false,game)
end
local function AutoFarm_F(onoff)
	autofarm = onoff
	if onoff == true then
		debounce = false
	end
end
local Toggle = AutoFarm:NewToggle("Auto Farm Boss","",AutoFarm_F)
local BossList = AutoFarm:NewDropdown("Boss select","",getallboss(),GetBossObject)
local BossRefresh = AutoFarm:NewButton("Refresh","",function()
	BossList:Refresh(getallboss())
end)
local MaxOpen = AutoStar:NewToggle("Max Star open","",function(value)
	multistar = value
end)
local EggDropDown = AutoStar:NewDropdown("Star select","",eggData,function(value)
	selectedEggMaxOpen = eggDisplayNameToNameLookUp[value]
end)
local AntiAFKBut = Misc:NewButton("Anti AFK","",function()

	cn = plr.Idled:Connect(function()
		VU:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		task.wait(1)
		VU:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)

	warn("ANTI-AFK: ON")

end)
local HideStarOpen = Misc:NewButton("Hide Star Open Effect","",function()
	if hidestar == false then
		hidestar = true
		plr.PlayerGui.EggOpenGui.EggOpenFrame.ChildAdded:Connect(function(v)
			if v.Name == "Shine" or  v.Name =="EggFrame" or v.Name == "StarParticle" then
				v.Visible = false
			end
		end)
	end
end)
local HideDmgInd = Misc:NewButton("Hide Damage Indicators","",function()
	game.ReplicatedStorage.ReplicatedAssets.Models.DamageEffect.Gui.Enabled = false
end)
local LowGraphic = Misc:NewButton("LowGraphic","",function()
	local Children = game.Workspace:GetDescendants()
	for _, Child in pairs(Children) do
		if Child:IsA("Part") or Child:IsA("WedgePart") or Child:IsA("MeshPart") or Child:IsA("UnionOperation") then
			Child.Material = "SmoothPlastic"

			game.Lighting.GlobalShadows = false
		end
	end
end)


cn1 = game:GetService("RunService").RenderStepped:Connect(function()
	if autofarm then
		if debounce == false then
			debounce = true
			local cWorld = plr.World.Value

			local enemySpawns = game.Workspace.Worlds[cWorld].EnemySpawners


			if boss ~= nil and autofarm then



				if bossspawn ~= nil then


					repeat
						if boss ~= nil then
							game.ReplicatedStorage.Bindable.SendPet:Fire(boss, true)
						end

						boss = bossspawn.CurrentEnemy.Value
						task.wait()
					until
					plr.World.Value ~= cWorld or boss == nil or plr:FindFirstChild("Attackers") == nil or not autofarm

					debounce = false

				end
			end
		end
	

	end
if multistar  then
		game.ReplicatedStorage.Remote.AttemptMultiOpen:FireServer(selectedEggMaxOpen)
end
end)
UI.Close().Closing:Connect(function()
	if cn then
		cn:Disconnect()
	end
	if cn1 then 
		cn1:Disconnect()
	end
end)








