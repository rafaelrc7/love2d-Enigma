local M = {};


local tools = require "tools";

local presets = {

    -- Reflectors
    ["A"]   =   { tools.toCharArray("EJMZALYXVBWFCRQUONTSPIKHGD"), " ", "A" },
    ["B"]   =   { tools.toCharArray("YRUHQSLDPXNGOKMIEBFZCWVJAT"), " ", "B" },
    ["C"]   =   { tools.toCharArray("FVPJIAOYEDRZXWGCTKUQSBNMHL"), " ", "C" },

    -- Rotors
    ["I"]   =   { tools.toCharArray("EKMFLGDQVZNTOWYHXUSPAIBRCJ"), "Q", "I" },
    ["II"]  =   { tools.toCharArray("AJDKSIRUXBLHWTMCQGZNPYFVOE"), "E", "II" },
    ["III"] =   { tools.toCharArray("BDFHJLCPRTXVZNYEIWGAKMUSQO"), "V", "III" },
    ["IV"]  =   { tools.toCharArray("ESOVPZJAYQUIRHXLNFTGKDCMWB"), "J", "IV" },
    ["V"]   =   { tools.toCharArray("VZBRGITYUPSDNHLXAWMJQOFECK"), "Z", "V" };

};


function M.getPreset (code)

    return presets[code];

end;


return M;