-- JUMP DRIVE OBJECT ------------------------------------------------------------
--
-- The Jump Drive is no longer a world entity. It is equipment installed in
-- the Mobile Factory equipment grid. Jump Charger is also equipment and acts
-- as the dedicated high-capacity energy buffer for the jump.
--
-- Homebrew energy model:
--   E = 100 MJ * mass(t) * distance(km)
--
-- The Drive Mark controls pulse power and therefore maximum jump duration:
--   Mk.I   = 120 MW, 10 s
--   Mk.II  = 240 MW, 5 s
--   Mk.III = 1.2 GW, 1 s
--
-- A jump is rejected if the required time is greater than the Drive's limit.
-- This is intentional: a weak Drive does not simply sit there teleporting for
-- minutes; it tells the player that the jump is beyond its capabilities.

JD = {
    player = "",
    MF = nil,
    charge = 0,
    maxCharge = 0,
    chargeRate = 0,
    jumpChargerTable = nil,
    locationTable = nil,
    updateTick = 60,
    lastUpdate = 0,
    drive = nil
}

local CHARGER_CAPACITY = 5e9
local CHARGER_INPUT_POWER = 100e6
local ENERGY_PER_TON_KM = 100e6

local DRIVE_STATS = {
    ["JumpDrive-Mk1"] = {mark = 1, power = 120e6, maxTime = 10},
    ["JumpDrive-Mk2"] = {mark = 2, power = 240e6, maxTime = 5},
    ["JumpDrive-Mk3"] = {mark = 3, power = 1.2e9, maxTime = 1}
}

function JD:new(MF)
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = JD

    t.player = MF.player
    t.MF = MF
    t.jumpChargerTable = {}
    t.locationTable = {}

    UpSys.addObj(t)
    return t
end

function JD:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = JD
    setmetatable(object, mt)
    object.jumpChargerTable = object.jumpChargerTable or {}
    object.locationTable = object.locationTable or {}
end

function JD:remove()
end

function JD:valid()
    return self.MF ~= nil
end

-- Find the installed Jump Drive and all Jump Chargers in the factory grid.
-- If several Drive Marks are installed, the highest Mark is used. Chargers are
-- additive because a large factory may sacrifice more grid space for storage.
function JD:scanEquipment()
    self.drive = nil
    self.jumpChargerTable = {}

    if self.MF == nil or self.MF.ent == nil or self.MF.ent.valid == false then
        return
    end

    local grid = self.MF.ent.grid
    if grid == nil then
        return
    end

    for _, equipment in pairs(grid.equipment) do
        local stats = DRIVE_STATS[equipment.name]
        if stats ~= nil then
            if self.drive == nil or stats.mark > self.drive.mark then
                self.drive = {
                    equipment = equipment,
                    mark = stats.mark,
                    power = stats.power,
                    maxTime = stats.maxTime
                }
            end
        elseif equipment.name == "JumpCharger" then
            table.insert(self.jumpChargerTable, equipment)
        end
    end

    self.maxCharge = #self.jumpChargerTable * CHARGER_CAPACITY
    self.chargeRate = #self.jumpChargerTable * CHARGER_INPUT_POWER
    self.charge = 0

    for _, charger in pairs(self.jumpChargerTable) do
        self.charge = self.charge + math.max(charger.energy or 0, 0)
    end
end

function JD:getCharge()
    self:scanEquipment()
    return self.charge
end

-- E = 100 MJ * mass(t) * distance(km)
function JD:getTeleportEnergy(mass, distance)
    local massTons = mass / 1000
    local distanceKm = distance / 1000
    return ENERGY_PER_TON_KM * massTons * distanceKm
end

-- Build a complete jump plan. The hard time limit is checked here: if the
-- pulse would take longer than the Drive Mark permits, the jump is impossible.
function JD:getJumpPlan(location)
    self:scanEquipment()

    local player = getPlayer(self.MF.playerIndex)

    if self.drive == nil then
        player.print({"gui-description.JDNoDrive"})
        return nil
    end

    if #self.jumpChargerTable == 0 then
        player.print({"gui-description.JDNoCharger"})
        return nil
    end

    if self.MF.ent == nil or self.MF.ent.valid == false then
        return nil
    end

    local distance = Util.distance(
        {location.posX, location.posY},
        self.MF.ent.position
    )
    local mass = self.MF.ent.weight or 25000
    local energy = self:getTeleportEnergy(mass, distance)
    local duration = energy / self.drive.power

    if duration > self.drive.maxTime then
        player.print({
            "gui-description.JDTimeLimit",
            self.drive.mark,
            duration,
            self.drive.maxTime
        })
        return nil
    end

    if self.charge < energy then
        player.print({
            "gui-description.JDInsufficientCharge",
            self.charge / 1e9,
            energy / 1e9
        })
        return nil
    end

    return {
        energy = energy,
        distance = distance,
        duration = duration,
        durationTicks = math.max(1, math.ceil(duration * 60)),
        driveMark = self.drive.mark
    }
