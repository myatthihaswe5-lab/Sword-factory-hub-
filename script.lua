-- ============================================================
--  SWORD FACTORY HUB v2.0 — Mobile Custom GUI
--  Adapted for Mobile Devices (Touch Enabled)
-- ============================================================

------------ Executor Stubs ------------
if not isfolder   then isfolder   = function() return false end end
if not isfile     then isfile     = function() return false end end
if not makefolder then makefolder = function() end end
if not writefile  then writefile  = function() end end
if not readfile   then readfile   = function() return "{}" end end
if not listfiles  then listfiles  = function() return {} end end
if not delfile    then delfile    = function() end end

------------ Services ------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local player           = Players.LocalPlayer
local mouse            = player:GetMouse()

------------ Theme ------------
local Theme = {
    bg        = Color3.fromRGB(32, 34, 37),
    sidebar   = Color3.fromRGB(24, 25, 28),
    panel     = Color3.fromRGB(40, 42, 47),
    card      = Color3.fromRGB(47, 49, 54),
    border    = Color3.fromRGB(60, 63, 70),
    accent    = Color3.fromRGB(114, 137, 218),
    accentDim = Color3.fromRGB(78, 96, 160),
    green     = Color3.fromRGB(87, 242, 135),
    red       = Color3.fromRGB(237, 66, 69),
    yellow    = Color3.fromRGB(254, 231, 92),
    text      = Color3.fromRGB(220, 221, 222),
    textDim   = Color3.fromRGB(148, 155, 164),
    textMuted = Color3.fromRGB(96, 100, 108),
    white     = Color3.fromRGB(255, 255, 255),
}

------------ File Paths ------------
local FOLDER       = "SwordFactoryHub"
local CONFIGS_PATH = FOLDER.."/configs"
local LAST_FILE    = FOLDER.."/last_config.json"
pcall(function()
    if not isfolder(FOLDER)       then makefolder(FOLDER) end
    if not isfolder(CONFIGS_PATH) then makefolder(CONFIGS_PATH) end
end)

------------ State Variables ------------
autoFarmEnabled      = false
autoAttackEnabled    = false
attackSpeed          = 40
currentNPC           = nil
isTracking           = false
farmAnchorPos        = nil
LERP_SPEED           = 0.55
MAX_FARM_DISTANCE    = 200
selectedDirection    = "Above"
directionDistances   = {Above=6,Below=6,Front=4,Back=4,Left=4,Right=4}
scannedSwordID       = nil
autoEquipEnabled     = false
swordSwitchMode      = "None"
lootingSwordID       = nil
sharpnessSwordID     = nil
switchRarityThreshold= "Extreme"
BossAvoider          = {enabled=false,rarity="Extreme"}
sniperEnabled        = false
sniperRarity         = "Extreme"
sniperDirection      = "Above"
sniperScanInterval   = 3
autoPickupEnabled    = false
enchantReturnEnabled = false
scanInterval         = 1
isPickingUp          = false
pickupDelay          = 0.16
MAX_ENCHANT_DISTANCE = 36
speedEnabled         = false
speedValue           = 50
jumpEnabled          = false
jumpValue            = 80
infJumpEnabled       = false
noClipEnabled        = false
clickTPEnabled       = false
zoomCapRemoved       = false
antiAFKEnabled       = false
fullbrightEnabled    = false
fullbrightConn       = nil
configNameInput      = ""
ESPBridge            = {enabled=false,box=false,rarity=false,chams=false,lines=false,
                        plrBox=false,plrChams=false,plrLines=false,scanDist=1000}
Det = {enabled=false,interval=1,range=1500,active=false,savedPos=nil,
       hhEnabled=false,hhThreshold=35,hhTimer=18,hhActive=false}
PF  = {enabled=false,target=nil,tracking=false}
EP  = {
    {"Fortune","Ancient","Insight"},
    {"Fortune","Ancient","Ancient"},
    {"Fortune","Insight","Insight"},
    {"Insight","Insight","Insight"},
    {"None","None","None"},
}
Stats             = {sessKills=0,sessEnch=0,allKills=0,allEnch=0}
hudNoobs          = 0
hudSwords         = 0
hudSecs           = 0
hudEnabled        = true
_pfNameMap        = {}
_defaultWalkSpeed = nil
_defaultJumpPower = nil
profileDDs        = {}
conn1             = nil
sniperConn        = nil
pfConn            = nil

RARITY_OPTIONS = {"None","Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine",
    "Super","Mega","Ultra","Omega","Extreme","Ultimate","Insane","Hyper","Godly",
    "Unique","Exotic","Supreme","Celestial","Eternal","Cosmic"}
ENCHANT_OPTIONS = {"None","Fortune","Sharpness","Protection","Haste","Swiftness","Critical",
    "Resistance","Healing","Looting","Attraction","Stealth","Ancient","Desperation","Insight","Opulence"}
BOSS_RARITY_LIST = {"None","Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine",
    "Super","Mega","Ultra","Omega","Extreme","Ultimate","Insane","Hyper","Godly",
    "Unique","Exotic","Supreme","Celestial","Eternal","Cosmic"}

------------ Config ------------
local function serializeConfig()
    return HttpService:JSONEncode({
        selectedDirection=selectedDirection,
        dAbove=directionDistances.Above,dBelow=directionDistances.Below,
        dFront=directionDistances.Front,dBack=directionDistances.Back,
        dLeft=directionDistances.Left,dRight=directionDistances.Right,
        lerpSpeed=LERP_SPEED,attackSpeed=attackSpeed,
        MAX_FARM_DISTANCE=MAX_FARM_DISTANCE,
        scannedSwordID=scannedSwordID,autoEquipEnabled=autoEquipEnabled,
        swordSwitchMode=swordSwitchMode,lootingSwordID=lootingSwordID,
        sharpnessSwordID=sharpnessSwordID,switchRarityThreshold=switchRarityThreshold,
        enchantReturnEnabled=enchantReturnEnabled,scanInterval=scanInterval,
        pickupDelay=pickupDelay,MAX_ENCHANT_DISTANCE=MAX_ENCHANT_DISTANCE,
        speedEnabled=speedEnabled,speedValue=speedValue,
        jumpEnabled=jumpEnabled,jumpValue=jumpValue,
        infJumpEnabled=infJumpEnabled,antiAFKEnabled=antiAFKEnabled,
        sniperRarity=sniperRarity,sniperDirection=sniperDirection,
        sniperScanInterval=sniperScanInterval,
        bossAvoiderEnabled=BossAvoider.enabled,bossAvoiderRarity=BossAvoider.rarity,
        detRange=Det.range,detInterval=Det.interval,
        hhThreshold=Det.hhThreshold,hhTimer=Det.hhTimer,
        p1e1=EP[1][1],p1e2=EP[1][2],p1e3=EP[1][3],
        p2e1=EP[2][1],p2e2=EP[2][2],p2e3=EP[2][3],
        p3e1=EP[3][1],p3e2=EP[3][2],p3e3=EP[3][3],
        p4e1=EP[4][1],p4e2=EP[4][2],p4e3=EP[4][3],
        p5e1=EP[5][1],p5e2=EP[5][2],p5e3=EP[5][3],
    })
end

local function saveConfig(name)
    name=name:gsub("[%s/\\]","_")
    if name=="" then return false,"Enter a name first" end
    pcall(function()
        if not isfolder(FOLDER) then makefolder(FOLDER) end
        if not isfolder(CONFIGS_PATH) then makefolder(CONFIGS_PATH) end
    end)
    local ok,err=pcall(writefile,CONFIGS_PATH.."/"..name..".json",serializeConfig())
    if ok then pcall(writefile,LAST_FILE,HttpService:JSONEncode({name=name})) end
    return ok,ok and "Saved '"..name.."'" or tostring(err)
end

local function loadConfig(name)
    name=name:gsub("[%s/\\]","_")
    if name=="" then return false,"Enter a name first" end
    local ok,data=pcall(readfile,CONFIGS_PATH.."/"..name..".json")
    if not ok or not data or data=="" then return false,"Not found: '"..name.."'" end
    local ok2,d=pcall(HttpService.JSONDecode,HttpService,data)
    if not ok2 or not d then return false,"Corrupt config" end
    if d.selectedDirection then selectedDirection=d.selectedDirection end
    if d.dAbove then directionDistances.Above=d.dAbove end
    if d.dBelow then directionDistances.Below=d.dBelow end
    if d.dFront then directionDistances.Front=d.dFront end
    if d.dBack  then directionDistances.Back=d.dBack   end
    if d.dLeft  then directionDistances.Left=d.dLeft   end
    if d.dRight then directionDistances.Right=d.dRight end
    if d.lerpSpeed then LERP_SPEED=d.lerpSpeed end
    if d.attackSpeed then attackSpeed=d.attackSpeed end
    if d.MAX_FARM_DISTANCE then MAX_FARM_DISTANCE=d.MAX_FARM_DISTANCE end
    if d.scannedSwordID then scannedSwordID=d.scannedSwordID end
    if d.autoEquipEnabled~=nil then autoEquipEnabled=d.autoEquipEnabled end
    if d.swordSwitchMode then swordSwitchMode=d.swordSwitchMode end
    if d.lootingSwordID then lootingSwordID=d.lootingSwordID end
    if d.sharpnessSwordID then sharpnessSwordID=d.sharpnessSwordID end
    if d.switchRarityThreshold then switchRarityThreshold=d.switchRarityThreshold end
    if d.enchantReturnEnabled~=nil then enchantReturnEnabled=d.enchantReturnEnabled end
    if d.scanInterval then scanInterval=d.scanInterval end
    if d.pickupDelay then pickupDelay=d.pickupDelay end
    if d.MAX_ENCHANT_DISTANCE then MAX_ENCHANT_DISTANCE=d.MAX_ENCHANT_DISTANCE end
    if d.speedEnabled~=nil then speedEnabled=d.speedEnabled end
    if d.speedValue then speedValue=d.speedValue end
    if d.jumpEnabled~=nil then jumpEnabled=d.jumpEnabled end
    if d.jumpValue then jumpValue=d.jumpValue end
    if d.infJumpEnabled~=nil then infJumpEnabled=d.infJumpEnabled end
    if d.antiAFKEnabled~=nil then antiAFKEnabled=d.antiAFKEnabled end
    if d.sniperRarity then sniperRarity=d.sniperRarity end
    if d.sniperDirection then sniperDirection=d.sniperDirection end
    if d.sniperScanInterval then sniperScanInterval=d.sniperScanInterval end
    if d.bossAvoiderEnabled~=nil then BossAvoider.enabled=d.bossAvoiderEnabled end
    if d.bossAvoiderRarity then BossAvoider.rarity=d.bossAvoiderRarity end
    if d.detRange then Det.range=d.detRange end
    if d.detInterval then Det.interval=d.detInterval end
    if d.hhThreshold then Det.hhThreshold=d.hhThreshold end
    if d.hhTimer then Det.hhTimer=d.hhTimer end
    for i=1,5 do for j=1,3 do
        local v=d["p"..i.."e"..j]; if v then EP[i][j]=v end
    end end
    return true,"Loaded '"..name.."'"
