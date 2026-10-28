-- JUMP MARKER GUI -------------------------------------------------------------
-- The existing Jump Drive button is repurposed as the Jump Map button.

local previousButtonClicked = GUI.buttonClicked

function GUI.buttonClicked(event)
    if event.element ~= nil and event.element.valid and event.element.name == "JumpDriveButton" then
        local player = getPlayer(event.player_index)
        local currentMF = player and getCurrentMF(player.name)

        if currentMF ~= nil and currentMF.jumpDriveObj ~= nil then
            currentMF.jumpDriveObj:openMap()
        end

        return
    end

    return previousButtonClicked(event)
end
