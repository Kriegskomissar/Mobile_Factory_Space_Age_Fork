-- JUMP MARKER EVENTS ----------------------------------------------------------
-- Markers are native chart tags. Placement is therefore limited to charted
-- terrain by Factorio itself.

local PREFIX = "[MF-JD] "

local function isMarker(tag)
    return tag ~= nil and tag.valid and string.sub(tag.text or "", 1, #PREFIX) == PREFIX
end

local function onChartTagAdded(event)
    local playerIndex = event.player_index
    if playerIndex == nil then return end
    if storage.jumpMarkerMode == nil or storage.jumpMarkerMode[playerIndex] ~= true then return end

    local tag = event.tag
    if tag == nil or not tag.valid then return end

    local name = tag.text
    if name == nil or name == "" then
        name = "Jump Marker " .. tostring(tag.tag_number)
    end

    if not isMarker(tag) then
        tag.text = PREFIX .. name
    end
end

local function onChartTagModified(event)
    local tag = event.tag
    if tag == nil or not tag.valid then return end

    if event.player_index ~= nil and isMarker(tag) then
        local text = tag.text
        if text == PREFIX or text == "" then
            tag.text = PREFIX .. "Jump Marker " .. tostring(tag.tag_number)
        end
    end
end

local function onChartTagRemoved(event)
    -- The native chart-tag registry is the Jump Marker registry.
end

local function onPlayerControllerChanged(event)
    local player = getPlayer(event.player_index)
    if player == nil or not player.valid then return end
    if storage.jumpMarkerMode == nil then return end

    if player.controller_type ~= defines.controllers.remote then
        storage.jumpMarkerMode[player.index] = nil
    end
end

script.on_event(defines.events.on_chart_tag_added, onChartTagAdded)
script.on_event(defines.events.on_chart_tag_modified, onChartTagModified)
script.on_event(defines.events.on_chart_tag_removed, onChartTagRemoved)
script.on_event(defines.events.on_player_controller_changed, onPlayerControllerChanged)
