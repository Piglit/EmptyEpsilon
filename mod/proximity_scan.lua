proximity_scan = {
	scan_range = 1000,
	full_scan_range = 200
}

function proximity_scan:updatePlayerShip(delta, p)
    local obj_list = p:getObjectsInRange(self.full_scan_range)
    if obj_list ~= nil and #obj_list > 0 then
        for i, obj in ipairs(obj_list) do
            if obj:isValid() and obj.typeName == "CpuShip" and not obj:isFullyScannedBy(p) then
                obj:setScanStateByFaction(p:getFaction(), "fullscan")
            end
        end
    end

    obj_list = p:getObjectsInRange(self.scan_range)
    if obj_list ~= nil and #obj_list > 0 then
        for i, obj in ipairs(obj_list) do
            if obj:isValid() and obj.typeName == "CpuShip" and not obj:isFullyScannedBy(p) then
                obj:setScanStateByFaction(p:getFaction(), "simplescan")
            end
        end
    end
end

