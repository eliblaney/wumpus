require "cave"

function love.load()
	config = {}
	config.maxWumpi = 3
	config.maxPits = 1
	config.maxBats = 1
	config.width = 808
	config.height = 800
	config.title = "Hunt the Wumpus"

	love.window.setMode(config.width, config.height, nil)
	love.window.setTitle(config.title)

	caveImg = love.graphics.newImage("images/cave.png")

	player = {}
	player.img = love.graphics.newImage("images/character.png")
	player.x = 300
	player.y = 550
	player.scale = 0.5
	player.speed = 300
	player.canMove = true
	player.alive = true
	player.statusMessage = ""
	player.grenadeReady = false

	scene = {}
	scene.minX = 200
	scene.maxX = 600
	scene.minZ = 0.3
	scene.maxZ = 0.7
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

	checkAdjCaveContents()
	
-- 	sound = love.audio.newSource("music.ogg", "stream")
-- love.audio.play(sound)
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
		player.x = 300
		player.y = 550
		player.scale = 0.5
		player.grenadeReady = false
		scene.cave = caves[scene.cave.adj[caveDir+1]]
		scene.cave:markAsVisited()
		if scene.cave.contents == "wumpus" then
			player.alive = false
			player.statusMessage = "YOU DIED!"
			-- play dead sound
		elseif scene.cave.contents == "pit" then
			player.alive = false
			player.statusMessage = "YOU DIED!"
		elseif scene.cave.contents == "bats" then
			-- move to random empty cave
			scene.shake = 1000
			repeat
				scene.cave = caves[#caves - 1]
			until scene.cave.contents == "empty"
			scene.cave:markAsVisited()
			checkAdjCaveContents()
			player.statusMessage = player.statusMessage
					.. "You were picked up in a whirlwind of bats!"
		else
			checkAdjCaveContents()
		end
		-- play appropriate sounds
	end
	if scene.dim >= -0.1 and scene.dim < 0 and player.alive then
		-- allow player mobility
		player.canMove = true
		scene.dim = 0
	end

	-- movement
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
		end
		if caves[scene.cave.adj[i]].contents == "pit" then
			player.statusMessage = player.statusMessage
			.. "Nearby wind makes you feel chilly.\n"
		end
		if caves[scene.cave.adj[i]].contents == "bats" then
			player.statusMessage = player.statusMessage
			.. "What's that flapping of wings nearby?\n"
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(caveImg, 0, 0)
	love.graphics.draw(player.img, player.x, player.y, 0, player.scale, player.scale, 250, 450)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print(scene.cave.name, 25, 25, 0, 1.5, 1.5)
	love.graphics.print(player.statusMessage, 25, 50, 0, 1.5, 1.5)

	--adjacent caves
	--left
	love.graphics.print(caves[scene.cave.adj[1]]:getName(), 25, 400, 0, 1.5, 1.5)
	--right
	love.graphics.print(caves[scene.cave.adj[2]]:getName(), 620, 400, 0, 1.5, 1.5)
	--top
	love.graphics.print(caves[scene.cave.adj[3]]:getName(), 350, 200, 0, 1.5, 1.5)
	if (#scene.cave.adj >3) then
		love.graphics.print(caves[scene.cave.adj[4]]:getName(), 400, 700, 0, 1.5, 1.5)
	end



	love.graphics.setColor(0, 0, 0, math.abs(scene.dim))
	love.graphics.rectangle('fill', 0, 0, 808, 800)




	-- for k,v in pairs(cave.adj) do
	-- 	love.graphics.print(v.getName(), 25, 25, 0, 1.5, 1.5)
	-- end

	if not player.alive then
		love.graphics.setColor(1, 0, 0, math.abs(scene.dim))
		love.graphics.print(player.statusMessage, 250, 300, 0, 5, 5)
	end
end

function toss(tunnel) 
	hitFlag = false
	if (player.grenades > 0) then
		player.grenades = player.grenades-1
		caveNum = scene.cave:getNeighborDownTunnel(tunnel)

		if (scene.cave.contents == "wumpus") then
			scene.cave.contents = "empty"
			wumpusCount = wumpusCount-1
			hitFlag = true
			-- play nice sound
		end

		tossedCave = caves[caveNum]
		for i=1,tossedCave:getNumAdjCaves() do 
			adjCaveNum = tossedCave:getNeighborDownTunnel(i)
			adjCave = caves[adjCaveNum]

			if adjCave.contents == "wumpus" then
				repeat
					wumpusCave = adjCave.adj[math.random(adjCave:getNumAdjCaves())]
				until wumpusCave.contents == "empty"
				if (wumpusCave == scene.cave) then
					player.statusMessage = "A wumpus moved into your cave!"
					-- growling noise
					player.alive = false
				end
				wumpusCave.contents = "wumpus"
				adjCave.contents = "empty"
			end
		end

		if (hitFlag) then
			player.statusMessage = "You hit and captured a wumpus!"
		else 
			player.statusMessage = "The arrow misses and you scared off the wumpus."
		end
	else
		player.statusMessage = "You have no arrows left!"
	end
end
