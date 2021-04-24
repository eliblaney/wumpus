
cave = {
    name = nil, 
    number = nil,
    adj = {}, 
    contents = "empty",
    visited = false
}

function cave:new(name, num, adj) 
    a = {}
    a.name = name
    a.number = num
    a.adj = adj
    setmetatable(a, self)
    self.__index = self
    return a
end

caves = {}
caves[0] = cave:new("The Fountainhead", 0, {3, 1, 4, 9})
caves[1] = cave:new("The Rumpus Room", 1, {3, 0, 2, 8})
caves[2] = cave:new("Buford's Folly", 2, {2, 1, 6})
caves[3] = cave:new("", 3, {3, 7, 4, 5})
caves[4] = cave:new("", 4, {4, 12, 0, 8, 3})
caves[5] = cave:new("", 5, {4, 8, 3, 9, 11})
caves[6] = cave:new("", 6, {4, 14, 13, 2, 7})
caves[7] = cave:new("", 7, {3, 3, 6, 19})
caves[8] = cave:new("", 8, {3, 5, 1, 4})
caves[9] = cave:new("", 9, {4, 0, 10, 12, 5})
caves[10] = cave:new("", 10, {2, 9, 15})
caves[11] = cave:new("", 11, {3, 14, 16, 5})
caves[12] = cave:new("", 12, {2, 4, 9})
caves[13] = cave:new("", 13, {4, 6, 16, 8, 14})
caves[14] = cave:new("", 14, {3, 6, 13, 11})
caves[15] = cave:new("", 15, {3, 10, 17, 16})
caves[16] = cave:new("", 16, {3, 17, 15, 19})
caves[17] = cave:new("", 17, {3, 16, 17, 18})
caves[18] = cave:new("", 18, {3, 19, 18, 17})
caves[19] = cave:new("", 19, {3, 17, 18, 19})


function cave:getNeighborDownTunnel(tunnelNum) 
    if (tunnelNum >= 0 and tunnelNum < table.getn(self.adj)) then
        return self.adj[tunnelNum]
    end
    return -1
end

function cave:getName() 
    if (self.visited) then
        return self.name
    end
    return "unknown"
end

function cave:getNumber() 
    return self.number
end

function cave:getContents() 
    return self.contents
end

function cave:getNumAdjCaves() 
    return table.getn(self.adj)
end

function cave:markAsVisited() 
    self.visited = true
end

function cave:setContents(contents) 
    self.contents = contents
end


print(caves[0]:getNeighborDownTunnel(1))
-- print(caves[0]:getName())
-- print(caves[0]:getNumber())
-- print(caves[0]:getContents())
-- print(caves[0]:getNumAdjCaves())
-- print(caves[0]:markAsVisited())
-- print(caves[0]:setContents("wumpus"))
-- print(caves[0]:getContents())