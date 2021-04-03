local Node = {}
Node.__index = Node

function Node.new(space, pos)
	local self = {
		Space = space,
		Position = pos,

		IsOpen = nil,
		Neighbors = nil,

		PathCost = math.huge,
		Score = math.huge,
	}

	setmetatable(self, Node)

	return self
end

function Node:GetNeighbors()
	return self.Neighbors
end

function Node:SetOpen(isOpen)
	self.IsOpen = isOpen
	self.Space.Open[self] = isOpen == true and true or nil
	self.Space.Closed[self] = isOpen == false and true or nil
end

return Node
