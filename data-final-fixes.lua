-- Copy Small Factory collision mask to the deployment helper entity.
local smallFactory = data.raw.car.SmallFactory
local MFDeploy = data.raw["simple-entity-with-owner"].MFDeploy

if smallFactory and MFDeploy then
    MFDeploy.collision_mask = table.deepcopy(smallFactory.collision_mask)
end
