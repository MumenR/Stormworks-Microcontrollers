
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

if onLBBuildStarted then onLBBuildStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]])) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test6.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test6.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[test6.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test6.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test6.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test6.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test5.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test5.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[test5.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test5.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test5.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test5.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test4.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test4.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[test4.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test4.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test4.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test4.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test3.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test3.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[test3.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test3.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test3.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test3.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test2.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test2.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[test2.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test2.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test2.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test2.lua]]), outFile, combinedText, outText) end

if onLBBuildFileStarted then onLBBuildFileStarted(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test1.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test1.lua]])) end

local combinedText, outText, outFile = _builder:buildMicrocontroller([[test1.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test1.lua]]), params)
if onLBBuildFileComplete then onLBBuildFileComplete(LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]]), [[test1.lua]], LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test\test1.lua]]), outFile, combinedText, outText) end

if onLBBuildComplete then onLBBuildComplete(_builder, params, LifeBoatAPI.Tools.Filepath:new([[c:\Users\yosuk\OneDrive\Stormworks\Microcontrollers\products\Logic\test]])) end
--- @diagnostic enable: undefined-global
