--[[
    AdvancedSpy - Advanced Version
    Feature-rich remote spy with blocking, filtering, and detailed logging.
    Version: 2.0.0
]]

local AdvancedSpy = {
    Version = "2.0.0",
    Enabled = false,
    RemoteLog = {},
    BlockedRemotes = {},
    FilteredRemotes = {},
    Settings = {
        MaxLogs = 500,
        AutoScroll = true,
        ShowArgs = true,
        ShowReturnValues = true,
        Theme = "dark"
    }
}

-- Color Theme
local Colors = {
    dark = {
        bg = Color3.fromRGB(30, 30, 30),
        secondary = Color3.fromRGB(50, 50, 50),
        header = Color3.fromRGB(255, 85, 85),
        text = Color3.fromRGB(255, 255, 255),
        accent = Color3.fromRGB(100, 200, 255),
        success = Color3.fromRGB(100, 255, 100),
        warning = Color3.fromRGB(255, 200, 100),
        error = Color3.fromRGB(255, 100, 100)
    },
    light = {
        bg = Color3.fromRGB(240, 240, 240),
        secondary = Color3.fromRGB(200, 200, 200),
        header = Color3.fromRGB(220, 80, 80),
        text = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(0, 100, 200),
        success = Color3.fromRGB(0, 150, 0),
        warning = Color3.fromRGB(200, 150, 0),
        error = Color3.fromRGB(200, 50, 50)
    }
}

local function getColor(name)
    return Colors[AdvancedSpy.Settings.Theme][name] or Colors.dark[name]
end

-- Create Main GUI
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedSpyGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if screenGui.Parent == nil then
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 700, 0, 550)
    container.Position = UDim2.new(0.5, -350, 0.5, -275)
    container.BackgroundColor3 = getColor("bg")
    container.BorderSizePixel = 2
    container.BorderColor3 = getColor("header")
    container.Parent = screenGui

    -- Dragging
    local dragging = false
    local dragStart = nil
    local frameStart = nil

    container.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = container.Position
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and dragStart then
            local delta = input.Position - dragStart
            container.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = getColor("header")
    header.BorderSizePixel = 0
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Text = "AdvancedSpy v" .. AdvancedSpy.Version
    title.Size = UDim2.new(1, -50, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = getColor("text")
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Padding = UDim.new(0, 10)
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundColor3 = getColor("error")
    closeBtn.TextColor3 = getColor("text")
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header

    closeBtn.MouseButton1Click:Connect(function()
        AdvancedSpy:Destroy()
    end)

    -- Tab Buttons
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = getColor("secondary")
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = container

    local tabs = {}
    local tabNames = {"Logs", "Remotes", "Settings"}
    
    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Text = tabName
        tabBtn.Size = UDim2.new(0, 100, 1, 0)
        tabBtn.Position = UDim2.new(0, (i-1) * 110, 0, 0)
        tabBtn.BackgroundColor3 = getColor("secondary")
        tabBtn.TextColor3 = getColor("text")
        tabBtn.BorderSizePixel = 0
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 12
        tabBtn.Parent = tabContainer
        
        tabs[tabName] = tabBtn
    end

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -70)
    contentArea.Position = UDim2.new(0, 0, 0, 70)
    contentArea.BackgroundColor3 = getColor("bg")
    contentArea.BorderSizePixel = 0
    contentArea.Parent = container

    -- Logs Tab
    local logsTab = Instance.new("Frame")
    logsTab.Name = "LogsTab"
    logsTab.Size = UDim2.new(1, 0, 1, 0)
    logsTab.BackgroundColor3 = getColor("bg")
    logsTab.BorderSizePixel = 0
    logsTab.Parent = contentArea

    local searchBar = Instance.new("TextBox")
    searchBar.Name = "SearchBar"
    searchBar.Size = UDim2.new(1, -20, 0, 25)
    searchBar.Position = UDim2.new(0, 10, 0, 5)
    searchBar.PlaceholderText = "Search remotes..."
    searchBar.BackgroundColor3 = getColor("secondary")
    searchBar.TextColor3 = getColor("text")
    searchBar.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBar.BorderSizePixel = 1
    searchBar.BorderColor3 = getColor("accent")
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextSize = 12
    searchBar.Parent = logsTab

    local scrollLogs = Instance.new("ScrollingFrame")
    scrollLogs.Name = "ScrollLogs"
    scrollLogs.Size = UDim2.new(1, -20, 1, -40)
    scrollLogs.Position = UDim2.new(0, 10, 0, 35)
    scrollLogs.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollLogs.BackgroundTransparency = 1
    scrollLogs.ScrollBarThickness = 8
    scrollLogs.Parent = logsTab

    -- Remotes Tab
    local remotesTab = Instance.new("Frame")
    remotesTab.Name = "RemotesTab"
    remotesTab.Size = UDim2.new(1, 0, 1, 0)
    remotesTab.BackgroundColor3 = getColor("bg")
    remotesTab.BorderSizePixel = 0
    remotesTab.Visible = false
    remotesTab.Parent = contentArea

    local scrollRemotes = Instance.new("ScrollingFrame")
    scrollRemotes.Name = "ScrollRemotes"
    scrollRemotes.Size = UDim2.new(1, -20, 1, -10)
    scrollRemotes.Position = UDim2.new(0, 10, 0, 5)
    scrollRemotes.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollRemotes.BackgroundTransparency = 1
    scrollRemotes.ScrollBarThickness = 8
    scrollRemotes.Parent = remotesTab

    -- Settings Tab
    local settingsTab = Instance.new("Frame")
    settingsTab.Name = "SettingsTab"
    settingsTab.Size = UDim2.new(1, 0, 1, 0)
    settingsTab.BackgroundColor3 = getColor("bg")
    settingsTab.BorderSizePixel = 0
    settingsTab.Visible = false
    settingsTab.Parent = contentArea

    local settingsScroll = Instance.new("ScrollingFrame")
    settingsScroll.Name = "SettingsScroll"
    settingsScroll.Size = UDim2.new(1, -20, 1, -10)
    settingsScroll.Position = UDim2.new(0, 10, 0, 5)
    settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
    settingsScroll.BackgroundTransparency = 1
    settingsScroll.ScrollBarThickness = 8
    settingsScroll.Parent = settingsTab

    -- Tab switching
    local currentTab = "Logs"
    tabs["Logs"].MouseButton1Click:Connect(function()
        logsTab.Visible = true
        remotesTab.Visible = false
        settingsTab.Visible = false
        currentTab = "Logs"
    end)

    tabs["Remotes"].MouseButton1Click:Connect(function()
        logsTab.Visible = false
        remotesTab.Visible = true
        settingsTab.Visible = false
        currentTab = "Remotes"
    end)

    tabs["Settings"].MouseButton1Click:Connect(function()
        logsTab.Visible = false
        remotesTab.Visible = false
        settingsTab.Visible = true
        currentTab = "Settings"
    end)

    return {
        ScreenGui = screenGui,
        Container = container,
        LogsScroll = scrollLogs,
        RemotesScroll = scrollRemotes,
        SettingsScroll = settingsScroll,
        SearchBar = searchBar
    }
