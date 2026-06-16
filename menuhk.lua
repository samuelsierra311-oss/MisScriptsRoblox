-- Evitar que se duplique la interfaz
local antiguoUI = game:GetService("CoreGui"):FindFirstChild("UniversalHubUI")
if antiguoUI then antiguoUI:Destroy() end

-- Servicios de Roblox
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Guardar configuración original de la iluminación
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient

-- Estados y Keybinds
local fbActivo = false
local fbKeybind = Enum.KeyCode.F
local cambiandoFbKey = false

local noclipActivo = false
local ncKeybind = Enum.KeyCode.N
local cambiandoNcKey = false

local infJumpActivo = false
local ijKeybind = Enum.KeyCode.J
local cambiandoIjKey = false

local clickTpActivo = false
local tpKeybind = Enum.KeyCode.T
local cambiandoTpKey = false

local volarActivo = false
local flyKeybind = Enum.KeyCode.E
local cambiandoFlyKey = false
local flySpeed = 50

local espActivo = false
local touchBringActivo = false

local velocidadActual = 16 
local saltoActual = 50 -- Valor base del JumpPower de Roblox
local menuMinimizado = false
local temaOscuro = true

-- --- TABLA DE COLORES PARA TEMAS ---
local Temas = {
    Oscuro = {
        Fondo = Color3.fromRGB(30, 30, 30),
        Contenedores = Color3.fromRGB(40, 40, 40),
        TextoPrincipal = Color3.fromRGB(255, 255, 255),
        TextoSecundario = Color3.fromRGB(200, 200, 200),
        BotonesSecundarios = Color3.fromRGB(55, 55, 55),
        BarraSlider = Color3.fromRGB(70, 70, 70)
    },
    Claro = {
        Fondo = Color3.fromRGB(240, 240, 240),
        Contenedores = Color3.fromRGB(225, 225, 225),
        TextoPrincipal = Color3.fromRGB(30, 30, 30),
        TextoSecundario = Color3.fromRGB(70, 70, 70),
        BotonesSecundarios = Color3.fromRGB(200, 200, 200),
        BarraSlider = Color3.fromRGB(170, 170, 170)
    },
    AcentoRojo = Color3.fromRGB(180, 40, 40),
    AcentoVerde = Color3.fromRGB(40, 180, 40)
}

-- --- CREACIÓN DE LA INTERFAZ ---
local UniversalHubUI = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner_Main = Instance.new("UICorner")
local MinimizeBtn = Instance.new("TextButton")
local ThemeBtn = Instance.new("TextButton")
local OpenBtn = Instance.new("TextButton")
local UICorner_Open = Instance.new("UICorner")

UniversalHubUI.Name = "UniversalHubUI"
UniversalHubUI.Parent = CoreGui
UniversalHubUI.ResetOnSpawn = false

-- Panel Principal
MainFrame.Name = "MainFrame"
MainFrame.Parent = UniversalHubUI
MainFrame.BackgroundColor3 = Temas.Oscuro.Fondo
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 410)
MainFrame.Active = true
MainFrame.Draggable = true 

UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainFrame

-- Botones de Control Superior
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = MainFrame
MinimizeBtn.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
MinimizeBtn.Position = UDim2.new(1, -25, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Temas.Oscuro.TextoPrincipal
MinimizeBtn.TextSize = 16
local UICorner_Min = Instance.new("UICorner") UICorner_Min.CornerRadius = UDim.new(0, 4) UICorner_Min.Parent = MinimizeBtn

ThemeBtn.Name = "ThemeBtn"
ThemeBtn.Parent = MainFrame
ThemeBtn.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
ThemeBtn.Position = UDim2.new(1, -50, 0, 8)
ThemeBtn.Size = UDim2.new(0, 20, 0, 20)
ThemeBtn.Font = Enum.Font.SourceSansBold
ThemeBtn.Text = "🌓"
ThemeBtn.TextColor3 = Temas.Oscuro.TextoPrincipal
ThemeBtn.TextSize = 12
local UICorner_Theme = Instance.new("UICorner") UICorner_Theme.CornerRadius = UDim.new(0, 4) UICorner_Theme.Parent = ThemeBtn

-- Botón Flotante
OpenBtn.Name = "OpenBtn"
OpenBtn.Parent = UniversalHubUI
OpenBtn.BackgroundColor3 = Temas.AcentoRojo
OpenBtn.Position = UDim2.new(0.02, 0, 0.1, 0)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Text = "HUB"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 14
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
UICorner_Open.CornerRadius = UDim.new(0, 23)
UICorner_Open.Parent = OpenBtn

-- --- SISTEMA DE PESTAÑAS (TABS) ---
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 8)
TabContainer.Size = UDim2.new(0, 210, 0, 25)

