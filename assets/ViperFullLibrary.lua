local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Viper = {
	Theme = {
		Main = Color3.fromRGB(12, 12, 15),
		Secondary = Color3.fromRGB(18, 18, 24),
		Accent = Color3.fromRGB(145, 70, 255),
		Accent2 = Color3.fromRGB(110, 45, 210),
		Text = Color3.fromRGB(245, 245, 245),
		SubText = Color3.fromRGB(165, 165, 175),
		Stroke = Color3.fromRGB(40, 40, 52),
		Shadow = Color3.fromRGB(0, 0, 0),
		Radius = 10
	},
	Connections = {},
	Notifications = {}
}

local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function round(parent, radius)
	return create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or Viper.Theme.Radius)
	})
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Parent = parent,
		Color = color or Viper.Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	})
end

local function tween(obj, time, props, style, direction)
	local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function ensureScreenGui(name)
	local old = CoreGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
	return create("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = CoreGui
	})
end

local function makeDraggable(handle, frame)
	local dragging = false
	local dragStart = Vector2.new()
	local startPos = UDim2.new()

	local down = handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	local up = handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local moved = UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	table.insert(Viper.Connections, down)
	table.insert(Viper.Connections, up)
	table.insert(Viper.Connections, moved)
end

local NotifGui = ensureScreenGui("ViperNotifs")
local NotifHolder = create("Frame", {
	Name = "Holder",
	Parent = NotifGui,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 320, 1, -24),
	Position = UDim2.new(0, 16, 1, -16),
	AnchorPoint = Vector2.new(0, 1)
})

create("UIListLayout", {
	Parent = NotifHolder,
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	Padding = UDim.new(0, 8)
})

function Viper:Notification(title, text, duration)
	local item = create("Frame", {
		Parent = NotifHolder,
		BackgroundColor3 = Viper.Theme.Secondary,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = #self.Notifications + 1
	})
	round(item, 14)
	local s = stroke(item, Viper.Theme.Accent, 1, 1)

	local top = create("TextLabel", {
		Parent = item,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 8),
		Size = UDim2.new(1, -28, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = title or "",
		TextColor3 = Viper.Theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local body = create("TextLabel", {
		Parent = item,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 28),
		Size = UDim2.new(1, -28, 0, 28),
		Font = Enum.Font.Gotham,
		Text = text or "",
		TextColor3 = Viper.Theme.Text,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	tween(item, 0.22, {
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, 62),
		Position = UDim2.new(0, 0, 0, 0)
	})
	tween(s, 0.22, { Transparency = 0.2 })
	tween(top, 0.18, { TextTransparency = 0 })
	tween(body, 0.18, { TextTransparency = 0 })

	local lifetime = duration or 4
	task.delay(lifetime, function()
		if not item.Parent then
			return
		end

		tween(top, 0.16, { TextTransparency = 1 })
		tween(body, 0.16, { TextTransparency = 1 })
		tween(s, 0.16, { Transparency = 1 })
		local out = tween(item, 0.2, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, -18, 0, 0)
		})
		out.Completed:Wait()
		if item and item.Parent then
			item:Destroy()
		end
	end)
end

