local Viper = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local windowCount = 0
local notifIndex = 0

-- CONFIGURACIÓN DE TEMA: VIPER PURPLE
local BG_THEME = Color3.fromRGB(10, 8, 18)
local ACCENT_COLOR = Color3.fromRGB(160, 32, 240)
local SECONDARY_BG = Color3.fromRGB(22, 16, 35)
local TEXT_COLOR = Color3.fromRGB(245, 245, 245)

local IS_TOUCH = UserInputService.TouchEnabled
local BUTTON_H = IS_TOUCH and 38 or 34
local SLIDER_H = IS_TOUCH and 58 or 52
local TITLE_H = IS_TOUCH and 42 or 38
local BODY_TEXT = IS_TOUCH and 14 or 13

local sg = Instance.new("ScreenGui")
sg.Name = "Viper_Engine"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	sg.Parent = CoreGui
end)
if not sg.Parent then
	sg.Parent = PlayerGui
end

-- CONTENEDOR DE NOTIFICACIONES (ABAJO IZQUIERDA)
local notifHolder = Instance.new("Frame")
notifHolder.Name = "ViperNotifs"
notifHolder.Parent = sg
notifHolder.Size = UDim2.new(0, 300, 0, 280)
notifHolder.Position = UDim2.new(0, 16, 1, -16)
notifHolder.AnchorPoint = Vector2.new(0, 1)
notifHolder.BackgroundTransparency = 1
notifHolder.ClipsDescendants = false

local notifLayout = Instance.new("UIListLayout")
notifLayout.Parent = notifHolder
notifLayout.Padding = UDim.new(0, 8)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifPadding = Instance.new("UIPadding")
notifPadding.Parent = notifHolder
notifPadding.PaddingLeft = UDim.new(0, 0)
notifPadding.PaddingRight = UDim.new(0, 0)
notifPadding.PaddingTop = UDim.new(0, 0)
notifPadding.PaddingBottom = UDim.new(0, 0)