local TabHacksBtn = Instance.new("TextButton")
TabHacksBtn.Parent = TabContainer
TabHacksBtn.Size = UDim2.new(0, 100, 1, 0)
TabHacksBtn.BackgroundColor3 = Temas.Oscuro.Contenedores
TabHacksBtn.Font = Enum.Font.SourceSansBold
TabHacksBtn.Text = "Hacks"
TabHacksBtn.TextColor3 = Temas.Oscuro.TextoPrincipal
TabHacksBtn.TextSize = 13
local cth = Instance.new("UICorner") cth.CornerRadius = UDim.new(0, 4) cth.Parent = TabHacksBtn

local TabItemsBtn = Instance.new("TextButton")
TabItemsBtn.Parent = TabContainer
TabItemsBtn.Position = UDim2.new(0, 105, 0, 0)
TabItemsBtn.Size = UDim2.new(0, 100, 1, 0)
TabItemsBtn.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
TabItemsBtn.Font = Enum.Font.SourceSansBold
TabItemsBtn.Text = "Objetos / Vis"
TabItemsBtn.TextColor3 = Temas.Oscuro.TextoSecundario
TabItemsBtn.TextSize = 13
local cti = Instance.new("UICorner") cti.CornerRadius = UDim.new(0, 4) cti.Parent = TabItemsBtn

-- Contenedores de contenido de pestañas
local ContentHacks = Instance.new("ScrollingFrame")
ContentHacks.Parent = MainFrame
ContentHacks.BackgroundTransparency = 1
ContentHacks.Position = UDim2.new(0, 0, 0, 40)
ContentHacks.Size = UDim2.new(1, 0, 1, -40)
ContentHacks.CanvasSize = UDim2.new(0, 0, 0, 480)
ContentHacks.ScrollBarThickness = 2

local ContentItems = Instance.new("ScrollingFrame")
ContentItems.Parent = MainFrame
ContentItems.BackgroundTransparency = 1
ContentItems.Position = UDim2.new(0, 0, 0, 40)
ContentItems.Size = UDim2.new(1, 0, 1, -40)
ContentItems.CanvasSize = UDim2.new(0, 0, 0, 400)
ContentItems.Visible = false
ContentItems.ScrollBarThickness = 2

-- Intercambio de Pestañas
TabHacksBtn.MouseButton1Click:Connect(function()
    ContentHacks.Visible = true; ContentItems.Visible = false
    TabHacksBtn.BackgroundColor3 = temaOscuro and Temas.Oscuro.Contenedores or Temas.Claro.Contenedores
    TabItemsBtn.BackgroundColor3 = temaOscuro and Temas.Oscuro.BotonesSecundarios or Temas.Claro.BotonesSecundarios
end)
TabItemsBtn.MouseButton1Click:Connect(function()
    ContentHacks.Visible = false; ContentItems.Visible = true
    TabItemsBtn.BackgroundColor3 = temaOscuro and Temas.Oscuro.Contenedores or Temas.Claro.Contenedores
    TabHacksBtn.BackgroundColor3 = temaOscuro and Temas.Oscuro.BotonesSecundarios or Temas.Claro.BotonesSecundarios
end)

