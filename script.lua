local fenv = getfenv()
local CoreGui = game:GetService('CoreGui')
local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')
local LocalPlayer = Players.LocalPlayer

-- Cleanup existing
pcall(function()
    CoreGui:FindFirstChild('LozzHub'):Destroy()
end)

-- State
local activated = false
local animOn = false
local modeIndex = 1
local modes = {'Carpet', 'Respawn', 'Unwalk'}

-- Root GUI
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'LozzHub'
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Panel
local Panel = Instance.new('Frame', ScreenGui)
Panel.Size = UDim2.new(0, 220, 0, 178)
Panel.Position = UDim2.new(0.75, 0, 0.45, 0)
Panel.BackgroundColor3 = Color3.fromRGB(17, 19, 24)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true

local PanelCorner = Instance.new('UICorner', Panel)
PanelCorner.CornerRadius = UDim.new(0, 4)

local PanelStroke = Instance.new('UIStroke', Panel)
PanelStroke.Color = Color3.fromRGB(30, 33, 40)
PanelStroke.Thickness = 1

-- Header
local Header = Instance.new('Frame', Panel)
Header.Size = UDim2.new(1, 0, 0, 28)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(13, 15, 19)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new('UICorner', Header)
HeaderCorner.CornerRadius = UDim.new(0, 4)

local HeaderBottomFix = Instance.new('Frame', Header)
HeaderBottomFix.Size = UDim2.new(1, 0, 0, 4)
HeaderBottomFix.Position = UDim2.new(0, 0, 1, -4)
HeaderBottomFix.BackgroundColor3 = Color3.fromRGB(13, 15, 19)
HeaderBottomFix.BorderSizePixel = 0

local HeaderDivider = Instance.new('Frame', Panel)
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 28)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
HeaderDivider.BorderSizePixel = 0

local TitleLabel = Instance.new('TextLabel', Header)
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = 'DESYNC'
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextColor3 = Color3.fromRGB(200, 205, 216)
TitleLabel.TextSize = 11
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status dot
local StatusDot = Instance.new('Frame', Header)
StatusDot.Size = UDim2.new(0, 6, 0, 6)
StatusDot.Position = UDim2.new(1, -42, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
StatusDot.BorderSizePixel = 0

local StatusDotCorner = Instance.new('UICorner', StatusDot)
StatusDotCorner.CornerRadius = UDim.new(1, 0)

local StatusLabel = Instance.new('TextLabel', Header)
StatusLabel.Size = UDim2.new(0, 50, 1, 0)
StatusLabel.Position = UDim2.new(1, -34, 0, 0)
StatusLabel.Text = 'inactive'
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextColor3 = Color3.fromRGB(85, 85, 85)
StatusLabel.TextSize = 9
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Helper: create a button row
local function makeButton(parent, posY, labelText, keyText)
    local btn = Instance.new('TextButton', parent)
    btn.Size = UDim2.new(1, -16, 0, 28)
    btn.Position = UDim2.new(0, 8, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 34)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ''

    local corner = Instance.new('UICorner', btn)
    corner.CornerRadius = UDim.new(0, 3)

    local stroke = Instance.new('UIStroke', btn)
    stroke.Color = Color3.fromRGB(30, 33, 40)
    stroke.Thickness = 1

    local lbl = Instance.new('TextLabel', btn)
    lbl.Size = UDim2.new(1, -36, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(138, 144, 158)
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local keyLbl = Instance.new('TextLabel', btn)
    keyLbl.Size = UDim2.new(0, 28, 0, 16)
    keyLbl.Position = UDim2.new(1, -32, 0.5, -8)
    keyLbl.Text = keyText or ''
    keyLbl.Font = Enum.Font.Code
    keyLbl.TextColor3 = Color3.fromRGB(85, 85, 85)
    keyLbl.TextSize = 10
    keyLbl.BackgroundColor3 = Color3.fromRGB(20, 23, 28)
    keyLbl.BorderSizePixel = 0

    local keyCorner = Instance.new('UICorner', keyLbl)
    keyCorner.CornerRadius = UDim.new(0, 2)

    local keyStroke = Instance.new('UIStroke', keyLbl)
    keyStroke.Color = Color3.fromRGB(42, 48, 64)
    keyStroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(28, 32, 40)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(24, 28, 34)
        }):Play()
    end)

    return btn, lbl, stroke, keyLbl
