local M = {};


function M.toCharArray (string)

    local charArray = {};

    for c in string:gmatch(".") do
        charArray[#charArray+1] = c;
    end;

    return charArray;

end;

function M.toString (charTable)

    local string = "";

    for _, char in pairs(charTable) do
        string = string .. char;
    end;

    return string;

end;

function M.printCharTable (charTable)

    for i=1, #charTable do
        io.write(charTable[i]);
    end;
    io.write("\n");

end;


return M;