-- --- GENERADOR DE COMPONENTES ---
local function crearFilaInteractiva(parent, yPos, textoBtn, textoBind)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 160, 0, 30)
    btn.Text = textoBtn
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Temas.AcentoRojo
    local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 5) c1.Parent = btn

    local bind = Instance.new("TextButton")
    bind.Parent = parent
    bind.Position = UDim2.new(0, 180, 0, yPos)
    bind.Size = UDim2.new(0, 90, 0, 30)
    bind.Text = "Bind: " .. textoBind
    bind.Font = Enum.Font.SourceSans
    bind.TextSize = 12
    bind.TextColor3 = Temas.Oscuro.TextoPrincipal
    bind.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
    local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 5) c2.Parent = bind

    return btn, bind
end

local function crearSliderCompleto(parent, yPos, titulo, min, max, baseVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent; Frame.BackgroundTransparency = 1; Frame.Position = UDim2.new(0, 10, 0, yPos); Frame.Size = UDim2.new(0, 260, 0, 65)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 0, 15)
    Label.Font = Enum.Font.SourceSansBold; Label.Text = titulo .. ": " .. baseVal; Label.TextColor3 = Temas.Oscuro.TextoSecundario; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("TextButton")
    Bar.Parent = Frame; Bar.BackgroundColor3 = Temas.Oscuro.BarraSlider; Bar.Position = UDim2.new(0, 0, 0, 18); Bar.Size = UDim2.new(1, 0, 0, 6); Bar.Text = ""; Bar.AutoButtonColor = false
    local cb = Instance.new("UICorner") cb.CornerRadius = UDim.new(0, 3) cb.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Parent = Bar; Fill.BackgroundColor3 = Temas.AcentoRojo; Fill.Size = UDim2.new((baseVal-min)/(max-min), 0, 1, 0)
    local cf = Instance.new("UICorner") cf.CornerRadius = UDim.new(0, 3) cf.Parent = Fill

    local MultContainer = Instance.new("Frame")
    MultContainer.Parent = Frame; MultContainer.BackgroundTransparency = 1; MultContainer.Position = UDim2.new(0, 0, 0, 28); MultContainer.Size = UDim2.new(1, 0, 0, 20)

    local lista = {2, 3, 4, 5, 8, 10}
    local listaBotonesMult = {}
    for i, m in ipairs(lista) do
        local mb = Instance.new("TextButton")
        mb.Parent = MultContainer; mb.Size = UDim2.new(0, 38, 1, 0); mb.Position = UDim2.new(0, (i-1) * 44, 0, 0)
        mb.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios; mb.Font = Enum.Font.SourceSansBold; mb.Text = "x" .. m; mb.TextColor3 = Temas.Oscuro.TextoPrincipal; mb.TextSize = 11
        local cmc = Instance.new("UICorner") cmc.CornerRadius = UDim.new(0, 4) cmc.Parent = mb
        table.insert(listaBotonesMult, mb)

        mb.MouseButton1Click:Connect(function()
            local v = math.clamp(baseVal * m, min, max)
            Label.Text = titulo .. ": " .. v
            TweenService:Create(Fill, TweenInfo.new(0.15), {Size = UDim2.new((v - min) / (max - min), 0, 1, 0)}):Play()
            callback(v)
        end)
    end

    -- Control deslizante manual
    local arrastrando = false
    local function actualizar()
        local p = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        local v = math.floor(min + (p * (max - min)))
        Label.Text = titulo .. ": " .. v
        callback(v)
    end
    Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then arrastrando = true; actualizar() end end)
    UserInputService.InputChanged:Connect(function(i) if arrastrando and i.UserInputType == Enum.UserInputType.MouseMovement then actualizar() end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then arrastrando = false end end)

    return Frame, Label, Bar, Fill, listaBotonesMult
end