-- UTILIDADES
local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function makeStroke(parent, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Parent = parent
	s.Thickness = thickness or 1
	s.Color = color or ACCENT_COLOR
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

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
			rot = (rot + 2) % 360
			g.Rotation = rot
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
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
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
	title = tostring(title or "VIPER")
	text = tostring(text or "")

	notifIndex += 1

	local wrapper = Instance.new("Frame")
	wrapper.Name = "Notif_" .. notifIndex
	wrapper.Parent = notifHolder
	wrapper.BackgroundTransparency = 1
	wrapper.ClipsDescendants = true
	wrapper.Size = UDim2.new(1, 0, 0, 0)
	wrapper.LayoutOrder = notifIndex

	local card = Instance.new("Frame")
	card.Parent = wrapper
	card.Size = UDim2.new(1, 0, 1, 0)
	card.Position = UDim2.new(-0.95, 0, 0, 0) -- entra desde la izquierda
	card.BackgroundColor3 = BG_THEME
	card.BackgroundTransparency = 0
	card.BorderSizePixel = 0
	makeCorner(card, 10)
	makeStroke(card, 1.2, ACCENT_COLOR, 0.45)

	local accent = Instance.new("Frame")
	accent.Parent = card
	accent.Size = UDim2.new(0, 4, 1, -10)
	accent.Position = UDim2.new(0, 8, 0, 5)
	accent.BackgroundColor3 = ACCENT_COLOR
	accent.BorderSizePixel = 0
	makeCorner(accent, 999)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Parent = card
	titleLbl.BackgroundTransparency = 1
	titleLbl.Position = UDim2.new(0, 18, 0, 8)
	titleLbl.Size = UDim2.new(1, -28, 0, 18)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.Text = title:upper()
	titleLbl.TextColor3 = ACCENT_COLOR
	titleLbl.TextSize = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local bodyLbl = Instance.new("TextLabel")
	bodyLbl.Parent = card
	bodyLbl.BackgroundTransparency = 1
	bodyLbl.Position = UDim2.new(0, 18, 0, 27)
	bodyLbl.Size = UDim2.new(1, -28, 1, -34)
	bodyLbl.Font = Enum.Font.Gotham
	bodyLbl.Text = text
	bodyLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
	bodyLbl.TextSize = 12
	bodyLbl.TextWrapped = true
	bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
	bodyLbl.TextYAlignment = Enum.TextYAlignment.Top

	local function resizeBody()
		local base = 62
		local extra = math.clamp(math.floor(#text / 42) * 12, 0, 34)
		local h = base + extra
		wrapper.Size = UDim2.new(1, 0, 0, h)
	end
	resizeBody()

	TweenService:Create(
		card,
		TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, 0, 0, 0) }
	):Play()

	task.delay(duration, function()
		if not wrapper.Parent then
			return
		end

		local outTween1 = TweenService:Create(
			card,
			TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
			{
				Position = UDim2.new(-0.95, 0, 0, 0),
				BackgroundTransparency = 1
			}
		)

		local outTween2 = TweenService:Create(
			wrapper,
			TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
			{ Size = UDim2.new(1, 0, 0, 0) }
		)

		outTween1:Play()
		outTween2:Play()
		outTween2.Completed:Wait()

		if wrapper then
			wrapper:Destroy()
		end
	end)
end

-- VENTANA PRINCIPAL
function Viper:CreateWindow(title, sizeX, sizeY)
	windowCount += 1
	sizeX, sizeY = tonumber(sizeX) or 260, tonumber(sizeY) or 340

	local main = Instance.new("Frame")
	main.Name = "Viper_" .. tostring(title)
	main.Parent = sg
	main.Size = UDim2.fromOffset(sizeX, sizeY)
	main.Position = UDim2.new(0.5, -sizeX / 2 + (windowCount - 1) * 30, 0.5, -sizeY / 2)
	main.BackgroundColor3 = BG_THEME
	main.BorderSizePixel = 0
	main.ClipsDescendants = true

	makeCorner(main, 12)
	applyViperStroke(main)

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, TITLE_H)
	header.BackgroundTransparency = 1
	header.Parent = main

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, 0, 1, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = tostring(title):upper()
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
	container.BorderSizePixel = 0
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
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
		makeCorner(btn, 8)
		makeStroke(btn, 1, Color3.fromRGB(60, 45, 80), 0.4)

		btn.MouseButton1Click:Connect(function()
			local original = btn.BackgroundColor3
			TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = ACCENT_COLOR }):Play()
			task.wait(0.1)
			TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundColor3 = original }):Play()
			pcall(callback)
		end)
	end

	-- TOGGLE
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
		makeCorner(tog, 8)
		makeStroke(tog, 1, Color3.fromRGB(60, 45, 80), 0.4)

		local track = Instance.new("Frame")
		track.Size = UDim2.new(0, 36, 0, 18)
		track.Position = UDim2.new(1, -44, 0.5, -9)
		track.BackgroundColor3 = state and ACCENT_COLOR or Color3.fromRGB(45, 45, 60)
		track.Parent = tog
		makeCorner(track, 999)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.Parent = track
		makeCorner(knob, 999)

		tog.MouseButton1Click:Connect(function()
			state = not state
			TweenService:Create(track, TweenInfo.new(0.18), {
				BackgroundColor3 = state and ACCENT_COLOR or Color3.fromRGB(45, 45, 60)
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.18), {
				Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			}):Play()

			pcall(callback, state)
		end)
	end

	-- SLIDER MEJORADO
	function win:Slider(text, min, max, default, callback)
		min = tonumber(min) or 0
		max = tonumber(max) or 100
		local val = tonumber(default) or min

		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, -5, 0, SLIDER_H)
		holder.BackgroundTransparency = 1
		holder.Parent = container

		local topRow = Instance.new("Frame")
		topRow.Size = UDim2.new(1, 0, 0, 18)
		topRow.BackgroundTransparency = 1
		topRow.Parent = holder

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -60, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = tostring(text)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextColor3 = Color3.fromRGB(235, 235, 235)
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = topRow

		local valueBadge = Instance.new("TextLabel")
		valueBadge.Size = UDim2.new(0, 50, 0, 18)
		valueBadge.Position = UDim2.new(1, -50, 0, 0)
		valueBadge.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
		valueBadge.Text = tostring(val)
		valueBadge.Font = Enum.Font.GothamBold
		valueBadge.TextColor3 = ACCENT_COLOR
		valueBadge.TextSize = 11
		valueBadge.Parent = topRow
		makeCorner(valueBadge, 6)
		makeStroke(valueBadge, 1, ACCENT_COLOR, 0.7)

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -10, 0, 8)
		bar.Position = UDim2.new(0, 5, 0, 30)
		bar.BackgroundColor3 = Color3.fromRGB(30, 24, 42)
		bar.BorderSizePixel = 0
		bar.Parent = holder
		makeCorner(bar, 999)
		makeStroke(bar, 1, Color3.fromRGB(60, 45, 80), 0.65)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(math.clamp((val - min) / math.max(max - min, 1), 0, 1), 1)
		fill.BackgroundColor3 = ACCENT_COLOR
		fill.BorderSizePixel = 0
		fill.Parent = bar
		makeCorner(fill, 999)

		local fillGrad = Instance.new("UIGradient")
		fillGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 20, 210)),
			ColorSequenceKeypoint.new(1, ACCENT_COLOR)
		})
		fillGrad.Rotation = 0
		fillGrad.Parent = fill

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.fromScale(math.clamp((val - min) / math.max(max - min, 1), 0, 1), 0.5)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = bar
		makeCorner(knob, 999)
		makeStroke(knob, 2, ACCENT_COLOR, 0)

		local knobGlow = Instance.new("Frame")
		knobGlow.Size = UDim2.new(0, 24, 0, 24)
		knobGlow.AnchorPoint = Vector2.new(0.5, 0.5)
		knobGlow.Position = knob.Position
		knobGlow.BackgroundTransparency = 1
		knobGlow.Parent = bar

		local glowStroke = Instance.new("UIStroke")
		glowStroke.Parent = knobGlow
		glowStroke.Thickness = 1
		glowStroke.Color = ACCENT_COLOR
		glowStroke.Transparency = 0.75

		local dragging = false

		local function setValueFromX(x)
			local ratio = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			val = math.floor(min + (max - min) * ratio + 0.5)

			local realRatio = math.clamp((val - min) / math.max(max - min, 1), 0, 1)
			fill.Size = UDim2.fromScale(realRatio, 1)
			knob.Position = UDim2.fromScale(realRatio, 0.5)
			knobGlow.Position = knob.Position
			valueBadge.Text = tostring(val)

			pcall(callback, val)
		end

		local function beginDrag(input)
			dragging = true
			setValueFromX(input.Position.X)
		end

		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				beginDrag(i)
			end
		end)

		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				beginDrag(i)
			end
		end)

		UserInputService.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				setValueFromX(i.Position.X)
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
		makeCorner(box, 8)
		makeStroke(box, 1, Color3.fromRGB(50, 40, 70), 0.45)

		box.FocusLost:Connect(function(enter)
			if enter then
				pcall(callback, box.Text)
			end
		end)
	end

	-- SECCIÓN
	function win:Section(text)
		local s = Instance.new("TextLabel")
		s.Size = UDim2.new(1, 0, 0, 25)
		s.BackgroundTransparency = 1
		s.Text = "──  " .. tostring(text):upper() .. "  ──"
		s.Font = Enum.Font.GothamBold
		s.TextColor3 = ACCENT_COLOR
		s.TextSize = 11
		s.Parent = container
	end

	return win
end

return Viper
