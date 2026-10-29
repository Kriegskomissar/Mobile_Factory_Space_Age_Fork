-- Copy Small Factory collision mask to the deployment helper entity.
local smallFactory = data.raw.car.SmallFactory
local MFDeploy = data.raw["simple-entity-with-owner"].MFDeploy

if smallFactory and MFDeploy then
    MFDeploy.collision_mask = table.deepcopy(smallFactory.collision_mask)
end

-- Factorio 2.1 renamed the vanilla stone wall icon asset to wall.png.
-- The interior collision-wall prototypes are invisible, so use the current
-- vanilla wall icon path only to satisfy prototype asset validation.
for _, name in pairs({"mf-interior-wall-horizontal", "mf-interior-wall-vertical"}) do
    local wall = data.raw["simple-entity"][name]
    if wall then
        wall.icon = "__base__/graphics/icons/wall.png"
    end
end