-- --- CONSTRUCCIÓN CONTENIDO: PESTAÑA HACKS ---
local ToggleBtn, BindBtn = crearFilaInteractiva(ContentHacks, 10, "FullBright: OFF", fbKeybind.Name)
local NoclipToggleBtn, NoclipBindBtn = crearFilaInteractiva(ContentHacks, 50, "Noclip: OFF", ncKeybind.Name)
local InfJumpToggleBtn, InfJumpBindBtn = crearFilaInteractiva(ContentHacks, 90, "Inf Jump: OFF", ijKeybind.Name)
local ClickTpToggleBtn, ClickTpBindBtn = crearFilaInteractiva(ContentHacks, 130, "Click TP: OFF", "Ctrl+Clk")
local FlyToggleBtn, FlyBindBtn = crearFilaInteractiva(ContentHacks, 170, "Fly (Vuelo): OFF", flyKeybind.Name)

local _, SpeedLabel, SpeedBar, SpeedFill, mButtonsSpeed = crearSliderCompleto(ContentHacks, 215, "Velocidad WalkSpeed", 16, 250, 16, function(v) velocidadActual = v end)
local _, JumpLabel, JumpBar, JumpFill, mButtonsJump = crearSliderCompleto(ContentHacks, 290, "Poder de Salto", 50, 400, 50, function(v) saltoActual = v end)

-- Slider de velocidad de Vuelo (Sin multiplicadores fijos)
local FlySliderFrame = Instance.new("Frame") FlySliderFrame.Parent = ContentHacks; FlySliderFrame.BackgroundTransparency = 1; FlySliderFrame.Position = UDim2.new(0, 10, 0, 365); FlySliderFrame.Size = UDim2.new(0, 260, 0, 35)
local FlySliderLabel = Instance.new("TextLabel") FlySliderLabel.Parent = FlySliderFrame; FlySliderLabel.BackgroundTransparency = 1; FlySliderLabel.Size = UDim2.new(1, 0, 0, 15); FlySliderLabel.Font = Enum.Font.SourceSansBold; FlySliderLabel.Text = "Velocidad de Vuelo: 50"; FlySliderLabel.TextColor3 = Temas.Oscuro.TextoSecundario; FlySliderLabel.TextSize = 12; FlySliderLabel.TextXAlignment = Enum.TextXAlignment.Left
local FlySliderBar = Instance.new("TextButton") FlySliderBar.Parent = FlySliderFrame; FlySliderBar.BackgroundColor3 = Temas.Oscuro.BarraSlider; FlySliderBar.Position = UDim2.new(0, 0, 0, 18); FlySliderBar.Size = UDim2.new(1, 0, 0, 6); FlySliderBar.Text = ""
local FlySliderFill = Instance.new("Frame") FlySliderFill.Parent = FlySliderBar; FlySliderFill.BackgroundColor3 = Temas.AcentoRojo; FlySliderFill.Size = UDim2.new(0.16, 0, 1, 0)
local f_arrastra = false
FlySliderBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then f_arrastra = true local p = math.clamp((UserInputService:GetMouseLocation().X - FlySliderBar.AbsolutePosition.X) / FlySliderBar.AbsoluteSize.X, 0, 1) FlySliderFill.Size = UDim2.new(p,0,1,0) flySpeed = math.floor(10 + (p*240)) FlySliderLabel.Text = "Velocidad de Vuelo: "..flySpeed end end)
UserInputService.InputChanged:Connect(function(i) if f_arrastra and i.UserInputType == Enum.UserInputType.MouseMovement then local p = math.clamp((UserInputService:GetMouseLocation().X - FlySliderBar.AbsolutePosition.X) / FlySliderBar.AbsoluteSize.X, 0, 1) FlySliderFill.Size = UDim2.new(p,0,1,0) flySpeed = math.floor(10 + (p*240)) FlySliderLabel.Text = "Velocidad de Vuelo: "..flySpeed end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then f_arrastra = false end end)


-- --- CONSTRUCCIÓN CONTENIDO: PESTAÑA OBJETOS / VISUALES ---
local EspToggleBtn = Instance.new("TextButton")
EspToggleBtn.Parent = ContentItems; EspToggleBtn.Position = UDim2.new(0, 10, 0, 10); EspToggleBtn.Size = UDim2.new(0, 260, 0, 32); EspToggleBtn.Text = "ESP Jugadores: OFF"; EspToggleBtn.Font = Enum.Font.SourceSansBold; EspToggleBtn.TextSize = 13; EspToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); EspToggleBtn.BackgroundColor3 = Temas.AcentoRojo
local ce1 = Instance.new("UICorner") ce1.CornerRadius = UDim.new(0, 5) ce1.Parent = EspToggleBtn

