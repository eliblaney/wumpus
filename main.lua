require "cave"

function love.load()
	config = {}
	config.maxWumpi = 3
	config.maxPits = 1
	config.maxBats = 1
	config.width = 800
	config.height = 800
	config.title = "Hunt the Wumpus"

	love.window.setMode(config.width, config.height, nil)
	love.window.setTitle(config.title)

	caveImg = love.graphics.newImage("images/cave.png")

	player = {}
	player.img = love.graphics.newImage("images/character.png")
	player.x = 500
	player.y = 650
	player.scale = 0.9
	player.speed = 300
	player.canMove = true
	player.alive = true
	player.statusMessage = ""
	player.grenadeReady = false

	caveImg:setFilter("nearest", "nearest")
	player.img:setFilter("nearest", "nearest")

	scene = {}
	scene.minX = 200
	scene.maxX = 800
	scene.minZ = 0.6
	scene.maxZ = 1.2
	scene.dim = 0
	scene.cave = caves[0]
	scene.cave:markAsVisited()

	math.randomseed(os.time())
	numWumpi = math.random(config.maxWumpi)
	player.grenades = 3 * numWumpi
	for i=1,numWumpi do
		repeat
			wumpusCave = caves[math.random(#caves) - 1]
		until wumpusCave.contents == "empty"
		wumpusCave.contents = "wumpus"
	end

	numPits = math.random(config.maxPits)
	for i=1,numPits do
		repeat
			pitCave = caves[math.random(#caves) - 1]
		until pitCave.contents == "empty"
		pitCave.contents = "pit"
	end

	numBats = math.random(config.maxBats)
	for i=1,numBats do
		repeat
			batsCave = caves[math.random(#caves) - 1]
		until batsCave.contents == "empty"
		batsCave.contents = "bats"
	end
	
	sounds = {}
	sounds.music = love.audio.newSource("sounds/music.mp3", "stream")
	sounds.bats = love.audio.newSource("sounds/bats.mp3", "stream")
	sounds.wumpus = love.audio.newSource("sounds/wumpus.mp3", "stream")
	sounds.death = love.audio.newSource("sounds/death.mp3", "stream")
	sounds.hit = love.audio.newSource("sounds/hit.wav", "stream")
	sounds.win = love.audio.newSource("sounds/win.wav", "stream")
	sounds.music:setLooping(true)
	sounds.music:play()
	sounds.flapping = love.audio.newSource("sounds/flapping.wav", "stream")

	font = love.graphics.newFont("fonts/Roboto-Regular.ttf", 24)

	checkAdjCaveContents()
end

function love.update(dt)
	-- detect which cave to go to (if necessary)
	caveDir = -1
	if player.x <= scene.minX then caveDir = 0 end
	if player.x >= scene.maxX then caveDir = 1 end
	if player.scale <= scene.minZ then caveDir = 2 end
	if player.scale >= scene.maxZ and #scene.cave.adj > 3 then caveDir = 3 end
	if caveDir > -1 or scene.dim < 0 or not player.alive then
		player.canMove = false
		scene.dim = scene.dim + 0.05
	end

	if scene.dim >= 1 and player.alive then
		-- change cave in complete darkness
		scene.dim = -1
		player.x = 500
		player.y = 650
		player.scale = 0.9
		player.speed = 300
		player.grenadeReady = false
		scene.cave = caves[scene.cave.adj[caveDir+1]]
		scene.cave:markAsVisited()
		if scene.cave.contents == "wumpus" then
			player.alive = false
			player.statusMessage = "A wumpus kills you!"
			sounds.death:play()
		elseif scene.cave.contents == "pit" then
			player.alive = false
			player.statusMessage = "You fell into a pit and died!"
			sounds.death:play()
		elseif scene.cave.contents == "bats" then
			-- move to random empty cave
			scene.shake = 1000
			repeat
				scene.cave = caves[math.random(#caves) - 1]
			until scene.cave.contents == "empty"
			scene.cave:markAsVisited()
			checkAdjCaveContents()
			sounds.bats:play()
			player.statusMessage = player.statusMessage
					.. "You were picked up in a whirlwind of bats!"
		
		else checkAdjCaveContents()
		end
	end
	if scene.dim >= -0.1 and scene.dim < 0 and player.alive then
		-- allow player mobility
		player.canMove = true
		scene.dim = 0
	end

	-- attack and movement
	if player.canMove and player.alive then
		if player.grenadeReady then
			if love.keyboard.isDown("left") then
				toss(1)
				player.grenadeReady = false
			elseif love.keyboard.isDown("right") then
				toss(2)
				player.grenadeReady = false
			elseif love.keyboard.isDown("up") then
				toss(3)
				player.grenadeReady = false
			elseif love.keyboard.isDown("down") then
				toss(4)
				player.grenadeReady = false
			elseif love.keyboard.isDown("escape") then
				player.statusMessage = "You lower your bow."
				player.grenadeReady = false
			end
		else
			if love.keyboard.isDown("left") then
				player.x = player.x - player.speed*dt
			elseif love.keyboard.isDown("right") then
				player.x = player.x + player.speed*dt
			elseif love.keyboard.isDown("up") then
				player.scale = player.scale - player.speed*dt/200
			elseif love.keyboard.isDown("down")
				and #scene.cave.adj > 3
				and player.scale < scene.maxZ
				then
					player.scale = player.scale + player.speed*dt/200
			elseif love.keyboard.isDown("g") then
				if player.grenades > 0 then
					player.grenadeReady = true
					player.statusMessage = "You hold up your bow."
				else 
					player.statusMessage = "You have no arrows left!"
				end
			end
		end
	end
end

function checkAdjCaveContents()
	player.statusMessage = ""
	for i=1,#scene.cave.adj do
		if caves[scene.cave.adj[i]].contents == "wumpus" then
			player.statusMessage = player.statusMessage
			.. "You smell the smelly stench of a Wumpus.\n"
			sounds.wumpus:play()
		end
		if caves[scene.cave.adj[i]].contents == "pit" then
			player.statusMessage = player.statusMessage
			.. "Nearby wind makes you feel chilly.\n"
		end
		if caves[scene.cave.adj[i]].contents == "bats" then
			player.statusMessage = player.statusMessage
			.. "What's that flapping of wings nearby?\n"
			sounds.flapping:play()
		end
	end
end

function love.draw()
	-- cave & player models
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(caveImg, 0, 0)
	love.graphics.draw(player.img, player.x, player.y, 0, player.scale, player.scale, 250, 350)

	-- cave name and status message
	love.graphics.setColor(0, 0, 0, 1)
	caveText = love.graphics.newText(font, scene.cave.name)
	love.graphics.draw(caveText, 25, 25, 0, 0.75, 0.85)
	statusText = love.graphics.newText(font, player.statusMessage)
	love.graphics.draw(statusText, 25, 50, 0, 0.75, 0.85)

	-- adjacent cave names
	left   = love.graphics.newText(font, caves[scene.cave.adj[1]]:getName())
	right  = love.graphics.newText(font, caves[scene.cave.adj[2]]:getName())
	top    = love.graphics.newText(font, caves[scene.cave.adj[3]]:getName())
	if (#scene.cave.adj >3) then
		bottom = love.graphics.newText(font, caves[scene.cave.adj[4]]:getName())
	end
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle('fill', 20, 395, left:getWidth() + 10, left:getHeight() + 10)
	love.graphics.rectangle('fill', 600, 395, right:getWidth() + 10, right:getHeight() + 10)
	love.graphics.rectangle('fill', 345, 195, top:getWidth() + 10, top:getHeight() + 10)
	if (#scene.cave.adj >3) then
		love.graphics.rectangle('fill', 395, 695, bottom:getWidth() + 10, bottom:getHeight() + 10)
	end
	love.graphics.setColor(1, 1, 1, 0.8)
	love.graphics.draw(left, 25, 400, 0)
	love.graphics.draw(right, 605, 400, 0)
	love.graphics.draw(top, 350, 200, 0)
	if (#scene.cave.adj >3) then
		love.graphics.draw(bottom, 400, 700, 0)
	end

	-- dim overlay
	love.graphics.setColor(0, 0, 0, math.abs(scene.dim))
	love.graphics.rectangle('fill', 0, 0, 808, 800)

	-- death screen
	if not player.alive then
		if numWumpi <= 0 then
			love.graphics.setColor(0, 1, 0, math.abs(scene.dim))
			if player.statusMessage == nil then
				player.statusMessage = "YOU WIN!"
			end
		else
			love.graphics.setColor(1, 0, 0, math.abs(scene.dim))
			if player.statusMessage == nil then
				player.statusMessage = "YOU DIED!"
			end
		end
		scale = 3*9 / #player.statusMessage
		endText = love.graphics.newText(font, player.statusMessage)
		love.graphics.draw(endText, 250, 300, 0, scale, scale)
	end
end

function toss(tunnel) 
	if player.grenades > 0 then
		player.grenades = player.grenades-1
		caveNum = scene.cave:getNeighborDownTunnel(tunnel)

		if caves[caveNum].contents == "wumpus" then
			caves[caveNum].contents = "empty"
			player.statusMessage = "You hit and captured a wumpus!"
			numWumpi = numWumpi - 1
			if numWumpi <= 0 then
				player.statusMessage = "YOU WIN!"
				player.alive = false
				sounds.win:play()
			else
				sounds.hit:play()
			end
		else
			player.statusMessage = "The arrow misses."
			tossedCave = caves[caveNum]
			for i=1,tossedCave:getNumAdjCaves() do 
				adjCaveNum = tossedCave:getNeighborDownTunnel(i)
				adjCave = caves[adjCaveNum]

				if adjCave.contents == "wumpus" then
					repeat
						wumpusCave = caves[adjCave.adj[math.random(adjCave:getNumAdjCaves())]]
					until wumpusCave.contents == "empty"
					player.statusMessage = "The arrow misses and you scared off the wumpus."
					if (wumpusCave == scene.cave) then
						player.statusMessage = "A wumpus moved into your cave!"
						player.alive = false
						sounds.death:play()
					end
					wumpusCave.contents = "wumpus"
					adjCave.contents = "empty"
				end

			end
		end
	else
		player.statusMessage = "You have no arrows left!"
	end
end
