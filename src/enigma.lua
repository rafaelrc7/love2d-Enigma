local M = {};

local rotor = require "rotor";


function M.create (rotorsTemplates, reflectorTemplate)

	local rotors, reflector = {}, rotor.create(reflectorTemplate[1], reflectorTemplate[2]);

	-- slow - medium - fast

	for i = 1, #rotorsTemplates do
		rotors[i] = rotor.create(rotorsTemplates[i][1], rotorsTemplates[i][2]);
	end;

	return {

		rotors 		= rotors,
		reflector 	= reflector;

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

		if( char ~= ' ' ) then step(enigma); else goto continue; end;

		for i = #enigma.rotors, 1, -1 do
			message[key] = rotor.encode( enigma.rotors[i], message[key], 0 );
		end;

		message[key] = rotor.encode( enigma.reflector, message[key], 0 );

		for i = 1, #enigma.rotors do
			message[key] = rotor.encode( enigma.rotors[i], message[key], 1 );
		end;

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

	enigma.rotors[rotorNum] = rotor.create(newRotor[1], newRotor[2]);

end;

function M.setReflector (enigma, newReflector)

	enigma.reflector = rotor.create(newReflector[1], newReflector[2]);

end;


return M;