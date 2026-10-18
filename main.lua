local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local function getWindowTitleFromPlaceId()
if game.PlaceId == 78453398695059 then
return "DrayvenX THRESHOLD | Lobby"
elseif game.PlaceId == 129085487311457 then
return "DrayvenX THRESHOLD | Chase Mode"
elseif game.PlaceId == 104507343743721 then
return "DrayvenX THRESHOLD | Story Mode: Deja Vu"
else
return "Unknown Game"
end
end

local function getAvailableMode()
return "Chase"
end


local function esp(inst)
local esp = Instance.new("Highlight")
esp.Adornee = inst
esp.FillColor = Color3.fromRGB(255, 0, 0)
esp.OutlineColor = Color3.fromRGB(255, 0, 0)
esp.FillTransparency = 0.5
esp.OutlineTransparency = 0
esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
esp.Enabled = false

esp.Enabled = false
esp.Parent = inst
return esp
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = getWindowTitleFromPlaceId(),
    Author = "by ACE1991ACE",
})

Window:Tag({
    Title = "BETA",
    Icon = "cog",
    Color = Color3.fromHex("#FFD700"),
    Radius = 13
})

if game.PlaceId == 129085487311457 then
local Eli = workspace:WaitForChild("ChaseWorld"):WaitForChild("Eli")
local TwinEntity = workspace:WaitForChild("_TwinEntityVisual")

local ChaseTab = Window:Tab({
    Title = "Act 1",
})

local MallTab = Window:Tab({
    Title = "Act 2",
})

local function getRoot()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    return Character:WaitForChild("HumanoidRootPart")
end

local function teleport(CFrame)
    getRoot().CFrame = CFrame + Vector3.new(0, 3, 0)
end

local function getBasePart(Prompt, Boundary)
    local Parent = Prompt.Parent

    while Parent and Parent ~= Boundary do
        if Parent:IsA("BasePart") then
            return Parent
        end

        Parent = Parent.Parent
    end

    return nil
end

local function activatePrompt(Prompt, Part, Delay)
    teleport(Part.CFrame)
    task.wait(Delay or 0.2)
    fireproximityprompt(Prompt)
end

local function runChaseEscape()
    local ChaseWorld = workspace.ChaseWorld
    local KeySpawns = ChaseWorld.KeySpawns
    local Kit = ChaseWorld.Kit

    local ChaseEvent = ReplicatedStorage.ChaseKeyEvent
    local MallChoice = ReplicatedStorage.ChaseRemotes.MallChoice

    local GotThree = false
    local Exiting = false

    local Connection

    local function exitGate()
        if Exiting then
            return
        end

        Exiting = true

        task.spawn(function()
            local Anchor = ChaseWorld.ExitGate.PromptAnchor
            local Prompt = Anchor:WaitForChild("GatePrompt")

            teleport(Anchor.CFrame)
            task.wait(0.2)

            fireproximityprompt(Prompt)

            task.wait(5)
            MallChoice:FireServer("continue")

            if Connection then
                Connection:Disconnect()
                Connection = nil
            end
        end)
    end

    Connection = ChaseEvent.OnClientEvent:Connect(function(Arg1, Arg2)
        if Arg1 == "picked"
            and typeof(Arg2) == "number"
            and Arg2 == 3 then

            GotThree = true
            exitGate()
        end
    end)

    local function searchKeys()
        for _, Model in ipairs(KeySpawns:GetDescendants()) do
            if GotThree then
                return
            end

            if Model:IsA("Model") and Model.Name == "Key" then
                for _, Prompt in ipairs(Model:GetDescendants()) do
                    if GotThree then
                        return
                    end

                    if Prompt:IsA("ProximityPrompt") then
                        local Part = getBasePart(Prompt, KeySpawns)

                        if Part then
                            activatePrompt(Prompt, Part)
                        end
                    end
                end
            end
        end

        task.wait(0.5)
    end

    local function searchKit()
        for _, Prompt in ipairs(Kit:GetDescendants()) do
            if GotThree then
                return
            end

            if Prompt:IsA("ProximityPrompt") then
                local Part = getBasePart(Prompt, Kit)

                if Part then
                    activatePrompt(Prompt, Part)
                end
            end
        end

        task.wait(0.5)
    end

    task.spawn(function()
        searchKeys()

        if GotThree then
            return
        end

        searchKit()

        if GotThree then
            return
        end

        searchKeys()
    end)
