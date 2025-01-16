-- intro.lua - Page d'introduction après connexion

local composer = require("composer")
local widget = require("widget")
local scene = composer.newScene()

-- Création de la scène
function scene:create(event)
    local sceneGroup = self.view
    
    -- Background
    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
    background:setFillColor(0.1, 0.1, 0.1)
    
    -- Titre
    local title = display.newText({
        parent = sceneGroup,
        text = "Bienvenue sur New Wish",
        x = display.contentCenterX,
        y = 100,
        font = native.systemFontBold,
        fontSize = 40,
        align = "center"
    })
    title:setFillColor(1, 1, 1)
    
    -- Message
    local message = display.newText({
        parent = sceneGroup,
        text = "Votre application de gestion de souhaits",
        x = display.contentCenterX,
        y = 160,
        font = native.systemFont,
        fontSize = 24,
        align = "center"
    })
    message:setFillColor(0.8, 0.8, 0.8)
    
    -- Bouton continuer
    local continueButton = widget.newButton({
        label = "Continuer",
        x = display.contentCenterX,
        y = display.contentHeight - 100,
        width = 200,
        onRelease = function()
            composer.gotoScene("scenes.menu")
        end
    })
    sceneGroup:insert(continueButton)
end

-- Fonctions standard de scène
function scene:show(event) end
function scene:hide(event) end
function scene:destroy(event) end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
