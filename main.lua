num_pipes = 0
-- love.load() is called every time the game restarts
function love.load()

	playingAreaWidth = 300
	playingAreaHeight = 388

	-- bird object with coordinates, speed, and size
	bird = {
		x = 62,
		y = 200,
		ySpeed = 0,
		width = 30,
		height = 25,
	}

	pipeSpaceHeight = 100
	pipeWidth = 54

	-- newPipeSpaceY(): called every time a pipe goes offscreen and a new one enters
	-- Returns a random value on the y-axis where the first pipe will end
	function newPipeSpaceY()
		local pipeSpaceYMin = 54
		local pipeSpaceY = love.math.random(
			pipeSpaceYMin,
			playingAreaHeight - pipeSpaceHeight - pipeSpaceYMin
		)
		return pipeSpaceY
	end

	-- reset(): called at the end of love.load when the player starts the game or dies
	-- initializes pipes and bird
	function reset()
		bird.y = 200
		bird.ySpeed = 0

		pipe1X = playingAreaWidth
		pipe1SpaceY = newPipeSpaceY()

		pipe2X = playingAreaWidth + ((playingAreaWidth + pipeWidth) / 2)
		pipe2SpaceY = newPipeSpaceY()

		score = 0

		upcomingPipe = 1
	end

	reset()
end

-- love.update() is called every time the game logic updates
function love.update(dt)
	bird.ySpeed = bird.ySpeed + (516 * dt)
	bird.y = bird.y + (bird.ySpeed * dt)

	-- movePipe(x, y) updates the position of the pipe
	local function movePipe(pipeX, pipeSpaceY)
		pipeX = pipeX - (60 * dt)

		if (pipeX + pipeWidth) < 0 then
			pipeX = playingAreaWidth
			pipeSpaceY = newPipeSpaceY()
			num_pipes = num_pipes + 1
		end

		return pipeX, pipeSpaceY
	end

	pipe1X, pipe1SpaceY = movePipe(pipe1X, pipe1SpaceY)
	pipe2X, pipe2SpaceY = movePipe(pipe2X, pipe2SpaceY)

	-- isBirdCollidingWithPipe() returns true or false
	function isBirdCollidingWithPipe(pipeX, pipeSpaceY)
		return
		-- Left edge of bird is to the left of the right edge of pipe
		bird.x < (pipeX + pipeWidth)
		and
		 -- Right edge of bird is to the right of the left edge of pipe
		(bird.x + bird.width) > pipeX
		and (
			-- Top edge of bird is above the bottom edge of first pipe segment
			bird.y < pipeSpaceY
			or
			-- Bottom edge of bird is below the top edge of second pipe segment
			(bird.y + bird.height) > (pipeSpaceY + pipeSpaceHeight)
		)
	end

	if isBirdCollidingWithPipe(pipe1X, pipe1SpaceY)
	or isBirdCollidingWithPipe(pipe2X, pipe2SpaceY)
	or bird.y > playingAreaHeight then
		reset()
	end

	local function updateScoreAndClosestPipe(thisPipe, pipeX, otherPipe)
		if upcomingPipe == thisPipe
		and (bird.x > (pipeX + pipeWidth)) then
			score = score + 1
			upcomingPipe = otherPipe
		end
	end

	updateScoreAndClosestPipe(1, pipe1X, 2)
	updateScoreAndClosestPipe(2, pipe2X, 1)
end


-- love.draw() is called every time the display is refreshed
function love.draw()
	love.graphics.setColor(35, 92, 118)
	love.graphics.rectangle('fill', 0, 0, playingAreaWidth, playingAreaHeight)

	love.graphics.setColor(224, 214, 68)
	love.graphics.rectangle('fill', bird.x, bird.y, bird.width, bird.height)

	local function drawPipe(pipeX, pipeSpaceY)
		love.graphics.setColor(94, bird.y, 72)
		-- draw top pipe
		love.graphics.rectangle(
			'fill',
			pipeX,
			0,
			pipeWidth,
			pipeSpaceY
		)
		-- draw bottom pipe
		love.graphics.rectangle(
			'fill',
			pipeX,
			pipeSpaceY + pipeSpaceHeight,
			pipeWidth,
			playingAreaHeight - pipeSpaceY - pipeSpaceHeight
		)
	end

	drawPipe(pipe1X, pipe1SpaceY)
	drawPipe(pipe2X, pipe2SpaceY)

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(score, 15, 15)
end

-- love.keypressed is called whenever ANY key is pressed
function love.keypressed(key)
	if bird.y > 0 then
		bird.ySpeed = -165
	end
end
