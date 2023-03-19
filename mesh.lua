-- to be run on another thread
local CHUNK_SIZE = 8
local CHUNK_HEIGHT = 32

local position, blocks, channel, blockTypes = ...

function getBlock(i, j, k)
  if j < 1 or j > CHUNK_HEIGHT then return 0 end
  if i < 1 or i > CHUNK_SIZE then return 0 end
  if k < 1 or k > CHUNK_SIZE then return 0 end

  return blocks[i][j][k]
end

function getMesh()
  local vertices = {}
  local start = 1
  local last

  local cx, cy, cz = position[1], position[2], position[3]
  function setFace(index, mesh, x, y, z, value)
    for i = 1, 6 do
      local vertexData = {}

      if value == 0 and mesh then
        local vertex = mesh[index*6+i]
        local vx, vy, vz, u, v, s = unpack(vertex)
        vertexData = {
          vx + x + cx, vy + y + cy, vz + z + cz,
          u, v,
          0, 0, 0,
          s, s, s, 255
        }
      end

      local vi = i + (index)*6 + (x-1)*6*6 + (y-1)*6*6*CHUNK_SIZE + (z-1)*6*6*CHUNK_SIZE*CHUNK_HEIGHT

      vertices[vi - start + 1] = vertexData
      last = vi
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

      love.thread.getChannel(channel):push({vertices, start, #vertices})
      start = last + 1
    end
  end
end

getMesh()