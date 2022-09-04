-- locals
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Vector2New = Vector2.new
local StringFormat = string.format
local StringFind = string.find
local StringSplit = string.split
local TableFind = table.find
local TableConcat = table.concat
local Wait = task.wait
local Color3New = Color3.new
local Color3FromRGB = Color3.fromRGB
local DrawingNew = Drawing.new

-- max words displayed
local MaxDisplayed = 30
local MaxCharacters = 8

--load wordlist
local Words = StringSplit(game:HttpGet("https://raw.githubusercontent.com/BimbusCoder/Roblox-Scripts/master/WordBomb/WordList.txt"), "\n")

-- draw words
local DefaultText = "[ Word Bomb Cheat - by aturner ]\n%s\n"
local WordsDrawing = DrawingNew("Text")
WordsDrawing.Visible = true
WordsDrawing.Size = 30
WordsDrawing.Text = DefaultText
WordsDrawing.Color = Color3FromRGB(255, 255, 0)

-- previous letters
local LastLetters
local LastWords = {}

-- main loop
while true do
    WordsDrawing.Position = Vector2New(10, 36)
    local TextFrame = PlayerGui.GameUI.Container.GameSpace.DefaultUI:FindFirstChild("TextFrame", true)
    local DesktopContainer = PlayerGui.GameUI.Container.GameSpace.DefaultUI:FindFirstChild("DesktopContainer", true)

    if DesktopContainer then
        for _, child in next, DesktopContainer:GetChildren() do
            if child.Name == "PlayerFrameContainer" then
                local PlayerFrame = child:FindFirstChild("PlayerFrame")

                if PlayerFrame then
                    local TypingText = PlayerFrame:FindFirstChild("TypingText")

                    if TypingText then
                        local TypingTextText = TypingText.Text

                        if not TableFind(LastWords, TypingTextText) then
                            LastWords[#LastWords + 1] = TypingTextText
                        end
                    end
                end
            end
        end
    end

    if TextFrame then
        local Letters = {}
        local Counter = 0

        for _, child in next, TextFrame:GetChildren() do
            if child.Name == "LetterFrame" then
                local Letter = child:FindFirstChild("Letter")

                if Letter and Letter.ImageColor3 ~= Color3New(0.996078, 0.996078, 0.996078) then
                    local LetterText = Letter:FindFirstChildWhichIsA("TextLabel")

                    if LetterText then
                        Counter += 1
                        
                        if Counter > 2 then
                            Letters[#Letters + 1] = LetterText.Text
                        end
                    end
                end
            end
        end
        
        Letters = TableConcat(Letters)
        
        if Letters ~= LastLetters then
            if #Letters > 0 then
                local WordsFound = {}
                local Counter = 0

                for _, word in next, Words do
                    if not TableFind(LastWords, word) and #word <= MaxCharacters and StringFind(word, Letters) then
                        Counter += 1
                        WordsFound[#WordsFound + 1] = Counter .. ". " .. word

                        if Counter == MaxDisplayed then
                            break
                        end
                    end
                end

                WordsDrawing.Text = StringFormat(DefaultText, "Current Charset: " .. Letters) .. TableConcat(WordsFound, "\n")
            else
                WordsDrawing.Text = StringFormat(DefaultText, "N/A")
            end
        end
    else
        if #LastWords > 0 then
            LastWords = {}
        end

        WordsDrawing.Text = StringFormat(DefaultText, "waiting for game to begin...")
    end

    Wait()
end