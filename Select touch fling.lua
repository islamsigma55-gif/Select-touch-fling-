-- Powerful Fling + Big Hitbox + Text Pusher (English)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- SETTINGS
local FLING_FORCE = 8500
local FLING_UP = 3200
local BIG_HITBOX_SIZE = Vector3.new(20, 20, 20)  -- Big hitbox (adjust if needed)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedFlingGUI"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 380, 0, 480)
Frame.Position = UDim2.new(0.5, -190, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
Title.Text = "Power Fling + Big Hitbox"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Scrolling player list
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(0.95, 0, 0, 160)
Scrolling.Position = UDim2.new(0.025, 0, 0.12, 0)
Scrolling.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Scrolling.ScrollBarThickness = 8
Scrolling.Parent = Frame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 4)
UIList.Parent = Scrolling

local hitboxEnabled = false
local originalSize = nil

-- Big Hitbox Function
local function toggleBigHitbox(enable)
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if enable then
        if not originalSize then
            originalSize = root.Size
        end
        root.Size = BIG_HITBOX_SIZE
        root.Transparency = 0.7  -- semi-transparent so you can still see
        hitboxEnabled = true
        print("🟢 Big Hitbox ENABLED (Light touch fling)")
    else
        if originalSize then
            root.Size = originalSize
            root.Transparency = 0
        end
        hitboxEnabled = false
        print("🔴 Big Hitbox DISABLED")
    end
end

-- Refresh player list
local function refreshPlayerList()
    for _, child in ipairs(Scrolling:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = plr.Name .. "  (" .. (plr.DisplayName or plr.Name) .. ")"
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Parent = Scrolling
            
            btn.MouseButton1Click:Connect(function()
                flingPlayer(plr)
            end)
        end
    end
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end

-- Power Fling Function
local function flingPlayer(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        warn("Target not found!")
        return
    end
    
    local targetRoot = target.Character.HumanoidRootPart
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = (targetRoot.Position - myRoot.Position).Unit * FLING_FORCE + Vector3.new(0, FLING_UP, 0)
    bv.Parent = targetRoot

    local anchor = Instance.new("BodyVelocity")
    anchor.MaxForce = Vector3.new(math.huge, 0, math.huge)
    anchor.Velocity = Vector3.new(0, 0, 0)
    anchor.Parent = myRoot

    game:GetService("Debris"):AddItem(bv, 0.7)
    game:GetService("Debris"):AddItem(anchor, 0.8)

    print("💥 Power Flung: " .. target.Name)
end

-- Text / GUI Pusher
local function pushTextElements()
    local count = 0
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or 
           obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            
            local part = obj:FindFirstAncestorWhichIsA("BasePart") 
                      or (obj.Parent and obj.Parent:FindFirstAncestorWhichIsA("BasePart"))
            
            if part and (part.Position - myRoot.Position).Magnitude < 200 then
                local push = Instance.new("BodyVelocity")
                push.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                push.Velocity = (part.Position - myRoot.Position).Unit * 4500 + Vector3.new(0, 2200, 0)
                push.Parent = part
                
                game:GetService("Debris"):AddItem(push, 0.5)
                count += 1
            end
        end
    end
    print("📜 Pushed " .. count .. " text/GUI elements!")
end

-- GUI Buttons
local HitboxBtn = Instance.new("TextButton")
HitboxBtn.Size = UDim2.new(0.95, 0, 0, 45)
HitboxBtn.Position = UDim2.new(0.025, 0, 0.55, 0)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
HitboxBtn.Text = "Toggle Big Hitbox (Light Touch)"
HitboxBtn.TextScaled = true
HitboxBtn.Parent = Frame

HitboxBtn.MouseButton1Click:Connect(function()
    toggleBigHitbox(not hitboxEnabled)
end)

local PushBtn = Instance.new("TextButton")
PushBtn.Size = UDim2.new(0.95, 0, 0, 45)
PushBtn.Position = UDim2.new(0.025, 0, 0.68, 0)
PushBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
PushBtn.Text = "Push Nearby Text / Signs / GUIs"
PushBtn.TextScaled = true
PushBtn.Parent = Frame

PushBtn.MouseButton1Click:Connect(pushTextElements)

-- Load player list
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

print("✅ GUI Loaded! Use Big Hitbox for easy light-touch flings.")
