local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 140, 0, 40)
toggleBtn.Position = UDim2.new(0.5, 0, 0, 10)
toggleBtn.AnchorPoint = Vector2.new(0.5, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Text = "mở menu"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.BorderSizePixel = 0
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.ClipsDescendants = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 460)
frame.Position = UDim2.new(0, 20, 0, 110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local shadow = Instance.new("ImageLabel", frame)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.BackgroundTransparency = 1

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN"
title.Size = UDim2.new(1, 0, 0, 40)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1

local tabs = { "ESP", "Mem/S&F" }
local tabFrames = {}

for i, name in ipairs(tabs) do
	local tb = Instance.new("TextButton", frame)
	tb.Text = name
	tb.Size = UDim2.new(0, 140, 0, 30)
	tb.Position = UDim2.new(0, (i - 1) * 150 + 10, 0, 45)
	tb.Font = Enum.Font.GothamBold
	tb.TextSize = 14
	tb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tb.TextColor3 = Color3.new(1, 1, 1)
	tb.AutoButtonColor = false
	tb.BorderSizePixel = 0
	Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)

	tabFrames[name] = Instance.new("Frame", frame)
	tabFrames[name].Size = UDim2.new(1, -20, 1, -90)
	tabFrames[name].Position = UDim2.new(0, 10, 0, 85)
	tabFrames[name].Visible = false
	tabFrames[name].BackgroundTransparency = 1

	tb.MouseButton1Click:Connect(function()
		for _, f in pairs(tabFrames) do f.Visible = false end
		tabFrames[name].Visible = true
	end)
end

tabFrames["ESP"].Visible = true

local function addToggle(parent, name, y)
	local state = false
	local btn = Instance.new("TextButton", parent)
	btn.Text = "OFF - " .. name
	btn.Size = UDim2.new(0, 280, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = (state and "ON - " or "OFF - ") .. name
	end)

	return function() return state end
end

local espToggle = addToggle(tabFrames["ESP"], "ESP Master", 10)
local mobToggle = addToggle(tabFrames["ESP"], "Mob ESP", 50)
local noRecoilToggle = addToggle(tabFrames["ESP"], "No Recoil", 90)
local itemPickToggle = addToggle(tabFrames["ESP"], "Item Pick ESP", 130)
local aimbotToggle = addToggle(tabFrames["ESP"], "Aimbot Lock", 170)
local speedToggle = addToggle(tabFrames["Mem/S&F"], "Speed Hack", 10)
local flyToggle = addToggle(tabFrames["Mem/S&F"], "Fly", 50)
local noReloadEnabled = true
local bulletFollowEnabled = true 

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

local playerESPCount = 0
local maxESPDistance = 450

if not counter then
    counter = Drawing.new("Text")
    counter.Size = 22
    counter.Center = true
    counter.Outline = true
    counter.Font = 2
    counter.Color = Color3.fromRGB(255, 255, 0)
    counter.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 30)
end

local ESPdata, Items, ItemPick = {}, {}, {}
local skeletonLines = { {1,2},{2,3},{3,4},{4,5},{2,6},{6,7},{3,8},{8,9},{3,10},{10,11} }

local function getJoints(char)
	local parts = {
		char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
		char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso"),
		char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm"),
		char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm"),
		char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg"),
		char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")
	}
	local pos = {}
	for i, part in ipairs(parts) do
		if part then
			local sp, on = Camera:WorldToViewportPoint(part.Position)
			if on then pos[i] = Vector2.new(sp.X, sp.Y) end
		end
	end
	return pos
end

local function initESP(p)
	local box = Drawing.new("Square") box.Thickness = 1 box.Filled = false box.Color = Color3.fromRGB(255, 0, 0)
	local line = Drawing.new("Line") line.Thickness = 1 line.Color = Color3.fromRGB(255, 255, 0)
	local name = Drawing.new("Text") name.Size = 13 name.Color = Color3.fromRGB(0, 255, 0) name.Center = true name.Outline = true
	local hp = Drawing.new("Text") hp.Size = 13 hp.Color = Color3.fromRGB(255, 255, 255) hp.Center = true hp.Outline = true
	local skl = {} for i = 1, 10 do skl[i] = Drawing.new("Line") skl[i].Color = Color3.fromRGB(0, 255, 255) skl[i].Thickness = 1 end
	ESPdata[p] = { box = box, line = line, name = name, hp = hp, skeleton = skl }
