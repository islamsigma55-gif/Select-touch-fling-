local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Wait for character
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local FLING_FORCE = 9500
local FLING_UP = 3500
local BIG_HITBOX_SIZE = Vector3.new(25, 25, 25)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FixedFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 380, 0, 500)
Frame.Position = UDim2.new(0.5, -190, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
Title.Text = "FIXED Power Fling + Big Hitbox"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(0.95, 0, 0, 160)
Scrolling.Position = UDim2.new(0.025, 0, 0.13, 0)
Scrolling.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Scrolling.ScrollBarThickness = 6
Scrolling.Parent = Frame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = Scrolling

local hitboxEnabled = false
local originalSize = nil
local myRoot = nil

local function updateMyRoot()
    if LocalPlayer.Character then
        myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    updateMyRoot()
end)
updateMyRoot()

-- Toggle Big Hitbox
local function toggleBigHitbox(enable)
    local character = LocalPlayer.Character
    if not character then 
        warn("Character not loaded!") 
        return 
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if enable then
        if not originalSize then
            originalSize = root.Size
        end
        root.Size = BIG_HITBOX_SIZE
        root.Transparency = 0.6
        root.CanCollide = true
        hitboxEnabled = true
        print("🟢 BIG HITBOX ENABLED - Light touch now works!")
    else
        if originalSize then
            root.Size = originalSize
            root.Transparency = 0
        end
        hitboxEnabled = false
        print("🔴 Big Hitbox disabled")
    end
end

-- Fling Player
local function flingPlayer(target)
    if not target or not target.Character then
        warn("Target not found or no character!")
        return
    end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    updateMyRoot()
    
    if not targetRoot or not myRoot then
        warn("RootPart missing!")
        return
    end

    -- Stronger & more reliable fling
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = (targetRoot.Position - myRoot.Position).Unit * FLING_FORCE + Vector3.new(0, FLING_UP, 0)
    bv.Parent = targetRoot

    local anchor = Instance.new("BodyVelocity")
    anchor.MaxForce = Vector3.new(1e5, 1, 1e5)
    anchor.Velocity = Vector3.new(0, 0, 0)
    anchor.Parent = myRoot

    game:GetService("Debris"):AddItem(bv, 0.8)
    game:GetService("Debris"):AddItem(anchor, 0.9)

    print("💥 Power Flung: " .. target.Name)
end

-- Text Pusher
local function pushTextElements()
    local count = 0
    updateMyRoot()
    if not myRoot then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or 
           obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            
            local part = obj:FindFirstAncestorWhichIsA("BasePart") or 
                        (obj.Parent and obj.Parent:FindFirstAncestorWhichIsA("BasePart"))
            
            if part and (part.Position - myRoot.Position).Magnitude < 250 then
                local push = Instance.new("BodyVelocity")
                push.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                push.Velocity = (part.Position - myRoot.Position).Unit * 5000 + Vector3.new(0, 2500, 0)
                push.Parent = part
                game:GetService("Debris"):AddItem(push, 0.5)
                count += 1
            end
        end
    end
    print("📜 Pushed " .. count .. " text elements!")
end

-- Player List
local function refreshPlayerList()
    for _, child in ipairs(Scrolling:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Parent = Scrolling
            
            btn.MouseButton1Click:Connect(function()
                flingPlayer(plr)
            end)
        end
    end
    Scrolling.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y)
end

-- GUI Buttons
local HitboxBtn = Instance.new("TextButton")
HitboxBtn.Size = UDim2.new(0.95, 0, 0, 50)
HitboxBtn.Position = UDim2.new(0.025, 0, 0.52, 0)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
HitboxBtn.Text = "Toggle Big Hitbox (for light touch)"
HitboxBtn.TextScaled = true
HitboxBtn.Parent = Frame
HitboxBtn.MouseButton1Click:Connect(function()
    toggleBigHitbox(not hitboxEnabled)
end)

local PushBtn = Instance.new("TextButton")
PushBtn.Size = UDim2.new(0.95, 0, 0, 50)
PushBtn.Position = UDim2.new(0.025, 0, 0.68, 0)
PushBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
PushBtn.Text = "Push Nearby Text / GUIs"
PushBtn.TextScaled = true
PushBtn.Parent = Frame
PushBtn.MouseButton1Click:Connect(pushTextElements)

-- Initialize
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
