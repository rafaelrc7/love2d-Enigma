local Width, Height, sx, sy = 1538, 864;
local mWidth, mHeight;

local state = "MAIN";

local bg, btnLmpAtlas, btnQuad, lmpQuad, letterHighlight, plugBoard;
local lmpCoords, btnCoords, plgCoords = {}, {}, {};
local letterLayout = {
    {"Q", "W", "E", "R", "T", "Z", "U", "I", "O"},
    {"A", "S", "D", "F", "G", "H", "J", "K"},
    {"P", "Y", "X", "C", "V", "B", "N", "M", "L"},
};
local messageIn, messageOut = "", "";
local rotorPositions;
local printFont, boardFont, boardFontBold;

local rotorSel, lA, lB = false;
local newRotors, newPositions = {}, {};

local preset = require "rotorPresets";
local enigma = require "enigma";
local tools = require "tools";

local enMachine = enigma.create({preset.getPreset("I"), preset.getPreset("II"), preset.getPreset("III")}, preset.getPreset("B"));


local function updateRotors()
    enigma.setRotor(enMachine, 1, preset.getPreset(newRotors[1]));
    enigma.setRotor(enMachine, 2, preset.getPreset(newRotors[2]));
    enigma.setRotor(enMachine, 3, preset.getPreset(newRotors[3]));
    enigma.setPosition(enMachine, {newPositions[1], newPositions[2], newPositions[3]});
end;

local function drawBackground()

    local x, y = bg:getDimensions();

    love.graphics.setColor(1,1,1);
    love.graphics.draw(bg, Width/2, Height/2, 0, sx, sy, x/2, y/2);

end;

local function drawText()

    love.graphics.setFont( printFont );
    love.graphics.setColor(0, 0, 0);

    love.graphics.printf(messageIn, sx*105, sy*513, sx*625);
    love.graphics.printf(messageOut, sx*1859, sy*513, sx*625);

end;

local function drawRotors()

    love.graphics.setFont( boardFont );
    love.graphics.setColor(0, 0, 0);

    for i = 1, #rotorPositions do
        love.graphics.printf(rotorPositions[i], sx*(1182 + 85*(i-1)), sy*434, sx*25, "center");
    end;

end;

local function drawRotorMenu()

    local positionString = string.format("POSITIONS:\t%s\t%s\t%s", newPositions[1], newPositions[2], newPositions[3]);
    local rotorString = string.format("ROTORS:\t%s\t%s\t%s", newRotors[1], newRotors[2], newRotors[3]);

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Width, Height)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", Width/2-(mWidth/2), Height/2-(mHeight/2), mWidth, mHeight)

    love.graphics.setColor(0, 0, 0);

    love.graphics.printf(rotorString, Width/2-(mWidth/2), Height/2-(mHeight/3), mWidth,"center")
    love.graphics.printf(positionString, Width/2-(mWidth/2), Height/2-(mHeight/4), mWidth,"center")

end;


function love.load ()
    love.window.setMode(Width, Height, {msaa=16});
    love.window.setTitle("Enigma");
    love.graphics.setBackgroundColor(0,0,0);

    bg = love.graphics.newImage("images/Enigma_PUC.png");
    btnLmpAtlas = love.graphics.newImage("images/thumbs_enigma.png");

    sx = Width / bg:getWidth();
    sy = Height / bg:getHeight();

    love.graphics.setLineWidth(3);
    mWidth, mHeight = 1000*sx, 700*sy;

    printFont = love.graphics.newFont("fonts/Kingthings Trypewriter 2.ttf", 24*sx);
    boardFont = love.graphics.newFont("fonts/LiberationMono-Regular.ttf", 24*sx);
    boardFontBold = love.graphics.newFont("fonts/LiberationMono-Bold.ttf", 24*sx);

    lmpQuad = love.graphics.newQuad(19, 30, 46, 46, btnLmpAtlas:getDimensions());
    btnQuad = love.graphics.newQuad(112, 32, 47, 47, btnLmpAtlas:getDimensions());

    local xo, yo = 884, 584;
    for lNum, line in ipairs(letterLayout) do
        local x;
        if lNum == 2 then x = xo + 46; else x = xo; end;
        for cNum, letter in ipairs(line) do
            lmpCoords[letter] = {x = x*sx, y = yo*sy};
            btnCoords[letter] = {x = x*sx, y = (yo + 254)*sy};
            plgCoords[letter] = {x = (x+30- ((cNum-1) * 1.75))*sx, y = (yo + 596)*sy};
            x = x + 91.5;
        end;
        yo = yo + 64;
    end;

    rotorPositions = {};

