-- JUMP DRIVE OBJECT --

-- Create the Jump Drive base Object --
JD = {
	ent = nil,
	player = "",
	MF = nil,
    charge = 0,
	maxCharge = _mfMaxJumpCharge,
	chargeRate = 0,
	jumpChargerTable = nil,
	locationTable = nil, -- [name]{surface, posX, posY, filter}
    light = 0,
    chargeSprite = nil,
    chargeLight = nil,
	updateTick = 60,
	lastUpdate = 0
}

-- Constructor --
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

-- Reconstructor --
function JD:rebuild(object)
	if object == nil then return end
	local mt = {}
	mt.__index = JD
	setmetatable(object, mt)
end

-- Destructor --
function JD:remove()
end

-- Is valid --
function JD:valid()
	return true
end

-- Обновление Jump Drive
function JD:update()

    -- Запоминаем последний тик обновления.
    self.lastUpdate = game.tick

    -- Проверяем, существует ли физическая сущность Jump Drive.
    if self.ent == nil or self.ent.valid == false then
        return
    end

    -- ============================================================
    -- ВРЕМЕННАЯ ЗАГЛУШКА СИСТЕМЫ ЗАРЯДА
    -- ============================================================
    --
    -- Раньше Jump Drive заряжался от Internal Energy.
    -- Мы пока отключаем эту зависимость.
    --
    -- TODO:
    -- Здесь позже подключить новую систему питания Jump Drive.
    -- Она должна изменять self.charge и self.maxCharge.
    --
    -- Пока Jump Drive считается полностью заряженным.

    self.maxCharge = _mfMaxJumpCharge
    self.charge = self.maxCharge
    self.chargeRate = 0


    -- ============================================================
    -- ИНДИКАТОР ЗАРЯДА
    -- ============================================================
    --
    -- Сам визуальный индикатор оставляем.
    -- Он теперь просто показывает, что Jump Drive полностью заряжен.

    self.ent.energy = math.min(
        self.ent.prototype.electric_energy_source_prototype.buffer_capacity,
        self.charge / self.maxCharge * 100
    )

    local spriteNumber = math.ceil(
        self.ent.energy /
        self.ent.prototype.electric_energy_source_prototype.buffer_capacity * 16
    )

    if self.chargeSprite then
        self.chargeSprite.destroy()
    end

    if self.chargeLight then
        self.chargeLight.destroy()
    end

    if spriteNumber ~= 0 then
        if self.sprite then
            self.sprite.destroy()
        end

        self.sprite = rendering.draw_sprite{
            sprite = "CubeChargeSprite" .. spriteNumber,
            x_scale = 1 / 2.25,
            y_scale = 1 / 2.25,
            target = self.ent,
            surface = self.ent.surface,
            render_layer = 130
        }
    end


    -- ============================================================
    -- JUMP CHARGER
    -- ============================================================
    --
    -- Старую систему Jump Charger пока отключаем.
    --
    -- TODO:
    -- Если Jump Charger будет возвращён в новой версии,
    -- здесь снова учитывать установленные зарядные устройства.
    --
    -- Пока они не влияют ни на заряд, ни на скорость зарядки.

end
 
-- Tooltip Infos --
function JD:getTooltipInfos(GUITable, mainFrame, justCreated)

	if justCreated == true then

		-- Set the GUI Title --
		GUITable.vars.GUITitle.caption = {"gui-description.JDTitle"}

		-- Create the Information Frame --
		local infoFrame = GAPI.addFrame(GUITable, "InformationFrame", mainFrame, "vertical", true)
		infoFrame.style = "MFFrame1"
		infoFrame.style.vertically_stretchable = true
		infoFrame.style.minimal_width = 200
		infoFrame.style.left_margin = 3
		infoFrame.style.left_padding = 3
		infoFrame.style.right_padding = 3

	end

	-- Get the Frame --
	local infoFrame = GUITable.vars.InformationFrame

	-- Clear the Frame --
	infoFrame.clear()

	-- Create the Tite --
	GAPI.addSubtitle(GUITable, "", infoFrame, {"gui-description.Information"})

	-- Add the Jump Charge --
	GAPI.addLabel(GUITable, "ChargeLabel", infoFrame, {"gui-description.JDCharge", self.charge, self.maxCharge}, _mfOrange, nil, true)
	GAPI.addProgressBar(GUITable, "ChargeBar", infoFrame, "", self.charge .. "/" .. self.maxCharge, true, _mfOrange, self.charge/self.maxCharge, 100)

	-- Add the Jump Charger count --
	local label = GAPI.addLabel(GUITable, "", infoFrame, {"gui-description.JDJCCount", table_size(self.jumpChargerTable)}, _mfOrange)
	label.style.top_margin = 10

	-- Add the Charge Rate --
	GAPI.addLabel(GUITable, "", infoFrame, {"gui-description.JDChargeRate", self.chargeRate}, _mfOrange)

end

-- Add a Location --
function JD:addLocation(name, filter)
	-- Check the Name --
	if name == nil or name == "" then return end
	-- Check if the Name doesn't exist --
	if self.locationTable[name] ~= nil then
		getPlayer(self.MF.playerIndex).print({"gui-description.NameConflict"})
		return
	end
	-- Check the Mobile Factory --
	if self.MF.ent == nil or self.MF.ent.valid == false then return end
	-- Add the Location --
	self.locationTable[name] = {surface=self.MF.ent.surface, posX=self.MF.ent.position.x, posY=self.MF.ent.position.y, filter=filter}
end

-- Remove a Location --
function JD:removeLocation(name)
	-- Check the Name --
	if name == nil or name == "" then return end
	-- Remove the Location --
	self.locationTable[name] = nil
end

-- Проверяет, может ли Jump Drive выполнить прыжок.
function JD:canTP(location)

    -- ============================================================
    -- ПРОВЕРКА ДАЛЬНОСТИ
    -- ============================================================
    --
    -- Раньше расстояние сравнивалось с текущим зарядом.
    -- Заряд пока является заглушкой и всегда максимальный.
    --
    -- TODO:
    -- Вернуть полноценный расчёт стоимости прыжка.
    -- Например:
    -- стоимость = расстояние * коэффициент
    --
    -- Пока любой прыжок разрешён.

    -- ============================================================
    -- ПЕРЕХОД МЕЖДУ SURFACE
    -- ============================================================
    --
    -- Раньше для перехода между поверхностями требовалось
    -- 1000 единиц Internal Quatron.
    --
    -- TODO:
    -- Позже сюда добавить новое правило для межповерхностных
    -- прыжков, если оно вообще понадобится.
    --
    -- Пока Quatron для Jump Drive НЕ используется.

    return true
end

-- Start the Jump --
function JD:jump(locationName)
	-- Get the Location --
	local location = self.locationTable[locationName]
	if location == nil then return end
	-- Check everything --
	if self.MF.ent == nil or self.MF.ent.valid == false or location == nil or self:canTP(location) == false then return end
	-- Teleport --
	self.MF:TPMobileFactoryPart1(location)
end
