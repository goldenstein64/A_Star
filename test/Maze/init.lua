local MazeNode = {}
MazeNode.__index = MazeNode

function MazeNode.new(position)
	local self = {
		Position = position,
		IsOpen = nil,
		Neighbors = {},
	}

	setmetatable(self, MazeNode)

	return self
end

local Maze = {}
Maze.__index = Maze

local function insert2d(self, x, y, v)
	if not self[x] then
		self[x] = {
			[y] = v,
		}
	end

	self[x][y] = v
end

local function pairs2d(array)
	return coroutine.wrap(function()
		for i1, dim in pairs(array) do
			for i2, v in pairs(dim) do
				coroutine.yield(i1, i2, v)
			end
		end
	end)
end

function Maze.new()
	local self = {
		Nodes = {},
		Open = {},
		Walls = {},
	}

	setmetatable(self, Maze)

	return self
end

local methods = {}
for _, module in ipairs(script:GetChildren()) do
	methods[module.Name] = require(module)
end

function Maze:Generate(wallParent)
	local method = methods[self.Method]

	assert(method, "method not found")

	wallParent = wallParent or workspace

	local protoWall = Instance.new("Part")
	do
		protoWall.Name = "Wall"
		protoWall.Anchored = true
		protoWall.Size = Vector3.new(1, 10, 1)
	end

	local gridSize = Vector3.new(self.GridSize.X, 1, self.GridSize.Y)

	for x = self.Bounds.Min.X, self.Bounds.Max.X do
		for y = self.Bounds.Min.Y, self.Bounds.Max.Y do
			local horizWall = protoWall:Clone()
			do
				local newPosition = Vector3.new(x, 5, y - 0.5)
				insert2d(self.Walls, newPosition.X, newPosition.Z, horizWall)
				horizWall.Size = Vector3.new(gridSize.X, 10, 1)
				horizWall.Position = newPosition * gridSize
				horizWall.Parent = wallParent
			end
			local vertWall = protoWall:Clone()
			do
				local newPosition = Vector3.new(x - 0.5, 5, y)
				insert2d(self.Walls, newPosition.X, newPosition.Z, vertWall)
				vertWall.Size = Vector3.new(1, 10, gridSize.Z)
				vertWall.Position = newPosition * gridSize
				vertWall.Parent = wallParent
			end

			local newNode = MazeNode.new(Vector2.new(x, y))
			newNode.Neighbors = {}
			newNode.IsOpen = true
			insert2d(self.Nodes, x, y, newNode)
			self.Open[newNode] = true
		end

		local edgeWall = protoWall:Clone()
		do
			local newPosition = Vector3.new(x, 5, self.Bounds.Max.Y + 0.5)
			insert2d(self.Walls, newPosition.X, newPosition.Z, edgeWall)
			edgeWall.Size = Vector3.new(gridSize.X, 10, 1)
			edgeWall.Position = newPosition * gridSize
			edgeWall.Parent = wallParent
		end
	end

	for y = self.Bounds.Min.Y, self.Bounds.Max.Y do
		local edgeWall = protoWall:Clone()
		do
			local newPosition = Vector3.new(self.Bounds.Max.X + 0.5, 5, y)
			insert2d(self.Walls, newPosition.X, newPosition.Z, edgeWall)
			edgeWall.Size = Vector3.new(1, 10, gridSize.Z)
			edgeWall.Position = newPosition * gridSize
			edgeWall.Parent = wallParent
		end
	end

	method(self)
end

function Maze:Associate(space)
	local transform = {}

	for _, _, node in pairs2d(self.Nodes) do
		local newNode = space:Create(node.Position)
		transform[node] = newNode
	end

	for _, _, node in pairs2d(self.Nodes) do
		local newNode = transform[node]
		local neighbors = {}

		for neighbor, distance in pairs(node.Neighbors) do
			local newNeighbor = transform[neighbor]
			neighbors[newNeighbor] = distance
		end

		newNode.Neighbors = neighbors
	end
end

return Maze
