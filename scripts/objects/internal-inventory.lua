-- Compatibility shell for the old Internal Inventory object.
-- The physical Mobile Factory inventory is now the car trunk inventory of the
-- factory entity itself. This object remains only for legacy runtime data.
INV = INV or {}

function INV:new(name)
    local t = {name = name or "Internal Inventory", inventory = {}}
    local mt = {__index = INV}
    setmetatable(t, mt)
    return t
end

function INV:rebuild(object)
    if object == nil then return end
    setmetatable(object, {__index = INV})
    object.inventory = object.inventory or {}
end

function INV:rescan()
    return false
end

function INV:valid()
    return true
end
