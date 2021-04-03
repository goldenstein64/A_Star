local function index2d(self, x, y)
	local dim = self[x]
	return dim and dim[y]
end

local function destroyWall(maze, position)
	local nextWall = index2d(maze.Walls, position.X, position.Y)
	if nextWall then
		nextWall:Destroy()
	end
end

local function makeNeighbor(maze, node, other, distance)
	local wallIndex = (node.Position + other.Position) / 2
	destroyWall(maze, wallIndex)

	node.Neighbors[other] = distance
	other.Neighbors[node] = distance
end

local possibleNeighbors = {
	Vector2.new(1, 0),
	Vector2.new(0, 1),
	Vector2.new(-1, 0),
	Vector2.new(0, -1),
}

local R = Random.new()

local function getNeighbors(maze, position, isOpen)
	local neighbors = {}

	for _, offset in ipairs(possibleNeighbors) do
		local newIndex = position + offset
		local neighbor = index2d(maze.Nodes, newIndex.X, newIndex.Y)
		if neighbor and (isOpen == nil or neighbor.IsOpen == isOpen) then
			table.insert(neighbors, {
				Node = neighbor,
				Distance = offset.Magnitude,
			})
		end
	end

	return neighbors
end

local function findNewNode(maze)
	local openArray = {}
	for node in pairs(maze.Open) do
		table.insert(openArray, node)
	end

	while #openArray > 0 do
		local pickedNode = table.remove(openArray, R:NextInteger(1, #openArray))

		local neighbors = getNeighbors(maze, pickedNode.Position, false)

		if #neighbors > 0 then
			local dict = neighbors[R:NextInteger(1, #neighbors)]

			makeNeighbor(maze, pickedNode, dict.Node, dict.Distance)

			return pickedNode
		end
	end
end

local function HuntAndKill(maze)
	local currentNode
	do
		local nodeArray = {}
		for node in pairs(maze.Open) do
			table.insert(nodeArray, node)
		end

		currentNode = nodeArray[R:NextInteger(1, #nodeArray)]
	end

	while currentNode do
		currentNode.IsOpen = false
		maze.Open[currentNode] = nil

		local neighbors = getNeighbors(maze, currentNode.Position, true)
		if #neighbors > 0 then
			local dict = neighbors[R:NextInteger(1, #neighbors)]
			makeNeighbor(maze, currentNode, dict.Node, dict.Distance)
			currentNode = dict.Node
		else
			currentNode = findNewNode(maze)
		end
	end
end

return HuntAndKill
