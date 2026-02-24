-- Name: Proximity Scan
-- Description: A demonstration of how to set up player ships to automatically simple scan ships in short range
-- Type: Development
-- Author: Xansta
function init()
    print("started proximity scan")
end
function updatePlayerProximityScan(p)
    local obj_list = p:getObjectsInRange(400)
    if obj_list ~= nil and #obj_list > 0 then
        for i, obj in ipairs(obj_list) do
            if obj:isValid() and obj.typeName == "CpuShip" and not obj:isFullyScannedBy(p) then
                obj:setScanStateByFaction(p:getFaction(), "simplescan")
            end
        end
    end
end
function update()
    for i,p in ipairs(getActivePlayerShips()) do
        updatePlayerProximityScan(p)
    end
end