end

-- ACTIVATE button
local activateBtn, activateLbl, activateStroke, activateKey = makeButton(Panel, 36, 'ACTIVATE', 'F')
activateKey.Text = 'F'
activateLbl.TextColor3 = Color3.fromRGB(232, 235, 240)
activateLbl.Font = Enum.Font.GothamBold

activateBtn.MouseButton1Click:Connect(function()
    activated = not activated
    if activated then
        TweenService:Create(activateBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(14, 31, 58)}):Play()
        TweenService:Create(activateStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(61, 142, 255)}):Play()
        activateLbl.Text = 'DEACTIVATE'
        activateLbl.TextColor3 = Color3.fromRGB(111, 179, 255)
        activateKey.TextColor3 = Color3.fromRGB(111, 179, 255)
        StatusDot.BackgroundColor3 = Color3.fromRGB(61, 220, 132)
        StatusLabel.TextColor3 = Color3.fromRGB(61, 220, 132)
        StatusLabel.Text = 'active'
        StarterGui:SetCore('SendNotification', {Title = 'Lozz Hub', Text = 'Desync activated!', Duration = 2})
    else
        TweenService:Create(activateBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 28, 34)}):Play()
        TweenService:Create(activateStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(30, 33, 40)}):Play()
        activateLbl.Text = 'ACTIVATE'
        activateLbl.TextColor3 = Color3.fromRGB(232, 235, 240)
        activateKey.TextColor3 = Color3.fromRGB(85, 85, 85)
        StatusDot.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
        StatusLabel.TextColor3 = Color3.fromRGB(85, 85, 85)
        StatusLabel.Text = 'inactive'
        StarterGui:SetCore('SendNotification', {Title = 'Lozz Hub', Text = 'Desync deactivated.', Duration = 2})
    end
end)

-- NO ANIM toggle
local animBtn, animLbl, animStroke, animVal = makeButton(Panel, 72, 'NO ANIM', '')
animVal.Text = 'OFF'
animVal.TextColor3 = Color3.fromRGB(224, 82, 82)
animVal.Size = UDim2.new(0, 36, 0, 16)
animVal.Position = UDim2.new(1, -40, 0.5, -8)

animBtn.MouseButton1Click:Connect(function()
    animOn = not animOn
    if animOn then
        animVal.Text = 'ON'
        animVal.TextColor3 = Color3.fromRGB(61, 220, 132)
    else
        animVal.Text = 'OFF'
        animVal.TextColor3 = Color3.fromRGB(224, 82, 82)
    end
end)

-- MODE cycle
local modeBtn, modeLbl, modeStroke, modeVal = makeButton(Panel, 108, 'MODE', '')
modeVal.Text = modes[modeIndex]
modeVal.TextColor3 = Color3.fromRGB(200, 160, 53)
modeVal.Font = Enum.Font.GothamBold
modeVal.TextSize = 11
modeVal.Size = UDim2.new(0, 56, 0, 16)
modeVal.Position = UDim2.new(1, -60, 0.5, -8)

