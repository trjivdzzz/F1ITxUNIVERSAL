-- Mini Menu by Delta Executor
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 50)
MainFrame.Position = UDim2.new(0.5, -100, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -25, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.white
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 4)
UICorner2.Parent = MinimizeBtn

-- Contenedor horizontal
local TogglesFrame = Instance.new("Frame")
TogglesFrame.Size = UDim2.new(1, -40, 1, 0)
TogglesFrame.BackgroundTransparency = 1
TogglesFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = TogglesFrame

-- Toggle F1
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0, 80, 0, 30)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SpeedToggle.Text = "F1: OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.Parent = TogglesFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = SpeedToggle

-- Toggle IT
local InstaTakeToggle = Instance.new("TextButton")
InstaTakeToggle.Size = UDim2.new(0, 80, 0, 30)
InstaTakeToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
InstaTakeToggle.Text = "IT: OFF"
InstaTakeToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
InstaTakeToggle.Font = Enum.Font.SourceSansBold
InstaTakeToggle.Parent = TogglesFrame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 6)
UICorner4.Parent = InstaTakeToggle

-- Variables
local SpeedEnabled = false
local InstaTakeEnabled = false
local OriginalWalkSpeed = 16

-- Función velocidad
local function updateSpeed()
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
        if SpeedEnabled then
            Humanoid.WalkSpeed = 120
            SpeedToggle.Text = "F1: ON"
            SpeedToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Humanoid.WalkSpeed = OriginalWalkSpeed
            SpeedToggle.Text = "F1: OFF"
            SpeedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

-- Función Instant Take
local function pickupItem(part)
    if InstaTakeEnabled and part and part:IsA("BasePart") then
        local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
    end
end

-- Evento para recoger items
game:GetService("RunService").Heartbeat:Connect(function()
    if InstaTakeEnabled and Character then
        local root = Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, part in ipairs(workspace:GetPartsInRadius(root.Position, 10)) do
                if part:FindFirstChildWhichIsA("ProximityPrompt") then
                    task.spawn(pickupItem, part)
                end
            end
        end
    end
end)

-- Toggles
SpeedToggle.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    updateSpeed()
end)

InstaTakeToggle.MouseButton1Click:Connect(function()
    InstaTakeEnabled = not InstaTakeEnabled
    if InstaTakeEnabled then
        InstaTakeToggle.Text = "IT: ON"
        InstaTakeToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        InstaTakeToggle.Text = "IT: OFF"
        InstaTakeToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Minimizar
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 200, 0, 30)
        TogglesFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, 50)
        TogglesFrame.Visible = true
        MinimizeBtn.Text = "_"
    end
end)

-- Arrastrar
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    if dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateInput(input)
    end
end)

-- Inicializar
if Character:FindFirstChild("Humanoid") then
    OriginalWalkSpeed = Character.Humanoid.WalkSpeed
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(1)
    if Character:FindFirstChild("Humanoid") then
        OriginalWalkSpeed = Character.Humanoid.WalkSpeed
        updateSpeed()
    end
end)