end;

function love.update(dt)

    for i = 1, #enMachine.rotors do
        rotorPositions[i] = enigma.getRotorPos(enMachine, i);
    end;

    plugBoard = enigma.getPlugboard(enMachine);

end;

function love.textinput(t)

    if not rotorSel then
        messageIn = messageIn .. t:upper();
        messageOut = messageOut .. tools.toString( enigma.encode(enMachine, tools.toCharArray(t:upper())) );

        if t:match("%a") then letterHighlight = {messageIn:sub(-1), messageOut:sub(-1)}; else letterHighlight = false; end;

        if #messageOut > 4 and (#messageOut+1) % 6 == 0 then
            messageOut = messageOut .. " ";
        end;
    end;

end;

function love.mousepressed( x, y, button )

    if button == 1 then
        if not rotorSel and x > 1159*sx and x < 1159*sx + 239*sx and y > 365*sy and y < 365*sy + 195*sy then
            lA, lB = nil, nil;
            newRotors = { enigma.getRotor(enMachine, 1), enigma.getRotor(enMachine, 2), enigma.getRotor(enMachine, 3) };
            newPositions = rotorPositions;
            rotorSel = true;
        elseif rotorSel and (x < Width/2-(mWidth/2) or y < Height/2-(mHeight/2) or x > Width/2-(mWidth/2) + mWidth or y > Height/2-(mHeight/2) + mHeight) then
            updateRotors();
            rotorSel = false;
        end;

        if not rotorSel and not lA then

            for _, letter in pairs(plugBoard) do
                local d = math.sqrt( (x-plgCoords[letter].x )^2 + (y-plgCoords[letter].y)^2 );

                if d <= 25*sx  then
                    lA = letter;
                    break;
                end;

            end;

        elseif not rotorSel then

            for _, letter in pairs(plugBoard) do
                local d = math.sqrt( (x-plgCoords[letter].x )^2 + (y-plgCoords[letter].y)^2 );

                if d <= 25*sx  then
                    lB = letter;
                    break;
                end;

            end;

            if lB then
                enigma.createPlug(enMachine, { {lA, lB} });
            end;

            lA, lB = nil, nil
        end;

    elseif lA then
        lA, lB = nil, nil;
    end;

end;

function love.keypressed(key)

    if rotorSel and key == "escape" then
        updateRotors();
        rotorSel = false;
    end;

end;

function love.draw ()

    drawBackground();
    drawText();
    drawRotors();

    love.graphics.setColor(1,1,1);

    if letterHighlight then
        love.graphics.draw(btnLmpAtlas, lmpQuad, lmpCoords[letterHighlight[2]].x, lmpCoords[letterHighlight[2]].y, 0, sx, sy, 0);
        love.graphics.draw(btnLmpAtlas, btnQuad, btnCoords[letterHighlight[1]].x, btnCoords[letterHighlight[1]].y, 0, sx, sy, 0);
    end;

    for i = 65, 90 do
        love.graphics.setColor(1,1,1);
        local letter = string.char(i);

        love.graphics.setFont( boardFontBold );
        love.graphics.printf(letter, lmpCoords[letter].x, lmpCoords[letter].y + (sy*46/4), sx*49, "center");

        love.graphics.setFont( boardFont );
        love.graphics.printf(letter, btnCoords[letter].x, btnCoords[letter].y + (sy*46/4), sx*49, "center");
        love.graphics.printf(letter, plgCoords[letter].x, plgCoords[letter].y + (sy*50/4), sx*50, "center");

        love.graphics.setColor(0, 0, 0);
        love.graphics.line(plgCoords[letter].x, plgCoords[letter].y, plgCoords[ plugBoard[letter] ].x, plgCoords[ plugBoard[letter] ].y);

    end;

    if lA then
        local xm, ym = love.mouse.getPosition();
        love.graphics.line( plgCoords[lA].x, plgCoords[lA].y, xm, ym);
    end;

    if rotorSel then
        drawRotorMenu();
    end;

end;