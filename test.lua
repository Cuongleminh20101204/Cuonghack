-- Created By QuanCheaterVN

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 140, 0, 40)
toggleBtn.Position = UDim2.new(0.5, 0, 0, 10) -- giữa ngang, cách top 10px
toggleBtn.AnchorPoint = Vector2.new(0.5, 0)   -- neo giữa theo trục X
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
--local hitboxToggle = addToggle(tabFrames["ESP"], "Hitbox Head", 170)
local noReloadEnabled = true
local bulletFollowEnabled = true 

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

local playerESPCount = 0
local mobESPCount = 0
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
FovCircle.Color = Color3.fromRGB(0, 255, 0)
FovCircle.Thickness = 1
FovCircle.Radius = 100
FovCircle.Filled = false




RunService.RenderStepped:Connect(function()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	if speedToggle() and LP.Character and LP.Character:FindFirstChild("Humanoid") then
		LP.Character.Humanoid.WalkSpeed = 200
	end

	if flyToggle() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
	end

	for obj, txt in pairs(ItemPick) do
		if not obj:IsDescendantOf(workspace) then
			txt:Remove()
			ItemPick[obj] = nil
		else
			txt.Visible = false
		end
	end
	
local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local targetPosition = part.Position
    local direction = targetPosition - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LP.Character}

    local result = workspace:Raycast(origin, direction, raycastParams)
    
    return not result or result.Instance:IsDescendantOf(part.Parent)
end