end

-- Add log entry
function AdvancedSpy:AddLogEntry(remote, args)
    local logEntry = {
        Name = remote.Name,
        Args = args,
        Time = os.time(),
        TimeStr = os.date("%H:%M:%S", os.time()),
        Count = 1
    }

    -- Check if remote already exists in log
    for i, log in ipairs(self.RemoteLog) do
        if log.Name == remote.Name then
            log.Count = (log.Count or 1) + 1
            log.Time = os.time()
            log.TimeStr = os.date("%H:%M:%S", os.time())
            table.move(self.RemoteLog, i, i, 1)
            self:UpdateDisplay()
            return
        end
    end

    table.insert(self.RemoteLog, 1, logEntry)
    
    if #self.RemoteLog > self.Settings.MaxLogs then
        table.remove(self.RemoteLog)
    end

    self:UpdateDisplay()
end

-- Update display
function AdvancedSpy:UpdateDisplay()
    if not self.GUI then return end
    
    local scroll = self.GUI.LogsScroll
    scroll:ClearAllChildren()
    
    local yPos = 0
    for i, log in ipairs(self.RemoteLog) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, -10, 0, 45)
        entry.Position = UDim2.new(0, 5, 0, yPos)
        entry.BackgroundColor3 = getColor("secondary")
        entry.BorderColor3 = getColor("header")
        entry.BorderSizePixel = 1
        entry.Parent = scroll

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = log.Name .. (log.Count > 1 and " [x" .. log.Count .. "]" or "")
        nameLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = getColor("text")
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = entry

        local timeLabel = Instance.new("TextLabel")
        timeLabel.Text = log.TimeStr
        timeLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
        timeLabel.Position = UDim2.new(0.6, 0, 0, 2)
        timeLabel.BackgroundTransparency = 1
        timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        timeLabel.TextSize = 11
        timeLabel.Font = Enum.Font.Gotham
        timeLabel.TextXAlignment = Enum.TextXAlignment.Right
        timeLabel.Parent = entry

        local argsLabel = Instance.new("TextLabel")
        argsLabel.Text = "Args: " .. #log.Args
        argsLabel.Size = UDim2.new(1, -10, 0.5, 0)
        argsLabel.Position = UDim2.new(0, 5, 0.5, 0)
        argsLabel.BackgroundTransparency = 1
        argsLabel.TextColor3 = getColor("accent")
        argsLabel.TextSize = 11
        argsLabel.Font = Enum.Font.Gotham
        argsLabel.TextXAlignment = Enum.TextXAlignment.Left
        argsLabel.Parent = entry

        yPos = yPos + 50
    end

    self.GUI.LogsScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(yPos, 1))
end

-- Initialize
function AdvancedSpy:Init()
    print("[AdvancedSpy] Starting...")
    
    if not game then
        warn("[AdvancedSpy] Must run in Roblox!")
        return
    end

    self.GUI = createMainGUI()

    local function hookRemote(remote)
        if self.BlockedRemotes[remote.Name] then return end
        
        local original = remote.FireServer
        remote.FireServer = function(_, ...)
            local args = {...}
            AdvancedSpy:AddLogEntry(remote, args)
            return original(remote, ...)
        end
    end

    -- Hook existing
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            hookRemote(obj)
        end
    end

    -- Hook new
    game.DescendantAdded:Connect(function(child)
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            task.wait(0.1)
            hookRemote(child)
        end
    end)

    self.Enabled = true
    print("[AdvancedSpy] Ready!")
end

-- Destroy
function AdvancedSpy:Destroy()
    self.Enabled = false
    if self.GUI and self.GUI.ScreenGui then
        self.GUI.ScreenGui:Destroy()
    end
    print("[AdvancedSpy] Closed")
end

-- Start
AdvancedSpy:Init()
return AdvancedSpy
