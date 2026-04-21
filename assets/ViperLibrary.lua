local ViperLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- THEME 🟣
local BG = Color3.fromRGB(18, 12, 30)
local PURPLE = Color3.fromRGB(170, 0, 255)
local DARK = Color3.fromRGB(28, 20, 45)

local IS_TOUCH = UserInputService.TouchEnabled
local BUTTON_H = IS_TOUCH and 40 or 32

-- GUI ROOT
local sg = Instance.new("ScreenGui")
sg.Name = "ViperLib"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = CoreGui

-- DRAG FIXED (NO BUG CON SLIDERS)
local function makeDrag(frame, handle)
	local dragging, dragStart, startPos

	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- WINDOW
function ViperLib:CreateWindow(title)
	local win = {}

	local main = Instance.new("Frame")
	main.Parent = sg
	main.Size = UDim2.fromOffset(260, 300)
	main.Position = UDim2.new(0, 100, 0, 100)
	main.BackgroundColor3 = BG

	local corner = Instance.new("UICorner", main)

	-- TITLE BAR
	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1, 0, 0, 36)
	top.BackgroundTransparency = 1

	local titleLbl = Instance.new("TextLabel", top)
	titleLbl.Size = UDim2.new(1, 0, 1, 0)
	titleLbl.Text = title or "VIPER"
	titleLbl.TextColor3 = PURPLE
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 14
	titleLbl.BackgroundTransparency = 1

	makeDrag(main, top)

	-- CONTAINER
	local container = Instance.new("ScrollingFrame", main)
	container.Position = UDim2.new(0, 5, 0, 40)
	container.Size = UDim2.new(1, -10, 1, -45)
	container.BackgroundTransparency = 1
	container.ScrollBarThickness = 3

	local layout = Instance.new("UIListLayout", container)
	layout.Padding = UDim.new(0, 6)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	-- BUTTON
	function win:Button(text, callback)
		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(1, 0, 0, BUTTON_H)
		btn.Text = text
		btn.BackgroundColor3 = DARK
		btn.TextColor3 = PURPLE
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12

		Instance.new("UICorner", btn)

		btn.MouseButton1Click:Connect(function()
			if callback then callback() end

			TweenService:Create(btn, TweenInfo.new(0.1), {
				BackgroundColor3 = PURPLE,
				TextColor3 = BG
			}):Play()

			task.wait(0.1)

			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = DARK,
				TextColor3 = PURPLE
			}):Play()
		end)
	end

	-- TOGGLE
	function win:Toggle(text, default, callback)
		local state = default or false

		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(1, 0, 0, BUTTON_H)
		btn.BackgroundColor3 = DARK
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12

		local function update()
			btn.Text = (state and "🟣 " or "⚪ ") .. text
			btn.TextColor3 = state and PURPLE or Color3.fromRGB(150,150,150)
		end

		update()

		btn.MouseButton1Click:Connect(function()
			state = not state
			update()
			if callback then callback(state) end
		end)
	end

	-- SLIDER (MEJORADO)
	function win:Slider(text, min, max, default, callback)
		local val = default or min

		local frame = Instance.new("Frame", container)
		frame.Size = UDim2.new(1, 0, 0, 50)
		frame.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(1, 0, 0, 15)
		label.Text = text .. ": " .. val
		label.TextColor3 = Color3.new(1,1,1)
		label.BackgroundTransparency = 1

		local bar = Instance.new("Frame", frame)
		bar.Position = UDim2.new(0, 0, 0, 25)
		bar.Size = UDim2.new(1, 0, 0, 6)
		bar.BackgroundColor3 = DARK

		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = PURPLE

		local dragging = false

		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)

		UserInputService.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local pos = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
				pos = math.clamp(pos, 0, 1)

				val = math.floor(min + (max - min) * pos)
				fill.Size = UDim2.new(pos, 0, 1, 0)
				label.Text = text .. ": " .. val

				if callback then callback(val) end
			end
		end)

		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	-- DROPDOWN 🔽
	function win:Dropdown(text, list, callback)
		local opened = false

		local mainBtn = Instance.new("TextButton", container)
		mainBtn.Size = UDim2.new(1, 0, 0, BUTTON_H)
		mainBtn.Text = text .. " ▼"
		mainBtn.BackgroundColor3 = DARK
		mainBtn.TextColor3 = PURPLE

		local drop = Instance.new("Frame", container)
		drop.Size = UDim2.new(1, 0, 0, 0)
		drop.BackgroundTransparency = 1
		drop.ClipsDescendants = true

		local lay = Instance.new("UIListLayout", drop)

		for _,v in pairs(list) do
			local opt = Instance.new("TextButton", drop)
			opt.Size = UDim2.new(1, 0, 0, 28)
			opt.Text = v
			opt.BackgroundColor3 = BG
			opt.TextColor3 = Color3.new(1,1,1)

			opt.MouseButton1Click:Connect(function()
				mainBtn.Text = text .. ": " .. v
				if callback then callback(v) end
			end)
		end

		mainBtn.MouseButton1Click:Connect(function()
			opened = not opened

			TweenService:Create(drop, TweenInfo.new(0.25), {
				Size = opened and UDim2.new(1,0,0,#list*30) or UDim2.new(1,0,0,0)
			}):Play()
		end)
	end

	return win
end

return ViperLib
