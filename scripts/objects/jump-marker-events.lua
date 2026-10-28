-- JUMP MARKER EVENTS ----------------------------------------------------------
-- Markers are native chart tags. Placement is therefore limited to charted
-- terrain by Factorio itself.

local PREFIX = "[MF-JD] "

storage.jumpMarkerMode = storage.jumpMarkerMode or {}
storage.jumpMarkerTags = storage.jumpMarkerTags or {}

local function tagKey(tag)
    return tostring(tag.force.index) .. ":" .. tostring(tag.tag_number)
end

local function isMarker(tag)
    if tag == nil or not tag.valid then return false end
    return storage.jumpMarkerTags[tagKey(tag)] == true
        or string.sub(tag.text or "", 1, #PREFIX) == PREFIX
end

local function onChartTagAdded(event)
    local playerIndex = event.player_index
    if playerIndex == nil then return end
    if storage.jumpMarkerMode[playerIndex] ~= true then return end

    local tag = event.tag
    if tag == nil or not tag.valid then return end

    local name = tag.text
    if name == nil or name == "" then
        name = "Jump Marker " .. tostring(tag.tag_number)
    end

    storage.jumpMarkerTags[tagKey(tag)] = true

    if string.sub(name, 1, #PREFIX) ~= PREFIX then
        tag.text = PREFIX .. name
    end
end

local function onChartTagModified(event)
    local tag = event.tag
    if tag == nil or not tag.valid then return end

    local key = tagKey(tag)
    if not isMarker(tag) then return end
    storage.jumpMarkerTags[key] = true

    local text = tag.text or ""
    if string.sub(text, 1, #PREFIX) ~= PREFIX then
        if text == "" then
            text = "Jump Marker " .. tostring(tag.tag_number)
        end
        tag.text = PREFIX .. text
    elseif text == PREFIX then
        tag.text = PREFIX .. "Jump Marker " .. tostring(tag.tag_number)
    end
end

local function onChartTagRemoved(event)
    local tag = event.tag
    if tag == nil then return end
    storage.jumpMarkerTags[tagKey(tag)] = nil
end

local function onPlayerControllerChanged(event)
    local player = getPlayer(event.player_index)
    if player == nil or not player.valid then return end

    if player.controller_type ~= defines.controllers.remote then
        storage.jumpMarkerMode[player.index] = nil
    end
end

script.on_event(defines.events.on_chart_tag_added, onChartTagAdded)
script.on_event(defines.events.on_chart_tag_modified, onChartTagModified)
script.on_event(defines.events.on_chart_tag_removed, onChartTagRemoved)
script.on_event(defines.events.on_player_controller_changed, onPlayerControllerChanged)
