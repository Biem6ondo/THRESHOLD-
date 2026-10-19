local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local Supported = {
    fireproximityprompt = typeof(fireproximityprompt) == "function"
}

local function getWindowTitleFromPlaceId()
    local Titles = {
        [78453398695059] = "DrayvenX THRESHOLD | Lobby",
        [129085487311457] = "DrayvenX THRESHOLD | Chase Mode",
        [104507343743721] = "DrayvenX THRESHOLD | Story Mode: Deja Vu"
    }

    return Titles[game.PlaceId] or "Unknown Game"
end

local function getAvailableMode()
    return "Chase"
end

local function createESP(Inst)
    local Highlight = Instance.new("Highlight")

    Highlight.Adornee = Inst
    Highlight.FillColor = Color3.fromRGB(255, 0, 0)
    Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Enabled = false
    Highlight.Parent = Inst

    return Highlight
end

local Window = WindUI:CreateWindow({
    Title = getWindowTitleFromPlaceId(),
    Author = "by ACE1991ACE or maihoangthuan"
})

Window:Tag({
    Title = "BETA",
    Icon = "cog",
    Color = Color3.fromHex("#FFD700"),
    Radius = 13
})

--// CHASE MODE

if game.PlaceId == 129085487311457 then
    local Eli = Workspace:WaitForChild("ChaseWorld"):WaitForChild("Eli")
    local TwinEntity = Workspace:WaitForChild("_TwinEntityVisual")

    local ReadmeTab = Window:Tab({
        Title = "Warning"
    })

    ReadmeTab:Paragraph({
        Title = "sUNC Warning",
        Desc = 'This script requires "fireproximityprompt()", which is not supported by all executors.\n\nTested Executors: Delta, Arceus X, and others.\n\nIf a feature is unavailable, try using a supported executor.'
    })

    local ChaseTab = Window:Tab({
        Title = "Chase World (Act 1)"
    })

    local MallTab = Window:Tab({
        Title = "Mall (Act 2)"
    })

    --// UTILITIES

    local function getRoot()
        local Character = Player.Character
            or Player.CharacterAdded:Wait()

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

    --// CHASE ESCAPE

    local function runChaseEscape()
        local ChaseWorld = Workspace.ChaseWorld
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
                and Arg2 == 3
            then
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

    --// MALL ESCAPE

    local function runMallEscape()
        local MallCode = Workspace.MallCode
        local MallExit = Workspace.MallExit
        local Event = ReplicatedStorage.ChaseRemotes.MallCode

        local Codes = {}
        local CodePaperCount = 0

        for _, Paper in ipairs(MallCode:GetChildren()) do
            if Paper.Name == "CodePaper" then
                CodePaperCount += 1
            end
        end

        local Connection = Event.OnClientEvent:Connect(function(
            Arg1,
            Arg2,
            Arg3
        )
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

    --// ESP ELI

    local EliESP = createESP(Eli)

    ChaseTab:Toggle({
        Title = "Esp Eli",
        Callback = function(Value)
            EliESP.Enabled = Value
        end
    })

    --// ESP KEY & CODE PAPER

    local ESPColor = Color3.fromRGB(255, 170, 0)

    local ESPObjects = {
        Key = {},
        CodePaper = {}
    }

    local ESPEnabled = {
        Key = true,
        CodePaper = false
    }

    local function getPos(Model)
        local Point = Model:FindFirstChild("KeyPoint", true)

        if Point and Point:IsA("Attachment") then
            return Point.WorldPosition
        end

        Point = Model:FindFirstChild("KEY__key", true)

        if Point and Point:IsA("BasePart") then
            return Point.Position
        end

        for _, Object in ipairs(Model:GetDescendants()) do
            if Object:IsA("BasePart") then
                return Object.Position
            end
        end
    end

    local function addESP(Model, Kind)
        local List = ESPObjects[Kind]

        if List[Model] then
            return
        end

        local Highlight = Instance.new("Highlight")

        Highlight.Adornee = Model
        Highlight.FillColor = ESPColor
        Highlight.OutlineColor = ESPColor
        Highlight.FillTransparency = 0.65
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Enabled = ESPEnabled[Kind]
        Highlight.Parent = Model

        local Billboard = Instance.new("BillboardGui")

        Billboard.Adornee = Model
        Billboard.Size = UDim2.fromOffset(180, 22)
        Billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.6, 0)
        Billboard.AlwaysOnTop = true
        Billboard.MaxDistance = 3000
        Billboard.Enabled = ESPEnabled[Kind]
        Billboard.Parent = Model

        local Label = Instance.new("TextLabel")

        Label.Size = UDim2.fromScale(1, 1)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.TextColor3 = Color3.fromRGB(255, 205, 90)
        Label.TextStrokeTransparency = 0
        Label.Text = Kind == "Key" and "KEY" or "CODE PAPER"
        Label.Parent = Billboard

        List[Model] = {
            Highlight,
            Billboard,
            Label
        }
    end

    local function removeESP(Model, Kind)
        local Objects = ESPObjects[Kind][Model]

        if not Objects then
            return
        end

        for _, Object in ipairs(Objects) do
            Object:Destroy()
        end

        ESPObjects[Kind][Model] = nil
    end

    local function syncESP()
        local Found = {
            Key = {},
            CodePaper = {}
        }

        local Paths = {
            {"ChaseWorld", "KeySpawns"},
            {"ChaseSpots", "KeySpawns"}
        }

        for _, Path in ipairs(Paths) do
            local Folder = Workspace

            for _, Name in ipairs(Path) do
                Folder = Folder and Folder:FindFirstChild(Name)
            end

            if Folder then
                for _, Child in ipairs(Folder:GetChildren()) do
                    local Key = Child:FindFirstChild("Key")

                    if Key and Key:IsA("Model") and getPos(Key) then
                        Found.Key[Key] = true
                        addESP(Key, "Key")
                    end
                end
            end
        end

        local Mall = Workspace:FindFirstChild("MallCode")

        if Mall then
            for _, Model in ipairs(Mall:GetChildren()) do
                if Model:IsA("Model") and Model.Name == "CodePaper" then
                    Found.CodePaper[Model] = true
                    addESP(Model, "CodePaper")
                end
            end
        end

        for Kind, List in pairs(ESPObjects) do
            for Model in pairs(List) do
                if not Found[Kind][Model] or not Model.Parent then
                    removeESP(Model, Kind)
                end
            end
        end
    end

    local function toggleESP(Kind, Value)
        ESPEnabled[Kind] = Value

        for _, Objects in pairs(ESPObjects[Kind]) do
            Objects[1].Enabled = Value
            Objects[2].Enabled = Value
        end
    end

    ChaseTab:Toggle({
        Title = "Esp Key",
        Desc = "Only displays exposed keys. Keys hidden inside boxes, drawers, or other containers cannot be detected because of this game's anti-cheat.",
        Default = true,
        Callback = function(Value)
            toggleESP("Key", Value)
        end
    })

    MallTab:Toggle({
        Title = "Esp CodePaper",
        Desc = "Esp Code Paper Mall World",
        Default = false,
        Callback = function(Value)
            toggleESP("CodePaper", Value)
        end
    })

    Workspace.DescendantAdded:Connect(function()
        task.defer(syncESP)
    end)

    Workspace.DescendantRemoving:Connect(function()
        task.defer(syncESP)
    end)

    RunService.RenderStepped:Connect(function()
        local Character = Player.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if not Root then
            return
        end

        for Kind, List in pairs(ESPObjects) do
            if ESPEnabled[Kind] then
                for Model, Objects in pairs(List) do
                    local Position

                    if Kind == "Key" then
                        Position = getPos(Model)
                    elseif Kind == "CodePaper" then
                        local Part = Model.PrimaryPart
                            or Model:FindFirstChildWhichIsA("BasePart", true)

                        Position = Part and Part.Position
                    end

                    if Position then
                        local Distance = math.floor(
                            (Root.Position - Position).Magnitude + 0.5
                        )

                        Objects[3].Text = (
                            Kind == "Key" and "KEY  " or "CODE PAPER  "
                        ) .. Distance .. "m"
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.75) do
            syncESP()
        end
    end)

    syncESP()

    --// ESCAPE BUTTONS

    local function addSupportedButton(Tab, Title, Desc, Callback)
        if Supported.fireproximityprompt then
            Tab:Button({
                Title = Title,
                Desc = Desc,
                Callback = Callback
            })
        else
            Tab:Button({
                Title = 'Not supported "' .. Title .. '"',
                Desc = "Your executor does not support fireproximityprompt; try another executor."
            })
        end
    end

    addSupportedButton(
        ChaseTab,
        "Escape Chase World",
        "Act 1 • Collect keys and escape from Eli",
        runChaseEscape
    )

    addSupportedButton(
        MallTab,
        "Escape Mall",
        "Act 2 • Read code papers and unlock the exit",
        runMallEscape
    )

    --// ESP TWIN ENTITY

    local TwinEntityESP = createESP(TwinEntity)

    MallTab:Toggle({
        Title = "Esp TwinEntity",
        Callback = function(Value)
            TwinEntityESP.Enabled = Value
        end
    })

    --// ESP SCROW

    task.spawn(function()
        local Scrow = Workspace:WaitForChild("_MascotVisual", 9e9)
        local ScrowESP = createESP(Scrow)

        MallTab:Toggle({
            Title = "Esp Scrow",
            Callback = function(Value)
                ScrowESP.Enabled = Value
            end
        })
    end)

    --// ALWAYS NOISE

    local AlwaysNoiseEnabled = false

    MallTab:Toggle({
        Title = "Alway noise",
        Desc = "Simulation (without a microphone) always produces noise.",
        Callback = function(Value)
            AlwaysNoiseEnabled = Value
        end
    })

    task.spawn(function()
        while task.wait(1 / 20) do
            if AlwaysNoiseEnabled then
                local Event = ReplicatedStorage.ChaseRemotes.MallNoise

                Event:FireServer("mic", math.huge)
            end
        end
    end)

--// LOBBY

elseif game.PlaceId == 78453398695059 then
    local LobbyTab = Window:Tab({
        Title = "READ ME"
    })

    LobbyTab:Paragraph({
        Title = "Run Script",
        Desc = 'Please choose a mode to continue cheating.\nClick "START" or the button below to play alone.'
    })

    LobbyTab:Button({
        Title = "Start Chase Mode",
        Desc = "Create Room and Teleport to Chase Mode (Single Player)",
        Callback = function()
            local Event = ReplicatedStorage:WaitForChild("LobbyRequest")

            local Success, Result = pcall(function()
                return Event:InvokeServer(
                    "create",
                    "01",
                    nil,
                    1,
                    nil,
                    "chase",
                    "eli",
                    "normal"
                )
            end)

            if not Success then
                warn("Create failed:", Result)
                return
            end

            print("Create result:", Result)

            task.wait(0.5)

            Event:InvokeServer("launch")
        end
    })

--// STORY MODE

elseif game.PlaceId == 104507343743721 then
    local Tab = Window:Tab({
        Title = "READ ME"
    })

    Tab:Paragraph({
        Title = "Not supported",
        Desc = "Only supported: " .. getAvailableMode() .. ", this mode dont need to cheat"
    })
end