-- Botón Touch & Bring (Escaneo inteligente al tocar)
local TouchBringToggleBtn = Instance.new("TextButton")
TouchBringToggleBtn.Parent = ContentItems; TouchBringToggleBtn.Position = UDim2.new(0, 10, 0, 50); TouchBringToggleBtn.Size = UDim2.new(0, 260, 0, 32); TouchBringToggleBtn.Text = "Touch & Bring Items: OFF"; TouchBringToggleBtn.Font = Enum.Font.SourceSansBold; TouchBringToggleBtn.TextSize = 13; TouchBringToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); TouchBringToggleBtn.BackgroundColor3 = Temas.AcentoRojo
local ce2 = Instance.new("UICorner") ce2.CornerRadius = UDim.new(0, 5) ce2.Parent = TouchBringToggleBtn

-- Botón de Bring General (Escaneo global instantáneo)
local GlobalBringBtn = Instance.new("TextButton")
GlobalBringBtn.Parent = ContentItems; GlobalBringBtn.Position = UDim2.new(0, 10, 0, 95); GlobalBringBtn.Size = UDim2.new(0, 260, 0, 35); GlobalBringBtn.Text = "⚡ Escanear y Traer Todos los Items Sueltos"; GlobalBringBtn.Font = Enum.Font.SourceSansBold; GlobalBringBtn.TextSize = 13; GlobalBringBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GlobalBringBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
local ce3 = Instance.new("UICorner") ce3.CornerRadius = UDim.new(0, 5) ce3.Parent = GlobalBringBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = ContentItems; InfoLabel.BackgroundTransparency = 1; InfoLabel.Position = UDim2.new(0, 12, 0, 140); InfoLabel.Size = UDim2.new(0, 256, 0, 100); InfoLabel.Font = Enum.Font.SourceSansItalic; InfoLabel.Text = "El escáner analiza todo el espacio en busca de herramientas (Tools) sueltas o carpetas interactivas con disparadores. 'Touch & Bring' te permite succionar el ítem con solo chocarlo."; InfoLabel.TextColor3 = Temas.Oscuro.TextoSecundario; InfoLabel.TextSize = 12; InfoLabel.TextWrapped = true; InfoLabel.TextYAlignment = Enum.TextYAlignment.Top


-- --- LÓGICA DE DETECCIÓN Y RECOLECCIÓN DE OBJETOS (BRING ITEMS) ---
local function recolectarItemEstructurado(obj)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = LocalPlayer.Character.HumanoidRootPart.CFrame
    
    -- Caso 1: Es un objeto equipable directo (Tool) tirado en el suelo
    if obj:IsA("Tool") and obj:FindFirstChildOfClass("Part") then
        obj:FindFirstChildOfClass("Part").CFrame = targetPos
    -- Caso 2: Es un objeto dentro de una carpeta con disparador de proximidad
    elseif obj:IsA("ProximityPrompt") then
        fireproximityprompt(obj)
    -- Caso 3: Es un bloque interactivo con un transmisor táctil (TouchTransmitter)
    elseif obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Parent, 0)
        task.wait(0.02)
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Parent, 1)
    end
end

-- Ejecución Global de Recolección (Trae herramientas sueltas mapeadas)
GlobalBringBtn.MouseButton1Click:Connect(function()
    local conteo = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Parent == workspace then
            recolectarItemEstructurado(v)
            conteo = conteo + 1
        end
    end
    GlobalBringBtn.Text = "¡Traídos " .. conteo .. " Objetos Sueltos!"
    task.delay(2, function() GlobalBringBtn.Text = "⚡ Escanear y Traer Todos los Items Sueltos" end)
end)

