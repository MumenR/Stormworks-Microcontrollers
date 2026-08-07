
require([[_build._buildactions]])
--- @diagnostic disable: undefined-global

require("LifeBoatAPI.Tools.Build.Builder")

-- replace newlines
for k,v in pairs(arg) do
    arg[k] = v:gsub("##LBNEWLINE##", "\n")
end

local luaDocsAddonPath  = LifeBoatAPI.Tools.Filepath:new(arg[1]);
local luaDocsMCPath     = LifeBoatAPI.Tools.Filepath:new(arg[2]);
local outputDir         = LifeBoatAPI.Tools.Filepath:new(arg[3]);
local params            = {
    boilerPlate             = arg[4],
    reduceAllWhitespace     = arg[5] == "true",
    reduceNewlines          = arg[6] == "true",
    removeRedundancies      = arg[7] == "true",
    shortenVariables        = arg[8] == "true",
    shortenGlobals          = arg[9] == "true",
    shortenNumbers          = arg[10]== "true",
    forceNCBoilerplate      = arg[11]== "true",
    forceBoilerplate        = arg[12]== "true",
    shortenStringDuplicates = arg[13]== "true",
    removeComments          = arg[14]== "true",
    skipCombinedFileOutput  = arg[15]== "true"
};
local rootDirs          = {};

for i=15, #arg do
    table.insert(rootDirs, LifeBoatAPI.Tools.Filepath:new(arg[i]));
end

local _builder = LifeBoatAPI.Tools.Builder:new(rootDirs, outputDir, luaDocsMCPath, luaDocsAddonPath)

if onLBBuildStarted then onLBBuildStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]])) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[timing.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\timing.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[timing.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\timing.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[timing.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\timing.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[pivot.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\pivot.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[pivot.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\pivot.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[pivot.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\pivot.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[Main.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\Main.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[Main.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\Main.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[Main.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\Main.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[firstR.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\firstR.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[firstR.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\firstR.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[firstR.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\firstR.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[firstL.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\firstL.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[firstL.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\firstL.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]]), [[firstL.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7\firstL.lua]]), outFile, combinedText, outText) end

if onLBBuildComplete then onLBBuildComplete(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 7]])) end
--- @diagnostic enable: undefined-global
