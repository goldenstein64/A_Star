local function reverse(array)
	local result = {}

	for i = 1, (#array + 1) / 2 do
		local j = #array - i + 1
		result[i], result[j] = array[j], array[i]
	end

	return result
end

local A_Star = {}
A_Star.__index = A_Star

local Node = require(script.Node)

local Space = require(script.Space)

function A_Star.new(start, finish, space)
	space = space or Space.new()

	local self = {
		Space = space,
		Start = start,
		Finish = finish,
	}

	setmetatable(self, A_Star)

	return self
end

function A_Star:GetBestNode()
	local bestNode

	for node in pairs(self.Space.Open) do
		if not bestNode or node.Score < bestNode.Score then
			bestNode = node
		end
	end

	return bestNode
end

function A_Star:GetBestNeighbor(node)
	local bestNode

	for neighbor in pairs(node:GetNeighbors()) do
		if not bestNode or neighbor.PathCost < bestNode.PathCost then
			bestNode = neighbor
		end
	end

	return bestNode
end

function A_Star:Compute()
	local currentNode = self.Space:Get(self.Start)
	currentNode.PathCost = 0
	currentNode.Score = self.Space:Estimate(currentNode, self.Finish)

	assert(currentNode, "starting node not found")

	currentNode:SetOpen(true)

	while currentNode and currentNode.Position ~= self.Finish and next(self.Space.Open) do
		currentNode:SetOpen(false)

		for node, distance in pairs(currentNode:GetNeighbors()) do
			if node.IsOpen ~= nil then
				continue
			end
			node.PathCost = math.min(node.PathCost, currentNode.PathCost + distance)
			node.Score = self.Space:Estimate(node, self.Finish)
			node:SetOpen(true)
		end

		currentNode = self:GetBestNode()
	end

	assert(currentNode and currentNode.Position == self.Finish, "path not found")
end

function A_Star:GetPath()
	local currentNode = self.Space:Get(self.Finish)

	local path = { self.Finish }

	while currentNode.PathCost ~= 0 do
		local bestNode = self:GetBestNeighbor(currentNode)

		table.insert(path, bestNode.Position)

		currentNode = bestNode
	end

	return reverse(path)
end

A_Star.Space = Space
A_Star.Node = Node

return A_Star
