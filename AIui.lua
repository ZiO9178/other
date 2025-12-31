local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LucidLib = {
    Theme = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        CornerRadius = UDim.new(0, 8)
    }
}

-- 工具函数：拖动功能
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 创建窗口
function LucidLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Lucid Lib"
    local sub = config.SubTitle or "Premium UI"
    local ver = config.Version or "1.0.0"

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "LucidUI_" .. math.random(100,999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = self.Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = self.Theme.CornerRadius

    MakeDraggable(MainFrame)

    -- 侧边栏
    local SideBar = Instance.new("Frame", MainFrame)
    SideBar.Size = UDim2.new(0, 150, 1, 0)
    SideBar.BackgroundColor3 = self.Theme.Secondary
    SideBar.BorderSizePixel = 0

    local SideCorner = Instance.new("UICorner", SideBar)
    SideCorner.CornerRadius = self.Theme.CornerRadius

    local TitleLabel = Instance.new("TextLabel", SideBar)
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.TextColor3 = self.Theme.Accent
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.BackgroundTransparency = 1

    local TabContainer = Instance.new("ScrollingFrame", SideBar)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)

    -- 内容区
    local ContentHolder = Instance.new("Frame", MainFrame)
    ContentHolder.Position = UDim2.new(0, 160, 0, 10)
    ContentHolder.Size = UDim2.new(1, -170, 1, -20)
    ContentHolder.BackgroundTransparency = 1

    local Tabs = {}
    local FirstTab = true

    function Tabs:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.BackgroundColor3 = LucidLib.Theme.Main
        TabBtn.Text = name
        TabBtn.TextColor3 = LucidLib.Theme.SubText
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", ContentHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = LucidLib.Theme.SubText}):Play()
                end 
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = LucidLib.Theme.Accent}):Play()
        end)

        if FirstTab then
            Page.Visible = true
            TabBtn.TextColor3 = LucidLib.Theme.Accent
            FirstTab = false
        end

        local Elements = {}

        -- 组件：Button
        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 35)
            Btn.BackgroundColor3 = LucidLib.Theme.Secondary
            Btn.Text = text
            Btn.TextColor3 = LucidLib.Theme.Text
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Instance.new("UICorner", Btn)

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = LucidLib.Theme.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = LucidLib.Theme.Secondary}):Play()
                callback()
            end)
        end

        -- 组件：Toggle
        function Elements:CreateToggle(text, config_name, callback)
            local TglFrame = Instance.new("Frame", Page)
            TglFrame.Size = UDim2.new(1, -10, 0, 35)
            TglFrame.BackgroundColor3 = LucidLib.Theme.Secondary
            Instance.new("UICorner", TglFrame)

            local TglLabel = Instance.new("TextLabel", TglFrame)
            TglLabel.Text = "  " .. text
            TglLabel.Size = UDim2.new(1, 0, 1, 0)
            TglLabel.BackgroundTransparency = 1
            TglLabel.TextColor3 = LucidLib.Theme.Text
            TglLabel.TextXAlignment = Enum.TextXAlignment.Left
            TglLabel.Font = Enum.Font.Gotham

            local Status = false
            local Indicator = Instance.new("Frame", TglFrame)
            Indicator.Position = UDim2.new(1, -40, 0.5, -10)
            Indicator.Size = UDim2.new(0, 30, 0, 20)
            Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame", Indicator)
            Dot.Position = UDim2.new(0, 2, 0.5, -8)
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            local function Toggle()
                Status = not Status
                if config_name then _G[config_name] = Status end
                local color = Status and LucidLib.Theme.Accent or Color3.fromRGB(50, 50, 50)
                local pos = Status and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = pos}):Play()
                callback(Status)
            end

            TglFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Toggle() end
            end)
        end

        -- 组件：Slider
        function Elements:CreateSlider(text, min, max, callback)
            local SldFrame = Instance.new("Frame", Page)
            SldFrame.Size = UDim2.new(1, -10, 0, 50)
            SldFrame.BackgroundColor3 = LucidLib.Theme.Secondary
            Instance.new("UICorner", SldFrame)

            local SldLabel = Instance.new("TextLabel", SldFrame)
            SldLabel.Text = "  " .. text
            SldLabel.Size = UDim2.new(1, 0, 0, 25)
            SldLabel.BackgroundTransparency = 1
            SldLabel.TextColor3 = LucidLib.Theme.Text
            SldLabel.TextXAlignment = Enum.TextXAlignment.Left
            SldLabel.Font = Enum.Font.Gotham

            local Bar = Instance.new("Frame", SldFrame)
            Bar.Position = UDim2.new(0, 10, 0, 35)
            Bar.Size = UDim2.new(1, -20, 0, 6)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Bar)

            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = LucidLib.Theme.Accent
            Instance.new("UICorner", Fill)

            local ValLabel = Instance.new("TextLabel", SldFrame)
            ValLabel.Position = UDim2.new(1, -50, 0, 0)
            ValLabel.Size = UDim2.new(0, 40, 0, 25)
            ValLabel.BackgroundTransparency = 1
            ValLabel.TextColor3 = LucidLib.Theme.SubText
            ValLabel.Text = tostring(min)

            local dragging = false
            local function Update()
                local pos = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                ValLabel.Text = tostring(val)
                callback(val)
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update() end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update() end
            end)
        end

        return Elements
    end
    return Tabs
end

return LucidLib