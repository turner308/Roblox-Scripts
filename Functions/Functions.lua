local Library = {}

local Players = game:GetService("Players")
local StringSub = string.sub
local StringUpper = string.upper
local StringSplit = string.split
local StringFind = string.find
local TableConcat = table.concat

function Library.Concat(Table, Delimiter, DelimitEvery, TruncateEnd)
    Delimiter = Delimiter or ""
    DelimitEvery = DelimitEvery or 0
    TruncateEnd = TruncateEnd or false
    local Result = ""
    local Counter = 0

    for _, v in next, Table do
        Counter += 1
        Result ..= v

        if (Counter == DelimitEvery) then
            Counter = 0
            Result ..= Delimiter
        end
    end

    return TruncateEnd and StringSub(Result, 0, #Result - #Delimiter) or Result
end

function Library.ReverseTable(X)
    local Result = {}

    for i = #X, 1, -1 do
        Result[#Result + 1] = X[i]
    end
    
    return Result
end

function Library.ReverseString(X)
    local Result = {}

    for i = #X, 1, -1 do
        Result[#Result + 1] = StringSub(X, i, i)
    end
    
    return Library.Concat(Result)
end

function Library.Reverse(X)
    return (type(X) == "table") and Library.ReverseTable(X) or Library.ReverseString(X)
end

function Library.BreakCamelCase(Str)
    local Result = {}

    Str = StringUpper(StringSub(Str, 1, 1)) .. StringSub(Str, 2, #Str)

    for word in Str:gmatch("%u%U*") do
        Result[#Result + 1] = word .. " "
    end

    Result = Library.Concat(Result)

    return StringSub(Result, 1, #Result - 1)
end

function Library.IsAlive(Char, MinHealth)
    local Player = Players:FindFirstChild(tostring(Char))

    if (Player) then
        local Character = Player.Character

        if (Character) then
            Char = Character
        end
    end

    local Humanoid = Char:FindFirstChildOfClass("Humanoid")

    return Humanoid and (Humanoid.Health > (MinHealth or 0)) and Char
end

function Library.GetTypeFromTable(Table, Type)
    for _, v in next, Table do
        if (typeof(v) == Type) then
            return v
        end
    end
end

function Library.StringInTable(Table, String, EqualsIgnoreCase)
    String = EqualsIgnoreCase and StringUpper(String) or String
    for _, v in next, Table do
        if StringFind(String, StringUpper(v)) then
            return true
        end
    end
end

function Library.InstanceContains(...)
    local Arguments = {...}
    local Inst = Library.GetTypeFromTable(Arguments, "Instance")
    local Descendants = Library.GetTypeFromTable(Arguments, "table")

    for _, v in next, Arguments do
        if (v ~= Inst and v ~= Descendants and not Inst:FindFirstChild(v)) then
            return
        end
    end

    if (Descendants) then
        for _, v in next, Descendants do
            if (not Inst:FindFirstChild(v, true)) then
                return
            end
        end
    end

    return true
end

function Library.StringReplace(Str, ToReplace, Replacement)
    local Result = {}

    for _, v in next, StringSplit(Str, ToReplace) do
        Result[#Result + 1] = v
    end

    return TableConcat(Result, Replacement)
end

function Library.StringReplaces(Str, ToReplaces, Replacements)
    local Result = Str

    for i = 1, #ToReplaces do
        Result = Library.StringReplace(Result, ToReplaces[i], Replacements[i])
    end

    return Result
end

function Library.InstanceChains(...)
    local Arguments = {...}
    local Inst = Library.GetTypeFromTable(Arguments, "Instance")
    local LastLink = Inst
    local Result = {}

    for _, v in next, Arguments do
        if (type(v) == "table") then
            for _, v2 in next, v do
                if (LastLink) then
                    LastLink = LastLink:FindFirstChild(v2)
                else
                    LastLink = Inst
                end
            end

            Result[v[#v]] = LastLink
        end

        LastLink = Inst
    end

    return Result
end

function Library.InstanceChain(...)
    local Arguments = {...}
    local Inst = Library.GetTypeFromTable(Arguments, "Instance")
    local LastLink = Inst
    local Result

    for _, v in next, Arguments do
        if (type(v) == "string") then
            if (LastLink) then
                LastLink = LastLink:FindFirstChild(v)
            else
                LastLink = Inst
            end
        end

        Result = LastLink
    end

    return Result
end

function Library.TableToX(_table, x)
    local result = {}

    for i = 1, x do
        result[#result + 1] = _table[i]
    end

    return result
end

function Library.TablePop(_table, x)
    x = x or 1
    return Library.TableToX(_table, #_table - x)
end

function Library.TableLast(_table)
    return _table[#_table]
end

return Library
