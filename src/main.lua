local preset = require "rotorPresets";                      -- Imports
local enigma = require "enigma";
local tools = require "tools";

local Width, Height, sx, sy = 1538, 864;                    -- WidthxHeight e escalas

local bg, btnLmpAtlas, btnQuad, lmpQuad, letterHighlight;   -- Objetos gráficos
local printFont, boardFont, boardFontBold;                  -- Fontes
local lmpCoords, btnCoords, plgCoords = {}, {}, {};
local letterLayout = {                                      -- Layout do teclado (QWERTZ)
    {"Q", "W", "E", "R", "T", "Z", "U", "I", "O"},
    {"A", "S", "D", "F", "G", "H", "J", "K"},
    {"P", "Y", "X", "C", "V", "B", "N", "M", "L"},
};
local messageIn, messageOut = "", "";                       -- Input e output principais
local rotorPositions, plugBoard = {};                       -- Posições dos rotores e estado do plugboard

local lA, lB;                                               -- Letras de novas conexões do plugboard

-- Criação do objeto Enigma
local enMachine = enigma.create({preset.getPreset("I"), preset.getPreset("II"), preset.getPreset("III")}, preset.getPreset("B"));


local function drawBackground()     -- Desenha a imagem de fundo, de acordo com a escala

    local x, y = bg:getDimensions();

    love.graphics.setColor(1,1,1);
    love.graphics.draw(bg, Width/2, Height/2, 0, sx, sy, x/2, y/2);

end;

local function drawText()           -- Desenha o texto dos dois cadernos

    love.graphics.setFont( printFont );
    love.graphics.setColor(0, 0, 0);

    love.graphics.printf(messageIn, sx*105, sy*513, sx*625);
    love.graphics.printf(messageOut, sx*1859, sy*513, sx*625);

end;

local function drawRotors()         -- Desenha as posições dos rotores

    love.graphics.setFont( boardFont );
    love.graphics.setColor(0, 0, 0);

    for i = 1, #rotorPositions do
        love.graphics.printf(rotorPositions[i], sx*(1182 + 85*(i-1)), sy*434, sx*25, "center");
    end;

end;


function love.load ()
    love.window.setMode(Width, Height, {msaa=16});
    love.window.setTitle("Enigma");
    love.graphics.setBackgroundColor(0,0,0);

    bg = love.graphics.newImage("images/Enigma_PUC.png");
    btnLmpAtlas = love.graphics.newImage("images/thumbs_enigma.png");

    sx = Width / bg:getWidth();     -- Calculo das escalas
    sy = Height / bg:getHeight();

    love.graphics.setLineWidth(3);

    printFont = love.graphics.newFont("fonts/Kingthings Trypewriter 2.ttf", 24*sx);
    boardFont = love.graphics.newFont("fonts/LiberationMono-Regular.ttf", 24*sx);
    boardFontBold = love.graphics.newFont("fonts/LiberationMono-Bold.ttf", 24*sx);

    lmpQuad = love.graphics.newQuad(19, 30, 46, 46, btnLmpAtlas:getDimensions());
    btnQuad = love.graphics.newQuad(112, 32, 47, 47, btnLmpAtlas:getDimensions());

    -- Calculo das coordenadas de todos os botões, lampadas e conexões do plugboard de acordo com a escala
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

end;

function love.update(dt)

    -- Pega a posição dos rotores e conexões do plugboard mais atualizadas

    for i = 1, #enMachine.rotors do
        rotorPositions[i] = enigma.getRotorPos(enMachine, i);
    end;

    plugBoard = enigma.getPlugboard(enMachine);

end;

function love.textinput(t)

    -- Recebe input do usuário e o codifica

    messageIn = messageIn .. t:upper();
    messageOut = messageOut .. tools.toString( enigma.encode(enMachine, tools.toCharArray(t:upper())) );

    -- Se o input for válido, as coordenadas da tecla apertada (no teclado virtual) e da letra codificada no lampboard são guardadas,
    -- se não, letterHighlight é definido como false

    if t:match("%a") then letterHighlight = {messageIn:sub(-1), messageOut:sub(-1)}; else letterHighlight = false; end;

    -- Quebra o output em grupos de 5 letras

    if #messageOut > 4 and (#messageOut+1) % 6 == 0 then
        messageOut = messageOut .. " ";
    end;

end;

function love.mousepressed( x, y, button )

    if button == 1 then

        if not lA then                              -- Checa se uma primeira letra já foi selecionada

            for _, letter in pairs(plugBoard) do    -- Checa se o click foi feito numa posição válida do plugboard
                local d = math.sqrt( (x-plgCoords[letter].x )^2 + (y-plgCoords[letter].y)^2 );

                if d <= 25*sx  then
                    lA = letter;
                    break;
                end;

            end;

        else

            for _, letter in pairs(plugBoard) do    -- Caso uma primeira letra já foi selecionada, checa se o click foi valido para selecionar a segunda
                local d = math.sqrt( (x-plgCoords[letter].x )^2 + (y-plgCoords[letter].y)^2 );

                if d <= 25*sx  then
                    lB = letter;
                    break;
                end;

            end;

            if lB then                              -- Cria uma conexão do Plugboard caso duas letras válidas forem selecionadas e depois limpa as seleções
                enigma.createPlug(enMachine, { {lA, lB} });
            end;

            lA, lB = nil, nil
        end;

    elseif lA then                                  -- Caso segundo click invalido, anula seleção
        lA, lB = nil, nil;
    end;

end;

function love.draw ()

    drawBackground();               -- Chama funções de desenho pre-criadas
    drawText();
    drawRotors();

    love.graphics.setColor(1,1,1);

    if letterHighlight then         -- Caso existam letras selecionadas, desenha o highlight nas coordenadas
        love.graphics.draw(btnLmpAtlas, lmpQuad, lmpCoords[letterHighlight[2]].x, lmpCoords[letterHighlight[2]].y, 0, sx, sy, 0);
        love.graphics.draw(btnLmpAtlas, btnQuad, btnCoords[letterHighlight[1]].x, btnCoords[letterHighlight[1]].y, 0, sx, sy, 0);
    end;

    for i = 65, 90 do               -- Imprime as letras no lampboard, teclado e plugboard e suas conexões
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

    if lA then                      -- Se existir uma primeira letra selecionada, desenha uma linha até o mouse
        local xm, ym = love.mouse.getPosition();
        love.graphics.line( plgCoords[lA].x, plgCoords[lA].y, xm, ym);
    end;

end;