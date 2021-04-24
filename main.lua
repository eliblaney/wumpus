require "cave"

function love.load()
	love.window.setMode(808, 800, nil)
	love.window.setTitle('Hunt the Wumpus')

	caveImg = love.graphics.newImage("images/cave.png")

	player = {}
	player.img = love.graphics.newImage("images/character.png")
	player.x = 300
	player.y = 550
	player.scale = 0.5
	player.speed = 300
	player.canMove = true
	player.grenades = 3 --FIX THIS
	player.statusMessage = "Welcome to Hunt the Wumpus"

	scene = {}
	scene.minX = 200
	scene.maxX = 600
	scene.minZ = 0.3
	scene.maxZ = 0.7
	scene.dim = 0
	scene.cave = caves[0]
	
-- 	sound = love.audio.newSource("music.ogg", "stream")
-- love.audio.play(sound)
end

function love.update(dt)
	-- detect which cave to go to (if necessary)
	caveDir = -1
	if player.x <= scene.minX then caveDir = 0 end
	if player.x >= scene.maxX then caveDir = 1 end
	if player.scale <= scene.minZ then caveDir = 2 end
	if player.scale >= scene.maxZ then caveDir = 3 end
	if caveDir > -1 or scene.dim < 0 then
		player.canMove = false
		scene.dim = scene.dim + 0.05
	end

	if scene.dim >= 1 then
		-- change cave in complete darkness
		scene.dim = -1
		player.x = 300
		player.y = 550
		player.scale = 0.5
		-- TODO: Change cave
		-- play appropriate sounds
	end
	if scene.dim >= -0.1 and scene.dim < 0 then
		-- allow player mobility
		player.canMove = true
		scene.dim = 0
	end

	-- movement
	if player.canMove then
		if love.keyboard.isDown("left") then
			player.x = player.x - player.speed*dt
		elseif love.keyboard.isDown("right") then
			player.x = player.x + player.speed*dt
		elseif love.keyboard.isDown("up") then
			player.scale = player.scale - player.speed*dt/200
		elseif love.keyboard.isDown("down") then
			player.scale = player.scale + player.speed*dt/200
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
	love.graphics.setColor(0, 0, 0, math.abs(scene.dim))
	love.graphics.rectangle('fill', 0, 0, 808, 800)
end

function toss(tunnel) 
	hitFlag = false
	if (player.grenades > 0) then
		player.grenades = player.grenades-1
		caveNum = scene.cave.getNeighborDownTunnel(tunnel)

		if (scene.cave.contents == "wumpus") then
			scene.cave.contents = "empty"
			wumpusCount = wumpusCount-1
			hitFlag = true
			-- play nice sound
		end

		tossedCave = caves[caveNum]
		for i=1, tossedCave:getNumAdjacentCaves(), 1 do 
			adjCaveNum = tossedCave.getNeighborDownTunnel(i)
			adjCave = caves[adjCaveNum]

			if (adjCaveNum.contents == "wumpus") then
				repeat
					wumpusCave = adjCave.adj[math.random(adjCave.getNumAdjacentCaves)]
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
			player.statusMessage = "You stunned and captured a wumpus!"
		else 
			player.statusMessage = "The stun grenade missed."
		end
	end
	player.statusMessage = "You have no stun grenades to throw!"
end
