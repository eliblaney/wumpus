
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
caves[3] = cave:new("The Hall of Kings", 3, {3, 7, 4, 5})
caves[4] = cave:new("The Silver Mirror", 4, {12, 0, 8, 3})
caves[5] = cave:new("The Gallimaufry", 5, {8, 3, 9, 11})
caves[6] = cave:new("The Den of Iniquity", 6, {14, 13, 2, 7})
caves[7] = cave:new("The Findledelve", 7, {3, 6, 19})
caves[8] = cave:new("The Page of the Deniers", 8, {3, 5, 1, 4})
caves[9] = cave:new("The Final Tally", 9, {0, 10, 12, 5})
caves[10] = cave:new("Ess Four", 10, {2, 9, 15})
caves[11] = cave:new("The Trillion", 11, {3, 14, 16, 5})
caves[12] = cave:new("The Scrofula", 12, {2, 4, 9})
caves[13] = cave:new("Ephemeron", 13, {6, 16, 8, 14})
caves[14] = cave:new("Shelob's Lair", 14, {3, 6, 13, 11})
caves[15] = cave:new("The Lost Caverns of the Wyrm", 15, {3, 10, 17, 16})
caves[16] = cave:new("The Lost Caverns of the Wyrm", 16, {3, 17, 15, 19})
caves[17] = cave:new("The Lost Caverns of the Wyrm", 17, {3, 16, 17, 18})
caves[18] = cave:new("The Lost Caverns of the Wyrm", 18, {3, 19, 18, 17})
caves[19] = cave:new("The Lost Caverns of the Wyrm", 19, {3, 17, 18, 19})

function cave:getNeighborDownTunnel(tunnelNum) 
    if tunnelNum >= 1 and tunnelNum <= #self.adj then
        return self.adj[tunnelNum]
    end
    return -1
end

function cave:getName() 
    if (self.visited) then
        return self.name
    end
    return "Unknown"
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

function cave:isVisited() 
    return self.visited
end

function cave:markAsVisited() 
    self.visited = true
end

function cave:setContents(contents) 
    self.contents = contents
end
