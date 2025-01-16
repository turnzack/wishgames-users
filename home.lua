local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    -- Ajoutez ici les éléments de votre scène
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- La scène est sur le point d'apparaître
    elseif phase == "did" then
        -- La scène est maintenant à l'écran
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