end

------------ GUI Root ------------
local SFHGui=Instance.new("ScreenGui")
SFHGui.Name="SFH_v2_Mobile"; SFHGui.ResetOnSpawn=false
SFHGui.DisplayOrder=10; SFHGui.IgnoreGuiInset=true
pcall(function() SFHGui.Parent=CoreGui end)
if not SFHGui.Parent then SFHGui.Parent=player.PlayerGui end

------------ Mobile Open Toggle ------------
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "SFHToggle"
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 10, 0.4, 0)
ToggleBtn.BackgroundColor3 = Theme.sidebar
ToggleBtn.TextColor3 = Theme.accent
ToggleBtn.Text = "⚔"
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 300
ToggleBtn.Parent = SFHGui
local tCorner = Instance.new("UICorner", ToggleBtn)
tCorner.CornerRadius = UDim.new(0, 24)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Thickness = 2
tStroke.Color = Theme.accent

------------ Helpers ------------
function new(cls,props,parent)
    local i=Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end
function corner(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
function stroke(t,c2,p) return new("UIStroke",{Thickness=t,Color=c2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
function tween(obj,props,t,s,d)
    TweenService:Create(obj,TweenInfo.new(t or 0.15,s or Enum.EasingStyle.Quad,d or Enum.EasingDirection.Out),props):Play()
end

------------ Notifications ------------
local notifHolder=new("Frame",{Size=UDim2.new(0,250,1,0),Position=UDim2.new(1,-260,0,0),BackgroundTransparency=1,ZIndex=200},SFHGui)
new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,6)},notifHolder)
new("UIPadding",{PaddingBottom=UDim.new(0,12),PaddingRight=UDim.new(0,8)},notifHolder)
local _nc=0
function notify(title,body,color)
    _nc=_nc+1
    local nc=new("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=Theme.card,BackgroundTransparency=0,Position=UDim2.new(1,10,0,0),LayoutOrder=_nc,ZIndex=201,ClipsDescendants=true},notifHolder)
    corner(8,nc); stroke(1,Theme.border,nc)
    local bar=new("Frame",{Size=UDim2.new(0,3,0,36),Position=UDim2.new(0,8,0,9),BackgroundColor3=color or Theme.accent,BorderSizePixel=0,ZIndex=202},nc); corner(2,bar)
    new("TextLabel",{Text=title,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,18,0,6),Size=UDim2.new(1,-24,0,16),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},nc)
    new("TextLabel",{Text=body or "",TextSize=10,Font=Enum.Font.Gotham,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(0,18,0,24),Size=UDim2.new(1,-24,0,14),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},nc)
    tween(nc,{Position=UDim2.new(0,0,0,0)},0.25)
    task.delay(3.5,function()
        tween(nc,{Position=UDim2.new(1,10,0,0)},0.2)
        task.wait(0.22); tween(nc,{Size=UDim2.new(1,0,0,0)},0.15)
        task.wait(0.17); pcall(function() nc:Destroy() end)
    end)
end

------------ Window (Mobile Responsive) ------------
local SIDEBAR_W=130
local Window=new("Frame",{Name="Window",Size=UDim2.new(0.85,0,0.75,0),Position=UDim2.new(0.075,0,0.125,0),BackgroundColor3=Theme.bg,BorderSizePixel=0,ClipsDescendants=true},SFHGui)
corner(10,Window); stroke(1,Theme.border,Window)

local TitleBar=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=Theme.sidebar,BorderSizePixel=0,ZIndex=2},Window)
new("TextLabel",{Text="⚔  SWORD FACTORY HUB",TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,170,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},TitleBar)
new("TextLabel",{Text="v2.0",TextSize=10,Font=Enum.Font.Gotham,TextColor3=Theme.textMuted,BackgroundTransparency=1,Position=UDim2.new(0,175,0,0),Size=UDim2.new(0,30,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},TitleBar)

local function winBtn(icon,xOffset,hoverColor,w)
    local b=new("TextButton",{Text=icon,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(1,xOffset,0,0),Size=UDim2.new(0,w or 32,1,0),ZIndex=3},TitleBar)
    return b
end
local CloseBtn=winBtn("X",-32,Theme.red)
local MinBtn=winBtn("_",-64,Theme.yellow)

CloseBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled=false; autoPickupEnabled=false; sniperEnabled=false
    PF.enabled=false; Det.enabled=false; Det.hhEnabled=false
    pcall(stopTracking); pcall(stopSniper); pcall(stopPlayerFarm)
    pcall(function()
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=32; h.JumpPower=50; h.AutoRotate=true end
    end)
    task.wait(0.1); SFHGui:Destroy()
end)

local hidden=false
local function toggleUI()
    hidden = not hidden
    Window.Visible = not hidden
end
MinBtn.MouseButton1Click:Connect(toggleUI)
ToggleBtn.MouseButton1Click:Connect(toggleUI)

do -- Mobile Drag
    local drag, dStart, dPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = inp.Position; dPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dStart
            Window.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + d.X, dPos.Y.Scale, dPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local Sidebar=new("Frame",{Size=UDim2.new(0,SIDEBAR_W,1,-38),Position=UDim2.new(0,0,0,38),BackgroundColor3=Theme.sidebar,BorderSizePixel=0},Window)
new("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=Theme.border,BorderSizePixel=0},Sidebar)
local ContentArea=new("Frame",{Size=UDim2.new(1,-SIDEBAR_W,1,-38),Position=UDim2.new(0,SIDEBAR_W,0,38),BackgroundColor3=Theme.panel,BorderSizePixel=0},Window)

local tabs={}
local activeTab=nil
local SidebarList=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},Sidebar)
new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},SidebarList)
new("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),PaddingTop=UDim.new(0,4)},SidebarList)

function selectTab(tab)
    for _,t in ipairs(tabs) do
        t.content.Visible=false; t.bar.Visible=false; t.btn.BackgroundTransparency=1
        local l=t.btn:FindFirstChildOfClass("TextLabel"); if l then l.TextColor3=Theme.textDim end
    end
    tab.content.Visible=true; tab.bar.Visible=true; tab.btn.BackgroundTransparency=0.82
    local l=tab.btn:FindFirstChildOfClass("TextLabel"); if l then l.TextColor3=Theme.accent end
    activeTab=tab
end

function createTab(name,icon)
    local btn=new("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Theme.bg,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=#tabs+1},SidebarList)
    corner(6,btn)
    local bar=new("Frame",{Size=UDim2.new(0,3,0,16),Position=UDim2.new(0,0,0.5,-8),BackgroundColor3=Theme.accent,BorderSizePixel=0,Visible=false},btn); corner(2,bar)
    new("TextLabel",{Text=icon.." "..name,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-8,1,0),TextXAlignment=Enum.TextXAlignment.Left},btn)
    local content=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Theme.panel,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Theme.border,ScrollingDirection=Enum.ScrollingDirection.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ClipsDescendants=true},ContentArea)
    new("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},content)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},content)
    local tab={name=name,btn=btn,content=content,bar=bar,order=#tabs+1}
    tabs[#tabs+1]=tab
    btn.MouseButton1Click:Connect(function() selectTab(tab) end)
    return tab
end

function addSection(tab,title)
    local order=#tab.content:GetChildren()
    local f=new("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=order},tab.content)
    new("TextLabel",{Text=title:upper(),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=Theme.textMuted,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},f)
    return f
end
function addCard(tab,h)
    local order=#tab.content:GetChildren()
    local c2=new("Frame",{Size=UDim2.new(1,0,0,h or 40),BackgroundColor3=Theme.card,BorderSizePixel=0,LayoutOrder=order},tab.content)
    corner(6,c2); return c2
end
function addDivider(tab)
    local order=#tab.content:GetChildren()
    new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.border,BorderSizePixel=0,LayoutOrder=order},tab.content)
end
function addParagraph(tab,title,body)
    local h=body and 48 or 32
    local card=addCard(tab,h)
    new("TextLabel",{Text=title,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,body and 4 or 0),Size=UDim2.new(1,-16,0,body and 18 or h),TextXAlignment=Enum.TextXAlignment.Left},card)
    local bodyLbl
    if body then bodyLbl=new("TextLabel",{Text=body,TextSize=9,Font=Enum.Font.Gotham,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(0,8,0,22),Size=UDim2.new(1,-16,0,18),TextXAlignment=Enum.TextXAlignment.Left},card) end
    return {setTitle=function(v) local l=card:FindFirstChildOfClass("TextLabel"); if l then l.Text=v end end,setBody=function(v) if bodyLbl then bodyLbl.Text=v end end}
end
function addToggle(tab,title,desc,default,callback)
    local card=addCard(tab,desc and 48 or 40)
    local state=default or false
    new("TextLabel",{Text=title,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-60,0,desc and 22 or 40),TextXAlignment=Enum.TextXAlignment.Left},card)
    if desc then new("TextLabel",{Text=desc,TextSize=9,Font=Enum.Font.Gotham,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(0,8,0,22),Size=UDim2.new(1,-60,0,18),TextXAlignment=Enum.TextXAlignment.Left},card) end
    local track=new("Frame",{Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-46,0.5,-9),BackgroundColor3=state and Theme.green or Theme.border,BorderSizePixel=0},card); corner(9,track)
    local knob=new("Frame",{Size=UDim2.new(0,14,0,14),Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=Theme.white,BorderSizePixel=0},track); corner(7,knob)
    local function setState(v)
        state=v
        tween(track,{BackgroundColor3=state and Theme.green or Theme.border},0.15)
        tween(knob,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},0.15)
        task.spawn(function() pcall(callback,state) end)
    end
    new("TextButton",{Size=UDim2.new(1,0,1,0),Text="",BackgroundTransparency=1},card).MouseButton1Click:Connect(function() setState(not state) end)
    return {set=setState,get=function() return state end}
end
function addSlider(tab,title,min,max,default,suffix,callback)
    local card=addCard(tab,48)
    local val=math.clamp(default or min,min,max)
    new("TextLabel",{Text=title,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,4),Size=UDim2.new(0.6,0,0,16),TextXAlignment=Enum.TextXAlignment.Left},card)
    local valLbl=new("TextLabel",{Text=tostring(val)..(suffix or ""),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=Theme.accent,BackgroundTransparency=1,Position=UDim2.new(1,-60,0,4),Size=UDim2.new(0,52,0,16),TextXAlignment=Enum.TextXAlignment.Right},card)
    local track=new("Frame",{Size=UDim2.new(1,-16,0,4),Position=UDim2.new(0,8,0,28),BackgroundColor3=Theme.border,BorderSizePixel=0},card); corner(2,track)
    local fill=new("Frame",{Size=UDim2.new((val-min)/(max-min),0,1,0),BackgroundColor3=Theme.accent,BorderSizePixel=0},track); corner(2,fill)
    local knob=new("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new((val-min)/(max-min),-6,0.5,-6),BackgroundColor3=Theme.white,BorderSizePixel=0,ZIndex=3},track); corner(6,knob)
    local sliding=false
    local function update(x)
        local r=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        val=math.floor(min+r*(max-min)+0.5); r=(val-min)/(max-min)
        fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,-6,0.5,-6)
        valLbl.Text=tostring(val)..(suffix or "")
        task.spawn(function() pcall(callback,val) end)
    end
    new("TextButton",{Size=UDim2.new(1,0,1,0),Text="",BackgroundTransparency=1,ZIndex=2},track).InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then sliding=true; update(inp.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
    return {set=function(v) val=math.clamp(v,min,max); local r=(val-min)/(max-min); fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,-6,0.5,-6); valLbl.Text=tostring(val)..(suffix or "") end,get=function() return val end}