end

local function runMallEscape()
    local MallCode = workspace.MallCode
    local MallExit = workspace.MallExit
    local Event = ReplicatedStorage.ChaseRemotes.MallCode

    local Codes = {}
    local CodePaperCount = 0

    for _, Paper in ipairs(MallCode:GetChildren()) do
        if Paper.Name == "CodePaper" then
            CodePaperCount += 1
        end
    end

    local Connection = Event.OnClientEvent:Connect(function(Arg1, Arg2, Arg3)
        if typeof(Arg2) == "number" then
            Codes[Arg2] = Arg3
        end
    end)

    for _, Paper in ipairs(MallCode:GetChildren()) do
        if Paper.Name == "CodePaper" then
            local Sheet = Paper:WaitForChild("Sheet")
            local Prompt = Sheet:WaitForChild("ReadPrompt")

            activatePrompt(Prompt, Sheet, 1)
            task.wait(0.2)
        end
    end

    repeat
        task.wait(0.1)

        local NumberCount = 0

        for _, Value in pairs(Codes) do
            if tonumber(Value) ~= nil then
                NumberCount += 1
            end
        end

        if NumberCount >= CodePaperCount then
            break
        end
    until false

    Connection:Disconnect()

    local Indexes = {}

    for Index, Value in pairs(Codes) do
        if tonumber(Value) ~= nil then
            Indexes[#Indexes + 1] = Index
        end
    end

    table.sort(Indexes)

    local CodeText = ""

    for _, Index in ipairs(Indexes) do
        CodeText ..= tostring(Codes[Index])
    end

    print("Code:", CodeText)
    print("Length:", #CodeText)
    print("There a debug from code. Review the code; if there are any errors or inaccuracies, please report them on ScriptBlox.")
  

    local Keypad = MallExit.Keypad
    local KeypadPrompt = Keypad.PromptPoint.KeypadPrompt

    teleport(Keypad.CFrame)
    task.wait(0.2)

    fireproximityprompt(KeypadPrompt)

    task.wait(2)

    Event:FireServer("try", CodeText)

    task.wait(0.5)

    teleport(MallExit.EscapeZone.CFrame)
end

ChaseTab:Button({
    Title = "Escape Chase World",
    Desc = "Act 1 • Collect keys and escape from Eli",
    Callback = runChaseEscape,
})

local Elih = esp(Eli)

ChaseTab:Toggle({
Title = "Esp Eli",
Callback = function(v)
Elih.Enabled = v
end
})

MallTab:Button({
    Title = "Escape Mall",
    Desc = "Act 2 • Read code papers and unlock the exit",
    Callback = runMallEscape,
})


local setTwinEntityESP = esp(TwinEntity)

task.spawn(function()
local Scrow = workspace:WaitForChild("_MascotVisual", 9e9)
local setScrowESP = esp(Scrow)
MallTab:Toggle({
    Title = "Esp Scrow",
    Callback = function(v)
        setScrowESP.Enabled = v
    end
})
end)

MallTab:Toggle({
    Title = "Esp TwinEntity",
    Callback = function(v)
        setTwinEntityESP.Enabled = v
    end
})


elseif game.PlaceId == 78453398695059 then
local LobbyTab = Window:Tab({
    Title = "READ ME",
})

LobbyTab:Paragraph({
    Title = "Run Script",
    Desc = "Please Choose mode to continue with cheating",
})

elseif game.PlaceId == 104507343743721 then
local Tab = Window:Tab({
    Title = "READ ME",
})

Tab:Paragraph({
    Title = "Not supported",
    Desc = "Only supported: " .. getAvailableMode() .. " ,this mode dont need to cheat",
})
end