end

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Radius = 100
FovCircle.Filled = false

local bulletCache = {}
local itemCache = {}
local lastHeavyScan = 0
local lastRecoilScan = 0
local HEAVY_INTERVAL = 0.6
local RECOIL_INTERVAL = 0.15

local function scanBulletsAndItems()
	local now = tick()
	if now - lastHeavyScan < HEAVY_INTERVAL then return end
	lastHeavyScan = now
	local newBullets = {}
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			local n = v.Name:lower()
			if n:find("bullet") or n:find("projectile") or n:find("shell") then
				newBullets[v] = true
			end
		end
		if (v:IsA("Part") or v:IsA("Model")) then
			if v:FindFirstChildWhichIsA("ProximityPrompt") or v:FindFirstChildWhichIsA("ClickDetector") then
				itemCache[v] = v
			end
		end
	end
	for k in pairs(bulletCache) do
		if not newBullets[k] then bulletCache[k] = nil end
	end
	for k in pairs(newBullets) do bulletCache[k] = true end
end

local function safeNoReload()
	if tick() - lastHeavyScan < HEAVY_INTERVAL then return end
	for _, tool in ipairs(LP.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:FindFirstChild("ReloadTime") then
				pcall(function() tool.ReloadTime.Value = 0 end)
			end
			if tool:FindFirstChild("Ammo") and tool:FindFirstChild("MaxAmmo") then
				pcall(function() tool.Ammo.Value = tool.MaxAmmo.Value end)
			end
		end
	end
end

local function safeNoRecoil()
	if tick() - lastRecoilScan < RECOIL_INTERVAL then return end
	lastRecoilScan = tick()
	pcall(function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
				local n = obj.Name:lower()
				if n:find("recoil") or n:find("kick") or n:find("spread") then
					obj.Value = 0
				end
			end
		end
		for _, tool in ipairs(LP.Backpack:GetChildren()) do
			for _, obj in ipairs(tool:GetDescendants()) do
				if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
					local n = obj.Name:lower()
					if n:find("recoil") or n:find("kick") or n:find("spread") then
						obj.Value = 0
					end
				end
			end
		end
		if LP.Character then
			for _, obj in ipairs(LP.Character:GetDescendants()) do
				if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
					local n = obj.Name:lower()
					if n:find("recoil") or n:find("kick") or n:find("spread") then
						obj.Value = 0
					end
				end
			end
		end
	end)
end

local function BulletFollowTarget(target)
	if not target then return end
	if not target:FindFirstChild("Head") then return end
	local headPos = target.Head.Position
	for b in pairs(bulletCache) do
		if b and b:IsA("BasePart") and b.Parent then
			pcall(function()
				b.CFrame = CFrame.new(b.Position, headPos)
				b.Position = headPos
			end)
		end
	end
end

local function IsVisiblePart(part)
	local origin = Camera.CFrame.Position
	local targetPosition = part.Position
	local direction = targetPosition - origin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {LP.Character}
	local result = workspace:Raycast(origin, direction, raycastParams)
	return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestTarget(maxDist, fov)
	local closest = nil
	local closestDist = math.huge
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
			local hum = p.Character:FindFirstChild("Humanoid")
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				local head = p.Character.Head
				local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen and IsVisiblePart(head) then
					local dist2D = (Vector2.new(sp.X, sp.Y) - center).Magnitude
					local dist3D = (hrp.Position - Camera.CFrame.Position).Magnitude
					if dist3D <= maxDist and dist2D <= fov and dist3D < closestDist then
						closestDist = dist3D
						closest = p.Character
					end
				end
			end
		end
	end
	return closest
end

local function handleESP(target)
	local hum = target:FindFirstChild("Humanoid")
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	local plr = Players:GetPlayerFromCharacter(target)
	if not plr or plr == LP then return end
	if plr.Team and LP.Team and plr.Team == LP.Team then return end
	local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
	if distance > maxESPDistance or hum.Health <= 0 or hum.Health == math.huge then return end
	local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
	local dir = (hrp.Position - Camera.CFrame.Position).Unit
	local dot = dir:Dot(Camera.CFrame.LookVector)
	if not (espToggle() and onScreen and dot > 0) then return end
	if not ESPdata[target] then initESP(target) end
	local ed = ESPdata[target]
	local visible = IsVisiblePart(hrp)
	local color = visible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	local sy = math.clamp(2000 / distance, 30, 200)
	local sx = sy / 2
	ed.box.Position = Vector2.new(sp.X - sx / 2, sp.Y - sy / 2)
	ed.box.Size = Vector2.new(sx, sy)
	ed.box.Color = color
	ed.box.Visible = true
	ed.name.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 15)
	ed.name.Text = target.Name
	ed.name.Color = color
	ed.name.Visible = true
	ed.hp.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 30)
	ed.hp.Text = "HP: " .. math.floor(hum.Health)
	ed.hp.Color = color
	ed.hp.Visible = true
	if not ed.dist then
		ed.dist = Drawing.new("Text")
		ed.dist.Size = 17
		ed.dist.Color = Color3.new(1, 1, 1)
		ed.dist.Outline = true
		ed.dist.Center = true
	end
	ed.dist.Position = Vector2.new(sp.X, sp.Y + sy / 2 + 10)
	ed.dist.Text = math.floor(distance) .. "m"
	ed.dist.Visible = true
	local joints = getJoints(target)
	for i, pair in ipairs(skeletonLines) do
		local a, b = joints[pair[1]], joints[pair[2]]
		local sl = ed.skeleton[i]
		if a and b then
			sl.From = a
			sl.To = b
			sl.Color = color
			sl.Visible = true
		else
			sl.Visible = false
		end
	end
