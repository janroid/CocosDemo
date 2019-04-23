local SoundManager = {}
local SoundMap = require("SoundMap")

function SoundManager:playMusic(filePath, isLoop)
	if not filePath then return end
	if tonumber(filePath) then
		filePath = SoundMap.musicFileMap[filePath]
	end
	local id = AudioEngine.preloadMusic(filePath)
	AudioEngine.playMusic(filePath, isLoop)
	return id
end

function SoundManager:stopMusic()
	AudioEngine.stopMusic()
end

function SoundManager:pauseMusic()
	SoundManager.isMusicPause = true
	AudioEngine.pauseMusic()
end

function SoundManager:resumeMusic()
	SoundManager.isMusicPause = false
	AudioEngine.resumeMusic()
end

function SoundManager:rewindMusic()
	AudioEngine.rewindMusic()
end

function SoundManager:isMusicPlaying()
	return AudioEngine.isMusicPlaying()
end

function SoundManager:playEffect(filePath, isLoop)
	if not filePath then return end
	if tonumber(filePath) then
		local id = filePath
		filePath = SoundMap.effectFileMap[filePath]
		if not filePath then
			filePath = SoundMap.effectFileMap.WOMEN[id]
		end
	end
	AudioEngine.preloadEffect(filePath)
	return AudioEngine.playEffect(filePath, isLoop)
end

function SoundManager:stopEffect(effectId)
	AudioEngine.stopEffect(effectId)
end

function SoundManager:pauseEffect(effectId)
	AudioEngine.pauseEffect(effectId)
end

function SoundManager:resumeEffect(effectId)
	AudioEngine.resumeEffect(effectId)
end

function SoundManager:pauseAllEffects(effectId)
	AudioEngine.pauseAllEffects(effectId)
end

function SoundManager:stopAllEffects(effectId)
	AudioEngine.stopAllEffects(effectId)
end

function SoundManager:unloadEffect(filePath)
	AudioEngine.unloadEffect(filePath)
end

function SoundManager:setMusicVolume(volume)
	AudioEngine.setMusicVolume(volume)
end

function SoundManager:getMusicVolume()
	return AudioEngine.getMusicVolume()
end

function SoundManager:setEffectsVolume(volume)
	AudioEngine.setEffectsVolume(volume)
end

function SoundManager:getEffectsVolume()
	return AudioEngine.getEffectsVolume()
end

function SoundManager:preloadMusic(filePath)
	if tonumber(filePath) then
		filePath = SoundMap.musicFileMap[filePath]
	end
	return AudioEngine.preloadMusic(filePath)
end

function SoundManager:preloadEffects(fileMap)
	for k, v in ipairs(fileMap) do
		local path = SoundMap.effectFileMap[v]
		self:preloadEffect(v)
	end
end

function SoundManager:preloadEffect(filePath)
	if tonumber(filePath) then
		filePath = SoundMap.effectFileMap[filePath]
	end
	return AudioEngine.preloadEffect(filePath)
end

for _,v in pairs(SoundMap.effectFileMap) do
	if io.exists(v) then
		SoundManager:preloadEffect(v)
	end
end

return SoundManager;