-- Sistema Touch & Bring Interactivo
TouchBringToggleBtn.MouseButton1Click:Connect(function()
    touchBringActivo = not touchBringActivo
    TouchBringToggleBtn.Text = touchBringActivo and "Touch & Bring: ON" or "Touch & Bring: OFF"
    local col = touchBringActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(TouchBringToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart").Touched:Connect(function(hit)
        if not touchBringActivo then return end
        if hit.Parent:IsA("Tool") then
            recolectarItemEstructurado(hit.Parent)
        else
            local prompt = hit:FindFirstChildOfClass("ProximityPrompt") or hit.Parent:FindFirstChildOfClass("ProximityPrompt")
            local touch = hit:FindFirstChildOfClass("TouchTransmitter")
            if prompt then recolectarItemEstructurado(prompt)
            elseif touch then recolectarItemEstructurado(touch) end
        end
    end)
end)

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.Character.HumanoidRootPart.Touched:Connect(function(hit)
        if not touchBringActivo then return end
        if hit.Parent:IsA("Tool") then
            recolectarItemEstructurado(hit.Parent)
        else
            local prompt = hit:FindFirstChildOfClass("ProximityPrompt") or hit.Parent:FindFirstChildOfClass("ProximityPrompt")
            local touch = hit:FindFirstChildOfClass("TouchTransmitter")
            if prompt then recolectarItemEstructurado(prompt)
            elseif touch then recolectarItemEstructurado(touch) end
        end
    end)
end


-- --- LÓGICA DE FLY (MODO VUELO COMPATIBLE) ---
local flyBodyGyro, flyBodyVelocity
local keysDown = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

local function iniciarVuelo()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4; flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9); flyBodyGyro.cframe = hrp.CFrame; flyBodyGyro.Parent = hrp
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0, 0.1, 0); flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9); flyBodyVelocity.Parent = hrp
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    task.spawn(function()
        while volarActivo and hrp and flyBodyVelocity and flyBodyGyro do
            local camCFrame = workspace.CurrentCamera.CFrame
            local dir = Vector3.new(0,0,0)
            
            if keysDown.W then dir = dir + camCFrame.LookVector end
            if keysDown.S then dir = dir - camCFrame.LookVector end
            if keysDown.A then dir = dir - camCFrame.RightVector end
            if keysDown.D then dir = dir + camCFrame.RightVector end
            if keysDown.Space then dir = dir + Vector3.new(0, 1, 0) end
            if keysDown.LeftShift then dir = dir - Vector3.new(0, 1, 0) end
            
            flyBodyVelocity.velocity = dir.Unit.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new(0, 0.1, 0)
            flyBodyGyro.cframe = camCFrame
            RunService.RenderStepped:Wait()
        end
    end)
end

local function detenerVuelo()
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

local function alternarFly()
    volarActivo = not volarActivo
    FlyToggleBtn.Text = volarActivo and "Fly (Vuelo): ON" or "Fly (Vuelo): OFF"
    local c = volarActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(FlyToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
    if volarActivo then iniciarVuelo() else detenerVuelo() end
end
FlyToggleBtn.MouseButton1Click:Connect(alternarFly)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then keysDown.W = true
    elseif input.KeyCode == Enum.KeyCode.S then keysDown.S = true
    elseif input.KeyCode == Enum.KeyCode.A then keysDown.A = true
    elseif input.KeyCode == Enum.KeyCode.D then keysDown.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then keysDown.Space = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keysDown.W = false
    elseif input.KeyCode == Enum.KeyCode.S then keysDown.S = false
    elseif input.KeyCode == Enum.KeyCode.A then keysDown.A = false
    elseif input.KeyCode == Enum.KeyCode.D then keysDown.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then keysDown.Space = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then keysDown.LeftShift = false end
end)


-- --- LÓGICA DE ESP (RASTRADOR VISUAL DE JUGADORES) ---
local contenedoresESP = {}