end

local function updateESP()
	if not espToggle() then
		for ent, ed in pairs(ESPdata) do
			for _, v in pairs(ed) do
				if typeof(v) == "table" then
					for _, sub in pairs(v) do sub.Visible = false end
				else
					v.Visible = false
				end
			end
		end
		if counter then counter.Visible = false end
		return
	end
	playerESPCount = 0
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
			handleESP(p.Character)
			playerESPCount += 1
		end
	end
	counter.Text = "ESP: " .. playerESPCount
	counter.Visible = true
end

RunService.RenderStepped:Connect(function()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	if speedToggle() and LP.Character and LP.Character:FindFirstChild("Humanoid") then
		pcall(function() LP.Character.Humanoid.WalkSpeed = 200 end)
	end
	if flyToggle() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		pcall(function() LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) end)
	end
	if espToggle() then
		updateESP()
	end
	if aimbotToggle() then
		local target = GetClosestTarget(300, 200)
		if target then
			if bulletFollowEnabled then BulletFollowTarget(target) end
			local head = target:FindFirstChild("Head")
			if head then
				local camPos = Camera.CFrame.Position
				Camera.CFrame = CFrame.lookAt(camPos, head.Position)
			end
		end
	end
	FovCircle.Position = Vector2.new(center.X, center.Y)
	FovCircle.Radius = 100
	FovCircle.Visible = aimbotToggle()
end)

RunService.Heartbeat:Connect(function()
	scanBulletsAndItems()
	if noReloadEnabled then safeNoReload() end
	if noRecoilToggle() then safeNoRecoil() end
end)

Players.PlayerRemoving:Connect(function(p)
	for ent, ed in pairs(ESPdata) do
		if ent and ent == p.Character then
			for _, d in pairs(ed) do
				if typeof(d) == "table" then
					for _, l in pairs(d) do l:Remove() end
				else
					d:Remove()
				end
			end
			ESPdata[ent] = nil
		end
	end
end)

for _, v in pairs(getconnections(LP.Idled)) do v:Disable() end