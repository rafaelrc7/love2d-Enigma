local M = {};

local tools = require "tools";

local presets = {

    -- Reflectors
    ["A"]   =   { tools.toCharArray("EJMZALYXVBWFCRQUONTSPIKHGD"), " " },
    ["B"]   =   { tools.toCharArray("YRUHQSLDPXNGOKMIEBFZCWVJAT"), " " },
    ["C"]   =   { tools.toCharArray("FVPJIAOYEDRZXWGCTKUQSBNMHL"), " " },

    -- Rotors
    ["I"]   =   { tools.toCharArray("EKMFLGDQVZNTOWYHXUSPAIBRCJ"), "Q" },
    ["II"]  =   { tools.toCharArray("AJDKSIRUXBLHWTMCQGZNPYFVOE"), "E" },
    ["III"] =   { tools.toCharArray("BDFHJLCPRTXVZNYEIWGAKMUSQO"), "V" },
    ["IV"]  =   { tools.toCharArray("ESOVPZJAYQUIRHXLNFTGKDCMWB"), "J" },
    ["V"]   =   { tools.toCharArray("VZBRGITYUPSDNHLXAWMJQOFECK"), "Z" };

};


function M.getPreset (code)

    return presets[code];

end;


return M;