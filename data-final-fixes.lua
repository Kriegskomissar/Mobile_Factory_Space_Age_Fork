-- Copy Mobile Factory collision mask to Deployment Entity --
local MobileFactory = data.raw.car.MobileFactory
local MFDeploy = data.raw["simple-entity-with-owner"].MFDeploy

if MobileFactory and MFDeploy then
    MFDeploy.collision_mask = table.deepcopy(MobileFactory.collision_mask)
end