if noRecoilToggle() then
	local cam = workspace.CurrentCamera
	if cam and cam:FindFirstChild("RecoilScript") then
		for _, v in ipairs(cam.RecoilScript:GetChildren()) do
			if v:IsA("NumberValue") or v:IsA("Vector3Value") then
				v.Value = 0
			end
		end
	end

	for _, tool in ipairs(LP.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Recoil") then
			for _, obj in ipairs(tool:GetDescendants()) do
				if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
					obj.Value = 0
				end
			end
		end
	end

	local char = LP.Character
	if char then
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
				if obj.Name:lower():find("recoil") then
					obj.Value = 0
				end
			end
		end
	end
end


-- NO RELOAD
if noReloadEnabled then
    pcall(function()
        for _, tool in ipairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                if tool:FindFirstChild("ReloadTime") then
                    tool.ReloadTime.Value = 0
                end
                if tool:FindFirstChild("Ammo") and tool:FindFirstChild("MaxAmmo") then
                    tool.Ammo.Value = tool.MaxAmmo.Value
                end
                local reloadFunc = tool:FindFirstChild("Reload")
                if reloadFunc and reloadFunc:IsA("ModuleScript") then
                    local m = require(reloadFunc)
                    for k, v in pairs(m) do
                        if typeof(v) == "function" then m[k] = function() end end
                    end
                end
            end
        end
    end)
end


if aimbotToggle() then
    local target = nil
    local closestDist = math.huge
    local maxDist = 250
    local fov = 180
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local aimPos = nil

    local function IsVisible(part, model)
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {LP.Character, Camera}
        local result = workspace:Raycast(origin, direction, params)
        return not result or result.Instance:IsDescendantOf(model)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if head and root and hum and hum.Health > 0 and IsVisible(head, char) then
                local dist3D = (head.Position - Camera.CFrame.Position).Magnitude
                if dist3D <= maxDist then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    local dot = (head.Position - Camera.CFrame.Position).Unit:Dot(Camera.CFrame.LookVector)

                    if onScreen and dot > 0 and dist2D <= fov then
                        if dist3D < closestDist then
                            target = char
                            closestDist = dist3D

                            -- Nếu lệch tâm nhiều thì aim cổ
                            if dist2D > 100 then
                                aimPos = root.Position + Vector3.new(0, 1.1, 0)  -- Aim cổ
                            else
                                aimPos = head.Position + Vector3.new(0, 0.05, 0) -- Aim đầu
                            end
                        end
                    end
                end
            end
        end
    end

    RunService:UnbindFromRenderStep("ForceAimbotLock")
    if target and aimPos then
        RunService:BindToRenderStep("ForceAimbotLock", Enum.RenderPriority.Camera.Value + 1, function()
            if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
                RunService:UnbindFromRenderStep("ForceAimbotLock")
                return
            end
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.lookAt(camPos, aimPos)
        end)

        local recoil = workspace.CurrentCamera:FindFirstChild("RecoilScript")
        if recoil then
            for _, v in ipairs(recoil:GetChildren()) do
                if v:IsA("NumberValue") or v:IsA("Vector3Value") then
                    v.Value = 0
                end
            end
        end

        pcall(function()
            for _, s in ipairs({
                LP.PlayerScripts:FindFirstChild("GunRecoil"),
                LP.PlayerScripts:FindFirstChild("Recoil"),
                LP.PlayerScripts:FindFirstChild("CameraShake"),
                LP.Character and LP.Character:FindFirstChild("Recoil"),
                LP.Character and LP.Character:FindFirstChild("CameraShakeScript")
            }) do
                if s then
                    if s:IsA("ModuleScript") then
                        local m = require(s)
                        for k, v in pairs(m) do
                            if typeof(v) == "function" then m[k] = function() end end
                        end
                    else
                        s:Destroy()
                    end
                end
            end
        end)
    end
end



local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character}
    local result = workspace:Raycast(origin, direction, params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end
if espToggle() then
    playerESPCount = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if not (p.Team and LP.Team and p.Team == LP.Team) then
                local hum = p.Character.Humanoid
                local hrp = p.Character.HumanoidRootPart
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                if distance <= maxESPDistance and hum.Health > 0 and hum.Health < math.huge then
                    playerESPCount += 1
                end
            end
        end
    end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local topCenter = Vector2.new(screenCenter.X, 0)
    local alertMap = {}
    local alertRadius = 60

    for ent, ed in pairs(ESPdata) do
        if not ent or not ent:IsDescendantOf(workspace) then
            for _, v in pairs(ed) do
                if typeof(v) == "table" then
                    for _, sub in pairs(v) do pcall(function() sub:Remove() end) end
                else
                    pcall(function() v:Remove() end)
                end
            end
            ESPdata[ent] = nil
        else
            for _, v in pairs(ed) do
                if typeof(v) == "table" then
                    for _, sub in pairs(v) do sub.Visible = false end
                else
                    v.Visible = false
                end
            end
        end
    end

    local function handleESP(target)
        local hum = target:FindFirstChild("Humanoid")
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local plr = Players:GetPlayerFromCharacter(target)
        if plr and LP and plr.Team and LP.Team and plr.Team == LP.Team then return end

        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > maxESPDistance or hum.Health <= 0 or hum.Health == math.huge then return end

        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local dir = (hrp.Position - Camera.CFrame.Position).Unit
        local dot = dir:Dot(Camera.CFrame.LookVector)

        if espToggle() and onScreen and dot > 0 then
            if not ESPdata[target] then initESP(target) end
            local ed = ESPdata[target]
            local visible = IsVisible(hrp)
            local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

            local sy = math.clamp(2000 / distance, 30, 200)
            local sx = sy / 2

            ed.box.Position = Vector2.new(sp.X - sx / 2, sp.Y - sy / 2)
            ed.box.Size = Vector2.new(sx, sy)
            ed.box.Color = color
            ed.box.Visible = true

            ed.line.From = topCenter
            ed.line.To = Vector2.new(sp.X, sp.Y)
            ed.line.Color = color
            ed.line.Visible = true

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
        else
            local angle = math.atan2(dir.Z, dir.X)
            local rounded = math.floor(angle * 10) / 10
            alertMap[rounded] = true
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            handleESP(p.Character)
        end
    end

    for _, box in ipairs(workspace:GetChildren()) do
        if box.Name == "AmmoBox2" and box:IsA("MeshPart") then
            local pos = box.Position
            local dist = (pos - Camera.CFrame.Position).Magnitude
            if dist <= maxESPDistance then
                if not ESPdata[box] then
                    local txtName = Drawing.new("Text")
                    txtName.Size = 14
                    txtName.Color = Color3.fromRGB(255, 255, 0)
                    txtName.Outline = true
                    txtName.Center = true

                    local txtDist = Drawing.new("Text")
                    txtDist.Size = 13
                    txtDist.Color = Color3.fromRGB(255, 255, 255)
                    txtDist.Outline = true
                    txtDist.Center = true

                    ESPdata[box] = {
                        name = txtName,
                        dist = txtDist
                    }
                end

                local sp, onScreen = Camera:WorldToViewportPoint(pos)
                local name = ESPdata[box].name
                local distText = ESPdata[box].dist

                name.Text = "[AmmoBox]"
                name.Position = Vector2.new(sp.X, sp.Y)
                name.Visible = onScreen

                distText.Text = math.floor(dist) .. "m"
                distText.Position = Vector2.new(sp.X, sp.Y + 15)
                distText.Visible = onScreen
            else
                if ESPdata[box] then
                    for _, v in pairs(ESPdata[box]) do pcall(function() v:Remove() end) end
                    ESPdata[box] = nil
                end
            end
        end
    end

    counter.Text = "ESP: " .. playerESPCount
    counter.Visible = true

else
    for ent, ed in pairs(ESPdata) do
        for _, v in pairs(ed) do
            if typeof(v) == "table" then
                for _, sub in pairs(v) do pcall(function() sub:Remove() end) end
            else
                pcall(function() v:Remove() end)
            end
        end
    end
    ESPdata = {}
    if counter then counter.Visible = false end
end
if itemPickToggle() then
    local LP = game:GetService("Players").LocalPlayer
    local Mouse = LP:GetMouse()
    local maxItemDistance = 200

    if not gui then
        gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
        gui.Name = "StoreUI"
        gui.ResetOnSpawn = false

        storeFrame = Instance.new("Frame", gui)
        storeFrame.Size = UDim2.new(0, 150, 0, 300)
        storeFrame.Position = UDim2.new(1, -160, 0.5, -150)
        storeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        storeFrame.BorderSizePixel = 0

        local storeLabel = Instance.new("TextLabel", storeFrame)
        storeLabel.Size = UDim2.new(1, 0, 0, 30)
        storeLabel.Text = " TÚI ĐỒ"
        storeLabel.TextColor3 = Color3.new(1, 1, 1)
        storeLabel.BackgroundTransparency = 1
        storeLabel.Font = Enum.Font.GothamBold
        storeLabel.TextSize = 14

        StoreItems = {}
    end

    for obj, txt in pairs(ItemPick) do
        if not obj:IsDescendantOf(workspace) then
            txt:Remove()
            if txt._dragBtn then txt._dragBtn:Destroy() end
            ItemPick[obj] = nil
        else
            txt.Visible = false
        end
    end

    for _, o in pairs(workspace:GetDescendants()) do
        if (o:IsA("Part") or o:IsA("Model")) and (o:FindFirstChildWhichIsA("ProximityPrompt") or o:FindFirstChildWhichIsA("ClickDetector")) then
            local pos = o:IsA("Model") and (o.PrimaryPart and o.PrimaryPart.Position or o:GetPivot().Position) or o.Position
            local dist = (pos - Camera.CFrame.Position).Magnitude
            if dist > maxItemDistance then
                if ItemPick[o] then
                    ItemPick[o]:Remove()
                    if ItemPick[o]._dragBtn then ItemPick[o]._dragBtn:Destroy() end
                    ItemPick[o] = nil
                end
            else
                if not ItemPick[o] then
                    local txt = Drawing.new("Text")
                    txt.Size = 13
                    txt.Color = Color3.fromRGB(0, 255, 255)
                    txt.Center = true
                    txt.Outline = true
                    ItemPick[o] = txt

                    local dragBtn = Instance.new("TextButton", gui)
                    dragBtn.Size = UDim2.new(0, 100, 0, 25)
                    dragBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                    dragBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                    dragBtn.Text = "[Pick] " .. o.Name
                    dragBtn.Font = Enum.Font.SourceSansBold
                    dragBtn.TextSize = 14
                    dragBtn.Position = UDim2.new(0, -9999, 0, -9999)
                    dragBtn.Visible = false
                    ItemPick[o]._dragBtn = dragBtn

                    local dragging = false
                    local offset = Vector2.new()

                    txt.MouseButton1Down = function()
                        dragging = true
                        offset = Vector2.new(Mouse.X - dragBtn.AbsolutePosition.X, Mouse.Y - dragBtn.AbsolutePosition.Y)
                        dragBtn.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
                        dragBtn.Visible = true
                    end

                    game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                            dragging = false
                            local ab = dragBtn.AbsolutePosition
                            local box = storeFrame.AbsolutePosition
                            local size = storeFrame.AbsoluteSize

                            if ab.X >= box.X and ab.X <= box.X + size.X and ab.Y >= box.Y and ab.Y <= box.Y + size.Y then
                                if not StoreItems[o] then
                                    StoreItems[o] = true
                                    local label = Instance.new("TextLabel", storeFrame)
                                    label.Size = UDim2.new(1, 0, 0, 20)
                                    label.Text = o.Name
                                    label.TextColor3 = Color3.new(1, 1, 1)
                                    label.BackgroundTransparency = 1
                                    label.Font = Enum.Font.Gotham
                                    label.TextSize = 13
                                end
                            end

                            dragBtn.Visible = false
                        end
                    end)

                    game:GetService("RunService").RenderStepped:Connect(function()
                        if dragging and dragBtn.Visible then
                            dragBtn.Position = UDim2.new(0, Mouse.X - offset.X, 0, Mouse.Y - offset.Y)
                        end
                    end)
                end

                local sp, on = Camera:WorldToViewportPoint(pos)
                ItemPick[o].Position = Vector2.new(sp.X, sp.Y)
                ItemPick[o].Text = "[Pick] " .. o.Name
                ItemPick[o].Visible = on
            end
        end
    end
