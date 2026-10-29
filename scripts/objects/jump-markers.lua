-- JUMP MARKERS ---------------------------------------------------------------
-- Jump Markers use Factorio's native chart-tag system. This gives them
-- map-level persistence and registry semantics without creating an entity.

local MARKER_PREFIX = "[MF-JD] "

storage.jumpMarkerMode = storage.jumpMarkerMode or {}

local function isJumpMarker(tag)
    return tag ~= nil and tag.valid and string.sub(tag.text or "", 1, #MARKER_PREFIX) == MARKER_PREFIX
end

local function markerName(tag)
    return string.sub(tag.text, #MARKER_PREFIX + 1)
end

local function getMarkers(force)
    local result = {}
    if force == nil then return result end

    for _, tag in pairs(force.find_chart_tags()) do
        if isJumpMarker(tag) then
            result[tag.tag_number] = tag
        end
    end

    return result
end

function JD:getMarkers()
    return getMarkers(getForce(self.MF))
end

function JD:findMarker(name)
    if name == nil or name == "" then return nil end

    for _, tag in pairs(self:getMarkers()) do
        if markerName(tag) == name then
            return tag
        end
    end

    return nil
end

function JD:addLocation(name, filter)
    -- Marker placement is deliberately map-only. The terminal button opens
    -- remote map mode; the player creates and names the native chart tag there.
    if name == nil or name == "" then return end

    local player = getPlayer(self.MF.playerIndex)
    if player == nil or not player.valid then return end

    if self:findMarker(name) ~= nil then
        player.print({"gui-description.NameConflict"})
        return
    end

    player.print({"gui-description.JDMarkerMapOnly"})
    self:openMap()
end

function JD:removeLocation(name)
    local tag = self:findMarker(name)
    if tag ~= nil then
        tag.destroy()
    end
end

function JD:jump(locationName)
    local tag = self:findMarker(locationName)
    if tag == nil then return end

    local location = {
        surface = tag.surface,
        posX = tag.position.x,
        posY = tag.position.y
    }

    if self.MF.ent == nil or not self.MF.ent.valid then return end
    self.MF:TPMobileFactoryPart1(location)
end

function JD:openMap()
    local player = getPlayer(self.MF.playerIndex)
    if player == nil or not player.valid then return end
    if self.MF.ent == nil or not self.MF.ent.valid then return end

    storage.jumpMarkerMode[player.index] = true

    player.set_controller {
        type = defines.controllers.remote,
        position = self.MF.ent.position,
        surface = self.MF.ent.surface
    }

    player.zoom = 0.5
end

function JD:canTP(location)
    return self:getJumpPlan(location) ~= nil
end

function JD:isLocationCharted(surface, position)
    if surface == nil or position == nil then return false end

    local chunkPosition = {
        x = math.floor(position.x / 32),
        y = math.floor(position.y / 32)
    }

    return getForce(self.MF):is_chunk_charted(surface, chunkPosition)
end

_G.MFJumpMarker = {
    PREFIX = MARKER_PREFIX,
    isJumpMarker = isJumpMarker,
    markerName = markerName
}
