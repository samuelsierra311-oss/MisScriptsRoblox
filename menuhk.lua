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

local velocidadActual = 16 
local menuMinimizado = false
local temaOscuro = true -- Estado del tema

-- --- TABLA DE COLORES PARA TEMAS ---
local Temas = {
    Oscuro = {
        Fondo = Color3.fromRGB(35, 35, 35),
        TextoPrincipal = Color3.fromRGB(255, 255, 255),
        TextoSecundario = Color3.fromRGB(230, 230, 230),
        BotonesSecundarios = Color3.fromRGB(50, 50, 50),
        BarraSlider = Color3.fromRGB(60, 60, 60)
    },
    Claro = {
        Fondo = Color3.fromRGB(240, 240, 240),
        TextoPrincipal = Color3.fromRGB(30, 30, 30),
        TextoSecundario = Color3.fromRGB(60, 60, 60),
        BotonesSecundarios = Color3.fromRGB(200, 200, 200),
        BarraSlider = Color3.fromRGB(180, 180, 180)
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

-- Contenedor Principal (Alto extendido para albergar todo limpiamente)
MainFrame.Name = "MainFrame"
MainFrame.Parent = UniversalHubUI
MainFrame.BackgroundColor3 = Temas.Oscuro.Fondo
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 295)
MainFrame.Active = true
MainFrame.Draggable = true 

UICorner_Main.CornerRadius = UDim.new(0, 8)
UICorner_Main.Parent = MainFrame

-- Botón de Minimizar
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = MainFrame
MinimizeBtn.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
MinimizeBtn.Position = UDim2.new(1, -25, 0, 6)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Temas.Oscuro.TextoPrincipal
MinimizeBtn.TextSize = 16
local UICorner_Min = Instance.new("UICorner") UICorner_Min.CornerRadius = UDim.new(0, 4) UICorner_Min.Parent = MinimizeBtn

-- Botón de Cambiar Tema (Ícono de Sol/Luna estilizado)
ThemeBtn.Name = "ThemeBtn"
ThemeBtn.Parent = MainFrame
ThemeBtn.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
ThemeBtn.Position = UDim2.new(1, -50, 0, 6)
ThemeBtn.Size = UDim2.new(0, 20, 0, 20)
ThemeBtn.Font = Enum.Font.SourceSansBold
ThemeBtn.Text = "🌓"
ThemeBtn.TextColor3 = Temas.Oscuro.TextoPrincipal
ThemeBtn.TextSize = 12
local UICorner_Theme = Instance.new("UICorner") UICorner_Theme.CornerRadius = UDim.new(0, 4) UICorner_Theme.Parent = ThemeBtn

-- Botón Flotante Abierto
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

-- Instancias de las filas
local ToggleBtn, BindBtn = Instance.new("TextButton"), Instance.new("TextButton")
local SliderFrame, SliderBar, SliderFill, SliderValueLabel = Instance.new("Frame"), Instance.new("TextButton"), Instance.new("Frame"), Instance.new("TextLabel")
local NoclipToggleBtn, NoclipBindBtn = Instance.new("TextButton"), Instance.new("TextButton")
local InfJumpToggleBtn, InfJumpBindBtn = Instance.new("TextButton"), Instance.new("TextButton")
local ClickTpToggleBtn, ClickTpBindBtn = Instance.new("TextButton"), Instance.new("TextButton")

-- Función para estructurar filas rápido
local function crearFila(btn, bind, yPos, textoBtn, textoBind)
    btn.Parent = MainFrame
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 140, 0, 32)
    btn.Text = textoBtn
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Temas.AcentoRojo
    local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 6) c1.Parent = btn

    bind.Parent = MainFrame
    bind.Position = UDim2.new(0, 160, 0, yPos)
    bind.Size = UDim2.new(0, 80, 0, 32)
    bind.Text = "Bind: " .. textoBind
    bind.Font = Enum.Font.SourceSans
    bind.TextSize = 13
    bind.TextColor3 = Temas.Oscuro.TextoPrincipal
    bind.BackgroundColor3 = Temas.Oscuro.BotonesSecundarios
    local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 6) c2.Parent = bind
end

-- Montaje de Filas (Posiciones Y bien calculadas)
crearFila(ToggleBtn, BindBtn, 35, "FullBright: OFF", fbKeybind.Name)
crearFila(NoclipToggleBtn, NoclipBindBtn, 130, "Noclip: OFF", ncKeybind.Name)
crearFila(InfJumpToggleBtn, InfJumpBindBtn, 175, "Inf Jump: OFF", ijKeybind.Name)
crearFila(ClickTpToggleBtn, ClickTpBindBtn, 220, "Click TP: OFF", "Ctrl+Clk")

-- Montaje del Slider de Velocidad
SliderFrame.Parent = MainFrame
SliderFrame.BackgroundTransparency = 1
SliderFrame.Position = UDim2.new(0, 10, 0, 75)
SliderFrame.Size = UDim2.new(0, 230, 0, 40)

SliderValueLabel.Parent = SliderFrame
SliderValueLabel.BackgroundTransparency = 1
SliderValueLabel.Size = UDim2.new(1, 0, 0, 15)
SliderValueLabel.Font = Enum.Font.SourceSansBold
SliderValueLabel.Text = "Velocidad: 16"
SliderValueLabel.TextColor3 = Temas.Oscuro.TextoSecundario
SliderValueLabel.TextSize = 13
SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Left

