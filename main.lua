
function love.load()
	love.window.setMode(808, 800, nil)
	love.window.setTitle('Hunt the Wumpus')

	caveImg = love.graphics.newImage("images/cave.png")
	playerImg = love.graphics.newImage("images/character.png")
	
-- 	sound = love.audio.newSource("music.ogg", "stream")
-- love.audio.play(sound)
end

function love.draw()
	love.graphics.print("Hello World!", 400, 300)
	love.graphics.draw(caveImg, 0, 0)
	love.graphics.draw(playerImg, 300, 300, 0, 0.5, 0.5)
end

