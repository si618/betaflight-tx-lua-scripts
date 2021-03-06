local apiVersionReceived = false
local vtxTablesReceived = false
local mcuIdReceived = false
local getApiVersion, getVtxTables, getMCUId
local returnTable = { f = nil, t = "" }

local function modelActive()
    return getValue(protocol.stateSensor) > 0
end

local function init()
    if not modelActive() then
        returnTable.t = "Waiting for connection"
    elseif not apiVersionReceived then
        getApiVersion = getApiVersion or assert(loadScript("api_version.lua"))()
        returnTable.t = getApiVersion.t
        apiVersionReceived = getApiVersion.f()
        if apiVersionReceived then
            getApiVersion = nil
            collectgarbage()
        end
    elseif not mcuIdReceived and apiVersion >= 1.042 then
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        returnTable.t = getMCUId.t
        mcuIdReceived = getMCUId.f()
        if mcuIdReceived then
            getMCUId = nil
            local vtxTables = loadScript("/BF/VTX/"..mcuId..".lua")
            if vtxTables and vtxTables() then
                vtxTablesReceived = true
                vtxTables = nil
            end
            collectgarbage()
        end
    elseif not vtxTablesReceived and apiVersion >= 1.042 then
        getVtxTables = getVtxTables or assert(loadScript("vtx_tables.lua"))()
        returnTable.t = getVtxTables.t
        vtxTablesReceived = getVtxTables.f()
        if vtxTablesReceived then
            getVtxTables = nil
            collectgarbage()
        end
    else
        return true
    end
    return apiVersionReceived and vtxTablesReceived and mcuId
end

returnTable.f = init

return returnTable