SliderBar.Parent = SliderFrame
SliderBar.BackgroundColor3 = Temas.Oscuro.BarraSlider
SliderBar.Position = UDim2.new(0, 0, 0, 18)
SliderBar.Size = UDim2.new(1, 0, 0, 8)
SliderBar.Text = ""
SliderBar.AutoButtonColor = false
local csb = Instance.new("UICorner") csb.CornerRadius = UDim.new(0, 4) csb.Parent = SliderBar

SliderFill.Parent = SliderBar
SliderFill.BackgroundColor3 = Temas.AcentoRojo
SliderFill.Size = UDim2.new(0, 0, 1, 0)
local csf = Instance.new("UICorner") csf.CornerRadius = UDim.new(0, 4) csf.Parent = SliderFill


-- --- INTERRUPTOR DE TEMA (OSCURO / CLARO) ---
ThemeBtn.MouseButton1Click:Connect(function()
    temaOscuro = not temaOscuro
    local t = temaOscuro and Temas.Oscuro or Temas.Claro
    
    -- Transición suave de colores de fondo y textos
    TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundColor3 = t.Fondo}):Play()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    TweenService:Create(ThemeBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    
    TweenService:Create(BindBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    TweenService:Create(NoclipBindBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    TweenService:Create(InfJumpBindBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    TweenService:Create(ClickTpBindBtn, TweenInfo.new(0.25), {BackgroundColor3 = t.BotonesSecundarios, TextColor3 = t.TextPrincipal}):Play()
    
    SliderValueLabel.TextColor3 = t.TextoSecundario
    TweenService:Create(SliderBar, TweenInfo.new(0.25), {BackgroundColor3 = t.BarraSlider}):Play()
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
    if clickTpActivo then
        ClickTpToggleBtn.Text = "Click TP: ON"
        TweenService:Create(ClickTpToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Temas.AcentoVerde}):Play()
    else
        ClickTpToggleBtn.Text = "Click TP: OFF"
        TweenService:Create(ClickTpToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Temas.AcentoRojo}):Play()
    end
end
ClickTpToggleBtn.MouseButton1Click:Connect(alternarClickTp)

-- Detectar Clic + Ctrl para Teletransportación
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if clickTpActivo and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local posFinal = Mouse.Hit.Position + Vector3.new(0, 3, 0)
            
            -- Efecto visual efímero de destello al hacer TP
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 5, 1)
            p.Position = LocalPlayer.Character.HumanoidRootPart.Position
            p.Anchored = true; p.CanCollide = false; p.BrickColor = BrickColor.new("Bright Red"); p.Material = Enum.Material.Neon
            p.Parent = workspace
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


-- --- LÓGICA DEL SLIDER (VELOCIDAD) ---
local minVel, maxVel, arrastrandoSlider = 16, 200, false
local function actualizarVelocidad(input)
    local porcentaje = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(porcentaje, 0, 1, 0)
    velocidadActual = math.floor(minVel + (porcentaje * (maxVel - minVel)))
    SliderValueLabel.Text = "Velocidad: " .. velocidadActual
end

SliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        arrastrandoSlider = true; actualizarVelocidad(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if arrastrandoSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        actualizarVelocidad(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then arrastrandoSlider = false end
end)


-- --- BUCLE HEARTBEAT (SPEED Y NOCLIP) ---
local function alternarNoclip()
    noclipActivo = not noclipActivo
    NoclipToggleBtn.Text = noclipActivo and "Noclip: ON" or "Noclip: OFF"
    local c = noclipActivo and Temas.AcentoVerde or Temas.AcentoRojo
    TweenService:Create(NoclipToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
end
NoclipToggleBtn.MouseButton1Click:Connect(alternarNoclip)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = velocidadActual
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


-- --- ASIGNACIÓN DE KEYBINDS ---
BindBtn.MouseButton1Click:Connect(function() cambiandoFbKey = true BindBtn.Text = "..."; BindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
NoclipBindBtn.MouseButton1Click:Connect(function() cambiandoNcKey = true NoclipBindBtn.Text = "..."; NoclipBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
InfJumpBindBtn.MouseButton1Click:Connect(function() cambiandoIjKey = true InfJumpBindBtn.Text = "..."; InfJumpBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)
ClickTpBindBtn.MouseButton1Click:Connect(function() cambiandoTpKey = true ClickTpBindBtn.Text = "..."; ClickTpBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100) end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if cambiandoFbKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then fbKeybind = input.KeyCode; BindBtn.Text = "Bind: " .. fbKeybind.Name; BindBtn.TextColor3 = Temas.Oscuro.TextoPrincipal; cambiandoFbKey = false end
    elseif cambiandoNcKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then ncKeybind = input.KeyCode; NoclipBindBtn.Text = "Bind: " .. ncKeybind.Name; NoclipBindBtn.TextColor3 = Temas.Oscuro.TextoPrincipal; cambiandoNcKey = false end
    elseif cambiandoIjKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then ijKeybind = input.KeyCode; InfJumpBindBtn.Text = "Bind: " .. ijKeybind.Name; InfJumpBindBtn.TextColor3 = Temas.Oscuro.TextoPrincipal; cambiandoIjKey = false end
    elseif cambiandoTpKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then tpKeybind = input.KeyCode; ClickTpBindBtn.Text = "Bind: " .. tpKeybind.Name; ClickTpBindBtn.TextColor3 = Temas.Oscuro.TextoPrincipal; cambiandoTpKey = false end
    else
        if input.KeyCode == fbKeybind then alternarFullbright()
        elseif input.KeyCode == ncKeybind then alternarNoclip()
        elseif input.KeyCode == ijKeybind then alternarInfJump()
        elseif input.KeyCode == tpKeybind then alternarClickTp()
        end
    end
end)
