gameSprites = {}
entitySprites = {}
guiSprites = {}
fontSprites = {}

entitySprites["player"] = video.createSpriteState("player", 'data/entityTiles.dat')
entitySprites["enemy1"] = video.createSpriteState("enemy", 'data/entityTiles.dat')
entitySprites["enemy2"] = video.createSpriteState("enemy2", 'data/entityTiles.dat')

guiSprites["MG_logo"] = video.createSpriteState("MG_logo", 'data/gui.dat')
guiSprites["story1"] = video.createSpriteState("01", 'data/gui.dat')
guiSprites["story2"] = video.createSpriteState("02", 'data/gui.dat')
guiSprites["story3"] = video.createSpriteState("03", 'data/gui.dat')
guiSprites["story4"] = video.createSpriteState("04", 'data/gui.dat')
guiSprites["story5"] = video.createSpriteState("05", 'data/gui.dat')
guiSprites["story6"] = video.createSpriteState("06", 'data/gui.dat')
guiSprites["story7"] = video.createSpriteState("07", 'data/gui.dat')
guiSprites["story8"] = video.createSpriteState("08", 'data/gui.dat')
guiSprites["story9"] = video.createSpriteState("09", 'data/gui.dat')
guiSprites["story10"] = video.createSpriteState("10", 'data/gui.dat')
guiSprites["story11"] = video.createSpriteState("11", 'data/gui.dat')
guiSprites["story12"] = video.createSpriteState("12", 'data/gui.dat')
guiSprites["story13"] = video.createSpriteState("13", 'data/gui.dat')
guiSprites["menu"] = video.createSpriteState("menu", 'data/gui.dat')
guiSprites["end"] = video.createSpriteState("end", 'data/gui.dat')
guiSprites["play"] = video.createSpriteState("play", 'data/gui.dat')
guiSprites["playHover"] = video.createSpriteState("playHover", 'data/gui.dat')
guiSprites["storyOff"] = video.createSpriteState("storyOff", 'data/gui.dat')
guiSprites["storyOffHover"] = video.createSpriteState("storyOffHover", 'data/gui.dat')
guiSprites["storyOn"] = video.createSpriteState("storyOn", 'data/gui.dat')
guiSprites["storyOnHover"] = video.createSpriteState("storyOnHover", 'data/gui.dat')
guiSprites["title"] = video.createSpriteState("title", 'data/gui.dat')
guiSprites["quit"] = video.createSpriteState("quit", 'data/gui.dat')
guiSprites["quitHover"] = video.createSpriteState("quitHover", 'data/gui.dat')

for index=0, 29, 1 do
	gameSprites[index] = video.createSpriteState(index, 'data/basicTiles.dat')
end

local fontNames = {"space", "comma", "dot", "colon", "semicolon", "question", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "!", "(", ")", "'", "-", "+", "_", "="}
for index, name in pairs(fontNames) do
	fontSprites[name] = video.createSpriteState(name, 'data/fixedsys.dat')
end
