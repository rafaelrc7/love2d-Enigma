local preset = require "rotorPresets";
local enigma = require "enigma";
local tools = require "tools";


local enMachine, message = enigma.create({preset.getPreset("I"), preset.getPreset("II"), preset.getPreset("III")}, preset.getPreset("B"));


enigma.createPlug( enMachine, { {"A", "B"}, {"G", "K"}, {"J", "X"}, } );
enigma.clearPlugBoard(enMachine);

enigma.setOnePosition(enMachine, 2, "J");
enigma.setPosition(enMachine, {"A", "A", "A"});

enigma.setReflector(enMachine, preset.getPreset("B"));
enigma.setRotor(enMachine, 1, preset.getPreset("I"));

io.write("rotor templates: " .. enigma.getRotor(enMachine, 1) .. " " .. enigma.getRotor(enMachine, 2) .. " " .. enigma.getRotor(enMachine, 3) .. " " .. "\n");

io.write("rotor position: " .. enigma.getRotorPos(enMachine, 1) .. enigma.getRotorPos(enMachine, 2) .. enigma.getRotorPos(enMachine, 3) .. "\n");

io.write("Enter a message: ")
message = io.read("*l");

message = enigma.encode(enMachine, tools.toCharArray(message:upper()));

io.write("rotor position: " .. enigma.getRotorPos(enMachine, 1) .. enigma.getRotorPos(enMachine, 2) .. enigma.getRotorPos(enMachine, 3) .. "\n");

print(tools.toString(message));