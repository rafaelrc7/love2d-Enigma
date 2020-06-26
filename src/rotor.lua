local M = {};

local alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
local referenceAlphabet = alphabet;


function M.create (wiringTable, turningNotch)

    return {
        wiringTable         = wiringTable;
        alphabet            = alphabet;
        referenceAlphabet   = referenceAlphabet;
        turningNotch        = turningNotch;
        rolled              = false;
    };

end;


local function encodeIn(rotor, char)

    local charPos, wiringTablePos = 0;

    for i = 1, #rotor.wiringTable do
        if char == rotor.referenceAlphabet[i] then
            charPos = i;
        end;
    end;

    wiringTablePos = rotor.wiringTable[charPos];

    for i = 1, #rotor.wiringTable do
        if wiringTablePos == rotor.alphabet[i] then
            charPos = i;
        end;
    end;

    return rotor.referenceAlphabet[charPos];

end;

local function encodeOut(rotor, char)

    local charPos, alphabetPos = 0;

    for i = 1, #rotor.wiringTable do
        if char == rotor.referenceAlphabet[i] then
            charPos = i;
        end;
    end;

    alphabetPos = rotor.alphabet[charPos];

    for i = 1, #rotor.wiringTable do
        if alphabetPos == rotor.wiringTable[i] then
            charPos = i;
        end;
    end;

    return rotor.referenceAlphabet[charPos];

end;

function M.encode (rotor, char, cycle)

    if char == ' ' then
        return ' ';
    end;

    if cycle == 0 then
        return encodeIn(rotor, char);
    else
        return encodeOut(rotor, char);
    end;

end;


function M.roll(rotor)

    local rollTable, rollAlphabet = {}, {};

    for i = 1, #rotor.wiringTable do
        rollTable[i] = rotor.wiringTable[i+1];
        rollAlphabet[i] = rotor.alphabet[i+1];
    end;

    rollTable[#rotor.wiringTable] = rotor.wiringTable[1];
    rollAlphabet[#rotor.alphabet] = rotor.alphabet[1];

    rotor.wiringTable = rollTable;
    rotor.alphabet = rollAlphabet;
    rotor.rolled = true;

end;

function M.rollTo(rotor, char)

    while rotor.alphabet[1] ~= char do
        M.roll(rotor);
    end;

end;

function M.isOnTurningNotch(rotor)

    return rotor.alphabet[1] == rotor.turningNotch;

end;


return M;