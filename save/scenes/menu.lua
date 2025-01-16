local composer = require("composer")
local scene = composer.newScene()

-- Fonction pour créer la scène
function scene:create(event)
    local sceneGroup = self.view
    
    -- Créer un fond d'écran
    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
    background:setFillColor(0.2, 0.4, 0.6)
    
    -- Ajouter un titre
    local title = display.newText(sceneGroup, "New Wish", display.contentCenterX, 100, native.systemFontBold, 40)
    title:setFillColor(1, 1, 1)
    
    -- Créer un bouton de démarrage
    local startButton = display.newRoundedRect(sceneGroup, display.contentCenterX, display.contentCenterY, 200, 60, 10)
    startButton:setFillColor(0.1, 0.7, 0.3)
    
    local startText = display.newText(sceneGroup, "Commencer", display.contentCenterX, display.contentCenterY, native.systemFont, 24)
    startText:setFillColor(1, 1, 1)
    
    -- Gestionnaire d'événements pour le bouton
    function startButton:tap()
        -- Rediriger vers la scène de connexion
        composer.gotoScene("scenes.login", { effect = "fade", time = 400 })
    end
    startButton:addEventListener("tap", startButton)
end

-- Fonctions standard de scène
function scene:show(event) end
function scene:hide(event) end
function scene:destroy(event) end

-- Écouteurs d'événements de scène
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