end

-- Consume energy from the Jump Chargers. Their stored energy is directly
-- accessible because they are battery-equipment objects.
function JD:consumeCharge(amount)
    self:scanEquipment()

    if self.charge < amount then
        return false
    end

    local remaining = amount

    for _, charger in pairs(self.jumpChargerTable) do
        local available = math.max(charger.energy or 0, 0)
        local used = math.min(available, remaining)
        charger.energy = available - used
        remaining = remaining - used

        if remaining <= 0 then
            break
        end
    end

    self:scanEquipment()
    return remaining <= 0
end

function JD:update()
    self.lastUpdate = game.tick
    -- Equipment handles normal charging through the Factorio electric network.
    -- We only refresh our cached totals for the GUI.
    self:scanEquipment()
end

function JD:getTooltipInfos(GUITable, mainFrame, justCreated)
    if justCreated == true then
        GUITable.vars.GUITitle.caption = {"gui-description.JDTitle"}

        local infoFrame = GAPI.addFrame(GUITable, "InformationFrame", mainFrame, "vertical", true)
        infoFrame.style = "MFFrame1"
        infoFrame.style.vertically_stretchable = true
        infoFrame.style.minimal_width = 200
        infoFrame.style.left_margin = 3
        infoFrame.style.left_padding = 3
        infoFrame.style.right_padding = 3
    end

    local infoFrame = GUITable.vars.InformationFrame
    infoFrame.clear()

    GAPI.addSubtitle(GUITable, "", infoFrame, {"gui-description.Information"})
    GAPI.addLabel(GUITable, "ChargeLabel", infoFrame,
        {"gui-description.JDCharge", self.charge / 1e9, self.maxCharge / 1e9},
        _mfOrange, nil, true)

    local ratio = 0
    if self.maxCharge > 0 then
        ratio = self.charge / self.maxCharge
    end

    GAPI.addProgressBar(GUITable, "ChargeBar", infoFrame, "",
        string.format("%.2f / %.2f GJ", self.charge / 1e9, self.maxCharge / 1e9),
        true, _mfOrange, ratio, 100)

    local label = GAPI.addLabel(GUITable, "", infoFrame,
        {"gui-description.JDJCCount", #self.jumpChargerTable}, _mfOrange)
    label.style.top_margin = 10

    GAPI.addLabel(GUITable, "", infoFrame,
        {"gui-description.JDChargeRate", self.chargeRate / 1e6}, _mfOrange)

    if self.drive ~= nil then
        GAPI.addLabel(GUITable, "", infoFrame,
            {"gui-description.JDMark", self.drive.mark, self.drive.maxTime}, _mfOrange)
    end
end

function JD:addLocation(name, filter)
    if name == nil or name == "" then return end

    if self.locationTable[name] ~= nil then
        getPlayer(self.MF.playerIndex).print({"gui-description.NameConflict"})
        return
    end

    if self.MF.ent == nil or self.MF.ent.valid == false then return end

    self.locationTable[name] = {
        surface = self.MF.ent.surface,
        posX = self.MF.ent.position.x,
        posY = self.MF.ent.position.y,
        filter = filter
    }
end

function JD:removeLocation(name)
    if name == nil or name == "" then return end
    self.locationTable[name] = nil
end

-- Compatibility helper used by the old GUI flow. The final validation is done
-- again after MF selects exact non-colliding destination coordinates.
function JD:canTP(location)
    return self:getJumpPlan(location) ~= nil
end

function JD:jump(locationName)
    local location = self.locationTable[locationName]
    if location == nil then return end

    if self.MF.ent == nil or self.MF.ent.valid == false then
        return
    end

    self.MF:TPMobileFactoryPart1(location)
end
