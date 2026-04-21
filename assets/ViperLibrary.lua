local Viper = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local windowCount = 0

-- CONFIGURACIÓN DE TEMA: VIPER PURPLE
local BG_THEME = Color3.fromRGB(10, 8, 18)
local ACCENT_COLOR = Color3.fromRGB(160, 32, 240) 
local SECONDARY_BG = Color3.fromRGB(22, 16, 35)
local TEXT_COLOR = Color3.fromRGB(245, 245, 245)

local IS_TOUCH = UserInputService.TouchEnabled
local BUTTON_H = IS_TOUCH and 38 or 34
local SLIDER_H = IS_TOUCH and 54 or 48
local TITLE_H = IS_TOUCH and 42 or 38
local BODY_TEXT = IS_TOUCH and 14 or 13

local sg = Instance.new("ScreenGui")
sg.Name = "Viper_Engine"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = PlayerGui end

-- CONTENEDOR DE NOTIFICACIONES (ABAJO A LA IZQUIERDA)
local notifHolder = Instance.new("Frame")
notifHolder.Name = "ViperNotifs"
notifHolder.Parent = sg
notifHolder.Size = UDim2.new(0, 250, 1, -40)
notifHolder.Position = UDim2.new(0, 20, 1, -20)
notifHolder.AnchorPoint = Vector2.new(0, 1)
notifHolder.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout")
layout.Parent = notifHolder
layout.Padding = UDim.new(0, 10)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- UTILIDADES
local function applyViperStroke(parent)
    local st = Instance.new("UIStroke")
    st.Parent = parent
    st.Thickness = 2.2
    st.Color = ACCENT_COLOR
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 200)),
        ColorSequenceKeypoint.new(0.5, ACCENT_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 200))
    })
    g.Parent = st

    task.spawn(function()
        local rot = 0
        while st.Parent do
            rot = rot + 2
            g.Rotation = rot % 360
            task.wait(0.02)
        end
    end)
    return st
end