function Viper:Destroy()
	for _, c in ipairs(self.Connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	self.Connections = {}

	local gui = CoreGui:FindFirstChild("ViperLib")
	if gui then
		gui:Destroy()
	end
end

function Viper:CreateWindow(windowTitle)
	local Gui = ensureScreenGui("ViperLib")

	local Main = create("Frame", {
		Parent = Gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 646, 0, 416),
		BackgroundColor3 = Viper.Theme.Main,
		BorderSizePixel = 0
	})
	round(Main, 14)
	stroke(Main, Viper.Theme.Stroke, 1.25, 0.1)

	local TopBar = create("Frame", {
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Viper.Theme.Secondary,
		BorderSizePixel = 0
	})
	round(TopBar, 14)

	local TopMask = create("Frame", {
		Parent = TopBar,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = Viper.Theme.Secondary,
		BorderSizePixel = 0
	})

	local TitleLabel = create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(1, -32, 1, 0),
		Font = Enum.Font.GothamBlack,
		Text = windowTitle or "Viper",
		TextColor3 = Viper.Theme.Accent,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local AccentLine = create("Frame", {
		Parent = Main,
		Position = UDim2.new(0, 14, 0, 44),
		Size = UDim2.new(1, -28, 0, 2),
		BackgroundColor3 = Viper.Theme.Accent,
		BorderSizePixel = 0
	})
	round(AccentLine, 999)

	makeDraggable(TopBar, Main)

	local Sidebar = create("Frame", {
		Parent = Main,
		Position = UDim2.new(0, 12, 0, 56),
		Size = UDim2.new(0, 170, 1, -68),
		BackgroundColor3 = Viper.Theme.Secondary,
		BorderSizePixel = 0
	})
	round(Sidebar, 12)
	stroke(Sidebar, Viper.Theme.Stroke, 1, 0.2)

	local SidebarTitle = create("TextLabel", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 10),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = "Tabs",
		TextColor3 = Viper.Theme.Accent,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local TabHolder = create("ScrollingFrame", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 36),
		Size = UDim2.new(1, -20, 1, -46),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Viper.Theme.Accent,
		ScrollingDirection = Enum.ScrollingDirection.Y
	})

	create("UIListLayout", {
		Parent = TabHolder,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local Content = create("Frame", {
		Parent = Main,
		Position = UDim2.new(0, 194, 0, 56),
		Size = UDim2.new(1, -206, 1, -68),
		BackgroundTransparency = 1
	})

	local OpenButton = create("ImageButton", {
		Parent = Gui,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 18, 0.5, 0),
		Size = UDim2.new(0, 46, 0, 46),
		BackgroundColor3 = Viper.Theme.Secondary,
		Image = "rbxthumb://type=Asset&id=75575871057272&w=150&h=150",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Fit
	})
	round(OpenButton, 999)
	stroke(OpenButton, Viper.Theme.Accent, 1.5, 0.1)

	local toggleOpen = true
	local animating = false

	local function setVisible(state)
		if animating then
			return
		end

		animating = true
		if state then
			Main.Visible = true
			Main.BackgroundTransparency = 1
			Main.Position = UDim2.new(0.5, 0, 0.5, 12)

			tween(Main, 0.2, { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) })
			task.delay(0.21, function()
				animating = false
			end)
		else
			local t1 = tween(Main, 0.18, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 12) })
			t1.Completed:Wait()
			Main.Visible = false
			animating = false
		end
	end

	OpenButton.MouseButton1Click:Connect(function()
		toggleOpen = not toggleOpen
		setVisible(toggleOpen)
	end)

	local Window = {
		Tabs = {},
		ActiveTab = nil,
		Gui = Gui,
		Main = Main,
		OpenButton = OpenButton
	}

	local function setActive(tab)
		for _, info in ipairs(Window.Tabs) do
			local active = info == tab
			info.Page.Visible = active

			tween(info.Button, 0.15, {
				BackgroundColor3 = active and Viper.Theme.Main or Viper.Theme.Secondary,
				TextColor3 = active and Viper.Theme.Text or Viper.Theme.SubText
			})

			tween(info.Stroke, 0.15, {
				Color = active and Viper.Theme.Accent or Viper.Theme.Stroke
			})

			tween(info.Indicator, 0.15, {
				BackgroundTransparency = active and 0 or 1
			})

			tween(info.Icon, 0.15, {
				ImageColor3 = active and Viper.Theme.Accent or Viper.Theme.SubText
			})
		end

		Window.ActiveTab = tab
	end

	local function refreshCanvas(page)
		task.defer(function()
			page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 12)
		end)
	end

	function Window:CreateTab(tabName, iconId)
		local TabButton = create("TextButton", {
			Parent = TabHolder,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Viper.Theme.Secondary,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0
		})
		round(TabButton, 10)
		local btnStroke = stroke(TabButton, Viper.Theme.Stroke, 1, 0.1)

		local Indicator = create("Frame", {
			Parent = TabButton,
			Name = "Indicator",
			BackgroundColor3 = Viper.Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 8, 0.5, -10),
			Size = UDim2.new(0, 4, 0, 20)
		})
		round(Indicator, 999)

		local Icon = create("ImageLabel", {
			Parent = TabButton,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 18, 0.5, -9),
			Size = UDim2.new(0, 18, 0, 18),
			Image = iconId or "rbxassetid://0",
			ImageColor3 = Viper.Theme.SubText,
			ScaleType = Enum.ScaleType.Fit
		})

		local Label = create("TextLabel", {
			Parent = TabButton,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 44, 0, 0),
			Size = UDim2.new(1, -52, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = tabName or "Tab",
			TextColor3 = Viper.Theme.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local Page = create("ScrollingFrame", {
			Parent = Content,
			Visible = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Viper.Theme.Accent,
			ScrollingDirection = Enum.ScrollingDirection.Y
		})

		create("UIPadding", {
			Parent = Page,
			PaddingTop = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 8)
		})

		local Layout = create("UIListLayout", {
			Parent = Page,
			Name = "UIListLayout",
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local Tab = {
			Button = TabButton,
			Page = Page,
			Stroke = btnStroke,
			Indicator = Indicator,
			Icon = Icon,
			Layout = Layout
		}

		table.insert(Window.Tabs, Tab)

		TabButton.MouseEnter:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(TabButton, 0.12, { BackgroundColor3 = Color3.fromRGB(24, 24, 31) })
			end
		end)

		TabButton.MouseLeave:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(TabButton, 0.12, { BackgroundColor3 = Viper.Theme.Secondary })
			end
		end)

		TabButton.MouseButton1Click:Connect(function()
			setActive(Tab)
		end)

		local function refresh()
			refreshCanvas(Page)
		end

		function Tab:CreateSection(text)
			local f = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, -4, 0, 40),
				BackgroundColor3 = Viper.Theme.Secondary,
				BorderSizePixel = 0
			})
			round(f, 10)
			stroke(f, Viper.Theme.Stroke, 1, 0.2)

			create("TextLabel", {
				Parent = f,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -24, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = text or "Section",
				TextColor3 = Viper.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			refresh()
			return f
		end

		function Tab:CreateButton(text, callback)
			local b = create("TextButton", {
				Parent = Page,
				Size = UDim2.new(1, -4, 0, 40),
				BackgroundColor3 = Viper.Theme.Secondary,
				BorderSizePixel = 0,
				Text = text or "Button",
				Font = Enum.Font.GothamSemibold,
				TextColor3 = Viper.Theme.Text,
				TextSize = 13,
				AutoButtonColor = false
			})
			round(b, 10)
			local bs = stroke(b, Viper.Theme.Stroke, 1, 0.2)

			b.MouseEnter:Connect(function()
				tween(b, 0.12, { BackgroundColor3 = Color3.fromRGB(24, 24, 31) })
				tween(bs, 0.12, { Color = Viper.Theme.Accent })
			end)

			b.MouseLeave:Connect(function()
				tween(b, 0.12, { BackgroundColor3 = Viper.Theme.Secondary })
				tween(bs, 0.12, { Color = Viper.Theme.Stroke })
			end)

			b.MouseButton1Click:Connect(function()
				tween(b, 0.08, { BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
				task.delay(0.08, function()
					if b and b.Parent then
						tween(b, 0.12, { BackgroundColor3 = Viper.Theme.Secondary })
					end
				end)
				if callback then
					task.spawn(callback)
				end
			end)

			refresh()
			return b
		end

		function Tab:CreateToggle(text, default, callback)
			local value = default and true or false

			local row = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, -4, 0, 40),
				BackgroundColor3 = Viper.Theme.Secondary,
				BorderSizePixel = 0
			})
			round(row, 10)
			stroke(row, Viper.Theme.Stroke, 1, 0.2)

			create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -70, 1, 0),
				Font = Enum.Font.Gotham,
				Text = text or "Toggle",
				TextColor3 = Viper.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local pill = create("Frame", {
				Parent = row,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 38, 0, 18),
				BackgroundColor3 = Color3.fromRGB(45, 45, 55),
				BorderSizePixel = 0
			})
			round(pill, 999)

			local dot = create("Frame", {
				Parent = pill,
				Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundColor3 = Color3.fromRGB(250, 250, 250),
				BorderSizePixel = 0
			})
			round(dot, 999)

			local hit = create("TextButton", {
				Parent = row,
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				AutoButtonColor = false
			})

			local function apply()
				tween(pill, 0.16, { BackgroundColor3 = value and Viper.Theme.Accent or Color3.fromRGB(45, 45, 55) })
				tween(dot, 0.16, {
					Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
				})
				if callback then
					callback(value)
				end
			end

			hit.MouseButton1Click:Connect(function()
				value = not value
				apply()
			end)

			apply()
			refresh()
			return row
		end

		function Tab:CreateSlider(text, min, max, default, callback)
			min = tonumber(min) or 0
			max = tonumber(max) or 100
			default = tonumber(default) or min

			local value = math.clamp(default, min, max)
			local dragging = false

			local row = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, -4, 0, 56),
				BackgroundColor3 = Viper.Theme.Secondary,
				BorderSizePixel = 0
			})
			round(row, 10)
			stroke(row, Viper.Theme.Stroke, 1, 0.2)

			local lbl = create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -88, 0, 16),
				Font = Enum.Font.Gotham,
				Text = text or "Slider",
				TextColor3 = Viper.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local val = create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -56, 0, 8),
				Size = UDim2.new(0, 44, 0, 16),
				Font = Enum.Font.GothamBold,
				Text = tostring(value),
				TextColor3 = Viper.Theme.Accent,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right
			})

			local bar = create("Frame", {
				Parent = row,
				Position = UDim2.new(0, 12, 0, 32),
				Size = UDim2.new(1, -24, 0, 8),
				BackgroundColor3 = Color3.fromRGB(32, 32, 40),
				BorderSizePixel = 0
			})
			round(bar, 999)

			local fill = create("Frame", {
				Parent = bar,
				Size = UDim2.new((value - min) / math.max((max - min), 1), 0, 1, 0),
				BackgroundColor3 = Viper.Theme.Accent,
				BorderSizePixel = 0
			})
			round(fill, 999)

			local knob = create("Frame", {
				Parent = bar,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((value - min) / math.max((max - min), 1), 0, 0.5, 0),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundColor3 = Color3.fromRGB(245, 245, 245),
				BorderSizePixel = 0
			})
			round(knob, 999)
			stroke(knob, Color3.fromRGB(0, 0, 0), 1, 0.65)

			local function setFromX(x)
				local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
				local newValue = min + ((max - min) * alpha)
				value = math.floor(newValue + 0.5)
				local ratio = (value - min) / math.max((max - min), 1)

				val.Text = tostring(value)
				tween(fill, 0.06, { Size = UDim2.new(ratio, 0, 1, 0) })
				tween(knob, 0.06, { Position = UDim2.new(ratio, 0, 0.5, 0) })

				if callback then
					callback(value)
				end
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					setFromX(Mouse.X)
				end
			end)

			bar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			local moveConn = UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					setFromX(Mouse.X)
				end
			end)
			table.insert(Viper.Connections, moveConn)

			refresh()
			if callback then
				task.spawn(callback, value)
			end
			return row
		end

		function Tab:CreateDropdown(text, list, callback)
			list = list or {}
			local selected = nil
			local expanded = false

			local row = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, -4, 0, 40),
				BackgroundColor3 = Viper.Theme.Secondary,
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			round(row, 10)
			stroke(row, Viper.Theme.Stroke, 1, 0.2)

			local head = create("TextButton", {
				Parent = row,
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, 40),
				AutoButtonColor = false
			})

			local lbl = create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -44, 0, 40),
				Font = Enum.Font.Gotham,
				Text = text or "Dropdown",
				TextColor3 = Viper.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local arrow = create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -28, 0, 0),
				Size = UDim2.new(0, 16, 0, 40),
				Font = Enum.Font.GothamBold,
				Text = "⌄",
				TextColor3 = Viper.Theme.Accent,
				TextSize = 16
			})

			local listHolder = create("Frame", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0, 44),
				Size = UDim2.new(1, -16, 0, 0),
				ClipsDescendants = true
			})

			local listLayout = create("UIListLayout", {
				Parent = listHolder,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			for _, item in ipairs(list) do
				local opt = create("TextButton", {
					Parent = listHolder,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = Viper.Theme.Main,
					BorderSizePixel = 0,
					Text = tostring(item),
					Font = Enum.Font.Gotham,
					TextColor3 = Viper.Theme.SubText,
					TextSize = 12,
					AutoButtonColor = false
				})
				round(opt, 8)
				local os = stroke(opt, Viper.Theme.Stroke, 1, 0.2)

				opt.MouseEnter:Connect(function()
					tween(opt, 0.12, { BackgroundColor3 = Color3.fromRGB(24, 24, 31) })
					tween(os, 0.12, { Color = Viper.Theme.Accent })
				end)

				opt.MouseLeave:Connect(function()
					tween(opt, 0.12, { BackgroundColor3 = Viper.Theme.Main })
					tween(os, 0.12, { Color = Viper.Theme.Stroke })
				end)

				opt.MouseButton1Click:Connect(function()
					selected = tostring(item)
					lbl.Text = text .. " : " .. selected
					expanded = false
					tween(arrow, 0.16, { Rotation = 0 })
					tween(row, 0.2, { Size = UDim2.new(1, -4, 0, 40) })
					tween(listHolder, 0.2, { Size = UDim2.new(1, -16, 0, 0) })
					refresh()
					if callback then
						callback(selected)
					end
				end)
			end

			local function toggle()
				expanded = not expanded
				local targetHeight = expanded and (46 + (#list * 32)) or 40
				tween(row, 0.22, { Size = UDim2.new(1, -4, 0, targetHeight) })
				tween(listHolder, 0.22, {
					Size = UDim2.new(1, -16, 0, expanded and ((#list * 28) + math.max(#list - 1, 0) * 4) or 0)
				})
				tween(arrow, 0.16, { Rotation = expanded and 180 or 0 })
				refresh()
			end

			head.MouseButton1Click:Connect(toggle)

			refresh()
			return row
		end

		function Tab:CreateColorPicker(text, defaultColor, callback)
			local selected = defaultColor or Color3.fromRGB(145, 70, 255)

			local row = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, -4, 0, 40),
				BackgroundColor3 = Viper.Theme.Secondary,
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			round(row, 10)
			stroke(row, Viper.Theme.Stroke, 1, 0.2)

			local head = create("TextButton", {
				Parent = row,
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, 40),
				AutoButtonColor = false
			})

			local lbl = create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -90, 0, 40),
				Font = Enum.Font.Gotham,
				Text = text or "Color Picker",
				TextColor3 = Viper.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local preview = create("Frame", {
				Parent = row,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -36, 0.5, 0),
				Size = UDim2.new(0, 18, 0, 18),
				BackgroundColor3 = selected,
				BorderSizePixel = 0
			})
			round(preview, 999)
			stroke(preview, Color3.fromRGB(255, 255, 255), 1, 0.7)

			local arrow = create("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -20, 0, 0),
				Size = UDim2.new(0, 16, 0, 40),
				Font = Enum.Font.GothamBold,
				Text = "⌄",
				TextColor3 = Viper.Theme.Accent,
				TextSize = 16
			})

			local overlay = create("Frame", {
				Parent = Gui,
				Visible = false,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 40
			})

			local closeLayer = create("TextButton", {
				Parent = overlay,
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				AutoButtonColor = false,
				ZIndex = 40
			})

			local popup = create("Frame", {
				Parent = overlay,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 340, 0, 288),
				BackgroundColor3 = Viper.Theme.Main,
				BorderSizePixel = 0,
				ZIndex = 41
			})
			round(popup, 14)
			stroke(popup, Viper.Theme.Stroke, 1, 0.1)

			create("TextLabel", {
				Parent = popup,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 10),
				Size = UDim2.new(1, -54, 0, 18),
				Font = Enum.Font.GothamBold,
				Text = text or "Color Picker",
				TextColor3 = Viper.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 42
			})

			local closeBtn = create("TextButton", {
				Parent = popup,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -34, 0, 6),
				Size = UDim2.new(0, 24, 0, 24),
				Text = "×",
				Font = Enum.Font.GothamBold,
				TextSize = 20,
				TextColor3 = Viper.Theme.SubText,
				AutoButtonColor = false,
				ZIndex = 43
			})

			local previewBox = create("Frame", {
				Parent = popup,
				Position = UDim2.new(0, 14, 0, 36),
				Size = UDim2.new(1, -28, 0, 28),
				BackgroundColor3 = selected,
				BorderSizePixel = 0,
				ZIndex = 42
			})
			round(previewBox, 10)
			stroke(previewBox, Color3.fromRGB(255, 255, 255), 1, 0.75)

			local hexBox = create("TextBox", {
				Parent = popup,
				Position = UDim2.new(0, 14, 0, 72),
				Size = UDim2.new(1, -28, 0, 30),
				BackgroundColor3 = Viper.Theme.Secondary,
				Text = "",
				PlaceholderText = "#RRGGBB",
				PlaceholderColor3 = Viper.Theme.SubText,
				ClearTextOnFocus = false,
				Font = Enum.Font.GothamSemibold,
				TextColor3 = Viper.Theme.Text,
				TextSize = 12,
				BorderSizePixel = 0,
				ZIndex = 42
			})
			round(hexBox, 10)
			stroke(hexBox, Viper.Theme.Stroke, 1, 0.2)

			local rgb = {
				R = math.floor(selected.R * 255 + 0.5),
				G = math.floor(selected.G * 255 + 0.5),
				B = math.floor(selected.B * 255 + 0.5)
			}

			local container = create("Frame", {
				Parent = popup,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 112),
				Size = UDim2.new(1, -28, 1, -124),
				ZIndex = 42
			})

			create("UIListLayout", {
				Parent = container,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			local function rgbToHex(r, g, b)
				return string.format("#%02X%02X%02X", r, g, b)
			end

			local function parseHex(str)
				if not str then
					return nil
				end
				str = str:gsub("#", ""):gsub("%s+", "")
				if #str ~= 6 then
					return nil
				end
				local r = tonumber(str:sub(1, 2), 16)
				local g = tonumber(str:sub(3, 4), 16)
				local b = tonumber(str:sub(5, 6), 16)
				if not (r and g and b) then
					return nil
				end
				return r, g, b
			end

			local function applyColor()
				selected = Color3.fromRGB(rgb.R, rgb.G, rgb.B)
				preview.BackgroundColor3 = selected
				previewBox.BackgroundColor3 = selected
				hexBox.Text = rgbToHex(rgb.R, rgb.G, rgb.B)
				if callback then
					callback(selected)
				end
			end

			local function miniSlider(labelText, key, initial)
				local holder = create("Frame", {
					Parent = container,
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = Viper.Theme.Secondary,
					BorderSizePixel = 0,
					ZIndex = 42
				})
				round(holder, 10)
				stroke(holder, Viper.Theme.Stroke, 1, 0.2)

				create("TextLabel", {
					Parent = holder,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 4),
					Size = UDim2.new(1, -20, 0, 14),
					Font = Enum.Font.Gotham,
					Text = labelText,
					TextColor3 = Viper.Theme.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 43
				})

				local valueLabel = create("TextLabel", {
					Parent = holder,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -44, 0, 4),
					Size = UDim2.new(0, 34, 0, 14),
					Font = Enum.Font.GothamBold,
					Text = tostring(initial),
					TextColor3 = Viper.Theme.Accent,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 43
				})

				local bar = create("Frame", {
					Parent = holder,
					Position = UDim2.new(0, 10, 0, 22),
					Size = UDim2.new(1, -20, 0, 8),
					BackgroundColor3 = Color3.fromRGB(32, 32, 40),
					BorderSizePixel = 0,
					ZIndex = 43
				})
				round(bar, 999)

				local fill = create("Frame", {
					Parent = bar,
					Size = UDim2.new(initial / 255, 0, 1, 0),
					BackgroundColor3 = Viper.Theme.Accent,
					BorderSizePixel = 0,
					ZIndex = 44
				})
				round(fill, 999)

				local knob = create("Frame", {
					Parent = bar,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(initial / 255, 0, 0.5, 0),
					Size = UDim2.new(0, 10, 0, 10),
					BackgroundColor3 = Color3.fromRGB(245, 245, 245),
					BorderSizePixel = 0,
					ZIndex = 44
				})
				round(knob, 999)
				stroke(knob, Color3.fromRGB(0, 0, 0), 1, 0.65)

				local dragging = false

				local function update(x)
					local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
					local n = math.floor(alpha * 255 + 0.5)
					rgb[key] = n
					valueLabel.Text = tostring(n)
					tween(fill, 0.06, { Size = UDim2.new(alpha, 0, 1, 0) })
					tween(knob, 0.06, { Position = UDim2.new(alpha, 0, 0.5, 0) })
					applyColor()
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						update(Mouse.X)
					end
				end)

				bar.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				local c = UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						update(Mouse.X)
					end
				end)
				table.insert(Viper.Connections, c)
			end

			miniSlider("R", "R", rgb.R)
			miniSlider("G", "G", rgb.G)
			miniSlider("B", "B", rgb.B)

			local function openPopup()
				overlay.Visible = true
				overlay.BackgroundTransparency = 1
				popup.Size = UDim2.new(0, 326, 0, 276)
				tween(overlay, 0.16, { BackgroundTransparency = 0.45 })
				tween(popup, 0.18, { Size = UDim2.new(0, 340, 0, 288) })
			end

			local function closePopup()
				local t1 = tween(overlay, 0.14, { BackgroundTransparency = 1 })
				tween(popup, 0.14, { Size = UDim2.new(0, 326, 0, 276) })
				t1.Completed:Wait()
				if overlay then
					overlay.Visible = false
				end
			end

			local function toggle()
				if overlay.Visible then
					closePopup()
				else
					openPopup()
				end
			end

			head.MouseButton1Click:Connect(toggle)
			closeBtn.MouseButton1Click:Connect(closePopup)
			closeLayer.MouseButton1Click:Connect(function()
				if overlay.Visible then
					closePopup()
				end
			end)

			hexBox.FocusLost:Connect(function(enterPressed)
				local r, g, b = parseHex(hexBox.Text)
				if r and g and b then
					rgb.R, rgb.G, rgb.B = r, g, b
					applyColor()
				elseif enterPressed then
					hexBox.Text = rgbToHex(rgb.R, rgb.G, rgb.B)
				end
			end)

			applyColor()
			refresh()
			return row
		end

		if #Window.Tabs == 1 then
			setActive(Tab)
		end

		return Tab
	end

	function Window:Notify(title, text, duration)
		return Viper:Notification(title, text, duration)
	end

	Main.Visible = true

	return Window
end

return Viper