modeBtn.MouseButton1Click:Connect(function()
    modeIndex = (modeIndex % #modes) + 1
    modeVal.Text = modes[modeIndex]
    StarterGui:SetCore('SendNotification', {Title = 'Lozz Hub', Text = 'Mode: ' .. modes[modeIndex], Duration = 1})
end)

-- Footer
local Footer = Instance.new('Frame', Panel)
Footer.Size = UDim2.new(1, 0, 0, 24)
Footer.Position = UDim2.new(0, 0, 1, -24)
Footer.BackgroundColor3 = Color3.fromRGB(13, 15, 19)
Footer.BorderSizePixel = 0

local FooterCorner = Instance.new('UICorner', Footer)
FooterCorner.CornerRadius = UDim.new(0, 4)

local FooterTopFix = Instance.new('Frame', Footer)
FooterTopFix.Size = UDim2.new(1, 0, 0, 4)
FooterTopFix.Position = UDim2.new(0, 0, 0, 0)
FooterTopFix.BackgroundColor3 = Color3.fromRGB(13, 15, 19)
FooterTopFix.BorderSizePixel = 0

local FooterDivider = Instance.new('Frame', Panel)
FooterDivider.Size = UDim2.new(1, 0, 0, 1)
FooterDivider.Position = UDim2.new(0, 0, 1, -25)
FooterDivider.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
FooterDivider.BorderSizePixel = 0

local DiscordBtn = Instance.new('TextButton', Footer)
DiscordBtn.Size = UDim2.new(0.5, -1, 1, 0)
DiscordBtn.Position = UDim2.new(0, 10, 0, 0)
DiscordBtn.Text = 'Join discord'
DiscordBtn.Font = Enum.Font.Code
DiscordBtn.TextColor3 = Color3.fromRGB(68, 68, 68)
DiscordBtn.TextSize = 9
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.TextXAlignment = Enum.TextXAlignment.Left

DiscordBtn.MouseEnter:Connect(function() DiscordBtn.TextColor3 = Color3.fromRGB(136, 136, 136) end)
DiscordBtn.MouseLeave:Connect(function() DiscordBtn.TextColor3 = Color3.fromRGB(68, 68, 68) end)
DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard('https://discord.gg/VRUKwBnwH')
    DiscordBtn.Text = '\u{2713} Copied!'
    task.wait(1.5)
    DiscordBtn.Text = 'Join discord'
    StarterGui:SetCore('SendNotification', {Title = 'Lozz Hub', Text = 'Discord link copied!', Duration = 2})
end)

local FooterDividerV = Instance.new('Frame', Footer)
FooterDividerV.Size = UDim2.new(0, 1, 0, 14)
FooterDividerV.Position = UDim2.new(0.5, 0, 0.5, -7)
FooterDividerV.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
FooterDividerV.BorderSizePixel = 0

local KeybindLabel = Instance.new('TextLabel', Footer)
KeybindLabel.Size = UDim2.new(0.5, -24, 1, 0)
KeybindLabel.Position = UDim2.new(0.5, 4, 0, 0)
KeybindLabel.Text = 'Keybind'
KeybindLabel.Font = Enum.Font.Code
KeybindLabel.TextColor3 = Color3.fromRGB(68, 68, 68)
KeybindLabel.TextSize = 9
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

local KeyBadge = Instance.new('TextLabel', Footer)
KeyBadge.Size = UDim2.new(0, 18, 0, 14)
KeyBadge.Position = UDim2.new(1, -24, 0.5, -7)
KeyBadge.Text = 'F'
KeyBadge.Font = Enum.Font.Code
KeyBadge.TextColor3 = Color3.fromRGB(85, 85, 85)
KeyBadge.TextSize = 9
KeyBadge.BackgroundColor3 = Color3.fromRGB(20, 23, 28)
KeyBadge.BorderSizePixel = 0

local KeyBadgeCorner = Instance.new('UICorner', KeyBadge)
KeyBadgeCorner.CornerRadius = UDim.new(0, 2)

local KeyBadgeStroke = Instance.new('UIStroke', KeyBadge)
KeyBadgeStroke.Color = Color3.fromRGB(42, 48, 64)
KeyBadgeStroke.Thickness = 1

-- Keybind (F key)
game:GetService('UserInputService').InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        activateBtn.MouseButton1Click:Fire()
    end
end)

-- Respawn desync logic (when activated in Respawn mode)
activateBtn.MouseButton1Click:Connect(function()
    if activated and modes[modeIndex] == 'Respawn' then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildWhichIsA('Humanoid')
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        char:ClearAllChildren()
        local dummy = Instance.new('Model')
        dummy.Parent = workspace
        LocalPlayer.Character = dummy
        task.wait()
        LocalPlayer.Character = char
        dummy:Destroy()
        StarterGui:SetCore('SendNotification', {Title = 'Lozz Hub', Text = 'Respawn desync complete!', Duration = 2})
    end
end)

-- Unwalk logic
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if activated and modes[modeIndex] == 'Unwalk' then
        local hum = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
        if hum then hum.WalkSpeed = 0 end
    end
end)

print('\u{2728} LOZZ HUB loaded â€” ' .. getexecutorname())