end



end)

Players.PlayerRemoving:Connect(function(p)
    if ESPdata[p] then
        for _, d in pairs(ESPdata[p]) do
            if typeof(d) == "table" then
                for _, l in pairs(d) do l:Remove() end
            else
                d:Remove()
            end
        end
        ESPdata[p] = nil
    end
end)


for _, v in pairs(getconnections(LP.Idled)) do v:Disable() end


local hitboxToggle = false

local function updateHead(model)
    local head = model:FindFirstChild("Head")
    local humanoid = model:FindFirstChild("Humanoid")
    if head and humanoid and humanoid.Health > 0 then
        head.Size = Vector3.new(10,10,10)
        head.CanCollide = false
        head.Massless = true
    end
end

RunService.RenderStepped:Connect(function()
    if not hitboxToggle then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Team ~= LP.Team then
            updateHead(p.Character)
        end
    end

    for _, npc in ipairs(workspace:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
            updateHead(npc)
        end
    end
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Cam = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local CurrentTarget = nil
local BulletTrails = {}

-- vẽ line từ tâm → target
local aimLine = Drawing.new("Line")
aimLine.Color = Color3.fromRGB(0, 255, 0)
aimLine.Thickness = 2
aimLine.Transparency = 1
aimLine.Visible = false

-- tìm head gần nhất màn hình
local function getClosestHead()
    local closest, dist = nil, math.huge
    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local pos, vis = Cam:WorldToViewportPoint(head.Position)
                if vis then
                    local d = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                    if d < dist then
                        dist = d
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

-- track bullet tới target + vẽ tracer
local function trackBullet(obj, target)
    local lastPos = obj.Position
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if obj and obj.Parent and target and target.Parent then
            -- hướng đạn
            obj.CFrame = CFrame.new(obj.Position, target.Position)
            obj.Velocity = (target.Position - obj.Position).Unit * 3000

            -- vẽ quỹ đạo
            local pos, vis = Cam:WorldToViewportPoint(obj.Position)
            local lastScreen, vis2 = Cam:WorldToViewportPoint(lastPos)
            if vis and vis2 then
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255, 255, 0)
                line.Thickness = 1.5
                line.Transparency = 1
                line.From = Vector2.new(lastScreen.X, lastScreen.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
                table.insert(BulletTrails, {Line = line, Tick = tick()})
            end
            lastPos = obj.Position
        else
            if conn then conn:Disconnect() end
        end
    end)
end

-- hook shoot event
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "FireServer" and tostring(self):lower():find("shoot") then
        local target = getClosestHead()
        if target then
            CurrentTarget = target
            -- chờ đạn spawn rồi track
            local bulletConn
            bulletConn = Workspace.ChildAdded:Connect(function(obj)
                if obj:IsA("BasePart") and obj.Name:lower():find("bullet") then
                    trackBullet(obj, target)
                    bulletConn:Disconnect()
                end
            end)
        end
    end

    return old(self, ...)
end)

-- update aim line + clear trail
RunService.RenderStepped:Connect(function()
    if CurrentTarget and CurrentTarget.Parent then
        local pos, vis = Cam:WorldToViewportPoint(CurrentTarget.Position)
        if vis then
            local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
            aimLine.From = center
            aimLine.To = Vector2.new(pos.X, pos.Y)
            aimLine.Visible = true
        else
            aimLine.Visible = false
        end
    else
        aimLine.Visible = false
    end

    -- xóa trail sau 0.4s
    for i = #BulletTrails, 1, -1 do
        if tick() - BulletTrails[i].Tick > 0.4 then
            BulletTrails[i].Line:Remove()
            table.remove(BulletTrails, i)
        end
    end
end)