local function crearEspParaJugador(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        if not espActivo then return end
        task.wait(0.5)
        if char:FindFirstChild("HumanoidRootPart") and not char.HumanoidRootPart:FindFirstChild("BoxESP") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "BoxESP"; box.Size = Vector3.new(4, 5.5, 4); box.AlwaysOnTop = true; box.ZIndex = 5
            box.Adornee = char.HumanoidRootPart; box.Color3 = Color3.fromRGB(255, 40, 40); box.Transparency = 0.6
            box.Parent = char.HumanoidRootPart
            table.insert(contenedoresESP, box)
        end
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character.HumanoidRootPart:FindFirstChild("BoxESP") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "BoxESP"; box.Size = Vector3.new(4, 5.5, 4); box.AlwaysOnTop = true; box.ZIndex = 5
        box.Adornee = player.Character.HumanoidRootPart; box.Color3 = Color3.fromRGB(255, 40, 40); box.Transparency = 0.6
        box.Parent = player.Character.HumanoidRootPart
        table.insert(contenedoresESP, box)
    end
end

EspToggleBtn.MouseButton1Click:Connect(function()
    espActivo = not espActivo
    EspToggleBtn.Text = espActivo and "ESP Jugadores: ON" or "ESP Jugadores: OFF"
    local c = espActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(EspToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
    
    if espActivo then
        for _, p in pairs(Players:GetPlayers()) do crearEspParaJugador(p) end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "BoxESP" then v:Destroy() end
        end
        contenedoresESP = {}
    end
end)
Players.PlayerAdded:Connect(crearEspParaJugador)


-- --- INTERRUPTOR DE TEMA (OSCURO / CLARO MODIFICADO) ---
local listaBindsTema = {BindBtn, NoclipBindBtn, InfJumpBindBtn, ClickTpBindBtn, FlyBindBtn}
local mButtonsAmbosSliders = {mButtonsSpeed, mButtonsJump}

ThemeBtn.MouseButton1Click:Connect(function()
    temaOscuro = not temaOscuro
    local t = temaOscuro and Temas.Oscuro or Temas.Claro
    
    TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundColor3 = t.Fondo}):Play()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    TweenService:Create(ThemeBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    
    for _, b in pairs(listaBindsTema) do
        TweenService:Create(b, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    end
    
    for _, grupo en pairs(mButtonsAmbosSliders) do
        for _, mb in pairs(grupo) do
            TweenService:Create(mb, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
        end
    end
    
    SpeedLabel.TextColor3 = t.TextoSecundario
    JumpLabel.TextColor3 = t.TextoSecundario
    FlySliderLabel.TextColor3 = t.TextoSecundario
    InfoLabel.TextColor3 = t.TextoSecundario
    TweenService:Create(SpeedBar, TweenInfo.new(0.25), {BackgroundColor3 = t.BarraSlider}):Play()
    TweenService:Create(JumpBar, TweenInfo.new(0.25), {BackgroundColor3 = t.BarraSlider}):Play()
    TweenService:Create(FlySliderBar, TweenInfo.new(0.25), {BackgroundColor3 = t.BarraSlider}):Play()
end)


-- --- LÓGICA DE MINIMIZAR ---
local function alternarMenu()
    menuMinimizado = not menuMinimizado
    MainFrame.Visible = not menuMinimizado
    OpenBtn.Visible = menuMinimizado
end
MinimizeBtn.MouseButton1Click:Connect(alternarMenu)
OpenBtn.MouseButton1Click:Connect(alternarMenu)


-- --- LÓGICA DE CLICK TELEPORT ---
local function alternarClickTp()
    clickTpActivo = not clickTpActivo
    local c = clickTpActivo and Temas.AcentoVerde or Temas.AcentoRojo
    ClickTpToggleBtn.Text = clickTpActivo and "Click TP: ON" or "Click TP: OFF"
    TweenService:Create(ClickTpToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
end
ClickTpToggleBtn.MouseButton1Click:Connect(alternarClickTp)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if clickTpActivo and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local posFinal = Mouse.Hit.Position + Vector3.new(0, 3, 0)
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 5, 1); p.Position = LocalPlayer.Character.HumanoidRootPart.Position; p.Anchored = true; p.CanCollide = false; p.BrickColor = BrickColor.new("Bright Red"); p.Material = Enum.Material.Neon; p.Parent = workspace
            game:GetService("Debris"):AddItem(p, 0.2)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(posFinal)
        end
    end
end)


-- --- LÓGICA DE SALTO INFINITO ---
local function alternarInfJump()
    infJumpActivo = not infJumpActivo
    InfJumpToggleBtn.Text = infJumpActivo and "Inf Jump: ON" or "Inf Jump: OFF"
    local c = infJumpActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(InfJumpToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
end
InfJumpToggleBtn.MouseButton1Click:Connect(alternarInfJump)

UserInputService.JumpRequest:Connect(function()
    if infJumpActivo and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)


-- --- BUCLE HEARTBEAT CONTROLLER ---
local function alternarNoclip()
    noclipActivo = not noclipActivo
    NoclipToggleBtn.Text = noclipActivo and "Noclip: ON" or "Noclip: OFF"
    local c = noclipActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(NoclipToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
end
NoclipToggleBtn.MouseButton1Click:Connect(alternarNoclip)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = velocidadActual
        
        -- Condición para mapear JumpPower nativo o según configuración del juego
        hum.JumpPower = saltoActual
        hum.UseJumpPower = true
        
        if noclipActivo then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end
    end
end)


-- --- LÓGICA DEL FULLBRIGHT ---
local function alternarFullbright()
    fbActivo = not fbActivo
    ToggleBtn.Text = fbActivo and "FullBright: ON" or "FullBright: OFF"
    local c = fbActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
    Lighting.Ambient = fbActivo and Color3.fromRGB(255, 255, 255) or origAmbient
    Lighting.OutdoorAmbient = fbActivo and Color3.fromRGB(255, 255, 255) or origOutdoorAmbient
end
ToggleBtn.MouseButton1Click:Connect(alternarFullbright)
Lighting.Changed:Connect(function() if fbActivo then Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) end end)


-- --- ASIGNACIÓN DE KEYBINDS INTERACTIVOS ---
BindBtn.MouseButton1Click:Connect(function() cambiandoFbKey = true BindBtn.Text = "..."; BindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
NoclipBindBtn.MouseButton1Click:Connect(function() cambiandoNcKey = true NoclipBindBtn.Text = "..."; NoclipBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
InfJumpBindBtn.MouseButton1Click:Connect(function() cambiandoIjKey = true InfJumpBindBtn.Text = "..."; InfJumpBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
ClickTpBindBtn.MouseButton1Click:Connect(function() cambiandoTpKey = true ClickTpBindBtn.Text = "..."; ClickTpBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
FlyBindBtn.MouseButton1Click:Connect(function() cambiandoFlyKey = true FlyBindBtn.Text = "..."; FlyBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if cambiandoFbKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then fbKeybind = input.KeyCode; BindBtn.Text = "Bind: " .. fbKeybind.Name; cambiandoFbKey = false end
    elseif cambiandoNcKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then ncKeybind = input.KeyCode; NoclipBindBtn.Text = "Bind: " .. ncKeybind.Name; cambiandoNcKey = false end
    elseif cambiandoIjKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then ijKeybind = input.KeyCode; InfJumpBindBtn.Text = "Bind: " .. ijKeybind.Name; cambiandoIjKey = false end
    elseif cambiandoTpKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then tpKeybind = input.KeyCode; ClickTpBindBtn.Text = "Bind: " .. tpKeybind.Name; cambiandoTpKey = false end
    elseif cambiandoFlyKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then flyKeybind = input.KeyCode; FlyBindBtn.Text = "Bind: " .. flyKeybind.Name; cambiandoFlyKey = false end
    else
        if input.KeyCode == fbKeybind then alternarFullbright()
        elseif input.KeyCode == ncKeybind then alternarNoclip()
        elseif input.KeyCode == ijKeybind then alternarInfJump()
        elseif input.KeyCode == tpKeybind then alternarClickTp()
        elseif input.KeyCode == flyKeybind then alternarFly()
        end
    end
end)