end
local _activeDDClose = nil

function addDropdown(tab,title,options,default,callback)
    local card=addCard(tab,40)
    local selected=default or (options and options[1]) or ""
    local open=false; local currentOptions=options or {}; local optBtns={}
    new("TextLabel",{Text=title,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(0.45,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},card)
    local selBtn=new("TextButton",{Text=selected.." ▾",TextSize=10,Font=Enum.Font.GothamMedium,TextColor3=Theme.accent,BackgroundColor3=Theme.bg,BorderSizePixel=0,ClipsDescendants=true,Position=UDim2.new(1,-120,0.5,-12),Size=UDim2.new(0,112,0,24),AutoButtonColor=false},card)
    corner(6,selBtn); stroke(1,Theme.border,selBtn)
    local listOuter=new("Frame",{Size=UDim2.new(0,130,0,0),BackgroundColor3=Color3.fromRGB(28,29,33),BorderSizePixel=0,Visible=false,ZIndex=100,ClipsDescendants=true},SFHGui)
    corner(6,listOuter); stroke(1,Theme.border,listOuter)
    local listScroll=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Theme.accent,ScrollingDirection=Enum.ScrollingDirection.Y,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=101,ClipsDescendants=true},listOuter)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},listScroll)
    local function closeDD()
        if not open then return end; open=false
        if _activeDDClose == closeDD then _activeDDClose = nil; _activeDDFrame = nil end
        tween(listOuter,{Size=UDim2.new(0,130,0,0)},0.12)
        task.delay(0.13,function() listOuter.Visible=false end)
    end
    local function buildOpts(opts)
        for _,b in pairs(optBtns) do pcall(function() b:Destroy() end) end; optBtns={}
        for i,opt in ipairs(opts) do
            local ob=new("TextButton",{Text=" "..opt,TextSize=10,Font=Enum.Font.GothamMedium,TextColor3=opt==selected and Theme.accent or Theme.text,BackgroundColor3=Color3.fromRGB(28,29,33),BorderSizePixel=0,Size=UDim2.new(1,0,0,26),AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=i,ZIndex=102},listScroll)
            ob.MouseButton1Click:Connect(function()
                selected=opt; selBtn.Text=opt.." ▾"
                for _,b in pairs(optBtns) do b.TextColor3=Theme.text; b.BackgroundColor3=Color3.fromRGB(28,29,33) end
                ob.TextColor3=Theme.accent
                closeDD()
                task.spawn(function() pcall(callback,selected) end)
            end)
            optBtns[opt]=ob
        end
    end
    buildOpts(currentOptions)
    selBtn.MouseButton1Click:Connect(function()
        if open then closeDD()
        else
            if _activeDDClose then _activeDDClose() end
            open=true; _activeDDClose=closeDD; _activeDDFrame=listOuter
            local ap=selBtn.AbsolutePosition; local as=selBtn.AbsoluteSize
            local maxH=math.min(#currentOptions*26,180)
            local screenH=workspace.CurrentCamera.ViewportSize.Y
            local useY=(ap.Y+as.Y+2+maxH<screenH) and (ap.Y+as.Y+2) or (ap.Y-maxH-2)
            listOuter.Position=UDim2.new(0,ap.X-10,0,useY); listOuter.Size=UDim2.new(0,130,0,0); listOuter.Visible=true
            tween(listOuter,{Size=UDim2.new(0,130,0,maxH)},0.15)
        end
    end)
    return {
        set=function(v) selected=v; selBtn.Text=v.." ▾"; for opt,b in pairs(optBtns) do b.TextColor3=opt==v and Theme.accent or Theme.text end end,
        get=function() return selected end,
        refresh=function(newOpts) currentOptions=newOpts; buildOpts(newOpts); local found=false; for _,v in ipairs(newOpts) do if v==selected then found=true; break end end; if not found then selected=newOpts[1] or ""; selBtn.Text=selected.." ▾" end end,
    }
end
function addButton(tab,title,desc,callback)
    local card=addCard(tab,desc and 48 or 40)
    new("TextLabel",{Text=title,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-75,0,desc and 22 or 40),TextXAlignment=Enum.TextXAlignment.Left},card)
    if desc then new("TextLabel",{Text=desc,TextSize=9,Font=Enum.Font.Gotham,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(0,8,0,22),Size=UDim2.new(1,-75,0,18),TextXAlignment=Enum.TextXAlignment.Left},card) end
    local btn=new("TextButton",{Text="Run",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=Theme.white,BackgroundColor3=Theme.accentDim,BorderSizePixel=0,Position=UDim2.new(1,-64,0.5,-12),Size=UDim2.new(0,56,0,24),AutoButtonColor=false},card); corner(5,btn)
    btn.MouseButton1Click:Connect(function()
        tween(btn,{BackgroundColor3=Theme.green},0.1)
        task.delay(0.4,function() tween(btn,{BackgroundColor3=Theme.accentDim},0.2) end)
        task.spawn(function() pcall(callback) end)
    end)
    return btn
end
function addInput(tab,title,placeholder,callback)
    local card=addCard(tab,40)
    new("TextLabel",{Text=title,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(0.4,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},card)
    local bg=new("Frame",{BackgroundColor3=Theme.bg,BorderSizePixel=0,Position=UDim2.new(1,-140,0.5,-12),Size=UDim2.new(0,130,0,24)},card); corner(5,bg); stroke(1,Theme.border,bg)
    local box=new("TextBox",{Text="",PlaceholderText=placeholder or "type...",PlaceholderColor3=Theme.textMuted,TextSize=10,Font=Enum.Font.Gotham,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-12,1,0),ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left},bg)
    box:GetPropertyChangedSignal("Text"):Connect(function() task.spawn(function() pcall(callback,box.Text) end) end)
    return {get=function() return box.Text end,set=function(v) box.Text=v end}
end

