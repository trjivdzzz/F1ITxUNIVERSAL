-- Mini Menu Delta Executor
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Crear UI simple
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniMenuDelta"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 40)
MainFrame.Position = UDim2.new(0.5, -90, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
MainFrame.Parent = ScreenGui

-- Minimizar/Maximizar
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -25, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

-- Interruptores en horizontal
local F1Btn = Instance.new("TextButton")
F1Btn.Size = UDim2.new(0, 70, 0, 30)
F1Btn.Position = UDim2.new(0, 10, 0, 5)
F1Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
F1Btn.Text = "F1: OFF"
F1Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
F1Btn.Font = Enum.Font.SourceSansBold
F1Btn.TextSize = 14
F1Btn.Parent = MainFrame

local ITBtn = Instance.new("TextButton")
ITBtn.Size = UDim2.new(0, 70, 0, 30)
ITBtn.Position = UDim2.new(0, 90, 0, 5)
ITBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
ITBtn.Text = "IT: OFF"
ITBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
ITBtn.Font = Enum.Font.SourceSansBold
ITBtn.TextSize = 14
ITBtn.Parent = MainFrame

-- Variables de estado
local velocidadActiva = false
local instaTakeActivo = false
local minimizado = false
local arrastrando = false
local inicioArrastre
local posicionInicial

-- Función velocidad F1
local function controlVelocidad()
    if velocidadActiva then
        F1Btn.Text = "F1: ON"
        F1Btn.TextColor3 = Color3.fromRGB(80, 255, 80)
        
        -- Aplicar velocidad
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 120
        end
    else
        F1Btn.Text = "F1: OFF"
        F1Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        -- Restaurar velocidad normal
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end
end

-- Función Instant Take IT
local function controlInstaTake()
    if instaTakeActivo then
        ITBtn.Text = "IT: ON"
        ITBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        ITBtn.Text = "IT: OFF"
        ITBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

-- Evento para detectar y recoger items
game:GetService("RunService").Heartbeat:Connect(function()
    if not instaTakeActivo then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Buscar proximity prompts cerca
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                -- Verificar distancia
                local pos = obj:IsA("BasePart") and obj.Position or obj:GetPivot().Position
                if (root.Position - pos).Magnitude <= prompt.MaxActivationDistance then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)

-- Eventos de clic
F1Btn.MouseButton1Click:Connect(function()
    velocidadActiva = not velocidadActiva
    controlVelocidad()
end)

ITBtn.MouseButton1Click:Connect(function()
    instaTakeActivo = not instaTakeActivo
    controlInstaTake()
end)

-- Minimizar
MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        MainFrame.Size = UDim2.new(0, 180, 0, 20)
        F1Btn.Visible = false
        ITBtn.Visible = false
        MinBtn.Text = "+"
        MinBtn.Position = UDim2.new(1, -25, 0, 0)
    else
        MainFrame.Size = UDim2.new(0, 180, 0, 40)
        F1Btn.Visible = true
        ITBtn.Visible = true
        MinBtn.Text = "-"
        MinBtn.Position = UDim2.new(1, -25, 0, 5)
    end
end)

-- Arrastrar UI
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastrando = true
        inicioArrastre = input.Position
        posicionInicial = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if arrastrando and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - inicioArrastre
        MainFrame.Position = UDim2.new(
            posicionInicial.X.Scale,
            posicionInicial.X.Offset + delta.X,
            posicionInicial.Y.Scale,
            posicionInicial.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastrando = false
    end
end)

-- Actualizar cuando el jugador respawnea
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    if velocidadActiva then
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 120
        end
    end
end)

-- Inicializar
controlVelocidad()
controlInstaTake()

print("✅ Mini Menu Delta cargado: F1 (Velocidad) | IT (Instant Take)")
