local Library = {}

local StringSub = string.sub
local StringUpper = string.upper

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

function Library.ReverseTable(x)
    local Result = {}

    for i = #x, 1, -1 do
        Result[#Result + 1] = x[i]
    end
    
    return Result
end

function Library.ReverseString(x)
    local Result = {}

    for i = #x, 1, -1 do
        Result[#Result + 1] = StringSub(x, i, i)
    end
    
    return Library.Concat(Result)
end

function Library.Reverse(x)
    return (type(x) == "table") and Library.ReverseTable(x) or Library.ReverseString(x)
end

function Library.BreakCamelCase(str)
    local Result = {}

    str = StringUpper(StringSub(str, 1, 1)) .. StringSub(str, 2, #str)

    for word in str:gmatch("%u%U*") do
        Result[#Result + 1] = word .. " "
    end

    Result = Library.Concat(Result)

    return StringSub(Result, 1, #Result - 1)
end

return Library