-- Global Touch/Click outside handler
local _activeDDFrame = nil
UserInputService.InputBegan:Connect(function(inp)
    if (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and _activeDDClose and _activeDDFrame then
        task.wait(0.05)
        if not _activeDDClose or not _activeDDFrame then return end
        local mp=inp.Position
        local fp=_activeDDFrame.AbsolutePosition; local fs=_activeDDFrame.AbsoluteSize
        if mp.X<fp.X or mp.X>fp.X+fs.X or mp.Y<fp.Y or mp.Y>fp.Y+fs.Y then
            _activeDDClose()
        end
    end
end)

------------ Tabs ------------
local tWelcome=createTab("Welcome","🏠")
local tAuto=createTab("Auto Farm","⚔")
local tPlayer=createTab("Pl. Farm","👤")
local tSwords=createTab("Swords","🗡")
local tPickup=createTab("Pickup","💎")
local tVisuals=createTab("Visuals","👁")
local tPlayerS=createTab("Player","🏃")
local tTeleport=createTab("Teleport","🌍")
local tSettings=createTab("Settings","⚙")
local tNerds=createTab("Nerds","🔧")
selectTab(tWelcome)

-- WELCOME
do
    local hero=new("Frame",{Size=UDim2.new(1,0,0,100),BackgroundColor3=Color3.fromRGB(36,37,43),BorderSizePixel=0,LayoutOrder=0},tWelcome.content)
    corner(8,hero); stroke(1,Theme.border,hero)
    local grad=new("Frame",{Size=UDim2.new(0.55,0,1,0),BackgroundColor3=Color3.fromRGB(60,50,120),BorderSizePixel=0},hero); corner(8,grad)
    new("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(90,70,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,30,60))},Rotation=45},grad)
    new("TextLabel",{Text="⚔",TextSize=36,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,50,1,0),TextXAlignment=Enum.TextXAlignment.Left},grad)
    new("TextLabel",{Text="V2.0 Mobile",TextSize=18,Font=Enum.Font.GothamBold,TextColor3=Theme.white,BackgroundTransparency=1,Position=UDim2.new(0,55,0,12),Size=UDim2.new(0,140,0,24),TextXAlignment=Enum.TextXAlignment.Left},grad)
    new("TextLabel",{Text="Happy Farming 🌾",TextSize=10,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(200,200,255),BackgroundTransparency=1,Position=UDim2.new(0,55,0,40),Size=UDim2.new(0,140,0,16),TextXAlignment=Enum.TextXAlignment.Left},grad)
    local rp=new("Frame",{Size=UDim2.new(0.44,0,1,0),Position=UDim2.new(0.56,0,0,0),BackgroundTransparency=1},hero)
    new("TextLabel",{Text="by 74mf on discord",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=Theme.textDim,BackgroundTransparency=1,Position=UDim2.new(0,6,0,8),Size=UDim2.new(1,-6,0,16),TextXAlignment=Enum.TextXAlignment.Left},rp)
    local clockLbl=new("TextLabel",{Text="00:00:00",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=Theme.accent,BackgroundTransparency=1,Position=UDim2.new(0,6,0,26),Size=UDim2.new(1,-6,0,22),TextXAlignment=Enum.TextXAlignment.Left},rp)
    local tzOffset=-7
    local tzMap={["UTC-12"]=-12,["UTC-11"]=-11,["UTC-10 (Hawaii)"]=-10,["UTC-9 (Alaska)"]=-9,["UTC-8 (PST)"]=-8,["UTC-7 (MST/Arizona)"]=-7,["UTC-6 (CST)"]=-6,["UTC-5 (EST)"]=-5,["UTC-4 (AST)"]=-4,["UTC-3"]=-3,["UTC+0"]=0,["UTC+1 (CET)"]=1,["UTC+2 (EET)"]=2,["UTC+3 (MSK)"]=3,["UTC+5:30 (IST)"]=5.5,["UTC+8 (CST/SGT)"]=8,["UTC+9 (JST)"]=9,["UTC+10 (AEST)"]=10,["UTC+12"]=12}
    local tzNames={}; for k in pairs(tzMap) do tzNames[#tzNames+1]=k end
    table.sort(tzNames,function(a,b) return (tzMap[a] or 0)<(tzMap[b] or 0) end)
    addDropdown(tWelcome,"🕐 Time Zone",tzNames,"UTC-7 (MST/Arizona)",function(v) tzOffset=tzMap[v] or -7 end)
    task.spawn(function()
        while true do task.wait(1)
            local t=os.time()+(tzOffset*3600)
            local h=math.floor(t/3600)%24; local m=math.floor(t/60)%60; local s=t%60
            local ap=h>=12 and "PM" or "AM"; h=h%12; if h==0 then h=12 end
            clockLbl.Text=string.format("%02d:%02d:%02d %s",h,m,s,ap)
        end
    end)
    addButton(tWelcome,"⚡ Load Last Config","Restore session",function()
        local ok,data=pcall(readfile,LAST_FILE)
        if not ok then notify("No Config","No last config saved",Theme.yellow); return end
        local ok2,d=pcall(HttpService.JSONDecode,HttpService,data)
        if not ok2 or not d or not d.name then notify("Failed","Could not read last config",Theme.red); return end
        local ok3,msg=loadConfig(d.name)
        notify(ok3 and "✅ Loaded!" or "❌ Failed",msg,ok3 and Theme.green or Theme.red)
    end)
    addDivider(tWelcome); addSection(tWelcome,"📋 Changelog")
    addParagraph(tWelcome,"v2.0 Mobile","Optimized layout for touch screens with persistent toggle button.")
end

-- AUTO FARM
do
    addSection(tAuto,"⚔ Farm Control")
    farmToggle=addToggle(tAuto,"Auto Farm","Lock onto NPCs automatically",false,function(v)
        autoFarmEnabled=v
        if not v then pcall(stopTracking); currentNPC=nil; notify("⚔ Auto Farm","Disabled",Theme.textDim)
        else
            local rp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if rp then farmAnchorPos=rp.Position end
            notify("⚔ Auto Farm","Enabled!",Theme.green)
        end
    end)
    attackToggle=addToggle(tAuto,"Auto Attack","Swing continuously",false,function(v)
        autoAttackEnabled=v
        notify("⚡ Auto Attack",v and "Swinging!" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    addDivider(tAuto); addSection(tAuto,"👁 Player Detector")
    detToggle=addToggle(tAuto,"Player Detector","Hide when players nearby",false,function(v)
        Det.enabled=v
        if not v and Det.active then Det.active=false end
        notify("👁 Detector",v and "Watching..." or "Disabled",v and Theme.accent or Theme.textDim)
    end)
    hhToggle=addToggle(tAuto,"Health Hide","Hide when HP low",false,function(v)
        Det.hhEnabled=v
        notify("💊 Health Hide",v and "Hides below "..Det.hhThreshold.."%" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    addDivider(tAuto); addSection(tAuto,"🎯 Boss Sniper")
    sniperToggle=addToggle(tAuto,"Boss Sniper","Lock onto boss rarity NPCs",false,function(v)
        sniperEnabled=v
        if v then startSniper() else stopSniper() end
        notify("🎯 Boss Sniper",v and "Targeting "..sniperRarity.."+" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    addDropdown(tAuto,"Sniper Rarity",BOSS_RARITY_LIST,"Extreme",function(v) sniperRarity=v end)
    addDivider(tAuto); addSection(tAuto,"🛡 Boss Avoider")
    avoiderToggle=addToggle(tAuto,"Boss Avoider","Skip NPCs above rarity",false,function(v)
        BossAvoider.enabled=v
        notify("🛡 Boss Avoider",v and "Skipping "..BossAvoider.rarity.."+" or "Disabled",v and Theme.yellow or Theme.textDim)
    end)
    addDropdown(tAuto,"Avoider Rarity",BOSS_RARITY_LIST,"Extreme",function(v) BossAvoider.rarity=v end)
end

-- PLAYER FARM
do
    addSection(tPlayer,"👤 Player Targeting")
    pfToggle=addToggle(tPlayer,"Auto Farm Player","Lock below selected player",false,function(v)
        PF.enabled=v
        if not v then pcall(stopPlayerFarm) end
        notify("👤 Player Farm",v and "Enabled!" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    local pfStatusPara=addParagraph(tPlayer,"🎯 Target","None selected")
    local pfTargetDD=addDropdown(tPlayer,"Select Player",{"(refresh first)"},"(refresh first)",function(v)
        if v=="(refresh first)" or v=="(no one online)" then return end
        if v=="⭐ Anyone (Closest)" then PF.target=nil; pfStatusPara.setBody("Anyone (Closest)"); notify("👤 Target","Closest player",Theme.accent)
        else
            local realName=_pfNameMap and _pfNameMap[v] or v:match("^([^%(]+)"):gsub("%s+$","")
            local p2=Players:FindFirstChild(realName)
            if p2 then PF.target=p2; pfStatusPara.setBody(p2.Name); notify("👤 Target Set",p2.Name,Theme.green)
            else notify("❌ Not Found",v.." not in game",Theme.red) end
        end
    end)
    addButton(tPlayer,"🔄 Refresh Players","Update player list",function()
        local opts={"⭐ Anyone (Closest)"}; _pfNameMap={}
        for _,p2 in ipairs(Players:GetPlayers()) do
            if p2~=player then
                local lbl=p2.DisplayName~=p2.Name and (p2.Name.." ("..p2.DisplayName..")") or p2.Name
                opts[#opts+1]=lbl; _pfNameMap[lbl]=p2.Name
            end
        end
        if #opts==1 then opts[#opts+1]="(no one online)" end
        pfTargetDD.refresh(opts); pfTargetDD.set("⭐ Anyone (Closest)")
        notify("🔄 Refreshed",(#opts-1).." player(s)",Theme.green)
    end)
    addButton(tPlayer,"⛔ Stop & Clear","Stop player farm",function()
        PF.enabled=false; PF.target=nil; pcall(stopPlayerFarm); pfToggle.set(false)
        pfStatusPara.setBody("None selected"); pfTargetDD.set("(refresh first)")
        notify("⛔ Stopped","Player farm stopped",Theme.yellow)
    end)
end

-- SWORDS
do
    addSection(tSwords,"🗡 Auto Equip")
    addToggle(tSwords,"Auto Equip Best Sword","Equip highest damage sword",false,function(v)
        autoEquipEnabled=v
        notify("🗡 Auto Equip",v and "Enabled!" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    local equippedIDPara=addParagraph(tSwords,"Scanned Sword ID","None")
    addButton(tSwords,"📡 Scan Current Sword","Reads equipped sword",function()
        local ch=player.Character; local tool=ch and ch:FindFirstChildOfClass("Tool")
        if tool then scannedSwordID=tool.Name; equippedIDPara.setBody(tool.Name); notify("📡 Scanned",tool.Name,Theme.green)
        else notify("❌ No Tool","Equip a sword first",Theme.red) end
    end)
    addButton(tSwords,"🗑 Reset Sword ID",nil,function()
        scannedSwordID=nil; equippedIDPara.setBody("None"); notify("🗑 Reset","Cleared",Theme.yellow)
    end)
    addDivider(tSwords); addSection(tSwords,"⚔ Sword Switching")
    addParagraph(tSwords,"How it works","Below threshold → Looting sword. At/above → Sharpness sword.")
    addDropdown(tSwords,"Switch Mode",{"Disabled","Auto Switch"},"Disabled",function(v)
        swordSwitchMode=v~="Disabled" and v or "None"
    end)
    addDropdown(tSwords,"Switch At Rarity",BOSS_RARITY_LIST,"Extreme",function(v)
        switchRarityThreshold=v
    end)
    addDivider(tSwords)
    local lootIDPara=addParagraph(tSwords,"🪝 Looting Sword ID","None")
    addButton(tSwords,"📡 Scan Looting Sword","Equipped sword",function()
        local tool=player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then lootingSwordID=tool.Name; lootIDPara.setBody(tool.Name); notify("📡 Looting",tool.Name,Theme.green)
        else notify("❌ No Tool","Equip looting sword",Theme.red) end
    end)
    addButton(tSwords,"🗑 Reset Looting ID",nil,function() lootingSwordID=nil; lootIDPara.setBody("None") end)
    addDivider(tSwords)
    local sharpIDPara=addParagraph(tSwords,"⚡ Sharpness Sword ID","None")
    addButton(tSwords,"📡 Scan Sharpness Sword","Equipped sword",function()
        local tool=player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then sharpnessSwordID=tool.Name; sharpIDPara.setBody(tool.Name); notify("📡 Sharpness",tool.Name,Theme.green)
        else notify("❌ No Tool","Equip sharpness sword",Theme.red) end
    end)
    addButton(tSwords,"🗑 Reset Sharpness ID",nil,function() sharpnessSwordID=nil; sharpIDPara.setBody("None") end)
end

-- PICKUP
do
    addSection(tPickup,"💎 Enchant Pickup")
    pickupToggle=addToggle(tPickup,"Auto Pickup Enchants","TP to matching swords",false,function(v)
        autoPickupEnabled=v
        notify("💎 Auto Pickup",v and "Scanning every "..scanInterval.."s" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    addToggle(tPickup,"Return After Pickup","TP back after collecting",false,function(v)
        enchantReturnEnabled=v
    end)
    addDivider(tPickup); addSection(tPickup,"📋 Enchant Profiles")
    addParagraph(tPickup,"Info","Swords matching ALL 3 enchants in profile are picked up.")
    addButton(tPickup,"🔄 Reset Profiles","Clear all to None",function()
        local defs={{"None","None","None"},{"None","None","None"},{"None","None","None"},{"None","None","None"},{"None","None","None"}}
        for i=1,5 do for j=1,3 do EP[i][j]=defs[i][j] end end
        if profileDDs then for i=1,5 do for j=1,3 do if profileDDs[i] and profileDDs[i][j] then profileDDs[i][j].set(defs[i][j]) end end end end
        notify("🔄 Reset","All profiles cleared",Theme.green)
    end)
    profileDDs={}
    for i=1,5 do
        addDivider(tPickup)
        local sp=addParagraph(tPickup,"Profile "..i,EP[i][1].." / "..EP[i][2].." / "..EP[i][3])
        local dds={}
        for j=1,3 do
            local jj=j
            dds[j]=addDropdown(tPickup," Enchant "..j,ENCHANT_OPTIONS,EP[i][j],function(v)
                EP[i][jj]=v; sp.setBody(EP[i][1].." / "..EP[i][2].." / "..EP[i][3])
            end)
        end
        profileDDs[i]=dds
        local ii=i
        addButton(tPickup,"🗑 Clear Profile "..i,nil,function()
            for j=1,3 do EP[ii][j]="None"; dds[j].set("None") end
            sp.setBody("None / None / None")
        end)
    end
end

-- VISUALS
do
    addSection(tVisuals,"👁 NPC ESP")
    addToggle(tVisuals,"Enable ESP","Toggle visual overlays",false,function(v)
        ESPBridge.enabled=v
        notify("👁 ESP",v and "Enabled!" or "Disabled",v and Theme.green or Theme.textDim)
    end)
    addToggle(tVisuals,"Boxes",nil,false,function(v) ESPBridge.box=v end)
    addToggle(tVisuals,"Rarity Labels",nil,false,function(v) ESPBridge.rarity=v end)
    addToggle(tVisuals,"Chams (Fill)",nil,false,function(v) ESPBridge.chams=v end)
    addToggle(tVisuals,"Lines",nil,false,function(v) ESPBridge.lines=v end)
    addDivider(tVisuals); addSection(tVisuals,"👤 Player ESP")
    addToggle(tVisuals,"Boxes",nil,false,function(v) ESPBridge.plrBox=v end)
    addToggle(tVisuals,"Chams (Fill)",nil,false,function(v) ESPBridge.plrChams=v end)
    addToggle(tVisuals,"Lines",nil,false,function(v) ESPBridge.plrLines=v end)
    addDivider(tVisuals); addSection(tVisuals,"⚙ ESP Settings")
    addSlider(tVisuals,"Scan Distance",100,3000,1000," studs",function(v) ESPBridge.scanDist=v end)
end

-- PLAYER
do
    addSection(tPlayerS,"🏃 Movement")
    speedToggle=addToggle(tPlayerS,"Speed Hack",nil,false,function(v)
        speedEnabled=v
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=v and speedValue or (_defaultWalkSpeed or 16) end
        notify("🏃 Speed",v and "Set to "..speedValue or "Restored",v and Theme.green or Theme.textDim)
    end)
    addSlider(tPlayerS,"Walk Speed",16,500,50,"",function(v)
        speedValue=v
        if speedEnabled then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v end end
    end)
    jumpToggle=addToggle(tPlayerS,"Jump Boost",nil,false,function(v)
        jumpEnabled=v
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower=v and jumpValue or (_defaultJumpPower or 50) end
        notify("🦘 Jump",v and "Set to "..jumpValue or "Restored",v and Theme.green or Theme.textDim)
    end)
    addSlider(tPlayerS,"Jump Height",50,500,80,"",function(v)
        jumpValue=v
        if jumpEnabled then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=v end end
    end)
    addDivider(tPlayerS); addSection(tPlayerS,"⚡ Misc")
    addToggle(tPlayerS,"Infinite Jump",nil,false,function(v) infJumpEnabled=v end)
    addToggle(tPlayerS,"No Clip",nil,false,function(v) noClipEnabled=v end)
    addToggle(tPlayerS,"Anti AFK",nil,false,function(v) antiAFKEnabled=v end)
    addToggle(tPlayerS,"Full Bright",nil,false,function(v)
        fullbrightEnabled=v
        if not v then
            if fullbrightConn then fullbrightConn:Disconnect(); fullbrightConn=nil end
            pcall(function() local L=game:GetService("Lighting"); L.Brightness=1; L.ClockTime=14; L.FogEnd=10000; L.GlobalShadows=true; L.Ambient=Color3.fromRGB(70,70,70); L.OutdoorAmbient=Color3.fromRGB(127,127,127) end)
        else
            if not fullbrightConn then
                fullbrightConn=RunService.RenderStepped:Connect(function()
                    if not fullbrightEnabled then return end
                    local L=game:GetService("Lighting"); L.Brightness=2; L.ClockTime=14; L.FogEnd=100000; L.GlobalShadows=false; L.Ambient=Color3.new(1,1,1); L.OutdoorAmbient=Color3.new(1,1,1)
                end)
            end
        end
        notify("☀ Full Bright",v and "Enabled!" or "Disabled",v and Theme.yellow or Theme.textDim)
    end)
end

-- TELEPORT
do
    addSection(tTeleport,"🏠 Base")
    addButton(tTeleport,"🏠 Teleport to My Base","TP to your island",function()
        local rp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not rp then notify("❌","No character",Theme.red); return end
        local found=false
        local bases=workspace:FindFirstChild("Bases")
        if bases then
            local myBase=bases:FindFirstChild(player.Name)
            if myBase then
                local ok,cf=pcall(function() return myBase:GetPivot() end)
                if ok and cf then rp.CFrame=CFrame.new(cf.Position+Vector3.new(0,10,0)); found=true
                else
                    for _,part in ipairs(myBase:GetDescendants()) do
                        if part:IsA("BasePart") then rp.CFrame=CFrame.new(part.Position+Vector3.new(0,10,0)); found=true; break end
                    end
                end
            end
        end
        if not found then
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Folder") then
                    local owner=obj:FindFirstChild("Owner") or obj:FindFirstChild("Username")
                    if owner and (owner.Value==player.Name or owner.Value==tostring(player.UserId)) then
                        local ok,cf=pcall(function() return obj:GetPivot() end)
                        if ok and cf then rp.CFrame=CFrame.new(cf.Position+Vector3.new(0,10,0)); found=true; break end
                    end
                end
            end
        end
        notify(found and "✅ Teleported!" or "❌ Not Found",found and "At your base!" or "Not found",found and Theme.green or Theme.red)
    end)
    addDivider(tTeleport); addSection(tTeleport,"👤 Player Teleport")
    local tpDD=addDropdown(tTeleport,"Select Player",{"(refresh first)"},"(refresh first)",function(v) end)
    addButton(tTeleport,"🔄 Refresh Players","Update list",function()
        local opts={"(select player)"}
        for _,p2 in ipairs(Players:GetPlayers()) do if p2~=player then opts[#opts+1]=p2.Name end end
        tpDD.refresh(opts); notify("🔄 Refreshed",#opts-1 .." player(s)",Theme.green)
    end)
    addButton(tTeleport,"🌍 Teleport to Player","TP to selected",function()
        local sel=tpDD.get()
        if sel=="(refresh first)" or sel=="(select player)" then notify("⚠","Select a player first",Theme.yellow); return end
        local p2=Players:FindFirstChild(sel)
        if p2 and p2.Character then
            local r2=p2.Character:FindFirstChild("HumanoidRootPart")
            local r1=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if r1 and r2 then r1.CFrame=r2.CFrame+Vector3.new(3,0,0); notify("✅ Teleported","To "..p2.Name,Theme.green) end
        else notify("❌ Not Found",sel.." not in game",Theme.red) end
    end)
end

-- SETTINGS
do
    addSection(tSettings,"💾 Config")
    local cfgInput=addInput(tSettings,"Name","e.g. farm",function(v) configNameInput=v end)
    addButton(tSettings,"💾 Save Config",nil,function()
        local name=(configNameInput or ""):gsub("[%s/\\]","_"):gsub("[^%w_%-]","")
        if name=="" then notify("❌","Type a name first",Theme.red); return end
        local ok,msg=saveConfig(name)
        notify(ok and "✅ Saved!" or "❌ Error",tostring(msg),ok and Theme.green or Theme.red)
    end)
    addButton(tSettings,"📂 Load Config",nil,function()
        local name=(configNameInput or ""):gsub("[%s/\\]","_"):gsub("[^%w_%-]","")
        if name=="" then notify("❌","Type a name first",Theme.red); return end
        local ok,msg=loadConfig(name)
        notify(ok and "✅ Loaded!" or "❌ Error",tostring(msg),ok and Theme.green or Theme.red)
    end)
    addDivider(tSettings); addSection(tSettings,"🎨 Accent Color")
    local colors={{"Blurple",Color3.fromRGB(114,137,218)},{"Green",Color3.fromRGB(87,242,135)},{"Red",Color3.fromRGB(237,66,69)},{"Orange",Color3.fromRGB(255,140,0)},{"Cyan",Color3.fromRGB(0,220,220)}}
    local cNames={}; for _,v in ipairs(colors) do cNames[#cNames+1]=v[1] end
    addDropdown(tSettings,"Theme Color",cNames,"Blurple",function(v)
        for _,pair in ipairs(colors) do
            if pair[1]==v then
                Theme.accent=pair[2]; Theme.accentDim=Color3.fromRGB(pair[2].R*180,pair[2].G*180,pair[2].B*180)
                ToggleBtn.TextColor3=Theme.accent; tStroke.Color=Theme.accent
                for _,tab in ipairs(tabs) do tab.bar.BackgroundColor3=Theme.accent; if activeTab==tab then local l=tab.btn:FindFirstChildOfClass("TextLabel"); if l then l.TextColor3=Theme.accent end end end
                notify("🎨 Color","Set to "..v,Theme.accent); break
            end
        end
    end)
    addDivider(tSettings); addSection(tSettings,"📊 Stats")
    addToggle(tSettings,"Show Stats HUD",nil,true,function(v) hudEnabled=v; if hudGui then hudGui.Visible=v end end)
    addButton(tSettings,"🗑 Reset Stats",nil,function()
        Stats.sessKills=0; Stats.sessEnch=0; hudNoobs=0; hudSwords=0; hudSecs=0
        notify("🗑 Reset","Stats cleared",Theme.yellow)
    end)
end

-- NERDS
do
    addSection(tNerds,"⚔ Combat")
    addSlider(tNerds,"Attack Speed",1,500,40," ms",function(v) attackSpeed=v end)
    addSlider(tNerds,"Farm LERP",1,99,55,"%",function(v) LERP_SPEED=v/100 end)
    addSlider(tNerds,"Max Farm Distance",50,1000,200," studs",function(v) MAX_FARM_DISTANCE=v end)
    addDivider(tNerds); addSection(tNerds,"📐 Directions")
    addDropdown(tNerds,"Attack Direction",{"Above","Below","Front","Back","Left","Right"},"Above",function(v) selectedDirection=v end)
    for _,dir in ipairs({"Above","Below","Front","Back","Left","Right"}) do
        local d=dir
        addSlider(tNerds,dir.." Distance",1,30,directionDistances[dir]," studs",function(v) directionDistances[d]=v end)
    end
    addDivider(tNerds); addSection(tNerds,"💀 Danger Zone")
    addButton(tNerds,"💀 Terminate GUI","Destroy script and GUI",function()
        autoFarmEnabled=false; autoPickupEnabled=false; sniperEnabled=false
        PF.enabled=false; Det.enabled=false; Det.hhEnabled=false
        pcall(stopTracking); pcall(stopSniper); pcall(stopPlayerFarm)
        if fullbrightConn then fullbrightConn:Disconnect(); fullbrightConn=nil end
        pcall(function() local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=32; h.JumpPower=50; h.AutoRotate=true end end)
        task.wait(0.1); SFHGui:Destroy()
    end)
end

-- HUD
hudGui=new("Frame",{Size=UDim2.new(0,140,0,60),Position=UDim2.new(1,-148,1,-68),BackgroundColor3=Theme.sidebar,BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=10},SFHGui)
corner(6,hudGui); stroke(1,Theme.border,hudGui)
local function hudLbl(t,y) return new("TextLabel",{Text=t,TextSize=10,Font=Enum.Font.GothamMedium,TextColor3=Theme.text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,y),Size=UDim2.new(1,-8,0,16),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11},hudGui) end
local hudKillsLbl=hudLbl("⚔  Noobs:  0",4)
local hudSwordsLbl=hudLbl("💎  Swords: 0",20)
local hudTimeLbl=hudLbl("⏱  Active: 00:00:00",36)

task.spawn(function()
    while true do task.wait(1)
        if hudEnabled and hudGui then
            if hudKillsLbl then hudKillsLbl.Text="⚔  Noobs:  "..hudNoobs end
            if hudSwordsLbl then hudSwordsLbl.Text="💎  Swords: "..hudSwords end
            local s=math.floor(hudSecs)
            if hudTimeLbl then hudTimeLbl.Text=string.format("⏱  Active: %02d:%02d:%02d",math.floor(s/3600),math.floor(s%3600/60),s%60) end
        end
        if autoFarmEnabled or autoPickupEnabled then hudSecs=hudSecs+1 end
    end
end)

------------ ESP ------------
local espObjects={}
local plrEspObjects={}
local espRarityCache={}
local ESP_RARITY_TTL=2

local espGui=Instance.new("ScreenGui")
espGui.Name="SFH_ESP"; espGui.ResetOnSpawn=false
espGui.IgnoreGuiInset=true; espGui.DisplayOrder=1; espGui.Enabled=true
pcall(function() espGui.Parent=game:GetService("CoreGui") end)
if not espGui.Parent then espGui.Parent=player.PlayerGui end

local ESP_COL={
    Cosmic=Color3.fromRGB(255,50,255),Eternal=Color3.fromRGB(255,120,40),
    Celestial=Color3.fromRGB(130,200,255),Supreme=Color3.fromRGB(255,210,0),
    Exotic=Color3.fromRGB(0,255,200),Unique=Color3.fromRGB(200,0,255),
    Godly=Color3.fromRGB(255,165,0),Hyper=Color3.fromRGB(255,50,50),
    Insane=Color3.fromRGB(200,0,0),Ultimate=Color3.fromRGB(255,255,0),
    Extreme=Color3.fromRGB(255,80,0),Omega=Color3.fromRGB(255,0,100),
    Legendary=Color3.fromRGB(255,140,0),Mythical=Color3.fromRGB(255,80,255),
    Divine=Color3.fromRGB(200,230,255),Ultra=Color3.fromRGB(255,100,0),
    Mega=Color3.fromRGB(220,80,0),Super=Color3.fromRGB(180,60,0),
    Epic=Color3.fromRGB(128,0,255),Rare=Color3.fromRGB(0,112,255),
    Uncommon=Color3.fromRGB(0,200,0),Common=Color3.fromRGB(200,200,200),
}

local function getCachedRarity(npc)
    local now=tick(); local c=espRarityCache[npc]
    if c and c.r~="" and (now-c.t)<ESP_RARITY_TTL then return c.r end
    local r=getNPCRarity(npc) or ""
    if r~="" then espRarityCache[npc]={r=r,t=now} end
    return r
end
local function clampToScreen(tx,ty,vpX,vpY)
    local margin=18; local cx=vpX/2; local cy=vpY/2
    local dx=tx-cx; local dy=ty-cy
    local sx=math.abs(dx)>0 and math.min(1,(vpX/2-margin)/math.abs(dx)) or 1
    local sy=math.abs(dy)>0 and math.min(1,(vpY/2-margin)/math.abs(dy)) or 1
    local sc=math.min(sx,sy); return cx+dx*sc,cy+dy*sc
end
local function makeESPObj()
    local cont=Instance.new("Frame"); cont.BackgroundTransparency=1; cont.Size=UDim2.new(1,0,1,0)
    cont.Position=UDim2.new(0,0,0,0); cont.ClipsDescendants=false; cont.Parent=espGui
    local sides={}
    for i=1,4 do local f=Instance.new("Frame"); f.BackgroundColor3=Color3.new(1,1,1); f.BorderSizePixel=0; f.Visible=false; f.Parent=cont; sides[i]=f end
    local tracer=Instance.new("Frame"); tracer.BackgroundColor3=Color3.new(1,1,1); tracer.BorderSizePixel=0
    tracer.AnchorPoint=Vector2.new(0.5,0.5); tracer.Visible=false; tracer.Parent=cont
    local nameL=Instance.new("TextLabel"); nameL.BackgroundTransparency=1; nameL.TextColor3=Color3.new(1,1,1)
    nameL.TextStrokeTransparency=0.5; nameL.TextStrokeColor3=Color3.new(0,0,0)
    nameL.TextSize=10; nameL.Font=Enum.Font.GothamBold
    nameL.AnchorPoint=Vector2.new(0.5,1); nameL.AutomaticSize=Enum.AutomaticSize.XY
    nameL.Size=UDim2.fromOffset(0,0); nameL.Visible=false; nameL.Parent=cont
    local rarL=Instance.new("TextLabel"); rarL.BackgroundTransparency=1; rarL.TextColor3=Color3.new(1,1,1)
    rarL.TextStrokeTransparency=0.5; rarL.TextStrokeColor3=Color3.new(0,0,0)
    rarL.TextSize=9; rarL.Font=Enum.Font.Gotham
    rarL.AnchorPoint=Vector2.new(0.5,0); rarL.AutomaticSize=Enum.AutomaticSize.XY
    rarL.Size=UDim2.fromOffset(0,0); rarL.Visible=false; rarL.Parent=cont
    return{cont=cont,sides=sides,tracer=tracer,nameL=nameL,rarL=rarL,hl=nil}
end
local function clearESPObj(store,key)
    local o=store[key]; if not o then return end
    pcall(function() o.cont:Destroy() end)
    pcall(function() if o.hl then o.hl:Destroy() end end)
    store[key]=nil
end
local function clearAllESP()
    if espObjects then for k in pairs(espObjects) do clearESPObj(espObjects,k) end end
    if plrEspObjects then for k in pairs(plrEspObjects) do clearESPObj(plrEspObjects,k) end end
    espObjects={}; plrEspObjects={}; espRarityCache={}
end
local function setBox(sides,lx,ty,rx,by,col)
    local t=1.5
    sides[1].Position=UDim2.fromOffset(lx,ty);   sides[1].Size=UDim2.fromOffset(rx-lx,t); sides[1].BackgroundColor3=col; sides[1].Visible=true
    sides[2].Position=UDim2.fromOffset(lx,by-t); sides[2].Size=UDim2.fromOffset(rx-lx,t); sides[2].BackgroundColor3=col; sides[2].Visible=true
    sides[3].Position=UDim2.fromOffset(lx,ty);   sides[3].Size=UDim2.fromOffset(t,by-ty); sides[3].BackgroundColor3=col; sides[3].Visible=true
    sides[4].Position=UDim2.fromOffset(rx-t,ty); sides[4].Size=UDim2.fromOffset(t,by-ty); sides[4].BackgroundColor3=col; sides[4].Visible=true
end
local function hideBox(sides) for _,s in ipairs(sides) do s.Visible=false end end
local function setTracer(tr,x1,y1,x2,y2,col)
    local dx=x2-x1; local dy=y2-y1; local dist=math.sqrt(dx*dx+dy*dy)
    if dist<1 then tr.Visible=false; return end
    tr.Size=UDim2.fromOffset(dist,1.5); tr.Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2)
    tr.BackgroundColor3=col; tr.Rotation=math.deg(math.atan2(dy,dx)); tr.Visible=true
end
local function espUpdateNPCs()
    local cam=workspace.CurrentCamera
    local npcF=workspace:FindFirstChild("NPCs"); if not npcF then return end
    local myHRP=getHRP()
    local vp=cam.ViewportSize; local scx=vp.X/2; local scy=vp.Y/2; local seen={}
    for _,npc in ipairs(npcF:GetChildren()) do
        if npc:IsA("Model") then
            local anyPart=npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildOfClass("BasePart")
            local nh=npc:FindFirstChildOfClass("Humanoid")
            if anyPart and nh and nh.Health>0 then
                local dist=myHRP and (anyPart.Position-myHRP.Position).Magnitude or 9999
                if dist<=ESPBridge.scanDist then
                    seen[npc]=true
                    if not espObjects[npc] then espObjects[npc]=makeESPObj() end
                    local o=espObjects[npc]
                    local rar=getCachedRarity(npc); local col=ESP_COL[rar] or Color3.fromRGB(255,255,255)
                    if ESPBridge.chams then
                        if not o.hl then local hl=Instance.new("Highlight"); hl.FillColor=col; hl.OutlineColor=col; hl.FillTransparency=0.45; hl.OutlineTransparency=0; hl.Adornee=npc; hl.Parent=npc; o.hl=hl
                        else o.hl.FillColor=col; o.hl.OutlineColor=col end
                    else if o.hl then pcall(function() o.hl:Destroy() end); o.hl=nil end end
                    local okBB,bbCF,bbSz=pcall(function() return npc:GetBoundingBox() end)
                    if okBB and bbCF and bbSz then
                        local topW=bbCF.Position+Vector3.new(0,bbSz.Y/2,0)
                        local botW=bbCF.Position-Vector3.new(0,bbSz.Y/2,0)
                        local topSc=cam:WorldToViewportPoint(topW)
                        local botSc=cam:WorldToViewportPoint(botW)
                        if topSc.Z>0 then
                            local h=math.abs(botSc.Y-topSc.Y); if h<4 then h=4 end
                            local w=h*0.5; local cx2=(topSc.X+botSc.X)/2; local ty2=topSc.Y; local by2=botSc.Y
                            local onVP=cx2>=0 and cx2<=vp.X and ty2>=-h and by2<=vp.Y+h
                            if ESPBridge.box and onVP then setBox(o.sides,cx2-w/2,ty2,cx2+w/2,by2,col) else hideBox(o.sides) end
                            o.nameL.Text=npc.Name; o.nameL.Position=UDim2.fromOffset(cx2,ty2-2); o.nameL.TextColor3=col; o.nameL.Visible=ESPBridge.box and onVP
                            o.rarL.Text=rar~="" and rar or "?"; o.rarL.Position=UDim2.fromOffset(cx2,by2+2); o.rarL.TextColor3=col; o.rarL.Visible=ESPBridge.rarity and onVP
                            if ESPBridge.lines then local tx2,ty2c=clampToScreen(cx2,by2,vp.X,vp.Y); setTracer(o.tracer,scx,scy,tx2,ty2c,col)
                            else o.tracer.Visible=false end
                        else
                            hideBox(o.sides); o.nameL.Visible=false; o.rarL.Visible=false
                            if ESPBridge.lines then local bx=2*scx-topSc.X; local by3=2*scy-topSc.Y; local tx2,ty2c=clampToScreen(bx,by3,vp.X,vp.Y); setTracer(o.tracer,scx,scy,tx2,ty2c,col)
                            else o.tracer.Visible=false end
                        end
                    else hideBox(o.sides); o.tracer.Visible=false; o.nameL.Visible=false; o.rarL.Visible=false end
                else clearESPObj(espObjects,npc) end
            else clearESPObj(espObjects,npc) end
        end
    end
    for npc in pairs(espObjects) do if not seen[npc] or not npc.Parent then clearESPObj(espObjects,npc) end end
end
local function espUpdatePlayers()
    local cam=workspace.CurrentCamera; local myHRP=getHRP()
    local vp=cam.ViewportSize; local scx=vp.X/2; local scy=vp.Y/2; local seen={}
    for _,p2 in ipairs(Players:GetPlayers()) do
        if p2~=player then
            local char=p2.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist=myHRP and (hrp.Position-myHRP.Position).Magnitude or 9999
                if dist<=ESPBridge.scanDist then
                    seen[p2]=true
                    if not plrEspObjects[p2] then plrEspObjects[p2]=makeESPObj() end
                    local o=plrEspObjects[p2]; local col=Color3.fromRGB(255,255,255)
                    if ESPBridge.plrChams then
                        if not o.hl then local hl=Instance.new("Highlight"); hl.FillColor=col; hl.OutlineColor=col; hl.FillTransparency=0.45; hl.OutlineTransparency=0; hl.Adornee=char; hl.Parent=char; o.hl=hl end
                    else if o.hl then pcall(function() o.hl:Destroy() end); o.hl=nil end end
                    local topSc=cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,3.2,0))
                    local botSc=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3.2,0))
                    if topSc.Z>0 then
                        local h=math.abs(botSc.Y-topSc.Y); if h<4 then h=4 end
                        local w=h*0.55; local cx2=topSc.X; local ty2=topSc.Y; local by2=botSc.Y
                        local onVP=cx2>=0 and cx2<=vp.X and ty2>=-h and by2<=vp.Y+h
                        if ESPBridge.plrBox and onVP then setBox(o.sides,cx2-w/2,ty2,cx2+w/2,by2,col) else hideBox(o.sides) end
                        o.nameL.Text=p2.Name.." "..math.floor(dist).."st"; o.nameL.Position=UDim2.fromOffset(cx2,ty2-2); o.nameL.TextColor3=col; o.nameL.Visible=onVP
                        if ESPBridge.plrLines then local tx2,ty2c=clampToScreen(cx2,by2,vp.X,vp.Y); setTracer(o.tracer,scx,scy,tx2,ty2c,col)
                        else o.tracer.Visible=false end
                    else
                        hideBox(o.sides); o.nameL.Visible=false
                        if ESPBridge.plrLines then local bx=2*scx-topSc.X; local by3=2*scy-topSc.Y; local tx2,ty2c=clampToScreen(bx,by3,vp.X,vp.Y); setTracer(o.tracer,scx,scy,tx2,ty2c,col)
                        else o.tracer.Visible=false end
                    end
                else clearESPObj(plrEspObjects,p2) end
            else clearESPObj(plrEspObjects,p2) end
        end
    end
    for p2 in pairs(plrEspObjects) do if not seen[p2] or not p2.Parent then clearESPObj(plrEspObjects,p2) end end
end

Players.PlayerRemoving:Connect(function(p2) clearESPObj(plrEspObjects,p2) end)
RunService.RenderStepped:Connect(function()
    if not ESPBridge.enabled then
        if espGui.Enabled then clearAllESP(); espGui.Enabled=false end; return
    end
    if not espGui.Enabled then espGui.Enabled=true end
    pcall(espUpdateNPCs); pcall(espUpdatePlayers)
end)
SFHGui.AncestryChanged:Connect(function()
    if not SFHGui.Parent then clearAllESP(); pcall(function() espGui:Destroy() end) end
end)

------------ Rarity system ------------
local RARITY_RANK={}
for i,v in ipairs({"None","Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine","Super","Mega","Ultra","Omega","Extreme","Ultimate","Insane","Hyper","Godly","Unique","Exotic","Supreme","Celestial","Eternal","Cosmic"}) do RARITY_RANK[v]=i end

function stripFont(s) return (s or ""):gsub("<[^>]+>",""):match("^%s*(.-)%s*$") or "" end
function getNPCRarity(npc)
    local best="None"
    pcall(function()
        for _,obj in ipairs(npc:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text~="" then
                local plain=stripFont(obj.Text)
                local last=plain:match("(%S+)%s*$")
                if last and RARITY_RANK[last] then best=last; return end
                if RARITY_RANK[plain] then best=plain; return end
            end
        end
    end)
    return best
end
function isAlive(npc)
    if not npc or not npc.Parent then return false end
    local h=npc:FindFirstChildOfClass("Humanoid"); return h and h.Health>0
end
function getHRP() local ch=player.Character; return ch and ch:FindFirstChild("HumanoidRootPart") end
function getHum() local ch=player.Character; return ch and ch:FindFirstChildOfClass("Humanoid") end
function getDirectionOffset(bCFrame,dir,dist)
    dir=dir or selectedDirection or "Above"; dist=dist or directionDistances[dir] or 6
    if dir=="Above" then return Vector3.new(0,dist,0)
    elseif dir=="Below" then return Vector3.new(0,-dist,0)
    elseif dir=="Front" then return bCFrame.LookVector*dist
    elseif dir=="Back"  then return -bCFrame.LookVector*dist
    elseif dir=="Left"  then return -bCFrame.RightVector*dist
    elseif dir=="Right" then return bCFrame.RightVector*dist end
    return Vector3.new(0,dist,0)
end

------------ Tracking ------------
function stopTracking()
    isTracking=false
    if conn1 then conn1:Disconnect(); conn1=nil end
    currentNPC=nil
    local h=getHum()
    if h then h.WalkSpeed=speedEnabled and speedValue or (_defaultWalkSpeed or 16); h.JumpPower=jumpEnabled and jumpValue or (_defaultJumpPower or 50); h.AutoRotate=true end
    local rp=getHRP(); if rp then rp.AssemblyLinearVelocity=Vector3.zero; rp.AssemblyAngularVelocity=Vector3.zero end
end
function startTracking(npc)
    stopTracking(); isTracking=true; currentNPC=npc
    local h=getHum(); if h then h.WalkSpeed=0; h.JumpPower=0; h.AutoRotate=false end
    conn1=RunService.RenderStepped:Connect(function()
        if not isTracking or not currentNPC or not currentNPC.Parent then stopTracking(); return end
        local rp=getHRP(); if not rp then return end
        local nhrp=currentNPC:FindFirstChild("HumanoidRootPart"); if not nhrp then return end
        rp.AssemblyLinearVelocity=Vector3.zero; rp.AssemblyAngularVelocity=Vector3.zero
        local target=nhrp.Position+getDirectionOffset(nhrp.CFrame)
        rp.CFrame=rp.CFrame:Lerp(CFrame.lookAt(target,nhrp.Position),LERP_SPEED)
    end)
end
function findNearestNPC()
    local rp=getHRP(); if not rp then return nil end
    local ref=farmAnchorPos or rp.Position
    local best,bestD=nil,MAX_FARM_DISTANCE
    local npcF=workspace:FindFirstChild("NPCs")
    local searchIn=npcF and npcF:GetChildren() or workspace:GetChildren()
    for _,obj in ipairs(searchIn) do
        if obj:IsA("Model") and isAlive(obj) then
            local nhrp=obj:FindFirstChild("HumanoidRootPart")
            if nhrp then
                local dx=nhrp.Position.X-ref.X; local dz=nhrp.Position.Z-ref.Z
                local d=math.sqrt(dx*dx+dz*dz)
                if d<bestD then
                    if BossAvoider.enabled then
                        local rar=getNPCRarity(obj)
                        if (RARITY_RANK[rar] or 0)<(RARITY_RANK[BossAvoider.rarity] or 99) then bestD=d; best=obj end
                    else bestD=d; best=obj end
                end
            end
        end
    end
    return best
end
function getNearbyPlayers()
    local ref=farmAnchorPos or (getHRP() and getHRP().Position); if not ref then return {} end
    local nearby={}
    for _,p2 in ipairs(Players:GetPlayers()) do
        if p2~=player and p2.Character then
            local r2=p2.Character:FindFirstChild("HumanoidRootPart")
            if r2 then
                local dx=r2.Position.X-ref.X; local dz=r2.Position.Z-ref.Z
                if math.sqrt(dx*dx+dz*dz)<=Det.range then nearby[#nearby+1]=p2 end
            end
        end
    end
    return nearby
end
function hideUnderMap()
    local rp=getHRP(); if not rp then return end
    Det.savedPos=rp.CFrame; rp.CFrame=CFrame.new(rp.Position.X,-500,rp.Position.Z)
end
function startDetectorLoop(triggerPlayer)
    if Det.active then return end; Det.active=true
    local wasFarm=autoFarmEnabled; local wasSnipe=sniperEnabled
    autoFarmEnabled=false; sniperEnabled=false
    stopTracking(); stopSniper(); hideUnderMap()
    notify("👁 Player Detected",(triggerPlayer and triggerPlayer.Name or "Someone").." nearby — hiding!",Theme.yellow)
    task.spawn(function()
        while Det.active and Det.enabled do
            task.wait(Det.interval)
            if not Det.active or not Det.enabled then break end
            local still=getNearbyPlayers()
            if #still==0 then
                Det.active=false
                local rp=getHRP(); local pos=farmAnchorPos or (Det.savedPos and Det.savedPos.Position)
                if rp and pos then rp.CFrame=CFrame.new(pos+Vector3.new(0,5,0)) end
                if wasFarm then autoFarmEnabled=true end
                if wasSnipe then sniperEnabled=true; startSniper() end
                notify("✅ Island Clear!","Resuming farm!",Theme.green); break
            end
        end
    end)
end
function triggerHealthHide()
    if Det.hhActive then return end; Det.hhActive=true
    local wasFarm=autoFarmEnabled; autoFarmEnabled=false; stopTracking()
    local rp=getHRP(); local saved=rp and rp.CFrame
    if rp then rp.CFrame=CFrame.new(rp.Position.X,-500,rp.Position.Z) end
    notify("💊 Low HP","Hiding for "..Det.hhTimer.."s",Theme.red)
    task.wait(Det.hhTimer)
    local rp2=getHRP()
    if rp2 then local pos=farmAnchorPos or (saved and saved.Position); if pos then rp2.CFrame=CFrame.new(pos+Vector3.new(0,5,0)) end end
    Det.hhActive=false; if wasFarm then autoFarmEnabled=true end
    notify("💊 Recovered","Resuming",Theme.green)
end
function getHPPercent()
    local ch=player.Character; if not ch then return 100 end
    local hp=ch:FindFirstChild("HP")
    if hp then
        local hv=hp:FindFirstChild("Health"); local mhv=hp:FindFirstChild("MaxHealth") or hp:FindFirstChild("Max")
        if hv and mhv and mhv.Value>0 then return (hv.Value/mhv.Value)*100 end
    end
    local h=ch:FindFirstChildOfClass("Humanoid")
    if h and h.MaxHealth>0 then return (h.Health/h.MaxHealth)*100 end
    return 100
end
task.spawn(function()
    while true do task.wait(1)
        if Det.hhEnabled and not Det.hhActive and not Det.active then
            if getHPPercent()<Det.hhThreshold then task.spawn(triggerHealthHide) end
        end
    end
end)
function doClick()
    local ch=player.Character; if not ch then return end
    local tool=ch:FindFirstChildOfClass("Tool"); if not tool then return end
    local vim=game:GetService("VirtualInputManager")
    if vim then 
        pcall(function() 
            vim:SendTouchEvent(1, 0, Vector2.new(0, 0)) 
            vim:SendTouchEvent(1, 2, Vector2.new(0, 0))
        end) 
    end
    pcall(function() tool:Activate() end)
end

-- Farm loop
task.spawn(function()
    while true do task.wait(0.1)
        if autoFarmEnabled then
            local rp=getHRP()
            if rp and Det.enabled and not Det.active then
                local nearby=getNearbyPlayers(); if #nearby>0 then startDetectorLoop(nearby[1]) end
            end
            if rp and autoFarmEnabled then
                if not currentNPC or not isAlive(currentNPC) then
                    if isTracking then stopTracking(); Stats.sessKills=Stats.sessKills+1; Stats.allKills=Stats.allKills+1; hudNoobs=hudNoobs+1 end
                    local npc=findNearestNPC(); if npc then startTracking(npc) end
                end
            end
        else if isTracking then stopTracking() end end
    end
end)

-- Attack loop
task.spawn(function()
    while true do
        task.wait(math.max(0.05,attackSpeed/1000))
        if autoAttackEnabled then doClick() end
    end
end)

-- Boss Sniper
function stopSniper() if sniperConn then sniperConn:Disconnect(); sniperConn=nil end end
function startSniper()
    stopSniper()
    task.spawn(function()
        while sniperEnabled do
            task.wait(sniperScanInterval); if not sniperEnabled then break end
            local npcF=workspace:FindFirstChild("NPCs")
            local searchList=npcF and npcF:GetChildren() or workspace:GetChildren()
            for _,obj in ipairs(searchList) do
                if obj:IsA("Model") and obj~=player.Character and isAlive(obj) then
                    local rar=getNPCRarity(obj)
                    if (RARITY_RANK[rar] or 0)>=(RARITY_RANK[sniperRarity] or 99) then
                        local nhrp=obj:FindFirstChild("HumanoidRootPart")
                        if nhrp then
                            notify("🎯 Boss Found",obj.Name.." ["..rar.."]",Theme.yellow)
                            stopSniper()
                            sniperConn=RunService.RenderStepped:Connect(function()
                                if not sniperEnabled then stopSniper(); return end
                                local rp2=getHRP(); if not rp2 then return end
                                rp2.AssemblyLinearVelocity=Vector3.zero; rp2.AssemblyAngularVelocity=Vector3.zero
                                local offset=getDirectionOffset(nhrp.CFrame,sniperDirection,directionDistances[sniperDirection] or 6)
                                rp2.CFrame=rp2.CFrame:Lerp(CFrame.lookAt(nhrp.Position+offset,nhrp.Position),0.35)
                            end)
                            while sniperEnabled and isAlive(obj) do task.wait(0.2) end
                            stopSniper(); if sniperEnabled then notify("✅ Boss Killed!",obj.Name,Theme.green) end; break
                        end
                    end
                end
            end
        end
        stopSniper()
    end)
end

-- Player Farm
function stopPlayerFarm()
    PF.tracking=false; if pfConn then pfConn:Disconnect(); pfConn=nil end
    local h=getHum()
    if h then h.WalkSpeed=speedEnabled and speedValue or (_defaultWalkSpeed or 16); h.JumpPower=jumpEnabled and jumpValue or (_defaultJumpPower or 50); h.AutoRotate=true end
    local rp=getHRP(); if rp then rp.AssemblyLinearVelocity=Vector3.zero; rp.AssemblyAngularVelocity=Vector3.zero end
end
function startPlayerFarm(target)
    stopPlayerFarm(); PF.target=target; PF.tracking=true
    local h=getHum(); if h then h.WalkSpeed=0; h.JumpPower=0; h.AutoRotate=false end
    pfConn=RunService.Heartbeat:Connect(function()
        if not PF.enabled then return end
        local rp=getHRP(); if not rp then return end
        local t=PF.target
        if not t then
            local best,bestD=nil,math.huge
            for _,p2 in ipairs(Players:GetPlayers()) do
                if p2~=player and p2.Character then
                    local r2=p2.Character:FindFirstChild("HumanoidRootPart")
                    if r2 then local d=(r2.Position-rp.Position).Magnitude; if d<bestD then bestD=d; best=p2 end end
                end
            end
            t=best
        end
        if not t or not t.Character then return end
        local tHRP=t.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
        rp.AssemblyLinearVelocity=Vector3.zero; rp.AssemblyAngularVelocity=Vector3.zero
        local dist=directionDistances.Below or 6
        rp.CFrame=CFrame.lookAt(tHRP.Position+Vector3.new(0,-dist,0),tHRP.Position)
    end)
end
task.spawn(function()
    while true do
        if PF.enabled then if not PF.tracking then startPlayerFarm(PF.target) end; task.wait(0.05)
        else if PF.tracking then stopPlayerFarm() end; task.wait(0.1) end
    end
end)

-- Enchant pickup
local swordsFolder=workspace:FindFirstChild("Swords") or workspace:WaitForChild("Swords",10)
local function getEnchantName(text)
    if not text or text=="" then return nil end
    local name=text:match("^(%a+)"); return name and name:lower() or nil
end
local function getSwordEnchants(sword)
    local ok,ef=pcall(function() return sword.Main.Gui.ItemInfo.Enchants end)
    if not ok or not ef then return {} end
    local r={}
    for _,ch in ipairs(ef:GetChildren()) do
        if ch:IsA("TextLabel") or ch:IsA("TextButton") then local n=getEnchantName(ch.Text); if n then r[#r+1]=n end end
    end
    return r
end
local function profileMatches(sword,a,b,cc)
    if a=="None" and b=="None" and cc=="None" then return false end
    local se=getSwordEnchants(sword); local pool={}
    for _,e in ipairs(se) do pool[#pool+1]=e end
    for _,flt in ipairs({a,b,cc}) do
        if flt~="None" then
            local found=false
            for i,e in ipairs(pool) do if e==flt:lower() then table.remove(pool,i); found=true; break end end
            if not found then return false end
        end
    end
    return true
end
local function swordMatchesFilter(sword)
    if EP[1][1]=="None" and EP[1][2]=="None" and EP[1][3]=="None" and EP[2][1]=="None" and EP[2][2]=="None" and EP[2][3]=="None" and EP[3][1]=="None" and EP[3][2]=="None" and EP[3][3]=="None" and EP[4][1]=="None" and EP[4][2]=="None" and EP[4][3]=="None" and EP[5][1]=="None" and EP[5][2]=="None" and EP[5][3]=="None" then return true end
    if profileMatches(sword,EP[1][1],EP[1][2],EP[1][3]) then return true end
    if profileMatches(sword,EP[2][1],EP[2][2],EP[2][3]) then return true end
    if profileMatches(sword,EP[3][1],EP[3][2],EP[3][3]) then return true end
    if profileMatches(sword,EP[4][1],EP[4][2],EP[4][3]) then return true end
    if profileMatches(sword,EP[5][1],EP[5][2],EP[5][3]) then return true end
    return false
end
local function isSwordAvailable(sword)
    local ok,itemInfo=pcall(function() return sword.Main.Gui.ItemInfo end)
    if not ok or not itemInfo then return true end
    local owner=itemInfo:FindFirstChild("Username")
    if owner and owner.Text~="" and owner.Text~=player.Name then return false end
    return true
end
local function pickupSword(sword)
    local ok0,main=pcall(function() return sword.Main end); if not ok0 or not main then return end
    local ch=player.Character; if not ch or not ch.Parent then return end
    local rp=ch:FindFirstChild("HumanoidRootPart"); if not rp then return end
    isPickingUp=true
    local savedCF=enchantReturnEnabled and rp.CFrame or nil
    pcall(function()
        if not sword.Parent then return end
        rp.CFrame=CFrame.new(main.Position+Vector3.new(0,3,0))
        rp.AssemblyLinearVelocity=Vector3.zero; rp.AssemblyAngularVelocity=Vector3.zero
        task.wait(pickupDelay)
    end)
    if savedCF then
        task.wait(pickupDelay*2)
        local rp2=getHRP()
        if rp2 then rp2.CFrame=savedCF; rp2.AssemblyLinearVelocity=Vector3.zero; rp2.AssemblyAngularVelocity=Vector3.zero end
    end
    Stats.sessEnch=Stats.sessEnch+1; Stats.allEnch=Stats.allEnch+1; hudSwords=hudSwords+1
    isPickingUp=false
end
local function trySword(sword)
    if not sword or not sword.Parent then return false end
    local okM,matches=pcall(swordMatchesFilter,sword); if not (okM and matches) then return false end
    local okA,available=pcall(isSwordAvailable,sword); if not (okA and available) then return false end
    pickupSword(sword); return true
end
task.spawn(function()
    while true do task.wait(scanInterval)
        if autoPickupEnabled and swordsFolder then
            local ch=player.Character; local rp=ch and ch:FindFirstChild("HumanoidRootPart")
            if rp then
                for _,sword in ipairs(swordsFolder:GetChildren()) do
                    if not autoPickupEnabled then break end; task.wait(0)
                    local ok,main=pcall(function() return sword.Main end)
                    if ok and main and (main.Position-rp.Position).Magnitude<=MAX_ENCHANT_DISTANCE then
                        if trySword(sword) then task.wait(0.1) end
                    end
                end
            end
        end
    end
end)
if swordsFolder then
    swordsFolder.ChildAdded:Connect(function(sword)
        task.wait(0.15); if autoPickupEnabled then trySword(sword) end
    end)
end

-- Misc
task.spawn(function()
    while true do task.wait(900)
        if antiAFKEnabled then
            pcall(function()
                local screenSize=game:GetService("Workspace").CurrentCamera.ViewportSize
                local cx=screenSize.X/2; local cy=screenSize.Y/2
                local VIM=game:GetService("VirtualInputManager")
                VIM:SendTouchEvent(1, 0, Vector2.new(cx, cy))
                task.wait(0.1)
                VIM:SendTouchEvent(1, 2, Vector2.new(cx, cy))
            end)
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
RunService.Stepped:Connect(function()
    if noClipEnabled then local ch=player.Character; if ch then for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end
end)
RunService.Heartbeat:Connect(function()
    if not isTracking and not PF.tracking then
        local h=getHum()
        if h then if speedEnabled then h.WalkSpeed=speedValue end; if jumpEnabled then h.JumpPower=jumpValue end end
    end
end)

-- Startup
task.wait(0.3)
task.spawn(function()
    local ch0=player.Character or player.CharacterAdded:Wait()
    local h0=ch0:WaitForChild("Humanoid",5)
    if h0 then _defaultWalkSpeed=h0.WalkSpeed; _defaultJumpPower=h0.JumpPower end
end)
task.delay(0.6,function()
    notify("⚔ Sword Factory Hub v2.0","Mobile Ready — happy farming! 🌾",Color3.fromRGB(114,137,218))
end)
