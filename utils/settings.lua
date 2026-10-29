local function merge(list)
	local ret = {}
	for _, array in pairs(list) do
		for _, value in pairs(array) do
			table.insert(ret, value)
		end
	end
	return ret
end

-- Update System --
_mfBaseUpdatePerTick = 100
_mfScanTicks = 100

-- Mobile Factory Surfaces name --
_mfSurfaceName = "mfSurface"
_mfControlSurfaceName = "ControlRoom"

-- Legacy energy values kept only for saved-data compatibility.
_mfInternalEnergy = 1500000000
_mfInternalEnergyMax = 3000000000

-- Legacy shield values kept only for saved-data compatibility.
_mfShieldChargeRate = 10
_mfShieldComsuption = 25000

-- Legacy laser settings kept only for saved-data compatibility.
_mfBaseLaserRadius = 10
_mfBaseLaserNumber = 1
_mfQuatronDrain = 1000
_mfEnergyDrain = 10000000
_mfFluidDrain = 10000
_mfFluidConsomption = 10
_mfItemsDrain = 100
_mfBaseItemEnergyConsumption = 1000

-- Jump Drive settings.
_mfMaxJumpCharge = 500
_chargeAddedPerJumpCharger = 150
_chargeRateAddedPerJumpCharger = 1
_mfJumpEnergyDrain = 300000

-- Legacy fuel settings.
_mfMaxFuelValue = 4000000
_mfFuelMultiplicator = 1

-- Legacy internal distribution values.
_mfBaseEnergyAccSend = 1000000
_pdpEnergyRadius = 10
_pdpEnergyDrain = 1000000
_pdpEnergyLaser = 1
_dtMaxFluid = 10000000

-- Legacy extraction settings.
_mfRCLUpdateTick = 20
_mfRCLMaxCharge = 1000
_mfRCLRadius = 50
_mfRCLTankSize = 10000
_mfOreCleanerResourcesPerExtraction = 19
_mfOreCleanerExtractionTicks = 20
_mfOreCleanerMaxDistance = 100
_mfFEFluidPerExtraction = 15
_mfFEMaxCharge = 1000
_mfFluidExtractorMaxDistance = 100

-- The old technology callback table referenced the deleted Control Center,
-- Deep Storage, Deep Tank and Constructible Area systems. Current technology
-- effects are handled by their prototypes and by the Jump Drive runtime.
_MFResearches = {}

-- Legacy entity/tag tables. They are harmless when the corresponding object
-- is absent and preserve compatibility with existing saved runtime data.
_mfEnergyLaserTargets = {
	"EnergyCubeMK1",
	"EnergyCubeMK2",
	"EnergyCubeMK3"
}

_mfQuatronLaserTargets = {
	"QuatronCubeMK1",
	"QuatronCubeMK2",
	"QuatronCubeMK3",
	"NetworkAccessPoint",
	"ResourcesCollector"
}

_mfTagsTable = {}
_mfTagsTable["ResourcesCollector"] = "RCL"

-- GUI settings retained for the current main GUI identity.
_GUIButtonsSize = 15
_mfGUIDragAreaSize = 25
_mfGUICloseButtonSize = 20
_mfDefaultGuiHeight = 10
_mfDefaultGuiWidth = 10
_mfMainGUIPosX = 300
_mfMainGUIPosY = 0
_mfInfoGUIButtonsSize = 25

_mfGUIName = {
	MainGUI = "MFMainGUI",
	InfoGUI = "MFInfoGUI",
	OptionGUI = "MFOptionGUI",
	TooltipGUI = "MFTooltipGUI",
	SwitchMF = "MFSwitchMFGUI",
	TPGUI = "MFTPGUI",
	DeployGUI = "MFDeployGUI",
	SlotGUI = "MFSlotGUI",
	RecipeGUI = "MFRecipeGUI",
	RecipeInfoGUI = "MFRecipeInfoGUI",
	CameraGUI = "MFCameraGUI"
}

_mfShortcutGUI = {}

_eventTick5 = 5
_eventTick7 = 7
_eventTick15 = 15
_eventTick27 = 27
_eventTick49 = 49
_eventTick55 = 55
_eventTick60 = 60
_eventTick80 = 80
_eventTick90 = 90
_eventTick125 = 125
_eventTick150 = 150
_eventTick1200 = 1200

_mfWhite = {255,255,255}
_mfBlue = {108, 114, 229}
_mfGreen = {92, 232, 54}
_mfPurple = {155, 0, 168}
_mfRed = {231, 5, 5}
_mfOrange = {255, 131, 0}
_mfYellow = {244, 208, 63}

_mfLabelType = {
	yellowTitle = "MF_Yellow_Label",
}

-- The starter item was renamed from the old MobileFactory prototype.
_MFStartingRecipes = {"SmallFactory"}

_MFVehicleFuelPrototype = nil
_MFVehicleFuelsByName = {
	["coal"] = true,
	["wood"] = true,
}
