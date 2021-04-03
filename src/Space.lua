local root = script.Parent
local Node = require(root.Node)

local Space = {
	Node = Node,
}
Space.__index = Space

function Space.new()
	local self = {
		Nodes = {},
		Open = {},
		Closed = {},
	}

	setmetatable(self, Space)

	return self
end

function Space:Hash(i)
	return string.format("%dx%d", i.X, i.Y)
end

function Space:Dehash(s)
	return Vector2.new(table.unpack(s:split("x")))
end

function Space:Estimate(node, finish)
	return node.PathCost + (node.Position - finish).Magnitude
end

function Space:Set(i, v)
	local index = self:Hash(i)
	self.Nodes[index] = v
end

function Space:Get(i)
	local index = self:Hash(i)
	return self.Nodes[index]
end

function Space:IsBlocked(node, other)
	return false
end

function Space:Create(i, isOpen)
	local newNode = self.Node.new(self, i)
	newNode.IsOpen = isOpen
	self:Set(i, newNode)

	if isOpen == true then
		self.Open[newNode] = true
	elseif isOpen == false then
		self.Closed[newNode] = true
	end

	return newNode
end

return Space
