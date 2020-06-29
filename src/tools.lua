local M = {};

function M.toCharArray (string)

    local charArray = {};

    for c in string:gmatch(".") do
        charArray[#charArray+1] = c;
    end;

    return charArray;

end;

function M.printCharTable (charTable)

    for i=1, #charTable do
        io.write(charTable[i]);
    end;
    io.write("\n");

end;

function M.formatMessage (message, pieceSize);

    local finalMessage = {};

    for i = 1, #message do
        table.insert(finalMessage, message[i]);
        if i % pieceSize == 0 then
            table.insert(finalMessage, " ");
        end;
    end;

    return finalMessage;

end;

return M;