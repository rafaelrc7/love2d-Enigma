local M = {};

local rotor = require "rotor";

local function defaultPlugBoard()

	return {
		["A"] = "A",
		["B"] = "B",
		["C"] = "C",
		["D"] = "D",
		["E"] = "E",
		["F"] = "F",
		["G"] = "G",
		["H"] = "H",
		["I"] = "I",
		["J"] = "J",
		["K"] = "K",
		["L"] = "L",
		["M"] = "M",
		["N"] = "N",
		["O"] = "O",
		["P"] = "P",
		["Q"] = "Q",
		["R"] = "R",
		["S"] = "S",
		["T"] = "T",
		["U"] = "U",
		["V"] = "V",
		["W"] = "W",
		["X"] = "X",
		["Y"] = "Y",
		["Z"] = "Z",
	};

end;


function M.create (rotorsTemplates, reflectorTemplate)

	local rotors, reflector = {}, rotor.create(reflectorTemplate);

	-- slow - medium - fast

	for i = 1, #rotorsTemplates do
		rotors[i] = rotor.create(rotorsTemplates[i]);
	end;

	return {

		rotors 		= rotors,
		reflector 	= reflector,
		plugBoard	= defaultPlugBoard(),

	};

end;


local function step (enigma)

	for i = 1, #enigma.rotors do
		enigma.rotors[i].rolled = false;
	end;

	for i = 1, #enigma.rotors-1 do

		if rotor.isOnTurningNotch(enigma.rotors[i+1]) then
			if not enigma.rotors[i].rolled then
				rotor.roll(enigma.rotors[i]);
			end;
			if not enigma.rotors[i+1].rolled then
				rotor.roll(enigma.rotors[i+1]);
			end;
		end;

	end;

	if not enigma.rotors[#enigma.rotors].rolled then
		rotor.roll(enigma.rotors[#enigma.rotors]);
	end;

end;

function M.encode (enigma, message)

	for key, char in pairs(message) do

		if( char:match("%a") ) then step(enigma); else goto continue; end;

		message[key] = enigma.plugBoard[message[key]];

		for i = #enigma.rotors, 1, -1 do
			message[key] = rotor.encode( enigma.rotors[i], message[key], 0 );
		end;

		message[key] = rotor.encode( enigma.reflector, message[key], 0 );

		for i = 1, #enigma.rotors do
			message[key] = rotor.encode( enigma.rotors[i], message[key], 1 );
		end;

		message[key] = enigma.plugBoard[message[key]];

		::continue::;

	end;

	return message;

end;

function M.setPosition (enigma, positions)

	for i = 1, #enigma.rotors do
		if positions[i] ~= -1 then
			rotor.rollTo(enigma.rotors[i], positions[i]);
		end;
	end;

end;

function M.setOnePosition (enigma, rotorNum, position)

	local positions = {};

	for i = 1, #enigma.rotors do
		if i == rotorNum then
			positions[i] = position;
		else
			positions[i] = -1;
		end;
	end;

	M.setPosition (enigma, positions);

end;

function M.setRotor (enigma, rotorNum, newRotor)

	enigma.rotors[rotorNum] = rotor.create(newRotor);

end;

function M.setReflector (enigma, newReflector)

	enigma.reflector = rotor.create(newReflector);

end;

function M.clearPlugBoard(enigma)

	enigma.plugBoard = defaultPlugBoard();

end;

function M.createPlug(enigma, plugs)

	for _, plug in ipairs(plugs) do
		for _, letter in ipairs(plug) do
			if enigma.plugBoard[letter] ~= letter then
				enigma.plugBoard[ enigma.plugBoard[letter] ] = enigma.plugBoard[letter];
				enigma.plugBoard[letter] = letter;
			end;
		end;
		enigma.plugBoard[ plug[1] ], enigma.plugBoard[ plug[2] ] = plug[2], plug[1];
	end;

end;

return M;