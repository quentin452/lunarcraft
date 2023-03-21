-- to be run on another thread
local CHUNK_SIZE = 8
local CHUNK_HEIGHT = 32

local position, blocks, channel, blockTypes = ...

local getVertex = require "mesh"

local function getBlock(i, j, k)
  return blocks[i][j][k]
end

function getMesh()
  local vertices = {}
  local vi = 1

  local cx, cy, cz = position[1], position[2], position[3]

  function setFace(index, mesh, x, y, z, value)
    for i = 1, 6 do
      local vertexData = getVertex(index, i, mesh, x, y, z, value, position, getBlock)

      if vertexData then
        vertices[vi] = vertexData
        vi = vi + 1
      end
    end
  end

  for k = 1, CHUNK_SIZE do
    for j = 1, CHUNK_HEIGHT do
      for i = 1, CHUNK_SIZE do
        local block = blocks[i][j][k]
        local mesh = blockTypes[block]
        local x, y, z = i + cx, j + cy, k + cz

        setFace(0, mesh, i, j, k, getBlock(i, j, k + 1))
        setFace(1, mesh, i, j, k, getBlock(i, j + 1, k))
        setFace(2, mesh, i, j, k, getBlock(i, j, k - 1))
        setFace(3, mesh, i, j, k, getBlock(i, j - 1, k))
        setFace(4, mesh, i, j, k, getBlock(i + 1, j, k))
        setFace(5, mesh, i, j, k, getBlock(i - 1, j, k))
      end
    end
  end

  love.thread.getChannel(channel):supply(vertices)
end

getMesh()
