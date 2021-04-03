local SerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local rootTest = script.Parent
local Maze = require(rootTest.Maze)
local Dummy = rootTest.Dummy

local A_Star = require(SerStorage.A_Star)

local maze = Maze.new()

local GRID_SIZE = Vector2.new(10, 10)

local function toVector3(v2, y)
	local mid = GRID_SIZE * v2
	return Vector3.new(mid.X, y or 3, mid.Y)
end

maze.Method = "2D_HuntAndKill"
maze.GridSize = GRID_SIZE
maze.Bounds = Rect.new(0, 0, 10, 10)

maze:Generate(Workspace.Walls)

local space = A_Star.Space.new()

maze:Associate(space)

local START = Vector2.new(0, 0)
local FINISH = Vector2.new(10, 10)
local pathfinder = A_Star.new(START, FINISH, space)

pathfinder:Compute()

local path = pathfinder:GetPath()

local dummy = Dummy:Clone()
dummy.Parent = Workspace.A_StarTest

dummy:MoveTo(toVector3(START))

local noid = dummy:FindFirstChildWhichIsA("Humanoid")

for _, pos in ipairs(path) do
	noid:MoveTo(toVector3(pos))
	noid.MoveToFinished:Wait()
end
