local preset = require "rotorPresets";
local enigma = require "enigma";
local tools = require "tools";

local enMachine = enigma.create({preset.getPreset("I"), preset.getPreset("II"), preset.getPreset("III")}, preset.getPreset("B"));

io.write("Enter a message: ")
local message = io.read("*l");

message = enigma.encode(enMachine, tools.toCharArray(message:upper()));

tools.printCharTable(message);