local function makeDrag(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- SISTEMA DE NOTIFICACIONES
function Viper:Notify(title, text, duration)
    duration = duration or 4
    local item = Instance.new("Frame")
    item.BackgroundColor3 = BG_THEME
    item.Size = UDim2.new(1, 0, 0, 0)
    item.Parent = notifHolder
    item.ClipsDescendants = true
    
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", item)
    s.Color = ACCENT_COLOR
    s.Transparency = 0.4

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 20)
    t.Position = UDim2.new(0, 10, 0, 8)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.Text = title:upper()
    t.TextColor3 = ACCENT_COLOR
    t.TextSize = 14
    t.Parent = item
    t.TextXAlignment = Enum.TextXAlignment.Left

    local b = Instance.new("TextLabel")
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, 28)
    b.BackgroundTransparency = 1
    b.Font = Enum.Font.Gotham
    b.Text = text
    b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    b.TextSize = 12
    b.TextWrapped = true
    b.Parent = item
    b.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(item, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 70)}):Play()
    task.delay(duration, function()
        local tw = TweenService:Create(item, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Wait()
        item:Destroy()
    end)
end

-- VENTANA PRINCIPAL
function Viper:CreateWindow(title, sizeX, sizeY)
    windowCount = windowCount + 1
    sizeX, sizeY = tonumber(sizeX) or 260, tonumber(sizeY) or 340

    local main = Instance.new("Frame")
    main.Name = "Viper_" .. title
    main.Parent = sg
    main.Size = UDim2.fromOffset(sizeX, sizeY)
    main.Position = UDim2.new(0.5, -sizeX/2 + (windowCount-1)*30, 0.5, -sizeY/2)
    main.BackgroundColor3 = BG_THEME
    main.BorderSizePixel = 0
    main.ClipsDescendants = true

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    applyViperStroke(main)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, TITLE_H)
    header.BackgroundTransparency = 1
    header.Parent = main

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title:upper()
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = ACCENT_COLOR
    titleLbl.TextSize = 16
    titleLbl.Parent = header

    makeDrag(main, header)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -16, 1, -(TITLE_H + 15))
    container.Position = UDim2.new(0, 8, 0, TITLE_H + 5)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = ACCENT_COLOR
    container.Parent = main

    local list = Instance.new("UIListLayout")
    list.Parent = container
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    local win = {}

    -- BOTÓN
    function win:Button(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -5, 0, BUTTON_H)
        btn.BackgroundColor3 = SECONDARY_BG
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = TEXT_COLOR
        btn.TextSize = BODY_TEXT
        btn.AutoButtonColor = false
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            btn.BackgroundColor3 = ACCENT_COLOR
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = SECONDARY_BG}):Play()
            pcall(callback)
        end)
    end

    -- TOGGLE (MEJORADO ESTÉTICAMENTE)
    function win:Toggle(text, default, callback)
        local state = default or false
        local tog = Instance.new("TextButton")
        tog.Size = UDim2.new(1, -5, 0, BUTTON_H)
        tog.BackgroundColor3 = SECONDARY_BG
        tog.Text = "   " .. text
        tog.Font = Enum.Font.GothamBold
        tog.TextColor3 = TEXT_COLOR
        tog.TextSize = BODY_TEXT
        tog.TextXAlignment = Enum.TextXAlignment.Left
        tog.AutoButtonColor = false
        tog.Parent = container
        Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 6)

        -- Track del Switch
        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 34, 0, 18)
        track.Position = UDim2.new(1, -40, 0.5, -9)
        track.BackgroundColor3 = state and ACCENT_COLOR or Color3.fromRGB(45, 45, 60)
        track.Parent = tog
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        -- Knob del Switch
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        tog.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = state and ACCENT_COLOR or Color3.fromRGB(45, 45, 60)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            pcall(callback, state)
        end)
    end

    -- SLIDER (MEJORADO Y CENTRADO)
    function win:Slider(text, min, max, default, callback)
        local val = default or min
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -5, 0, SLIDER_H)
        holder.BackgroundTransparency = 1
        holder.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. ": " .. val
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Center -- TEXTO CENTRADO
        lbl.Parent = holder

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -20, 0, 6)
        bar.Position = UDim2.new(0.5, 0, 0, 36)
        bar.AnchorPoint = Vector2.new(0.5, 0)
        bar.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
        bar.Parent = holder
        Instance.new("UICorner", bar)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(math.clamp((val-min)/(max-min), 0, 1), 1)
        fill.BackgroundColor3 = ACCENT_COLOR
        fill.Parent = bar
        Instance.new("UICorner", fill)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.fromScale(math.clamp((val-min)/(max-min), 0, 1), 0.5)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Parent = bar
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local ks = Instance.new("UIStroke", knob)
        ks.Thickness = 2
        ks.Color = ACCENT_COLOR

        local dragging = false
        local function update(input)
            local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * ratio)
            fill.Size = UDim2.fromScale(ratio, 1)
            knob.Position = UDim2.fromScale(ratio, 0.5)
            lbl.Text = text .. ": " .. val
            pcall(callback, val)
        end

        holder.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(i)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- LABEL
    function win:Label(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -5, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize = BODY_TEXT
        lbl.TextWrapped = true
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container
        return lbl
    end

    -- TEXTBOX
    function win:TextBox(placeholder, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -5, 0, BUTTON_H)
        box.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
        box.PlaceholderText = placeholder
        box.Text = ""
        box.Font = Enum.Font.Gotham
        box.TextColor3 = Color3.new(1, 1, 1)
        box.TextSize = BODY_TEXT
        box.Parent = container
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", box).Color = Color3.fromRGB(40, 40, 40)

        box.FocusLost:Connect(function(enter)
            if enter then pcall(callback, box.Text) end
        end)
    end

    -- SECCIÓN
    function win:Section(text)
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, 0, 0, 25)
        s.BackgroundTransparency = 1
        s.Text = "──  " .. text:upper() .. "  ──"
        s.Font = Enum.Font.GothamBold
        s.TextColor3 = ACCENT_COLOR
        s.TextSize = 11
        s.Parent = container
    end

    return win
end

return Viper
