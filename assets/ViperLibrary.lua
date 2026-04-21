local ViperLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Configuración de Colores y Estilo (Viper Theme)
local BG_MAIN = Color3.fromRGB(15, 15, 20)
local BG_SECOND = Color3.fromRGB(25, 25, 35)
local ACCENT = Color3.fromRGB(0, 255, 255)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

local IS_TOUCH = UserInputService.TouchEnabled
local WINDOW_SIZE = IS_TOUCH and Vector2.new(380, 260) or Vector2.new(450, 300)

-- Contenedor Principal
local sg = Instance.new("ScreenGui")
sg.Name = "ViperLib_UI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = PlayerGui end

-- Función para arrastrar (Mobile & PC)
local function makeDrag(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function ViperLib:CreateWindow(title)
	title = title or "VIPER LIB"
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = sg
	MainFrame.BackgroundColor3 = BG_MAIN
	MainFrame.Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y)
	MainFrame.Position = UDim2.new(0.5, -WINDOW_SIZE.X/2, 0.5, -WINDOW_SIZE.Y/2)
	MainFrame.ClipsDescendants = true

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = MainFrame

	-- Borde Neón Animado
	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 2
	Stroke.Color = ACCENT
	Stroke.Parent = MainFrame
	
	task.spawn(function()
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ACCENT),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 100, 255)),
			ColorSequenceKeypoint.new(1, ACCENT)
		})
		g.Parent = Stroke
		while task.wait(0.02) do g.Rotation = g.Rotation + 2 end
	end)

	-- Barra de Título / Tabs
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0, 100, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.Text = title
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextColor3 = ACCENT
	TitleLabel.TextSize = 14
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Parent = TopBar

	local TabHolder = Instance.new("Frame")
	TabHolder.Name = "TabHolder"
	TabHolder.Position = UDim2.new(0, 120, 0, 5)
	TabHolder.Size = UDim2.new(1, -130, 0, 30)
	TabHolder.BackgroundTransparency = 1
	TabHolder.Parent = TopBar

	local TabList = Instance.new("UIListLayout")
	TabList.FillDirection = Enum.FillDirection.Horizontal
	TabList.Padding = UDim.new(0, 10)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Parent = TabHolder

	local ContainerHolder = Instance.new("Frame")
	ContainerHolder.Name = "ContainerHolder"
	ContainerHolder.Position = UDim2.new(0, 10, 0, 45)
	ContainerHolder.Size = UDim2.new(1, -20, 1, -55)
	ContainerHolder.BackgroundTransparency = 1
	ContainerHolder.Parent = MainFrame

	makeDrag(MainFrame, TopBar)

	local Tabs = {}
	local firstTab = true

	function Tabs:CreateTab(name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 70, 1, 0)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = name
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
		TabBtn.TextSize = 13
		TabBtn.Parent = TabHolder

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = ACCENT
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.Parent = ContainerHolder

		local PageList = Instance.new("UIListLayout")
		PageList.Padding = UDim.new(0, 5)
		PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		PageList.Parent = Page

		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
		end)

		if firstTab then
			Page.Visible = true
			TabBtn.TextColor3 = ACCENT
			firstTab = false
		end

		TabBtn.MouseButton1Click:Connect(function()
			for _, v in pairs(ContainerHolder:GetChildren()) do v.Visible = false end
			for _, v in pairs(TabHolder:GetChildren()) do
				if v:IsA("TextButton") then
					TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
				end
			end
			Page.Visible = true
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = ACCENT}):Play()
		end)

		local Elements = {}

		-- BOTÓN
		function Elements:Button(text, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -10, 0, 35)
			Btn.BackgroundColor3 = BG_SECOND
			Btn.Text = text
			Btn.Font = Enum.Font.GothamSemibold
			Btn.TextColor3 = TEXT_COLOR
			Btn.TextSize = 13
			Btn.AutoButtonColor = false
			Btn.Parent = Page
			
			Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
			Btn.Parent.UICorner.Parent = Btn

			Btn.MouseButton1Click:Connect(function()
				Btn.BackgroundColor3 = ACCENT
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = BG_SECOND}):Play()
				pcall(callback)
			end)
		end

		-- TOGGLE
		function Elements:Toggle(text, default, callback)
			local enabled = default or false
			local TglFrame = Instance.new("TextButton")
			TglFrame.Size = UDim2.new(1, -10, 0, 35)
			TglFrame.BackgroundColor3 = BG_SECOND
			TglFrame.Text = ""
			TglFrame.AutoButtonColor = false
			TglFrame.Parent = Page
			Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
			TglFrame.Parent.UICorner.Parent = TglFrame

			local TglLabel = Instance.new("TextLabel")
			TglLabel.Position = UDim2.new(0, 10, 0, 0)
			TglLabel.Size = UDim2.new(1, -50, 1, 0)
			TglLabel.Text = text
			TglLabel.Font = Enum.Font.Gotham
			TglLabel.TextColor3 = TEXT_COLOR
			TglLabel.TextSize = 13
			TglLabel.TextXAlignment = Enum.TextXAlignment.Left
			TglLabel.BackgroundTransparency = 1
			TglLabel.Parent = TglFrame

			local Box = Instance.new("Frame")
			Box.Size = UDim2.new(0, 20, 0, 20)
			Box.Position = UDim2.new(1, -30, 0.5, -10)
			Box.BackgroundColor3 = BG_MAIN
			Box.BorderSizePixel = 0
			Box.Parent = TglFrame
			Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
			Box.Parent.UICorner.Parent = Box

			local Check = Instance.new("Frame")
			Check.Size = UDim2.new(0, 12, 0, 12)
			Check.Position = UDim2.new(0.5, -6, 0.5, -6)
			Check.BackgroundColor3 = ACCENT
			Check.BackgroundTransparency = enabled and 0 or 1
			Check.Parent = Box
			Instance.new("UICorner").CornerRadius = UDim.new(0, 3)
			Check.Parent.UICorner.Parent = Check

			TglFrame.MouseButton1Click:Connect(function()
				enabled = not enabled
				TweenService:Create(Check, TweenInfo.new(0.2), {BackgroundTransparency = enabled and 0 or 1}):Play()
				pcall(callback, enabled)
			end)
		end

		-- SLIDER
		function Elements:Slider(text, min, max, default, callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, -10, 0, 45)
			SliderFrame.BackgroundColor3 = BG_SECOND
			SliderFrame.Parent = Page
			Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
			SliderFrame.Parent.UICorner.Parent = SliderFrame

			local Label = Instance.new("TextLabel")
			Label.Position = UDim2.new(0, 10, 0, 5)
			Label.Text = text .. ": " .. default
			Label.Font = Enum.Font.Gotham
			Label.TextColor3 = TEXT_COLOR
			Label.TextSize = 12
			Label.BackgroundTransparency = 1
			Label.Parent = SliderFrame

			local Tray = Instance.new("Frame")
			Tray.Size = UDim2.new(1, -20, 0, 4)
			Tray.Position = UDim2.new(0, 10, 0, 30)
			Tray.BackgroundColor3 = BG_MAIN
			Tray.Parent = SliderFrame

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.fromScale((default-min)/(max-min), 1)
			Fill.BackgroundColor3 = ACCENT
			Fill.Parent = Tray

			local function update(input)
				local pos = math.clamp((input.Position.X - Tray.AbsolutePosition.X) / Tray.AbsoluteSize.X, 0, 1)
				local val = math.floor(min + (max - min) * pos)
				Fill.Size = UDim2.fromScale(pos, 1)
				Label.Text = text .. ": " .. val
				pcall(callback, val)
			end

			Tray.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local moveCon, endCon
					update(input)
					moveCon = UserInputService.InputChanged:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
							update(i)
						end
					end)
					endCon = UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							moveCon:Disconnect()
							endCon:Disconnect()
						end
					end)
				end
			end)
		end

		-- DROPDOWN
		function Elements:Dropdown(text, list, callback)
			local isDropped = false
			local DropFrame = Instance.new("Frame")
			DropFrame.Size = UDim2.new(1, -10, 0, 35)
			DropFrame.BackgroundColor3 = BG_SECOND
			DropFrame.ClipsDescendants = true
			DropFrame.Parent = Page
			Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
			DropFrame.Parent.UICorner.Parent = DropFrame

			local DropBtn = Instance.new("TextButton")
			DropBtn.Size = UDim2.new(1, 0, 0, 35)
			DropBtn.BackgroundTransparency = 1
			DropBtn.Text = text .. "  ▼"
			DropBtn.Font = Enum.Font.GothamSemibold
			DropBtn.TextColor3 = TEXT_COLOR
			DropBtn.TextSize = 13
			DropBtn.Parent = DropFrame

			local OptionHolder = Instance.new("Frame")
			OptionHolder.Position = UDim2.new(0, 0, 0, 35)
			OptionHolder.Size = UDim2.new(1, 0, 0, #list * 30)
			OptionHolder.BackgroundTransparency = 1
			OptionHolder.Parent = DropFrame
			
			Instance.new("UIListLayout").Parent = OptionHolder

			for _, opt in pairs(list) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1, 0, 0, 30)
				OptBtn.BackgroundTransparency = 1
				OptBtn.Text = tostring(opt)
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
				OptBtn.TextSize = 12
				OptBtn.Parent = OptionHolder

				OptBtn.MouseButton1Click:Connect(function()
					isDropped = false
					DropFrame:TweenSize(UDim2.new(1, -10, 0, 35), "Out", "Quart", 0.3, true)
					DropBtn.Text = text .. " : " .. opt
					pcall(callback, opt)
				end)
			end

			DropBtn.MouseButton1Click:Connect(function()
				isDropped = not isDropped
				DropFrame:TweenSize(isDropped and UDim2.new(1, -10, 0, 35 + (#list * 30)) or UDim2.new(1, -10, 0, 35), "Out", "Quart", 0.3, true)
			end)
		end

		return Elements
	end

	return Tabs
end

return ViperLib
