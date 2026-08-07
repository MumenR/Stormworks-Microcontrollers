
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

if onLBBuildStarted then onLBBuildStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]])) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[EIL2.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\EIL2.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[EIL2.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\EIL2.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[EIL2.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\EIL2.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[second_MTX1.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\second_MTX1.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[second_MTX1.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\second_MTX1.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[second_MTX1.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\second_MTX1.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[IFF.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\IFF.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[IFF.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\IFF.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[IFF.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\IFF.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[first.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\first.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[first.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\first.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[first.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\first.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[select.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\select.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[select.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\select.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[select.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\select.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[second_SRD3.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\second_SRD3.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[second_SRD3.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\second_SRD3.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[second_SRD3.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\second_SRD3.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[timing.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\timing.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[timing.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\timing.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]]), [[timing.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6\timing.lua]]), outFile, combinedText, outText) end

if onLBBuildComplete then onLBBuildComplete(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\FCS Type 6]])) end
--- @diagnostic enable: undefined-global
